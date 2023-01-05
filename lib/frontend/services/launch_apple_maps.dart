import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

// launch google maps a

class MapUtils {

  MapUtils._();
  static Future<void> openMap(double latitude, double longitude, BuildContext context) async {
    final failSnackbar = SnackBar(content: Text('Error. Try Again.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);

    String urlAppleMaps = 'https://maps.apple.com/?q=$latitude,$longitude';
    try{
      if (await canLaunch(urlAppleMaps)) {
        await launch(urlAppleMaps);
      }
    } catch (e){
      print(e);
      Scaffold.of(context).showSnackBar(failSnackbar);
    }
  }
}