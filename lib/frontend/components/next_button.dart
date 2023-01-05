import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NextButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  const NextButton({Key key, this.callback, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(minWidth: 250, minHeight: 50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          gradient: LinearGradient(
            colors: [
              Color(0xffB53D3D),
              Color(0xff630094)
            ]
          )
        ),
        child: ElevatedButton(
          onPressed: callback,

          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),

            ),
            elevation: 0,
              primary: Colors.transparent
          ),
          child: Text(text,textAlign: TextAlign.center, style: TextStyle(color: Colors.white,  fontSize: 20),),
    ));
  }
}
