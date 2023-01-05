import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NoPlotJoined extends StatelessWidget {
  // Page shown if no plot joined. Make one for pending
  final String text;

  const NoPlotJoined({Key key, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('join a plot first!'),
          Text(text)
        ],
      )
    );
  }
}
