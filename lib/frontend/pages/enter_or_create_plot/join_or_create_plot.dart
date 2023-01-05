import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/backend/firebase_auth_services.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:plots/frontend/components/fs_sp_data_widget.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/user_agreement_to_host.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/bidding_and_plus_ones.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/create_plot.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/find_instagram.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/plot_preview.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/user_agreement_to_attend.dart';
import 'package:plots/frontend/pages/login/upload_profile_pic.dart';
import 'package:plots/frontend/pages/nav/profile/edit_profile.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

// join or create plot page. navigated from floating action button in home

class JoinOrCreatePlot extends StatefulWidget {
  final SharedPrefData sharedPrefData;

  const JoinOrCreatePlot({Key key, this.sharedPrefData}) : super(key: key);

  @override
  _JoinOrCreatePlotState createState() => _JoinOrCreatePlotState();
}

class _JoinOrCreatePlotState extends State<JoinOrCreatePlot> {
  String enteredCode;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  bool _validate = false;
  final _joinPlotFormKey = GlobalKey<FormState>();
  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
  Future<String> profilePicURL;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profilePicURL = getProfilePicURL();
  }

  Future<String> getProfilePicURL() async {
    String profilePicURL = await firestoreFunctions.getProfilePicURLFromAuthID(widget.sharedPrefData.authID);
    return profilePicURL;
  }


  String validatePlotCode(String value) {
    if (value == null || value.isEmpty) {
      return "Missing Code";
    }
    return null;
  }

  void _joinPlot() async {
    Timer(Duration(milliseconds: 300), () async{
      if (_joinPlotFormKey.currentState.validate()) {
        List plotExistStatus = await checkIfPlotExists();
        bool plotExists = plotExistStatus[0];
        bool plotStarted = plotExistStatus[1];
        if (_joinPlotFormKey.currentState.validate() && plotExists && !plotStarted) {
          FirestorePlotData firestorePlotData = await firestoreFunctions.makePlotObject(enteredCode);
          String hostProfilePic = await firestoreFunctions.getProfilePicURLFromAuthID(firestorePlotData.hostAuthID);
          _btnController.reset();
          Navigator.push(context, MaterialPageRoute(
              builder: (BuildContext context) => UserAgreementToAttend(
                firestorePlotData: firestorePlotData,
                sharedPrefData: widget.sharedPrefData,
                hostProfilePic: hostProfilePic,
              )
          ));
        } else if (plotStarted){
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Color(0xff1e1e1e),
                  title: Text('this plot has been closed.', textAlign: TextAlign.center, style: TextStyle(
                    color: Colors.white
                  ),),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white,),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
          _btnController.reset();
        }
        else {
          setState(() {
            _validate = true;
          });
          _btnController.reset();
        }
      } else {
        _btnController.reset();
      }
    });
  }


  Future<List> checkIfPlotExists () async {
    bool plotExists = false;
    bool closed = false;
    var currPlots = await firestoreFunctions.getPlots();
    currPlots.docs.forEach((element) {
      String plotID = element.data()['plotCode'].toString();
      // checks subString because code format added to database
      if (enteredCode == plotID){
        plotExists = true;
        if (element.data()['closed']) {
          closed = true;
        }
      }
    });
    return [plotExists, closed];
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child:GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Column(
      children:[
          SafeArea(
            child: Row(children: [
              Container(
                  alignment:Alignment.centerLeft, padding: EdgeInsets.only(left: 20, top: 20),
                  child: Text("what's plots?", textAlign: TextAlign.start, style: TextStyle(
                      fontSize: 32
                  ),)),
              Expanded(child: Container(),),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.white, size: 35,),
                  onPressed: (){
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
                            IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: (){
                              Navigator.pop(context);
                            } ),
                            TextButton(
                              child: Text("log out", style: TextStyle(
                                color: Colors.red
                              )),
                                onPressed: ()async{
                              AuthService authService = AuthService();
                              SharedPrefsServices sharedPrefsServices =
                              SharedPrefsServices();
                              await sharedPrefsServices.logOut();
                              authService.signOut(context);
                            })
                          ],
                        );
                      }
                    );
                  },
                ),
              ),
              SizedBox(width: 25,)
            ],),
          ),
          SizedBox(height: 20,),
          // ExpandablePanel(
          //   collapsed: Container(),
          //   header: Container(
          //     width: 100,
          //     color: Colors.red,
          //     height: 25,
          //     child: Text("DEMONSTRATION MODE\nDO NOT TOUCH IF YOUR NAME IS NOT JAMES HAN", ),
          //   ),
          //   expanded: Column(children: [
          //     Divider(
          //       color: Colors.grey,
          //     ),
          //     ListTile(
          //       tileColor: Color(0xff1e1e1e),
          //       leading: Icon(Icons.language, color: Colors.red,),
          //       title: Text('Sample Guest', style: TextStyle(
          //           color: Colors.red
          //       ),),
          //       onTap: ()  async{
          //         SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
          //         await sharedPrefsServices.setAll(joinedPlot:false,
          //             authID:'ek2MbByuU9Yig6sVUzfDGnX5ElS2',
          //             username: 'mom1',
          //             phoneNumber:'5104931523',
          //             plotCode:'197b8',
          //             approved: true);
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (BuildContext context) => FSSPDataWidget(
          //                   authID: 'ek2MbByuU9Yig6sVUzfDGnX5ElS2',
          //                   sync: false,
          //                 )));
          //       },
          //     ),
          //     ListTile(
          //       tileColor: Color(0xff1e1e1e),
          //       leading: Icon(Icons.person, color: Colors.red,),
          //       title: Text('Host', style: TextStyle(
          //           color: Colors.red
          //       ),),
          //       onTap: ()  {
          //         SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
          //         sharedPrefsServices.setAll(joinedPlot:true,
          //             authID:'Lnj53MzP1zLtCCNQ0nnP9nRlwTG3',
          //             username: 'hamesjan',
          //             phoneNumber:'3107559222',
          //             plotCode:'ef25b',
          //             approved: true);
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (BuildContext context) => FSSPDataWidget(
          //                   authID: 'Lnj53MzP1zLtCCNQ0nnP9nRlwTG3',
          //                   sync: false,
          //                 )));
          //       },
          //     ),
          //     Divider(
          //       color: Colors.grey,
          //     ),
          //     ListTile(
          //       leading: Icon(Icons.settings_applications, color: Colors.red,),
          //       title: Text('Firestore & SharedPref Data', style: TextStyle(color: Colors.red),),
          //       onTap: ()  {
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (BuildContext context) => FSSPDataWidget(
          //                   authID: widget.sharedPrefData.authID,
          //                   sync: false,
          //                 )));
          //       },
          //     ),
          //   ],),),
    SizedBox(height: 10,),
    Stack(children: [
      Align(
       alignment: Alignment.center,
          child:
      FutureBuilder(
            future: profilePicURL,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done){
                return GestureDetector(
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
                                    imageUrl: snapshot.data,
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
                                      height: 50.0,
                                      width: 50.0,
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                              )
                          );
                        }
                    );
                  },
                  child: Container(
                      child:CircleAvatar(
                          radius: MediaQuery.of(context).size.height / 8 +1,
                          backgroundColor: Colors.transparent,
                          child:CircleAvatar(
                            backgroundColor: Color(0xff1e1e1e),
                              radius: MediaQuery.of(context).size.height / 8,
                              child: CachedNetworkImage(
                                imageUrl: snapshot.data,
                                imageBuilder: (context, imageProvider) => Container(
                                  width: MediaQuery.of(context).size.height / 4,
                                  height: MediaQuery.of(context).size.height /4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider, fit: BoxFit.cover),
                                  ),
                                ),
                                placeholder: (context, url) => CircleAvatar(
                                    backgroundColor: Color(0xff1e1e1e),
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                        strokeWidth: 4.0
                                )),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              )
                          )
                      )),
                );
              } else {
                return CircleAvatar(
                  backgroundColor:Color(0xff1e1e1e) ,
                    radius: MediaQuery.of(context).size.height / 8,
                    child: Container(
                        width: MediaQuery.of(context).size.height / 4,
                        height: MediaQuery.of(context).size.height / 4,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                            strokeWidth: 4.0
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        )
                    )
                );
              }
            }),
          ),
      Align(alignment: Alignment.bottomRight, child: Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(right: 90),
          height: MediaQuery.of(context).size.height / 4,
          child: RawMaterialButton(
            onPressed: () async {
              FirestoreFunctions firestoreFunctions = FirestoreFunctions();
              String profilePicURL = await firestoreFunctions.getProfilePicURLFromAuthID(widget.sharedPrefData.authID);
              FirebaseFirestore _firestore = FirebaseFirestore.instance;
              var result = await _firestore.collection('appData').doc('records').get();
              List takenUsernames = []..addAll(result.data()['usernames']);
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EditProfile(
                        sharedPrefData: widget.sharedPrefData,
                        takenUsernames: takenUsernames,
                        profilePicURL: profilePicURL,
                      )
                  ));
            },
            elevation: 2.0,
            fillColor: Color(0xff630094),
            child: Icon(
              Icons.edit,
              size: 25.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          ),
      ),),
    ],),
          Text("${widget.sharedPrefData.username}", style: TextStyle(fontSize:35),),
          Text("please enter 5 digit plot code", style: TextStyle(fontSize: 12),),

          Form(
          key: _joinPlotFormKey,
          child:
          Container(
            padding: EdgeInsets.all(16),
            child:
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                    autocorrect: false,
                    validator: (value) => validatePlotCode(value),
                    onChanged: (value) => enteredCode = value,
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      paste: true,
                      selectAll: true,
                      cut: true,
                    ),
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: '5 digit plot code',
                    hintText: 'plots',
                    hintStyle: TextStyle(
                        color: Colors.grey
                    ),
                    errorText: _validate ? 'Invalid Code' : null,
                    errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    hoverColor: Colors.white,
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
                SizedBox(height: 20,),
                Container(
                    alignment: Alignment.center,
                    child:  RoundedLoadingButton(
                      color: Color(0xff630094),
                      elevation: 2,
                      width: 200,
                      height: 40,
                      borderRadius: 5,
                      child: Text('join plot', style: TextStyle(color: Colors.white,fontSize: 20)),
                      controller: _btnController,
                      onPressed: _joinPlot,
                    )
                ),
                SizedBox(height: 10,),
            RawMaterialButton(
              onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => UserAgreementToHost(
                          createActual: true,
                          sharedPrefData: widget.sharedPrefData,
                        )
                    ));
              },
              elevation: 2.0,
              constraints: BoxConstraints(minWidth: 200, minHeight: 40),
              fillColor: Color(0xff630094),
              child: Text('create new plot', style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
              ),),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))
              ),
            ),
                SizedBox(height: 10,),
              ],
            ),
          )
    ),
              ]
    ),
        ));
  }
}
