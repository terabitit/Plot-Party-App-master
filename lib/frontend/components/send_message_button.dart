import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// just another custom button
class SendMessageButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback callback;
  const SendMessageButton({Key key, this.icon, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: callback,
    );
  }
}
