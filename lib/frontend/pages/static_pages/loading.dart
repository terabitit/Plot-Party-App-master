import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Loading extends StatelessWidget {
  // static loading page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child:CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
          strokeWidth: 4.0
      )),
    );
  }
}
