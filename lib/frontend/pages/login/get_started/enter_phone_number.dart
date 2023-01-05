import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/login/register_and_verify_phone_number.dart';
import 'package:plots/frontend/components/custom_button.dart';

class EnterPhoneNumber extends StatefulWidget {
  // Register Page On Startup, only accessible on first open app after download
  final List takenUsernames;
  final List takenPhoneNumbers;

  const EnterPhoneNumber({Key key, this.takenUsernames, this.takenPhoneNumbers}) : super(key: key);
  @override
  _EnterPhoneNumberState createState() => _EnterPhoneNumberState();
}

class _EnterPhoneNumberState extends State<EnterPhoneNumber> {
  String username;
  String phoneNumber;
  final _enterPhoneNumberKey = GlobalKey<FormState>();

  String validatePhoneNumber(String value,) {
    if (value.isEmpty || value.length != 10) {
      return "invalid. try again.";
    }
    if (widget.takenPhoneNumbers.contains(phoneNumber)) {
      return "that phone number is already in use.";
    }
    return null;
  }

  String validateUsername(String username,) {
    bool usernameInvalid = false;
    List acceptableCharacters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8','9','0', '_', '.'];
    if (username.isNotEmpty) {
      for (var char in username.characters) {
        if (!acceptableCharacters.contains(char.toLowerCase())){
          usernameInvalid = true;
        }
      }
    }
    if (username.isEmpty || usernameInvalid) {
      return "invalid. try again.";
    }
    if (widget.takenUsernames.contains(username)) {
      return "that username is not available.";
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent,),
        body: SingleChildScrollView(child:Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20),
          child: Text("register", style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),),
        ),
        SizedBox(height: 7,),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20),
          child: Text("please enter a mobile phone number\nand username", style: TextStyle(
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
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: 'phone number',
                        hintText: '##########',
                        hintStyle: TextStyle(
                            color: Colors.grey
                        ),
                        errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                            BorderRadius.all(Radius.circular(5)))),),
                  flex: 5,
                ),
              ],),
              SizedBox(height: 20,),
              TextFormField(
                  validator: (text) => validateUsername(text),
                  onChanged: (value) => username = value,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'new username',
                    hintText: 'thelegend27',
                    hintStyle: TextStyle(
                        color: Colors.grey

                    ),
                    errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                        BorderRadius.all(Radius.circular(5)))),),
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
                      builder: (BuildContext context) => RegisterAndVerifyPhoneNumber(phoneNumber: phoneNumber, username: username,)
                  ));
            }
          },
        ),
      ],
        )
        )
    );
  }
}

