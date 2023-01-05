import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/message_box.dart';
import 'package:plots/frontend/components/send_message_button.dart';
import 'package:plots/frontend/pages/home/home.dart';

// Page with messages for each party groupchat

class HostAndGuestDM extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final GuestInfoObject guestInfoObject;
  final String plotFlyer;
  final String receivingAuthID;
  final String receivingNotificationToken;

  final bool isHost;

  const HostAndGuestDM({Key key, this.sharedPrefData, this.guestInfoObject, this.receivingAuthID, this.receivingNotificationToken, this.plotFlyer, this.isHost}) : super(key: key);

  @override
  _HostAndGuestDMState createState() => _HostAndGuestDMState();
}

class _HostAndGuestDMState extends State<HostAndGuestDM> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreFunctions firestorefunctions = FirestoreFunctions();
  final snackBar = SnackBar(content: Text('code copied to clipboard'));



  Future<void> sendNewMessageFromHost(String token) async {
    try{
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNewMessageFromHost');
      await callable.call(token);
    } catch(e){
      print(e.toString());
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.length > 0) {
      await firestorefunctions.incrementUnreadMessages(widget.receivingAuthID);
      // Send notifcation
      if(widget.isHost){
        try{
        sendNewMessageFromHost(widget.receivingNotificationToken);
        } catch (e){
          print(e.toString());
        }
      }

      await _firestore.collection('plots').doc(widget.sharedPrefData.plotCode).collection(widget.guestInfoObject.authID).add({
        'text': messageController.text,
        'from': widget.sharedPrefData.username,
        'date': DateTime.now().toIso8601String().toString(),
      });

      messageController.clear();
      // scrollController.animateTo(
      //   scrollController.position.maxScrollExtent,
      //   curve: Curves.easeOut,
      //   duration: const Duration(milliseconds: 300),
      // );
    }
  }

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_outlined), onPressed: ()async{
          try{
          int unreadMessages = await firestorefunctions.getUnreadMessagesFromAuthID(widget.sharedPrefData.authID);
          if (unreadMessages != 0){
            await firestorefunctions.resetUnreadMessages(widget.sharedPrefData.authID);
          }}
          catch (e){
            print(e.toString());
          }
          if(widget.isHost){
            await firestorefunctions.updateMessageInfo(plotCode: widget.sharedPrefData.plotCode, authID: widget.guestInfoObject.authID, newValue: 0, field: 'numUnread');
            Navigator.pop(context);
          } else {
            Navigator.pushAndRemoveUntil(context, PageTransition(
              type: PageTransitionType.leftToRight,
              child: Home(
                initialTabIndex: 0,
                sharedPrefData: widget.sharedPrefData,
              ),
            ), (route) => false);
          }
        },),
        elevation: 0,
        title: Text(widget.isHost ? widget.guestInfoObject.username: 'Host', style: TextStyle(
          fontSize: 25,
          color: Colors.white
        ),),
        actions: [
          SafeArea(
            child: GestureDetector(
                onTap: (){
                  showDialog(context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(10),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child:
                              InteractiveViewer(
                                panEnabled: false, // Set it to false
                                boundaryMargin: EdgeInsets.all(100),
                                minScale: 0.5,
                                maxScale: 2,
                                child:  CachedNetworkImage(
                                  imageUrl: widget.isHost ? widget.guestInfoObject.profilePicURL : widget.plotFlyer ,
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25)
                                      ),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Container(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                        strokeWidth: 4.0
                                    ),
                                    height: 80.0,
                                    width: 80.0,
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            )
                        );
                      }
                  );
                },
                child:Container(
                    constraints: BoxConstraints(
                        maxHeight: 80,
                        minWidth: 80,
                        maxWidth: 80,
                        minHeight: 80
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.isHost ? widget.guestInfoObject.profilePicURL : widget.plotFlyer,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle
                        ),
                        constraints: BoxConstraints(
                            maxHeight: 80,
                            minWidth: 80,
                            maxWidth: 80,
                            minHeight: 80
                        ),
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                )),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10,),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('plots').doc(widget.sharedPrefData.plotCode).collection(widget.guestInfoObject.authID).orderBy('date', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData){
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                          strokeWidth: 4.0
                      ),
                    );
                  }
                  List<DocumentSnapshot> docs = snapshot.data.docs;
                  if (docs.length == 0) {
                    return Column(
                      children: [
                        Text("no messages yet.", style: TextStyle(color: Colors.white,fontSize: 20),),
                        Text("say hi!", style: TextStyle(color: Colors.grey,fontSize: 16, fontStyle: FontStyle.italic),),
                      ],
                    );
                  }
                  List<Widget> messages = docs
                      .map((doc) => MessageBox(
                    date: doc['from'],
                    text: doc['text'],
                    me: widget.sharedPrefData.username == doc['from'],
                  ))
                      .toList();
                  return ListView(
                    reverse: true,
                    controller: scrollController,
                    children: <Widget>[
                      ...messages
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 16,
                right: 16,),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      onSubmitted: (value) => sendMessage(),
                      controller: messageController,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: 'send a message',
                          hintText: 'wazzzaaaa',
                          hintStyle: TextStyle(
                              color: Colors.grey
                          ),
                          errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          enabledBorder: OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.transparent),
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                          focusedBorder: OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.transparent),
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                          border: OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.transparent),
                              borderRadius:
                              BorderRadius.all(Radius.circular(5)))),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xffB53D3D),
                                Color(0xff630094)
                              ]
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      child: SendMessageButton(
                        icon: Icon(Icons.send, color: Colors.white,),
                        callback: ()async{
                      await firestorefunctions.newMessageForHost(
                          authID: widget.guestInfoObject.authID,
                          profilePicURL: widget.guestInfoObject.profilePicURL,
                          username: widget.guestInfoObject.username,
                          FCMtoken: widget.guestInfoObject.FCMtoken,
                          plotCode: widget.sharedPrefData.plotCode,
                          lastMessage: messageController.text).then((value){
                      sendMessage();
                      });

                        },
                      )
                  )
                ],
              ),
            ),
            SizedBox(height: 50,),
          ],
        ),
      ),
    );
  }
}
