import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plots/backend/firebase_auth_services.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/fs_sp_data_widget.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/nav/profile/edit_profile.dart';
import 'package:plots/frontend/pages/nav/profile/view_profile.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_approval.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_firstTime.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_guest.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_host.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_security.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

class NavigationDrawer extends StatefulWidget {
  // Navigation widget to draw navigation  widges.
  final SharedPrefData sharedPrefData;
  const NavigationDrawer({Key key, this.sharedPrefData}) : super(key: key);

  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            AppBar(
              elevation: 0,
              title: Text('navigation'),
              actions: <Widget>[
                new Container(),
              ],
              leading: IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.white,),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Column(
              children: <Widget>[
                Divider(color: Colors.grey,),
                ListTile(
                  tileColor: Color(0xff1e1e1e),
                  leading: Icon(Icons.person, color: Colors.white,),
                  title: Text('view profile', style: TextStyle(
                      color: Colors.white
                  ),),
                  onTap: ()  async{
                    FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                    String profilePicURL = await firestoreFunctions.getProfilePicURLFromAuthID(widget.sharedPrefData.authID);
                     Navigator.push(context, MaterialPageRoute(
                       builder: (BuildContext context) => ViewProfile(
                         sharedPrefData: widget.sharedPrefData,
                         profilePicURL: profilePicURL,
                       )
                     ));
                  },
                ),
                Divider(color: Colors.grey,),
                ListTile(
                  tileColor: Color(0xff1e1e1e),
                  leading: Icon(Icons.logout, color: Colors.white,),
                  title: Text('log out', style: TextStyle(
                    color: Colors.white
                  ),),
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContextcontext) {
                          return AlertDialog(
                            backgroundColor: Color(0xff1e1e1e),
                            title: Text("are you sure you want to log out?", style: TextStyle(
                                fontSize: 20,
                              color: Colors.white
                            ),),
                            actions: [
                              Row(children: [
                                IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: (){
                                  Navigator.pop(context);
                                } ),
                                Expanded(child: Container(),),
                                ElevatedButton(
                                  onPressed: () async{
                                    AuthService authService = AuthService();
                                    SharedPrefsServices sharedPrefsServices =
                                    SharedPrefsServices();
                                    await sharedPrefsServices.logOut();
                                    authService.signOut(context);
                                  }, child: Text("log out", style: TextStyle(
                                    color: Colors.white
                                ),),
                                  style: ElevatedButton.styleFrom(primary: Colors.red),
                                ),
                              ],)

                            ],
                          );
                        }
                    );
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                widget.sharedPrefData.joinedPlot
                    ? ListTile(
                  tileColor: Color(0xff1e1e1e),
                  leading: Icon(Icons.bedtime_outlined, color: Colors.white,),
                        title: Text('leave plot', style: TextStyle(
                          color: Colors.white
                        ),),
                        onTap: () async {
                          FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
                          bool isHost = await firestoreFunctions.isHost(widget.sharedPrefData.username, widget.sharedPrefData.plotCode);
                          isHost ? showDialog(context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Color(0xff1e1e1e),
                                  title: Text("are you sure you want to leave this plot?", style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20
                                  ),),
                                  content: Text("this will close the plot for everybody.\nthis action can not be undone.", style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20
                                  ),),
                                  actions: <Widget>[
                                    Row(children: [
                                      IconButton(icon: Icon(Icons.close, color: Colors.white,),onPressed: (){
                                        Navigator.pop(context);
                                      }),
                                      Expanded(child: Container(),),
                                      ElevatedButton(
                                        onPressed: () async{
                                          firestoreFunctions.closePlot(widget.sharedPrefData.plotCode);
                                         await sharedPrefsServices.setPlotStatusNotJoined();
                                        await  sharedPrefsServices.setPlotCode('none');
                                          SharedPrefData sharedPrefData =
                                          await sharedPrefsServices.makeUserObject();
                                          firestoreFunctions.updateUserInfo(
                                              authID: widget.sharedPrefData.authID, fields: ['plotCode', 'joinedPlot'],newValues: ['none', false]);
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Home(
                                                    sharedPrefData: sharedPrefData,
                                                    initialTabIndex: 0,
                                                  )),
                                                  (route) => false);
                                        }, child: Text("Leave", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                        style: ElevatedButton.styleFrom(primary: Colors.red),
                                      )
                                    ],)

                                  ],
                                );
                              }
                          ): showDialog(context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Color(0xff1e1e1e),
                                  title: Text("are you sure you want to leave this plot?", style: TextStyle(
                                    color: Colors.white,
                                  ),),
                                  actions: <Widget>[
                                    Row(children: [
                                      IconButton(icon: Icon(Icons.close, color: Colors.white,),onPressed: (){
                                        Navigator.pop(context);
                                      }),
                                      Expanded(child: Container(),),
                                      ElevatedButton(
                                          onPressed: () async{
                                           await sharedPrefsServices.setPlotStatusNotJoined();
                                           await sharedPrefsServices.setPlotCode('none');
                                            SharedPrefData sharedPrefData =
                                                await sharedPrefsServices.makeUserObject();
                                            firestoreFunctions.updateUserInfo(
                                                authID: widget.sharedPrefData.authID, fields: ['plotCode', 'joinedPlot'],newValues: ['none', false]);
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Home(
                                                      sharedPrefData: sharedPrefData,
                                                      initialTabIndex: 0,
                                                    )),
                                                    (route) => false);
                                          }, child: Text("leave", style: TextStyle(
                                        color: Colors.white
                                      ),),
                                      style: ElevatedButton.styleFrom(primary: Colors.red),
                                      )
                                    ],)

                                  ],
                                );
                              }
                          ) ;
                        },
                      )
                    : Container(),
                // SizedBox(height: 50,),
                // Divider(
                //   color: Colors.grey,
                // ),
                // Text("Demonstration mode\nDO NOT CLICK RED\nTHIS IS JUST FOR HAMESJAN", style: TextStyle(
                //   fontWeight: FontWeight.bold,
                //   color: Colors.red,
                //   fontSize: 32
                // ),),
                // ListTile(
                //   leading: Icon(Icons.settings_applications, color: Colors.red,),
                //   title: Text('Firestore & SharedPref Data', style: TextStyle(color: Colors.red),),
                //   onTap: ()  {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (BuildContext context) => FSSPDataWidget(
                //               authID: widget.sharedPrefData.authID,
                //               sync: false,
                //             )));
                //   },
                // ),
                // ListTile(
                //   tileColor: Color(0xff1e1e1e),
                //   leading: Icon(Icons.filter_1,color: Colors.red,),
                //   title: Text('Intro screens host', style: TextStyle(
                //       color: Colors.red
                //   ),),
                //   onTap: ()  {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (BuildContext context) => IntroScreensHost(
                //               sharedPrefData: widget.sharedPrefData,
                //             )));
                //   },
                // ),
                // ListTile(
                //   tileColor: Color(0xff1e1e1e),
                //   leading: Icon(Icons.filter_1,color: Colors.red,),
                //   title: Text('Intro screens guest', style: TextStyle(
                //       color: Colors.red
                //   ),),
                //   onTap: ()  {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (BuildContext context) => IntroScreensGuest(
                //               sharedPrefData: widget.sharedPrefData,
                //             )));
                //   },
                // ),
                // ListTile(
                //   tileColor: Color(0xff1e1e1e),
                //   leading: Icon(Icons.filter_1,color: Colors.red,),
                //   title: Text('Intro screens approval', style: TextStyle(
                //       color: Colors.red
                //   ),),
                //   onTap: ()  {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (BuildContext context) => IntroScreensApproval(
                //               sharedPrefData: widget.sharedPrefData,
                //             )));
                //   },
                // ),
                // ListTile(
                //   tileColor: Color(0xff1e1e1e),
                //   leading: Icon(Icons.filter_1,color: Colors.red,),
                //   title: Text('Intro screens security', style: TextStyle(
                //       color: Colors.red
                //   ),),
                //   onTap: ()  {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (BuildContext context) => IntroScreensSecurity(
                //               sharedPrefData: widget.sharedPrefData,
                //             )));
                //   },
                // ),
                // ListTile(
                //   tileColor: Color(0xff1e1e1e),
                //   leading: Icon(Icons.filter_1,color: Colors.red,),
                //   title: Text('Intro firsttime', style: TextStyle(
                //       color: Colors.red
                //   ),),
                //   onTap: ()  {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (BuildContext context) => IntroScreensFirstTime(
                //               sharedPrefData: widget.sharedPrefData,
                //             )));
                //   },
                // ),
                Divider(
                  color: Colors.grey,
                ),
                // ListTile(
                //   tileColor: Color(0xff1e1e1e),
                //   leading: Icon(Icons.language, color: Colors.red,),
                //   title: Text('Sample Guest', style: TextStyle(
                //     color: Colors.red
                //   ),),
                //   onTap: () async {
                //     SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
                //          await sharedPrefsServices.setAll(joinedPlot:true,
                //               authID:'ab9p7hF2ULZE0fBuokxuNRDr9pC3',
                //               username: 'hamesjan',
                //               FCMtoken: 'drhIqCGhVEpLrreeOW1GE8:APA91bGsCzKc6fNW8xh7aichU0tJ5SLH_T5FEGaa8FgynQznCzA61IcfInBxJHiv8cIIVl7v79t73qqN_0noCOy49bdMj7XeAhhwPGXtwBR1hUw04hlez1AkDiGdBz0FqmD5lbiFPV6K',
                //               phoneNumber:'3107559222',
                //               plotCode:'bb519',
                //               approved: true);
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (BuildContext context) => FSSPDataWidget(
                //                     authID: 'ab9p7hF2ULZE0fBuokxuNRDr9pC3',
                //                     sync: false,
                //                   )));
                //   },
                //
                // ),
                // ListTile(
                //   tileColor: Color(0xff1e1e1e),
                //   leading: Icon(Icons.person, color: Colors.red,),
                //   title: Text('Host', style: TextStyle(
                //       color: Colors.red
                //   ),),
                //   onTap: ()  async {
                //     SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
                //          await sharedPrefsServices.setAll(joinedPlot:true,
                //               authID:'GDXFB1WGkFWPrKSfNUaRlXJ2GuY2',
                //               username: 'mommy',
                //               FCMtoken: 'c1-IPNCD1U2BvEv6P5bdff:APA91bEUbU0uUhzpzBSpC1dn57_2N96ZB5UIB9GygeUnCbbKaJaqr3Rf8WbJHzJnTYdJSGsd0deSKVUxSKnSnCV82ndJR0Jy_k7jdDC5_vJntryE_fQkdcQfHi9jNm2uvV7g2ZNkpxqv',
                //               phoneNumber:'5104931523',
                //               plotCode:'bb519',
                //               approved: true);
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (BuildContext context) => FSSPDataWidget(
                //                     authID: 'GDXFB1WGkFWPrKSfNUaRlXJ2GuY2',
                //                     sync: false,
                //                   )));
                //   },
                // ),
                // Divider(
                //   color: Colors.grey,
                // ),
                // ListTile(
                //   leading: Icon(Icons.settings_applications),
                //   title: Text('Firestore & SharedPref Data'),
                //   onTap: ()  {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (BuildContext context) => FSSPDataWidget(
                //               authID: widget.sharedPrefData.authID,
                //               sync: true,
                //             )));
                //   },
                // ),
              ],
            ),
          ],
      ),
    );
  }
}
