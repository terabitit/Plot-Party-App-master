import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pinput/pin_put/pin_put.dart';
//import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:plots/frontend/pages/login/verify_success_page.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';

class VerifyPhoneNumber extends StatefulWidget {

  // Verification if logging in normally
  final String phoneNumber;

  const VerifyPhoneNumber({Key key, this.phoneNumber}) : super(key: key);
  @override
  _VerifyPhoneNumberState createState() => _VerifyPhoneNumberState();
}

class _VerifyPhoneNumberState extends State<VerifyPhoneNumber> {
  String _verificationCode;
  String errorMessage;
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );

  _verifyPhone() async {
    String pn = '+1${widget.phoneNumber}';
    await FirebaseAuth.instance.verifyPhoneNumber(
      // 310 755 9222
        phoneNumber: pn,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (_verificationCode != null) {
              if (value.user != null) {
                SyncService syncService = SyncService();
                await syncService.syncSharedPrefsWithFirestore(authID: FirebaseAuth.instance.currentUser.uid);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => VerifySucessPage()),
                        (route) => false);
              }
            } else {
              setState(() {
                errorMessage = "error. are you sure you put the right phone number?";
              });
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            errorMessage = "error. are you sure you put the right phone number?";
          });
          print(e.message);
        },
        codeSent: (String verificationID, int resendToken) {
          print(resendToken);
          setState(() {
            _verificationCode = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyPhone();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent,),
        key: _scaffoldkey,
        body: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Text("Verification", style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),),
            ),
            SizedBox(height: 7,),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Text("please allow up to 30 seconds for your code to arrive", style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey
              ),),
            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: PinPut(
                fieldsCount: 6,
                textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
                eachFieldWidth: 40.0,
                eachFieldHeight: 55.0,
                focusNode: _pinPutFocusNode,
                controller: _pinPutController,
                submittedFieldDecoration: pinPutDecoration,
                selectedFieldDecoration: pinPutDecoration,
                followingFieldDecoration: pinPutDecoration,
                pinAnimationType: PinAnimationType.fade,
                onSubmit: (pin) async {
                  if (_verificationCode != null) {
                    try {
                      await FirebaseAuth.instance
                          .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                          .then((value) async {

                        if (value.user != null) {
                          // Shared Prefs stuff
                          SyncService syncService = SyncService();
                          await syncService.syncSharedPrefsWithFirestore(authID: FirebaseAuth.instance.currentUser.uid);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => VerifySucessPage()),
                                  (route) => false);
                        }
                      });
                    } catch (e) {
                      FocusScope.of(context).unfocus();
                      _scaffoldkey.currentState
                          .showSnackBar(SnackBar(content: Text('error.')));
                    }
                  } else {
                    setState(() {
                      errorMessage = "error. are you sure you put the right phone number?";
                    });
                  }

                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('enter the 6 digit code sent to +1${widget.phoneNumber}', style: TextStyle(fontSize: 16, color: Colors.grey),),
              ],),
            errorMessage == null ? Container() :Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: Text(errorMessage, style: TextStyle(fontSize: 16, color: Colors.red),),
            ),
          ],
        )
        )
    );
  }


}

