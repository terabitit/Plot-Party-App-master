import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_guest.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

class JoinFreePlot extends StatelessWidget {
  final SharedPrefData sharedPrefData;
  final String plotCode;
  final String instaUsername;

  const JoinFreePlot({Key key, this.sharedPrefData, this.instaUsername, this.plotCode}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Container(),
      ),
      body: Center(
         child: Column(
           children: [
             Text("this plot is free.",style: TextStyle(
               fontWeight: FontWeight.bold,
               color: Colors.white,
               fontSize: 20
             ),),
             SizedBox(height: 5,),
             Text("the best things in life are free",style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Colors.grey,
                 fontStyle: FontStyle.italic,
                 fontSize: 16
             ),),
             SizedBox(height: 5,),
             NextButton(
                text: "go go go go",
                callback: ()async{
                  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                  SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
                  FirebaseMessaging messaging = FirebaseMessaging.instance;
                  var plotInfo = await _firestore.collection('plots').doc(this.plotCode).get();
                  String profilePicURL = await firestoreFunctions.getProfilePicURLFromAuthID(this.sharedPrefData.authID);
                  List currGuests = []..addAll(plotInfo.data()['guests']);
                  String FCMtoken = await messaging.getToken();
                  Map newGuest = {
                    'username': this.sharedPrefData.username,
                    'authID':this.sharedPrefData.authID,
                    'paymentMethod': 'Free',
                    'instaUsername': this.instaUsername,
                    'plusOnes':'none',
                    'FCMToken':  this.sharedPrefData.FCMtoken != null ? this.sharedPrefData.FCMtoken : FCMtoken == null ? '' : FCMtoken,
                    'profilePicURL': profilePicURL,
                    'price': 0,
                    'paid': true,
                    'paymentDetails': '',
                    'noteToHost': '',
                    'status': 'General Admission',
                  };
                  currGuests.add(newGuest);
                  firestoreFunctions.updatePlotsInfo(plotCode: this.plotCode, field: 'guests', newValue:currGuests);
                  firestoreFunctions.updateUserInfo(authID: this.sharedPrefData.authID, fields: ['plotCode', 'joinedPlot', 'approved'], newValues: [this.plotCode,true,true]);
                  await sharedPrefsServices.setPlotCode(this.plotCode);
                  await sharedPrefsServices.setPlotStatusJoined();
                  await sharedPrefsServices.setUserApprovedStatus();
                  SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
                  bool isFirstTimeGuest = await sharedPrefsServices.isFirstTimeGuest();
                  if(isFirstTimeGuest){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (BuildContext context) => IntroScreensGuest(sharedPrefData: sharedPrefData,)
                    ), (route) => false);
                  }else {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Home(initialTabIndex: 0,
                              sharedPrefData: sharedPrefData,)
                    ), (route) => false);
                  }
                },
              ),
           ],
         )
      ),
    );
  }
}
