import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/backend/firebase_auth_services.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/login/register.dart';
import 'package:plots/frontend/pages/login/verify_phone_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  // Login page if you signed out after downloading app
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phoneNumber;
  final _enterPhoneNumberKey = GlobalKey<FormState>();

  String validatePhoneNumber(String value,) {
    if (value.isEmpty || value.length != 10) {
      return "invalid. try again.";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent,),
        body: SingleChildScrollView(child:GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
              ),
              Container(
               alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
              child: Text("log in", style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),),
              ),
              SizedBox(height: 7,),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Text("please enter your mobile phone number", style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey
                ),),
              ),
              SizedBox(height: 50,),
              Container(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _enterPhoneNumberKey,
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                        child: Text("+1", style: TextStyle(
                          fontSize: 32,
                          color: Colors.white
                        ),),
                        flex: 1,
                      ),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          onChanged: (value) => phoneNumber = value,
                          validator: (value) => validatePhoneNumber(value),
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: 'phone number',
                              hintText: '###########',
                              hintStyle: TextStyle(
                                  color: Colors.grey
                              ),
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
                      flex: 5,
                      ),
                    ],)

                  ],),
                ),
              ),
              SizedBox(height: 50,),
              NextButton(
                text: 'send verification',
                callback: ()async {
                  if (_enterPhoneNumberKey.currentState.validate()){
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => VerifyPhoneNumber(phoneNumber: phoneNumber,)
                        ));
                  }
                },
              ),
              SizedBox(height: 20,),
              TextButton(
                  child: Text('new user?', style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold
                  ),),
                  onPressed: () async{
                    FirebaseFirestore _firestore = FirebaseFirestore.instance;
                    var result = await _firestore.collection('appData').doc('records').get();
                    List takenUsernames = []..addAll(result.data()['usernames']);
                    List takenPhoneNumbers = []..addAll(result.data()['phoneNumbers']);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Register(takenUsernames: takenUsernames, takenPhoneNumbers:takenPhoneNumbers ,)
                        ));
                  }
              )
            ],
          ),
        )
        )
    );
  }
}

