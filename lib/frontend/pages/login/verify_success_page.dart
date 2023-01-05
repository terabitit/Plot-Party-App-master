import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_firstTime.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';

class VerifySucessPage extends StatelessWidget {
  // PAge where it shows that the verification was a success, make another page where verification fails
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async{
          SyncService syncService = SyncService();
          await syncService.syncSharedPrefsWithFirestore(authID: FirebaseAuth.instance.currentUser.uid);
          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
          SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
          bool firstTimeEnter = await sharedPrefsServices.isFirstTimeEnter();
          // Check for first time guest
          if (firstTimeEnter){
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (BuildContext context) => IntroScreensFirstTime(sharedPrefData: sharedPrefData)
            ), (route) => false);
          }else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (BuildContext context) => Home(initialTabIndex: 0, sharedPrefData: sharedPrefData,)
          ), (route) => false);
          }
          },
        child: Container(
          color: Color(0xff1e1e1e),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.face_retouching_natural, color: Colors.white, size: 80,),
              Text("success!",textAlign: TextAlign.center,style: TextStyle(
                fontSize: 52,
                color: Colors.purpleAccent
              )),
              Text("tap anywhere to begin",textAlign: TextAlign.center,style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey
              )),
            ],
          )),
        ),
      ),
    );
  }
}
