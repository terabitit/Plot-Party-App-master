import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // this widget creates a button
  final VoidCallback callback;
  final String text;
  final Color color;

  const CustomButton({Key key, this.callback, this.text, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      shape: StadiumBorder(),
      minWidth: 300,
      height: 50,
      child: RaisedButton(
        color: color,
        elevation: 8,
        child: Text(
          text,
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        onPressed: callback,
      ),
    );
  }
}