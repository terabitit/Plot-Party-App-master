import 'package:cached_network_image/cached_network_image.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/home/message_board/host_and_guest_dm.dart';


class AllMessagesforHost extends StatefulWidget {
  // Page that can only be accessed by host where you can deny or accept requests given price and guests
  final List unreadMessages;
  final SharedPrefData sharedPrefData;

  const AllMessagesforHost({Key key, this.unreadMessages, this.sharedPrefData,}) : super(key: key);
  @override
  _AllMessagesforHostState createState() => _AllMessagesforHostState();
}

class _AllMessagesforHostState extends State<AllMessagesforHost> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> sendNotification(String token) async {
    try{
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendApprovalUpdateNotification');
      await callable.call(token);

    } catch(e){
      print(e.toString());
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: ()async{
            Navigator.pushAndRemoveUntil(context, PageTransition(
              type: PageTransitionType.leftToRight,
              child: Home(
                initialTabIndex: 0,
                sharedPrefData: widget.sharedPrefData,
              ),
            ), (route) => false);
          },
        ),
        title: Text('messages'),
      ),
      body: Column(
        children: [
          widget.unreadMessages.length == null || widget.unreadMessages.length == 0 ?
          Container(
            alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              child: Text('you have no messages.')
          ) :
          Expanded(child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.unreadMessages.length,
              itemBuilder: (BuildContext context, int index) {
                final item = widget.unreadMessages[index]['authID'];
                return  RawMaterialButton(
                  onPressed: ()async{
                    FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                    String flyerURL = await firestoreFunctions.getFlyerURLFromPlotCode(widget.sharedPrefData.plotCode);
                    GuestInfoObject guestInfoObject = await firestoreFunctions.makeGuestObjectFromAuthID(widget.sharedPrefData.plotCode, widget.unreadMessages[index]['authID']);
                    if (guestInfoObject == null){
                      guestInfoObject = await firestoreFunctions.makeAttendRequestObjectFromAuthID(widget.sharedPrefData.plotCode, widget.unreadMessages[index]['authID']);
                    }
                    if(guestInfoObject == null){
                      showDialog(context: context,
                          barrierDismissible: true, builder: (BuildContext context){
                        return AlertDialog(
                          backgroundColor: Color(0xff1e1e1e),
                          title: Text("this user has left the plot", style: TextStyle(
                            color: Colors.white
                          ),),
                        );
                      });
                    } else {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context) => HostAndGuestDM(
                          sharedPrefData: widget.sharedPrefData,
                          receivingAuthID: widget.unreadMessages[index]['authID'],
                          receivingNotificationToken: widget.unreadMessages[index]['FCMtoken'],
                          isHost: true,
                          plotFlyer: flyerURL == '' ? 'https://firebasestorage.googleapis.com/v0/b/plots-6e93e.appspot.com/o/no_plot_image.jpg?alt=media&token=44aaa97a-0c79-42d5-b4b3-61966d051224' : flyerURL,
                          guestInfoObject: guestInfoObject,
                        )
                    ));}
                  },
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      Stack(
                        children: [
                          CircleAvatar(
                              radius: 45,
                              child: CachedNetworkImage(
                                imageUrl:  widget.unreadMessages[index]['profilePicURL'],
                                imageBuilder: (context, imageProvider) => Container(
                                  width: 90.0,
                                  height: 90.0,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider, fit: BoxFit.cover),
                                  ),
                                ),
                                placeholder: (context, url) => CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                    strokeWidth: 4.0
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              )
                          ),
                          widget.unreadMessages[index]['numUnread'] > 0 ? Positioned(
                            right: 0,
                            child: new Container(
                              padding: EdgeInsets.all(1),
                              decoration: new BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: new Text(
                                '${widget.unreadMessages[index]['numUnread'].toString()}',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ): Container(),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            child: Text(
                              widget.unreadMessages[index]['username'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,),
                            ),
                          ),
                          Container(
                            width: 125,
                            child: Text(
                              widget.unreadMessages[index]['lastMessage'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,),
                            ),
                          ),
                        ],),
                    ],
                  ),
                );
              })
          )
        ],
      ),
    );
  }
}
