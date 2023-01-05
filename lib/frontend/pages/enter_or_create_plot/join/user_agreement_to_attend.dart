import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/create_plot.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/plot_preview.dart';



class UserAgreementToAttend extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final FirestorePlotData firestorePlotData;
  final String hostProfilePic;

  const UserAgreementToAttend({Key key, this.sharedPrefData, this.firestorePlotData, this.hostProfilePic}) : super(key: key);
  @override
  _UserAgreementToAttendState createState() => _UserAgreementToAttendState();
}

class _UserAgreementToAttendState extends State<UserAgreementToAttend> {



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DISCLAIMER", style: TextStyle(
                color: Colors.white,fontSize: 25,
                fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 5,),
            Text("The information provided by us on our mobile application \"plots - party with your homies\" is for general informational purposes only. All information on the Site and our mobile application is provided in good faith, however we make no representation or warranty of any kind, express or implied, regarding the accuracy, adequacy, validity, reliability, availability or completeness of any information on our Site or our mobile application. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF THE USE OF THE SITE OR OUR MOBILE APPLICATION OR RELIANCE ON ANY INFORMATION PROVIDED ON THE SITE AND OUR MOBILE APPLICATION. YOUR USE OF THE SITE AND OUR MOBILE APPLICATION AND YOUR RELIANCE ON ANY INFORMATION ON THE SITE AND OUR MOBILE APPLICATION IS SOLELY AT YOUR OWN RISK.", style: TextStyle(
              color: Colors.white,fontSize: 16,
            ),),
            SizedBox(height: 15,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RawMaterialButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  elevation: 2.0,
                  constraints: BoxConstraints(minWidth: 75, minHeight: 40),
                  fillColor: Color(0xff630094),
                  child: Text('decline', style: TextStyle(
                      fontSize: 16,
                      color: Colors.white
                  ),),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                ),
                SizedBox(width: 10,),
                RawMaterialButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context) => PlotPreview(
                          plotData: widget.firestorePlotData,
                          sharedPrefData: widget.sharedPrefData,
                          hostProfilePic: widget.hostProfilePic,
                        )
                    ));
                  },
                  elevation: 2.0,
                  constraints: BoxConstraints(minWidth: 75, minHeight: 40),
                  fillColor: Color(0xff630094),
                  child: Text('accept', style: TextStyle(
                      fontSize: 16,
                      color: Colors.white
                  ),),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                ),

              ],)


          ],
        ),
      ),
    );
  }
}
