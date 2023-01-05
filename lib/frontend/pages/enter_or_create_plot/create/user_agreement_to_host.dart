import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/create_plot.dart';
import 'package:plots/frontend/pages/home/map_page/third_party_plot_modal/create_third_party_plot.dart';
import 'package:signature/signature.dart';



class UserAgreementToHost extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final bool createActual;

  const UserAgreementToHost({Key key, this.sharedPrefData, this.createActual}) : super(key: key);
  @override
  _UserAgreementToHostState createState() => _UserAgreementToHostState();
}

class _UserAgreementToHostState extends State<UserAgreementToHost> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );


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
            Text("your signature here", style: TextStyle(
                color: Colors.white,fontSize: 16,
                fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 5,),
            Row(children: [
              Signature(
                controller: _signatureController,
                width: MediaQuery.of(context).size.width - 100,
                height: 100,
                backgroundColor: Colors.white,
              ),
              SizedBox(width: 5,),
              IconButton(
                icon: Icon(Icons.clear,color: Colors.white,),
                onPressed: (){
                  _signatureController.clear();
                },
              )
            ],),
            SizedBox(height: 5,),
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
                  onPressed: ()async{
                    if(_signatureController.isNotEmpty){
                       ui.Image signatureData = await _signatureController.toImage();
                       var signatureDataPNG = await _signatureController.toPngBytes();
                       ByteData data = await signatureData.toByteData();
                       Uint8List listData = data.buffer.asUint8List();
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          backgroundColor: Color(0xff1e1e1e),
                          title: Text("are you sure you read everything and agree to all conditions?\n", style: TextStyle(
                              color: Colors.white
                          ),),
                          content:Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("confirm signature", style: TextStyle(
                                  color: Colors.white,
                                fontSize: 12
                              ),),
                              Container(
                                height: 100,
                                width: 500,
                                color: Colors.white,
                                child: Image.memory(signatureDataPNG),
                              ),
                            ],
                          ) ,
                          actions: [
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white,),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(child: Text("agree", style: TextStyle(
                              color: Colors.blue,
                            ),),
                              onPressed: ()async{
                              if(widget.createActual){
                                if (listData != null) {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => CreatePlot(
                                            signature: signatureData,
                                            sharedPrefData: widget.sharedPrefData,
                                          )
                                      ));
                                }else {
                                  Navigator.pop(context);
                                }
                              } else {
                                if (listData != null) {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => CreateThirdPartyPlot(
                                            signature: signatureData,
                                            sharedPrefData: widget.sharedPrefData,
                                          )
                                      ));
                                }else {
                                  Navigator.pop(context);
                                }
                              }
                              },
                            )
                          ],
                        );
                      });
                    }else {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          backgroundColor: Color(0xff1e1e1e),
                          title: Text("your signature can not be empty.", style: TextStyle(
                              color: Colors.white
                          ),),
                          actions: [
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white,),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                    }
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
