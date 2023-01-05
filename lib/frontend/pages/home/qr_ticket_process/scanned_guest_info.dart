import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/qr_ticket_process/qr_scanner.dart';
import 'package:plots/frontend/pages/static_pages/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannedGuestInfo extends StatefulWidget {
  final String qrCode;
  final SharedPrefData sharedPrefData;

  const ScannedGuestInfo({Key key, this.qrCode, this.sharedPrefData}) : super(key: key);

  @override
  _ScannedGuestInfoState createState() => _ScannedGuestInfoState();
}

class _ScannedGuestInfoState extends State<ScannedGuestInfo> {
  Future<GuestInfoObject> guestInfoObject;
  bool paid;
  final failSnackbar = SnackBar(content: Text('unable to open instagram.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    guestInfoObject = getInformation();
  }


  Future<GuestInfoObject> getInformation() async {
    FirestoreFunctions firestoreFunctions = FirestoreFunctions();
    GuestInfoObject guestInfoObject = await firestoreFunctions.makeGuestObjectFromAuthID(widget.sharedPrefData.plotCode, widget.qrCode);
    return guestInfoObject;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: FutureBuilder(
                future: guestInfoObject,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done){
                    GuestInfoObject guestInfoObject = snapshot.data;
                    return snapshot.data != null ? Column(
                      children: [
                        Row(children: [
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white,),
                              onPressed: ()async{
                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.leftToRight,
                                    child: QRScanner(
                                      sharedPrefData: widget.sharedPrefData,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text("tap profile picture to enlarge",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12
                              ),),
                          ),
                          Expanded(child: Container(), flex: 1,)
                        ],),

                        SizedBox(height: 10,),
                        GestureDetector(
                            onTap: (){
                              showDialog(context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.all(10),
                                        child: GestureDetector(
                                          onTap: (){
                                            Navigator.pop(context);
                                          },
                                          child:
                                          InteractiveViewer(
                                            panEnabled: false, // Set it to false
                                            boundaryMargin: EdgeInsets.all(100),
                                            minScale: 0.5,
                                            maxScale: 2,
                                            child:  CachedNetworkImage(
                                              imageUrl: guestInfoObject.profilePicURL,
                                              imageBuilder: (context, imageProvider) => Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(25)
                                                  ),
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) => Container(
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                    strokeWidth: 4.0
                                                ),
                                                height: 50.0,
                                                width: 50.0,
                                              ),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                        )
                                    );
                                  }
                              );
                            },
                            child:Container(
                                constraints: BoxConstraints(
                                    maxHeight: 150,
                                    minWidth: 150,
                                    maxWidth: 150,
                                    minHeight: 150
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: guestInfoObject.profilePicURL,
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle
                                    ),
                                    constraints: BoxConstraints(
                                        maxHeight: 150,
                                        minWidth: 150,
                                        maxWidth: 150,
                                        minHeight: 150
                                    ),
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                        strokeWidth: 4.0
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                )
                            )),
                        SizedBox(height: 10,),
                        Row(children: [
                          Expanded(child: Container(),),
                          Column(children: [
                            Container(
                              width: 250,
                              child:
                              Text(guestInfoObject.username,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white
                                ),),
                            ),

                            Container(
                              width: 250,
                              child: Text(guestInfoObject.status,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey
                                ),),
                            ),
                          ],),
                          Expanded(child: Container(),),
                        ],),
                        SizedBox(height: 10,),
                        Row(children: [
                          Expanded(child: Container(),),
                          Container(
                            child: Column(
                              children: [
                                Text(guestInfoObject.plusOnes, style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.purpleAccent
                                ),),
                                Text('plus ones', style: TextStyle(fontSize: 20, color: Colors.grey),)
                              ],
                            ),
                          ),
                          Expanded(child: Container(),),
                          Container(
                              child: Column(
                                children: [
                                  Text("\$${guestInfoObject.price.toString()}", style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.green
                                  ),),
                                  Text('price', style: TextStyle(fontSize: 20, color: Colors.grey),)
                                ],
                              )
                          ),
                          Expanded(child: Container(),),
                        ],),
                        SizedBox(height: 5,),
                        Container(
                          child:  Text("tap on sections for more", textAlign: TextAlign.left, style: TextStyle(
                              color: Colors.grey
                          ),),
                          padding: EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                        ),
                        SizedBox(height: 5,),
                        GestureDetector(
                          onTap: ()async{
                            var url = 'https://www.instagram.com/${guestInfoObject.instaUsername}/';
                            if (await canLaunch(url)) {
                              await launch(
                                url,
                                universalLinksOnly: true,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
                            }
                          },
                          child: Container(
                            width:350,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.green,
                                      Colors.blue
                                    ]
                                )
                            ),
                            child: Row(children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  constraints: BoxConstraints(
                                    maxHeight: 45,
                                    minWidth: 45,
                                    maxWidth: 45,
                                    minHeight: 45,
                                  ),
                                  child:
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/Instagram-Logo.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                              Text("instagram username", style: TextStyle(fontSize: 16, color: Colors.white),),
                              Expanded(child: Container(),),
                              Container(
                                width: 100,
                                child: Text(
                                  guestInfoObject.instaUsername,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,),
                                ),
                              ),
                            ],),
                          ),
                        ),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: (){
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                backgroundColor: Color(0xff1e1e1e),
                                title: Text("payment method", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                content:  Text(guestInfoObject.paymentMethod, style: TextStyle(color: Colors.white),),
                                actions: [
                                  IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                                    Navigator.pop(context);
                                  })
                                ],
                              );
                            });
                          },
                          child: Container(
                            width:350,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: Colors.black
                            ),
                            child: Row(children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  constraints: BoxConstraints(
                                    maxHeight: 45,
                                    minWidth: 45,
                                    maxWidth: 45,
                                    minHeight: 45,
                                  ),
                                  child:Icon(Icons.payment, color: Colors.white,)
                              ),
                              Text("payment method", style: TextStyle(fontSize: 16, color: Colors.white),),
                              Expanded(child: Container(),),
                              Container(
                                width: 100,
                                child: Text(
                                  guestInfoObject.paymentMethod,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,),
                                ),
                              ),
                              SizedBox(width: 5,)
                            ],),
                          ),
                        ),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: (){
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                backgroundColor: Color(0xff1e1e1e),
                                title: Text("payment details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                content:  Text(guestInfoObject.paymentDetails, style: TextStyle(color: Colors.white),),
                                actions: [
                                  IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                                    Navigator.pop(context);
                                  })
                                ],
                              );
                            });
                          },
                          child: Container(
                            width:350,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: Colors.black
                            ),
                            child: Row(children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  constraints: BoxConstraints(
                                    maxHeight: 45,
                                    minWidth: 45,
                                    maxWidth: 45,
                                    minHeight: 45,
                                  ),
                                  child:Icon(Icons.info, color: Colors.white,)
                              ),
                              Text("payment details", style: TextStyle(fontSize: 16, color: Colors.white),),
                              Expanded(child: Container(),),
                              Container(
                                width: 100,
                                child: Text(
                                  guestInfoObject.paymentDetails,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,),
                                ),
                              ),
                              SizedBox(width: 5,)
                            ],),
                          ),
                        ),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: (){
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                backgroundColor: Color(0xff1e1e1e),
                                title: Text("note to host", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                content:  Text(guestInfoObject.noteToHost, style: TextStyle(color: Colors.white),),
                                actions: [
                                  IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                                    Navigator.pop(context);
                                  })
                                ],
                              );
                            });
                          },
                          child: Container(
                            width:350,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: Colors.black
                            ),
                            child: Row(children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  constraints: BoxConstraints(
                                    maxHeight: 45,
                                    minWidth: 45,
                                    maxWidth: 45,
                                    minHeight: 45,
                                  ),
                                  child:Icon(Icons.sticky_note_2_rounded, color: Colors.white,)
                              ),
                              Text("note to host", style: TextStyle(fontSize: 16, color: Colors.white),),
                              Expanded(child: Container(),),
                              Container(
                                width: 100,
                                child: Text(
                                  guestInfoObject.noteToHost,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,),
                                ),
                              ),
                              SizedBox(width: 5,)
                            ],),
                          ),
                        ),
                        SizedBox(height: 10,),
                        paid == null ? guestInfoObject.paid ? Text('paid and ready to party!', style: TextStyle(
                            fontSize: 20,
                            color: Colors.green
                        ),) : Text('not paid yet', style: TextStyle(
                            fontSize: 20,
                            color: Colors.red
                        ),) : paid ? Text('paid and ready to party!', style: TextStyle(
                            fontSize: 20,
                            color: Colors.green
                        ),) : Text('not paid yet', style: TextStyle(
                            fontSize: 20,
                            color: Colors.red
                        ),),
                        SizedBox(height: 10,),
                        ButtonTheme(
                          shape: StadiumBorder(),
                          minWidth: 300,
                          height: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xff630094),
                                elevation: 8
                            ),
                            child: Container(
                              width: 300,
                              padding: EdgeInsets.all(16),
                              child:
                              Text(
                                'update payment status',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                            onPressed: (){
                              showDialog(context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Color(0xff1e1e1e),
                                      title: Text('set the payment status for ${guestInfoObject.username}.'
                                          '\nhave you received \$${guestInfoObject.price}?', style: TextStyle(
                                          color: Colors.white
                                      ),),
                                      actions: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.white,),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(onPressed: (){
                                          FirestoreFunctions firestorefunctions = FirestoreFunctions();
                                          firestorefunctions.updateGuestInfo(plotCode: widget.sharedPrefData.plotCode,
                                              authID: guestInfoObject.authID,
                                              field: 'paid',
                                              newValue: true
                                          );
                                          setState(() {
                                            paid = true;
                                          });
                                          Navigator.pop(context);

                                        }, child: Text("paid", style: TextStyle(
                                            color: Colors.green
                                        ),)),
                                        TextButton(onPressed: (){
                                          FirestoreFunctions firestorefunctions = FirestoreFunctions();
                                          firestorefunctions.updateGuestInfo(plotCode: widget.sharedPrefData.plotCode,
                                              authID: guestInfoObject.authID,
                                              field: 'paid',
                                              newValue: false
                                          );
                                          setState(() {
                                            paid = false;
                                          });
                                          Navigator.pop(context);
                                        }, child: Text("not paid", style: TextStyle(
                                            color: Colors.red
                                        ),)),
                                      ],
                                    );
                                  }
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 25,),
                      ],
                    ) : Center(
                  child: Text("Code not found on guest list."),
                  );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                          strokeWidth: 4.0
                      ),
                    );
                  }
                })
        ),
      ),
    );
  }
}
