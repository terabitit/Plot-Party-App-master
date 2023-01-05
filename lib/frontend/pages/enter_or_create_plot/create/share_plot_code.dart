import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_host.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:flutter/services.dart';

// A page where the plot Code appears and one can copy the button
class SharePlotCode extends StatelessWidget {
  final String plotCode;

  const SharePlotCode({Key key, this.plotCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final snackBar = SnackBar(content: Text('code copied to clipboard'));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('plot code'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: ()async{
            SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
            SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
            bool isFirstTimeHost = await sharedPrefsServices.isFirstTimeHost();
            if (isFirstTimeHost){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (BuildContext context) => IntroScreensHost(sharedPrefData: sharedPrefData,)
              ), (route) => false);
            } else {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (BuildContext context) => Home(initialTabIndex: 0, sharedPrefData: sharedPrefData,)
              ), (route) => false);
            }

          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child:  Text('your plot has been created.\ncopy and share this code with your friends.',
              textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.white
            ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(plotCode, style: TextStyle(
                  fontSize: 32,
                )),
                IconButton(
                    icon: Icon(Icons.copy, color: Colors.white,),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: plotCode))
                          .then((value) { //only if ->
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      );
                    }
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
}
