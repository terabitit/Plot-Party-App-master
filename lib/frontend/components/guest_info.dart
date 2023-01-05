import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class GuestInfoWidget extends StatelessWidget {
  // widget where it just shows a container with circle avatar, used for each guest in the plot info page hostview
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: Colors.white)
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.purpleAccent,
            child:CircleAvatar(
              radius: 150,
              backgroundImage: NetworkImage('https://media.glamour.com/photos/5a425fd3b6bcee68da9f86f8/master/pass/best-face-oil.png'),
            ),
          ),
          SizedBox(width: 10,),
          Text("Name here", style: TextStyle(fontSize: 20),)
        ],
      ),
    );
  }
}
