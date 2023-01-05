import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/login/get_started/enter_phone_number.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:plots/frontend/pages/login/login.dart';

class GetStarted extends StatelessWidget {
  // First page when opening app for first time, only accessible after first time opening app after download
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent,),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
          ),
          Text("what's plots?", style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              decoration: TextDecoration.none,
          ),),
          Text("discover and organize parties!",textAlign: TextAlign.center, style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),),
          SizedBox(height: 20,),
          NextButton(
            text: 'get started',
            callback: ()async {
              FirebaseFirestore _firestore = FirebaseFirestore.instance;
              var result = await _firestore.collection('appData').doc('records').get();
              List takenUsernames = []..addAll(result.data()['usernames']);
              List takenPhoneNumbers = []..addAll(result.data()['phoneNumbers']);
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EnterPhoneNumber(
                        takenUsernames: takenUsernames,
                        takenPhoneNumbers: takenPhoneNumbers,

                      )
                  ));
            },
          ),
          SizedBox(height: 5,),
          TextButton(
              child: Text('already have an account?', style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.bold
              ),),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Login()
                    ));
              }
          )
        ],
      ),
    );
  }
}
