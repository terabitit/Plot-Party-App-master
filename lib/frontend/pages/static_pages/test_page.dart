import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  // Just a test page
 final String username;
  final String phoneNumber;

  const TestPage({Key key, this.username, this.phoneNumber}) : super(key: key);
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Text(widget.username),
        Text(widget.phoneNumber)
      ],)
      ,
    );
  }
}
