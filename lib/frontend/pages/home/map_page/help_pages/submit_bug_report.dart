import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SubmitBugReport extends StatefulWidget {
  @override
  _SubmitBugReportState createState() => _SubmitBugReportState();
}

class _SubmitBugReportState extends State<SubmitBugReport> {
  String bugReport;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _bugReportKey = GlobalKey<FormState>();

  final failSnackbar = SnackBar(
    content: Text(
      'error. Try again.',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
  );
  final successSnackbar = SnackBar(
    content: Text(
      'success! your name is written in the history books.',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.green,
  );


  void _submitBug() async {
    FocusScope.of(context).unfocus();
    Timer(Duration(milliseconds: 300), () async{
      if(_bugReportKey.currentState.validate()) {
        try{
          DateTime today = new DateTime.now();
          var _today = DateTime.parse(today.toString());
          String _formatToday = DateFormat.yMMMd().format(_today);
          FirestoreFunctions firestoreFunctions = FirestoreFunctions();
          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
          SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
          await firestoreFunctions.writeBugReport(authID: sharedPrefData.authID, dateWritten: _formatToday, bug: bugReport );
          print(bugReport);
          ScaffoldMessenger.of(context).showSnackBar(successSnackbar);
          _btnController.reset();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
          _btnController.reset();
          print(e.toString());
        }
      }
      else {
        _btnController.reset();
      }
    });
  }


  String validateBugReport(String value) {
    if (value == null || value.isEmpty) {
      return "Missing Details";
    } else if (value.length < 5) {
      return "Minimum 5 characters";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("help improve plots"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Form(
            key: _bugReportKey,
            child: Column(
              children: [
                Text("thank you for clicking on this tab!\n\nevery bit of information we get from you guys is extremely helpful to improving the overall experience for users around the world.", style: TextStyle(
                  color: Colors.white, fontSize: 16,
                ),textAlign: TextAlign.center,),
                SizedBox(height: 20,),
                TextFormField(
                    onChanged: (value) => bugReport = value,
                    autocorrect: false,
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      paste: true,
                      selectAll: true,
                      cut: true,
                    ),
                    maxLines: null,
                    minLines: 6,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    validator: (value) => validateBugReport(value.toString()),
                    decoration: InputDecoration(
                      // flashing container
                      // unfocus after you click background
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: "home page buggggggin!!",
                        labelText: "write your bug report here.",
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
                            BorderRadius.all(Radius.circular(5))
                        ))),
                SizedBox(height: 20,),
                Container(
                    alignment: Alignment.center,
                    child:  RoundedLoadingButton(
                      color: Color(0xff630094),
                      width: 165,
                      height: 50,
                      borderRadius: 5,
                      child: Text('submit', style: TextStyle(fontSize: 20,color: Colors.white)),
                      controller: _btnController,
                      onPressed: _submitBug,
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

