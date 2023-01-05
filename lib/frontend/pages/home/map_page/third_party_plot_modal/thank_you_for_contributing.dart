import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

class ThankYouForContributing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Container(),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async{
          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
          SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (BuildContext context) => Home(initialTabIndex: 0, sharedPrefData: sharedPrefData,)
            ), (route) => false);
        },
        child: Container(
          color: Color(0xff1e1e1e),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.face_retouching_natural, size: 80, color: Colors.white,),
              Text("success!\nthank you for\ncontributing\nto plots.",textAlign: TextAlign.center,style: TextStyle(
                  fontSize: 32,
                  color: Colors.purpleAccent
              )),
            ],
          ),
        ),
      ),
    );
  }
}
