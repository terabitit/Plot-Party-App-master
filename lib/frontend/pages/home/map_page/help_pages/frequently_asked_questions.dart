import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FrequentlyAskedQuestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("frequently asked questions", style: TextStyle(
          color: Colors.white
        ),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ExpandablePanel(
                collapsed: Container(),
                header: Text("what is the definition of plots?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                    iconColor: Colors.purpleAccent
                ),
                expanded: Text("plots means the move, the plan, the main event for the night. when someone says what's plots?, they are essentially asking, where are the parties tonight?", style: TextStyle(
                  color: Colors.white, fontSize: 20,
                ),)),
            Divider(thickness: 2, color: Colors.grey,),
            ExpandablePanel(
              collapsed: Container(),
                header: Text("what's plots?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                  iconColor: Colors.purpleAccent
                ),
                expanded: Text("plots is an app aimed to facilitate the discovery and organization of parties.", style: TextStyle(
                  color: Colors.white, fontSize: 20,
                ),)),
            Divider(thickness: 2, color: Colors.grey,),
            ExpandablePanel(
                collapsed: Container(),
                header: Text("how do I join a plot?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                    iconColor: Colors.purpleAccent
                ),
                expanded: Text("one would join a plot either by finding a party on the plot map or entering a 5 digit plot code in the 'fun' tab of the homescreen, which one would receive from a friend or party host", style: TextStyle(
                  color: Colors.white, fontSize: 20,
                ),)),
            Divider(thickness: 2, color: Colors.grey,),
            ExpandablePanel(
                collapsed: Container(),
                header: Text("how many plots can I be a part of at once?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                    iconColor: Colors.purpleAccent
                ),
                expanded: Text("¡one!", style: TextStyle(
                  color: Colors.white, fontSize: 20,
                ),)),
            Divider(thickness: 2, color: Colors.grey,),
            ExpandablePanel(
                collapsed: Container(),
                header: Text("i've joined a plot. what now?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                    iconColor: Colors.purpleAccent
                ),
                expanded: Text("now, we wait. after joining a plot and sending in your payment info, send the payment through your selected method and then wait for the host to approve you. you can send the host messages if any confusion arises.", style: TextStyle(
                  color: Colors.white, fontSize: 20,
                ),)),
            Divider(thickness: 2, color: Colors.grey,),
            ExpandablePanel(
                collapsed: Container(),
                header: Text("i've been approved. what now?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                    iconColor: Colors.purpleAccent
                ),
                expanded: Text("when you arrive at the address take out your ticket, which is in the form of a QR code on your home screen. the security will scan your code and have access to all your payment info, so make sure you are approved and good to go by the time you reach the door.", style: TextStyle(
                  color: Colors.white, fontSize: 20,
                ),)),
            Divider(thickness: 2, color: Colors.grey,),
            ExpandablePanel(
                collapsed: Container(),
                header: Text("why host a party using plots?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                    iconColor: Colors.purpleAccent
                ),
                expanded: Text("plots allows hosts to organize and manage all their guests seamlessly through cloud technology. all the data is syncrhonized and everything is in one place. QR code tickets, direct messages, easy-to-manage attend requests, and more are available for hosts so that they can throw ragers without any trouble.", style: TextStyle(
                  color: Colors.white, fontSize: 20,
                ),)),
            Divider(thickness: 2, color: Colors.grey,),
            ExpandablePanel(
                collapsed: Container(),
                header: Text("who is the tallest person to ever live?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                    iconColor: Colors.purpleAccent
                ),
                expanded: Column(
                  children: [
                    Text("Robert Wadlow, standing at a whopping 8 feet and 11 inches, is the tallest person to ever live. Wadlow was so tall because of his extremely large pituitary gland.", style: TextStyle(
                      color: Colors.white, fontSize: 20,
                    ),),
                    SizedBox(height: 5,),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 4 + 25,
                        minHeight: MediaQuery.of(context).size.height / 4 + 25,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/robby.jpeg',
                            ),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
            Divider(thickness: 2, color: Colors.grey,),
            ExpandablePanel(
                collapsed: Container(),
                header: Text("what's coming in the future?", style: TextStyle(color: Colors.purpleAccent, fontSize: 20),),
                theme: ExpandableThemeData(
                    iconColor: Colors.purpleAccent
                ),
                expanded: Text("many things. i want you guys to stick with me as a turn plots into a fun side project into a billion dollar company.", style: TextStyle(
                  color: Colors.white, fontSize: 20,
                ),)),
            Divider(thickness: 2, color: Colors.grey,),
          ],


        ),
      ),
    );
  }
}
