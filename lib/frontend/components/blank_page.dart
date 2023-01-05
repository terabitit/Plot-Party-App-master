import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

// just for testing, right now its qr code

class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: ()async{
            SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
            SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (BuildContext context) => Home(initialTabIndex: 0, sharedPrefData: sharedPrefData,)
            ), (route) => false);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: MediaQuery.of(context).size.width,),
          Text("Hello")
        ],
      ),
    );
  }
}
