import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Guest Ticket

class GuestQRCode extends StatelessWidget {
  final SharedPrefData sharedPrefData;

  const GuestQRCode({Key key, this.sharedPrefData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("your ticket"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: MediaQuery.of(context).size.width,height: 150,),
          Ticket(
              clipShadows: [ClipShadow(color: Colors.black)],
              radius: 50,child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xffB53D3D),
                    Color(0xff630094)
                  ]
              )
            ),
    padding: EdgeInsets.only(top: 75, bottom: 75, right: 30, left: 30),
    child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(25))
            ),
            child:
            QrImage(
              data: sharedPrefData.authID,
              version: QrVersions.auto,
              foregroundColor: Colors.purpleAccent,
              size: 250,
            ),
          ),
            )
          ),
        ],
      ),
    );
  }
}
