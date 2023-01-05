import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/pages/login/login.dart';

class AuthService {

  // service for firestore authentication

  Future<bool> getLoggedInStatus() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }
    return true;
  }

  getAuthID () async{
    String uid = FirebaseAuth.instance.currentUser.uid;
    return uid;
  }

  signOut(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (route) => false);
  }

}

