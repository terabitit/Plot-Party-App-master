import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ThreeStepWidget extends StatelessWidget {
  final int step;

  const ThreeStepWidget({Key key, this.step}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(),),
       Column(children: [
         Row(children: [
           CircleAvatar(
           child: Icon(Icons.create,
             size: 15,
             color: step == 1 ? Colors.white : Colors.black,),
           radius: 10,
           backgroundColor:  step == 1 ? Colors.purpleAccent : Colors.grey,
         ),
           SizedBox(width: 10,),
           Text("details", style: TextStyle(fontSize: 14, color: step == 1 ? Colors.purpleAccent : Colors.grey),)
         ],),
         SizedBox(height: 10,),
         Container(width: 90, height: 2, color: step == 1 ? Colors.purpleAccent : Colors.grey,),
       ],),
        SizedBox(width: 5,),
        Column(children: [
          Row(children: [
            CircleAvatar(
              child: Icon(Icons.attach_money,
                size: 15,
                color: step == 2 ? Colors.white : Colors.black,),
              radius: 10,
              backgroundColor: step == 2 ? Colors.purpleAccent : Colors.grey,
            ),
            SizedBox(width: 10,),
            Text("payment", style: TextStyle(fontSize: 14, color: step == 2 ? Colors.purpleAccent : Colors.grey),)
          ],),
          SizedBox(height: 10,),
          Container(width: 90, height: 2, color: step == 2 ? Colors.purpleAccent : Colors.grey,),
        ],),
        SizedBox(width: 5,),
        Column(children: [
          Row(children: [
            CircleAvatar(
              child: Icon(Icons.done,
                size: 15,
                color: step == 3 ? Colors.white : Colors.black,),
              radius: 10,
              backgroundColor: step == 3 ? Colors.purpleAccent : Colors.grey,
            ),
            SizedBox(width: 10,),
            Text("review", style: TextStyle(fontSize: 14, color: step == 3 ? Colors.purpleAccent : Colors.grey),)
          ],),
          SizedBox(height: 10,),
          Container(width: 90, height: 2, color: step == 3 ? Colors.purpleAccent : Colors.grey,),
        ],),
        Expanded(child: Container(),),
      ],
    );
  }
}
