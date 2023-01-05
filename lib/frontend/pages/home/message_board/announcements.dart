import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Announcements Page that you can access from message board

class Announcements extends StatefulWidget {
  final List announcements;

  const Announcements({Key key, this.announcements}) : super(key: key);
  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("announcements", style: TextStyle(
        color: Colors.white
      ),), elevation: 0,),
      body:
          widget.announcements.length == 0 ? Container(
            child: Center(child:Column(mainAxisSize: MainAxisSize.min, children: [
              Text("there are no announcements.", textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 20,
                color: Colors.white
              ),),Text("check back later!", textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 20,
                color: Colors.grey
              ),)
            ],) ),
          ):  ListView.builder(
              shrinkWrap: true,
              itemCount: widget.announcements.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  child: Container(
                    padding: EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    minHeight: 75
                  ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple,
                          Colors.transparent
                        ]
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Text(widget.announcements[index], style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20
                      ),),
                ),padding: EdgeInsets.all(16),
                );
              })
    );
  }
}
