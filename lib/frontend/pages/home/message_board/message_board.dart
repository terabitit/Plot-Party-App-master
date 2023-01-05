import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/components/fs_sp_data_widget.dart';
import 'package:plots/frontend/components/message_box.dart';
import 'package:plots/frontend/components/send_message_button.dart';
import 'package:plots/frontend/pages/home/message_board/announcements.dart';
import 'package:flutter/services.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

// Page with messages for each party groupchat

class MessageBoard extends StatefulWidget {
  final String name;
  final String plotCode;

  const MessageBoard({Key key, this.name, this.plotCode}) : super(key: key);

  @override
  _MessageBoardState createState() => _MessageBoardState();
}

class _MessageBoardState extends State<MessageBoard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreFunctions firestorefunctions = FirestoreFunctions();
  final snackBar = SnackBar(content: Text('code copied to clipboard'));
  Future<String> plotPrivacy;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    plotPrivacy = getPlotPrivacy();
  }


  Future<void> sendMessage() async {
    if (messageController.text.length > 0) {
      await _firestore.collection('plots').doc(widget.plotCode).collection('convo').add({
        'text': messageController.text,
        'from': widget.name,
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

  Future<String> getPlotPrivacy() async {
    String plotPrivacy = await firestorefunctions.getPlotPrivacyFromPlotCode(widget.plotCode);
    return plotPrivacy;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 10,),
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xffB53D3D),
                      Color(0xff630094)
                    ]
                )
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: Colors.transparent,),
              onPressed: ()async{
                List announcements = await firestorefunctions.getAnnouncementsFromPlotCode(widget.plotCode);
                Navigator.push(context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Announcements(
                      announcements: announcements,
                  )
               ));
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisSize:MainAxisSize.max,
                  children: [
                  Icon(Icons.announcement),
                  SizedBox(width: 20,),
                  Text("view announcements", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),),
                ],)
              ),
          ),
          ),
        Padding(
          padding:  EdgeInsets.only(left:16, bottom: 10),
          child: FutureBuilder(
              future: plotPrivacy,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done){
                  return snapshot.data == "open invite" ? Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(16))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: 8.0),
                              child: Text("invite code: ", style: TextStyle(fontSize: 16),),
                            ),
                            Text(widget.plotCode, style: TextStyle(
                              fontSize: 20,
                              color: Colors.white
                            )),
                            IconButton(
                                icon: Icon(Icons.copy, color: Colors.white,),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: widget.plotCode))
                                      .then((value) { //only if ->
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  },
                                  );
                                }
                            )
                          ],
                        ),
                      ),
                      Expanded(child: Container(),),
                    ],
                  ) : Container();
                } else {
                  return SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                        strokeWidth: 4.0
                    ),
                  );
                }
              }),
        ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('plots').doc(widget.plotCode).collection('convo').orderBy('date', descending: true).snapshots(),
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
                List<Widget> messages = docs
                    .map((doc) => MessageBox(
                  date: doc['from'],
                  text: doc['text'],
                  me: widget.name == doc['from'],
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
                    callback: (){
                      sendMessage();
                    },
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
