import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteFromHost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("about the developer", style: TextStyle(
          color: Colors.white,
        ),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              Row(children: [
                GestureDetector(
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
                                  child:  Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.contain,
                                              image: AssetImage('assets/images/meetJames.png')
                                          ))),
                                ),
                              )
                          );
                        }
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15))
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 75,
                      maxWidth: 75,
                      minWidth: 75,
                      minHeight: 75,
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image:  AssetImage(
                                    'assets/images/meetJames.png')))),
                  ),
                ),
                SizedBox(width: 10,),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Meet James",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),),
                    GestureDetector(
                      onTap: ()async{
                        var url = 'https://www.instagram.com/hamesjan/';
                        if (await canLaunch(url)) {
                          await launch(
                            url,
                            universalLinksOnly: true,
                          );
                        } else {
                          print("error");
                        }
                      },
                      child: Row(children: [
                        Container(
                            constraints: BoxConstraints(
                              maxHeight: 25,
                              minWidth: 25,
                              maxWidth: 25,
                              minHeight: 25,
                            ),
                            child:
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/Instagram-Logo.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
                        SizedBox(width: 5,),
                        Container(
                          child: Text(
                            'hamesjan',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,),
                          ),
                        ),
                        SizedBox(width: 10,),
                      ],),
                    ),
                  ],
                ),
              ],),
              SizedBox(height: 5,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Hello everybody! I am an incoming freshman at UCSD majoring in Computer Science. I'm 18 years old and when I grow up, I want to be either a supervillain or a genius billionaire playboy philantropist.\n\nAs I'm writing this message into the app, I'm nerviously bouncing my leg because I'm moving in tomorrow.\nFirst day jitters huh?\n\nI can't wait to meet everyone...", style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                  ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 10,),
                  Text("\nJust like you, I love getting lit at parties and having a good time with my friends.", style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                  ),),
                  SizedBox(height: 10,),
                  Text("Be good to each other. Be patient with the app. If you encounter a glitch or something, please feel free to submit a bug report. The future of plots is bright. Let's kindle the fire together! <3333", style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                  ),),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}
