import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ErrorOccurred extends StatelessWidget {
  // Just a static error occurred page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('an error occurred.\ntry restarting the application.', textAlign: TextAlign.center,),
      ),
    );
  }
}
