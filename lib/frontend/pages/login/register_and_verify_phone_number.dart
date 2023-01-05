import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pinput/pin_put/pin_put.dart';
//import 'package:pinput/pinput.dart';
import 'package:plots/backend/firebase_auth_services.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plots/frontend/pages/login/upload_profile_pic.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';

class RegisterAndVerifyPhoneNumber extends StatefulWidget {
  // register and verify phone number, accessed after registering both for first time and if logged out then registering
  final String phoneNumber;
  final String username;

  const RegisterAndVerifyPhoneNumber({Key key, this.phoneNumber, this.username}) : super(key: key);
  @override
  _RegisterAndVerifyPhoneNumberState createState() => _RegisterAndVerifyPhoneNumberState();
}

class _RegisterAndVerifyPhoneNumberState extends State<RegisterAndVerifyPhoneNumber> {
  String _verificationCode;
  String errorMessage;
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
              // Implement Firestore Database stuff here
            if (value.user != null) {
              DateTime today = new DateTime.now();
              var _today = DateTime.parse(today.toString());
              String _formatToday = DateFormat.yMMMd().format(_today);
              AuthService authService = AuthService();
              await _firestore.collection('users').doc(
                  authService.getAuthID()).set({
                'username': widget.username,
                'unreadMessages': 0,
                'phoneNumber': widget.phoneNumber,
                'dateJoined': _formatToday,
                'joinedPlot': false,
                'FCMtoken': '',
                'uuid': authService.getAuthID(),
                'plotCode': '',
                'profilePicURL': '',
                'approved': false,
              }).catchError((onError) => print(onError.toString()));
              // Shared Prefs stuff
              FirestoreFunctions firestoreFunctions = FirestoreFunctions();
              await firestoreFunctions.writeUsernameRecord(widget
                  .username);
              await firestoreFunctions.writePhoneNumberRecord(widget
                  .phoneNumber);
              SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
              await sharedPrefsServices.setUsername(widget.username);
              await sharedPrefsServices.setAuthID(authService
                  .getAuthID());
              await sharedPrefsServices.setPlotStatusNotJoined();
              await  sharedPrefsServices.setPlotCode('noPlot');
              await sharedPrefsServices.setUserNotApprovedStatus();
              await sharedPrefsServices.setPhoneNumber(widget
                  .phoneNumber);
              SharedPrefData sharedPrefData = await sharedPrefsServices
                  .makeUserObject();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      UploadProfilePic(
                          sharedPrefData: sharedPrefData
                      )),
                      (route) => false);
            } else {
              DateTime today = new DateTime.now();
              var _today = DateTime.parse(today.toString());
              var _formatToday = DateFormat.yMMMd().format(_today);
              AuthService authService = AuthService();
              await _firestore.collection('users')
                  .doc(authService.getAuthID())
                  .set({
                'username': widget.username,
                'phoneNumber': widget.phoneNumber,
                'dateJoined': _formatToday,
                'unreadMessages': 0,
                'joinedPlot': false,
                'FCMtoken': '',
                'uuid': authService.getAuthID(),
                'plotCode': '',
                'profilePicURL': '',
                'approved': false,
              })
                  .catchError((onError) => print(onError.toString()));
              // Shared Prefs stuff
              FirestoreFunctions firestoreFunctions = FirestoreFunctions();
              await firestoreFunctions.writeUsernameRecord(widget.username);
              await firestoreFunctions.writePhoneNumberRecord(widget.phoneNumber);
              SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
              await sharedPrefsServices.setUsername(widget.username);
              await sharedPrefsServices.setAuthID(authService.getAuthID());
              await sharedPrefsServices.setPlotStatusNotJoined();
              await sharedPrefsServices.setPlotCode('noPlot');
              await sharedPrefsServices.setUserNotApprovedStatus();
              await sharedPrefsServices.setPhoneNumber(widget.phoneNumber);
              SharedPrefData sharedPrefData = await sharedPrefsServices
                  .makeUserObject();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      UploadProfilePic(
                          sharedPrefData: sharedPrefData
                      )),
                      (route) => false);
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            // 563021
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
                            print("before");
                        if (value.user != null) {
                          print("user not null");
                          DateTime today = new DateTime.now();
                          var _today = DateTime.parse(today.toString());
                          String _formatToday = DateFormat.yMMMd().format(_today);
                          AuthService authService = AuthService();
                          await _firestore.collection('users').doc(
                              FirebaseAuth.instance.currentUser.uid).set({
                            'username': widget.username,
                            'phoneNumber': widget.phoneNumber,
                            'dateJoined': _formatToday,
                            'joinedPlot': false,
                            'unreadMessages': 0,
                            'FCMtoken': '',
                            'uuid': FirebaseAuth.instance.currentUser.uid,
                            'plotCode': '',
                            'profilePicURL': '',
                            'approved': false,
                          }).catchError((onError) => print(onError.toString()));
                          print("set");
                          // Shared Prefs stuff
                          FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                          await firestoreFunctions.writeUsernameRecord(widget.username);
                          await firestoreFunctions.writePhoneNumberRecord(widget.phoneNumber);
                          print("firestore");
                          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
                          await sharedPrefsServices.setUsername(widget.username);
                          await sharedPrefsServices.setAuthID(FirebaseAuth.instance.currentUser.uid);
                          await sharedPrefsServices.setPlotStatusNotJoined();
                          await sharedPrefsServices.setPlotCode('noPlot');
                          await sharedPrefsServices.setUserNotApprovedStatus();
                          await sharedPrefsServices.setPhoneNumber(widget.phoneNumber);
                          print("sharedPref");
                          SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
                          print(sharedPrefData.authID);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  UploadProfilePic(
                                      sharedPrefData: sharedPrefData
                                  )),
                                  (route) => false);
                        }
                          else {
                          // Implement Firestore Database stuff here
                          DateTime today = new DateTime.now();
                          var _today = DateTime.parse(today.toString());
                          String _formatToday = DateFormat.yMMMd().format(_today);
                          AuthService authService = AuthService();
                          await _firestore.collection('users').doc(
                              authService.getAuthID()).set({
                            'username': widget.username,
                            'phoneNumber': widget.phoneNumber,
                            'dateJoined': _formatToday,
                            'joinedPlot': false,
                            'FCMtoken': '',
                            'unreadMessages': 0,
                            'uuid': authService.getAuthID(),
                            'plotCode': '',
                            'profilePicURL': '',
                            'approved': false,
                          }).catchError((onError) => print(onError.toString()));
                          // Shared Prefs stuff
                          FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                          await firestoreFunctions.writeUsernameRecord(widget
                              .username);
                          await firestoreFunctions.writePhoneNumberRecord(widget
                              .phoneNumber);
                          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
                          await sharedPrefsServices.setUsername(widget.username);
                         await sharedPrefsServices.setAuthID(authService
                              .getAuthID());
                          await sharedPrefsServices.setPlotStatusNotJoined();
                         await  sharedPrefsServices.setPlotCode('noPlot');
                         await sharedPrefsServices.setUserNotApprovedStatus();
                         await sharedPrefsServices.setPhoneNumber(widget
                              .phoneNumber);
                          SharedPrefData sharedPrefData = await sharedPrefsServices
                              .makeUserObject();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  UploadProfilePic(
                                      sharedPrefData: sharedPrefData
                                  )),
                                  (route) => false);
                        }
                      });
                    } catch (e) {
                      FocusScope.of(context).unfocus();
                      _scaffoldkey.currentState
                          .showSnackBar(
                          SnackBar(content: Text('invalid code.')));
                    }
                  } else {
                    setState(() {
                      errorMessage = "error. are you sure you put the right phone number?";
                    });
                  }
                }
              ),
            ),
            Container(
                alignment: Alignment.center,
                child: Text('enter the 6 digit code sent to +1${widget.phoneNumber}', style: TextStyle(fontSize: 16, color: Colors.grey),),
                ),
            errorMessage == null ? Container() :Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: Text(errorMessage, style: TextStyle(fontSize: 16, color: Colors.red),),
            ),
          ],
        )
    );
  }


}

