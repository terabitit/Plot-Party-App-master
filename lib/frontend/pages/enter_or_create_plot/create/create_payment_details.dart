import 'dart:io';
import 'dart:typed_data';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/review_information.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/three_step_widget.dart';

class CreatePaymentDetails extends StatefulWidget {
  final String plotName;
  final SharedPrefData sharedPrefData;
  final String plotDescription;
  final String plotAddress;
  final ui.Image signature;
  final double latitude;
  final double longitude;
  final DateTime startDate;
  final String plotPrivacy;
  final String hostName;
  final String contactDetails;
  final File plotImage;

  const CreatePaymentDetails({Key key, this.plotName, this.signature, this.sharedPrefData, this.plotDescription, this.plotAddress, this.latitude, this.longitude, this.startDate, this.plotPrivacy, this.hostName, this.contactDetails, this.plotImage}) : super(key: key);


  @override
  _CreatePaymentDetailsState createState() => _CreatePaymentDetailsState();
}

class _CreatePaymentDetailsState extends State<CreatePaymentDetails> {
  final _createPaymentDetailsFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  bool canBid = false;
  int minimumBidPrice;
  bool free = false;

  // For ticket Prices, change price up there to minimum bidding price
  String ticketLevel1 = "General Admission";
  String ticketLevel2;
  String ticketLevel3;
  String ticketLevel4;
  String ticketLevel5;
  int ticketPrice1;
  int ticketPrice2;
  int ticketPrice3;
  int ticketPrice4;
  int ticketPrice5;
  int numberOfLevels = 1;

  //for money
  bool payAtDoor = true;
  String payAtDoorDetails = '';

  bool allowVenmo = false;
  bool allowZelle = false;
  bool allowCashapp = false;
  bool allowPayPal = false;
  bool allowOther1 = false;
  bool allowOther2 = false;
  String venmo;
  String zelle;
  String cashApp;
  String paypal;
  String otherPaymentMethod1;
  String otherPaymentMethod2;

  String errorMessage;


  Map makePaymentInfoObject (List paymentMethods, List paymentHandles){
    Map<String, String> paymentInfoObject = {};
    List paymentGateways = ['Venmo', 'Zelle', 'PayPal','Cash App', 'Other1', 'Other2', 'Pay at Door'];
    for (var i = 0; i< paymentMethods.length; i++){
      if (paymentMethods[i]) {
        paymentInfoObject[paymentGateways[i]] = paymentHandles[i];
      }
    }
    return paymentInfoObject;
  }

  Map makeTicketInfoObject (List ticketLevels, List ticketPrices){
    Map<String, int> ticketInfoObject = {};
    for (var i =0; i < numberOfLevels; i++){
      ticketInfoObject[ticketLevels[i]]= ticketPrices[i];
    }
    return ticketInfoObject;
  }


  String validateField(String value) {
    if (value == null || value.isEmpty) {
      return "missing field";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: ThreeStepWidget(step: 2,),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _createPaymentDetailsFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("NOTE: the guests will not be paying you directly through the app, but will be using the third party payment methods to pay you.", style: TextStyle(
                color: Colors.grey,fontSize: 14
              ),),
              Row(
                children: [
                  Text(
                    "free",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Transform.scale(
                    scale: 1.3,
                    child: Switch(
                      onChanged: (bool value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          free = value;
                          canBid = false;
                          allowOther1 = false;
                          allowPayPal = false;
                          allowVenmo = false;
                          allowCashapp = false;
                          allowZelle = false;
                          allowOther2 = false;
                          payAtDoor = false;
                        });
                      },
                      value: free,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.purple,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    "enable bidding",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:free ? Colors.grey : Colors.white),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Transform.scale(
                    scale: 1.3,
                    child: Switch(
                      onChanged: (bool value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          canBid = value;
                        });
                        if (free == true) {
                          setState(() {
                            free = false;
                          });
                        }
                      },
                      value: canBid,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.purple,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                    ),
                  ),
                ],
              ),
              canBid ? SizedBox(height: 10,) : Container(),
              Opacity(
                opacity: free ? 0.5 : 1,
                child: Column(children: [
                canBid ?
                  TextFormField(
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) => minimumBidPrice = int.parse(value),
                      autocorrect: false,
                      validator: (value) => validateField(value.toString()),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: 'minimum bid price',
                        hintStyle: TextStyle(
                            color: Colors.grey
                        ),
                        errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        hoverColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        border: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5)))),
                  )
                    : Container(),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("payment methods",textAlign: TextAlign.left, style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: free ? Colors.grey : Colors.white
                  ),),),
                SizedBox(height: 5,),
                Text("provide the handle if using one of the following peer to peer payment systems", style: TextStyle(
                    fontSize: 16,
                    color:free ? Colors.grey : Colors.white
                ),),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: allowVenmo ? Colors.purpleAccent: Colors.black, width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(15))
                          ),
                          child: InkWell(
                           borderRadius: BorderRadius.all(Radius.circular(15)),
                            overlayColor: MaterialStateProperty.all(Colors.white),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                allowVenmo = !allowVenmo;
                              });
                              if (free == true) {
                                setState(() {
                                  free = false;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.only(left:10, top: 10, right: 10, bottom: 10,),
                              child:Column(
                                mainAxisSize: MainAxisSize.min,
                                      children: [
                            Container(
                            padding: EdgeInsets.all(7),
                            constraints: BoxConstraints(
                            maxHeight: 55,
                            minWidth: 55,
                            maxWidth: 55,
                            minHeight: 55,
                            ),
                            child:
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/images/Venmo-Logo.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )),
                                Text("Venmo", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                                        SizedBox(height: 10,),
                              ],),
                            ),

                          ),
                        ),
                        Align(
                            alignment: Alignment.topRight,
                            child: allowVenmo ? CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.purpleAccent,
                              child: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.purpleAccent,
                                  child:Icon(Icons.check, color: Colors.black, size: 15,)),) : Container()
                        )
                      ],),
                    Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: allowZelle ? Colors.purpleAccent: Colors.black, width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(15))
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            overlayColor: MaterialStateProperty.all(Colors.white),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                allowZelle = !allowZelle;
                              });
                              if (free == true) {
                                setState(() {
                                  free = false;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.only(left:10, top: 10, right: 10, bottom: 10,),
                              child:Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(7),
                                      constraints: BoxConstraints(
                                        maxHeight: 55,
                                        minWidth: 55,
                                        maxWidth: 55,
                                        minHeight: 55,
                                      ),
                                      child:
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/images/Zelle-Logo.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )),
                                  Text("Zelle", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 10,),
                                ],),
                            ),

                          ),
                        ),
                        Align(
                            alignment: Alignment.topRight,
                            child: allowZelle ? CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.purpleAccent,
                              child: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.purpleAccent,
                                  child:Icon(Icons.check, color: Colors.black, size: 15,)),) : Container()
                        )
                      ],),
                    Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: allowCashapp ? Colors.purpleAccent: Colors.black, width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(15))
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            overlayColor: MaterialStateProperty.all(Colors.white),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                allowCashapp = !allowCashapp;
                              });
                              if (free == true) {
                                setState(() {
                                  free = false;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.only(left:10, top: 10, right: 10, bottom: 10,),
                              child:Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(7),
                                      constraints: BoxConstraints(
                                        maxHeight: 55,
                                        minWidth: 55,
                                        maxWidth: 55,
                                        minHeight: 55,
                                      ),
                                      child:
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/images/Cash App-Logo.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )),
                                  Text("Cash App", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 10,),
                                ],),
                            ),

                          ),
                        ),
                        Align(
                            alignment: Alignment.topRight,
                            child: allowCashapp ? CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.purpleAccent,
                              child: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.purpleAccent,
                                  child:Icon(Icons.check, color: Colors.black, size: 15,)),) : Container()
                        )
                      ],),
                    Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: allowPayPal ? Colors.purpleAccent: Colors.black, width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(15))
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            overlayColor: MaterialStateProperty.all(Colors.white),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                allowPayPal = !allowPayPal;
                              });
                              if (free == true) {
                                setState(() {
                                  free = false;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.only(left:10, top: 10, right: 10, bottom: 10,),
                              child:Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(7),
                                      constraints: BoxConstraints(
                                        maxHeight: 55,
                                        minWidth: 55,
                                        maxWidth: 55,
                                        minHeight: 55,
                                      ),
                                      child:
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/images/PayPal-Logo.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )),
                                  Text("PayPal", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 10,),
                                ],),
                            ),

                          ),
                        ),
                        Align(
                            alignment: Alignment.topRight,
                            child: allowPayPal ? CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.purpleAccent,
                              child: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.purpleAccent,
                                  child:Icon(Icons.check, color: Colors.black, size: 15,)),) : Container()
                        )
                      ],),
                  ],),
                allowVenmo ?
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child:TextFormField(
                      validator: (value) => validateField(value.toString()),
                      onChanged: (value) => venmo = value,
                      autocorrect: false,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: 'Venmo',
                        hintText: '@James-Han-55',
                        hintStyle: TextStyle(
                            color: Colors.grey
                        ),
                        errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        hoverColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        border: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5)))),
                  ), ) : Container(),
                allowZelle ?
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child:TextFormField(
                      style: TextStyle(color: Colors.white),
                      validator: (value) => validateField(value.toString()),
                      onChanged: (value) => zelle = value,
                      autocorrect: false,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: 'Zelle',
                        hintText: '###########',
                        hintStyle: TextStyle(
                            color: Colors.grey
                        ),
                        errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        hoverColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        border: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5)))),
                  ), ) : Container(),
                allowCashapp ?
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child:TextFormField(
                      style: TextStyle(color: Colors.white),
                      validator: (value) => validateField(value.toString()),
                      onChanged: (value) => cashApp = value,
                      autocorrect: false,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: 'Cash App',
                        hintText: '###########',
                        hintStyle: TextStyle(
                            color: Colors.grey
                        ),
                        errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        hoverColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        border: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5)))),
                  ), ) : Container(),
                allowPayPal ?
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child:TextFormField(
                      style: TextStyle(color: Colors.white),
                      validator: (value) => validateField(value.toString()),
                      onChanged: (value) => paypal = value,
                      autocorrect: false,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: 'PayPal',
                        hintText: '###########',
                        hintStyle: TextStyle(
                            color: Colors.grey
                        ),
                        errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        hoverColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        border: OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.transparent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5)))),), ) : Container(),
          SizedBox(height: 10,),
                Row(
                  children: [
                    Text(
                      "pay at door",
                      style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Transform.scale(
                      scale: 1.4,
                      child: Switch(
                        onChanged: (bool value) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            payAtDoor = value;
                          });
                          if (free == true) {
                            setState(() {
                              free = false;
                            });
                          }
                        },
                        value: payAtDoor,

                        activeColor: Colors.white,
                        activeTrackColor: Colors.purple,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                payAtDoor ? TextFormField(
                    style: TextStyle(color: Colors.white),

                    onChanged: (value) => payAtDoorDetails = value,
                      autocorrect: false,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      maxLines: null,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'details',
                      hintText: 'only accepting cash at door',
                      hintStyle: TextStyle(
                          color: Colors.grey
                      ),
                      errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      hoverColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5))),
                      border: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)))),
                )
                 : Container(),
                payAtDoor ? SizedBox(height: 10,): Container(),
                Text("you can add up to two custom payment methods", style: TextStyle(
                    fontSize: 16,
                    color: Colors.white
                ),),
                SizedBox(height: 10,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "custom 1",
                      style: TextStyle(fontSize: 24),
                    ),
                    Transform.scale(
                      scale: 1.4,
                      child: Switch(
                        onChanged: (bool value) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            allowOther1 = value;
                          });
                          if (free == true) {
                            setState(() {
                              free = false;
                            });
                          }
                        },
                        value: allowOther1,

                        activeColor: Colors.white,
                        activeTrackColor: Colors.purple,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                    Text(
                      "custom 2",
                      style: TextStyle(fontSize: 24),
                    ),
                    Transform.scale(
                      scale: 1.4,
                      child: Switch(
                        onChanged: (bool value) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            allowOther2 = value;
                          });
                          if (free == true) {
                            setState(() {
                              free = false;
                            });
                          }
                        },
                        value: allowOther2,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.purple,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
                allowOther1 ?
                TextFormField(
                    style: TextStyle(color: Colors.white),

                    onChanged: (value) => otherPaymentMethod1 = value,
                      autocorrect: false,
                      maxLines: null,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      validator: (value) => validateField(value.toString()),
                  cursorColor: Colors.white,
                  decoration:
                  InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'custom payment method 1',
                      hintText: 'a kiss',
                      hintStyle: TextStyle(
                          color: Colors.grey
                      ),
                      errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      hoverColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5))),
                      border: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)))),
                ) : Container(),
                allowOther1? SizedBox(height: 10,): Container(),
                allowOther2 ?
                TextFormField(
                    style: TextStyle(color: Colors.white),

                    onChanged: (value) => otherPaymentMethod2 = value,
                      autocorrect: false,
                      maxLines: null,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      validator: (value) => validateField(value.toString()),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'custom payment method 2',
                      hintText: 'apple pay',
                      hintStyle: TextStyle(
                          color: Colors.grey
                      ),
                      errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      hoverColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5))),
                      border: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)))),
                ) : Container(),
                Divider(thickness: 2,),
                free ? Container() : Column(children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("set up guest statuses and ticket pricing",textAlign: TextAlign.left, style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),),),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("you can add up to 5 statuses",textAlign: TextAlign.left, style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                    ),),),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(child: Container(),),
                      RawMaterialButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInOut
                          );
                          if (numberOfLevels != 5) {
                            setState(() {
                              numberOfLevels += 1;
                            });
                          }
                        },
                        elevation: 2.0,
                        fillColor: Colors.purple,
                        child: Icon(
                          Icons.add,
                          size: 15.0,
                        ),
                        padding: EdgeInsets.all(5.0),
                        shape: CircleBorder(),
                      ),
                      Text(numberOfLevels.toString(), style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),),
                      RawMaterialButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (numberOfLevels != 1) {
                            setState(() {
                              numberOfLevels -= 1;
                            });
                          }
                        },
                        elevation: 2.0,
                        fillColor: Colors.purple,
                        child: Icon(
                          Icons.remove,
                          size: 15.0,
                        ),
                        padding: EdgeInsets.all(5.0),
                        shape: CircleBorder(),
                      ),
                      Expanded(child: Container(),),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Ticket(
                        radius: 8.0,
                        clipShadows: [ClipShadow(color: Colors.black)],
                        child:
                        Container(
                            width: 30,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.purpleAccent
                            ),
                            padding: EdgeInsets.all(2),
                            child:
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 2,
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.white)
                              ),
                            )
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        width: 210,
                        child: TextFormField(
                            maxLines: null,
                            onChanged: (value) => ticketLevel1 = value,
                            autocorrect: false,
                            initialValue: "general admission",
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: 'status 1',
                              hintText: 'general admission',
                              hintStyle: TextStyle(
                                  color: Colors.grey
                              ),
                              errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              hoverColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              border: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5)))),

                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width :80,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            onChanged: (value) => ticketPrice1 = int.parse(value),
                            autocorrect: false,
                            validator: (value) => validateField(value.toString()),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: '\$',
                              errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              hoverColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              border: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5)))),
                        ),
                      ),
                    ],
                  ),
                  numberOfLevels >= 2
                      ?SizedBox(height: 20,): Container(),
                  numberOfLevels >= 2
                      ? Row(
                    children: [
                      Ticket(
                        radius: 8.0,
                        clipShadows: [ClipShadow(color: Colors.black)],
                        child:
                        Container(
                            width: 30,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.purpleAccent
                            ),
                            padding: EdgeInsets.all(2),
                            child:
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 2,
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.white)
                              ),
                            )
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        width: 210,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            maxLines: null,
                            validator: (value) => validateField(value.toString()),
                            onChanged: (value) => ticketLevel2 = value,
                            autocorrect: false,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.black,
                                labelStyle: TextStyle(color: Colors.white),
                                labelText: "status 2",
                                hintText: "VIP 2",
                                hintStyle: TextStyle(
                                  color: Colors.grey
                                ),
                                errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                                border: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))))
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 80,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            onChanged: (value) => ticketPrice2 = int.parse(value),
                            autocorrect: false,
                            validator: (value) => validateField(value.toString()),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: '\$',
                              errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              hoverColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              border: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5)))),
                        ),
                      ),
                    ],
                  )
                      : Container(),
                  numberOfLevels >= 3
                      ?SizedBox(height: 20,): Container(),
                  numberOfLevels >= 3
                      ? Row(
                    children: [
                      Ticket(
                        radius: 8.0,
                        clipShadows: [ClipShadow(color: Colors.black)],
                        child:
                        Container(
                            width: 30,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.purpleAccent
                            ),
                            padding: EdgeInsets.all(2),
                            child:
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 2,
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.white)
                              ),
                            )
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        width: 210,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            maxLines: null,
                            validator: (value) => validateField(value.toString()),
                            onChanged: (value) => ticketLevel3 = value,
                            autocorrect: false,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.black,
                                labelStyle: TextStyle(color: Colors.white),
                                labelText: "status 3",
                                hintText: "VIP 3",
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                                border: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))))
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 80,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            onChanged: (value) =>
                            ticketPrice3 = int.parse(value),
                            autocorrect: false,
                            validator: (value) => validateField(value.toString()),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: '\$',
                              errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              hoverColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              border: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5)))),
                        ),
                      ),
                    ],
                  )
                      : Container(),
                  numberOfLevels >= 4
                      ?SizedBox(height: 20,): Container(),
                  numberOfLevels >= 4
                      ? Row(
                    children: [
                      Ticket(
                        radius: 8.0,
                        clipShadows: [ClipShadow(color: Colors.black)],
                        child:
                        Container(
                            width: 30,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.purpleAccent
                            ),
                            padding: EdgeInsets.all(2),
                            child:
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 2,
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.white)
                              ),
                            )
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        width: 210,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            maxLines: null,
                            validator: (value) => validateField(value.toString()),
                            onChanged: (value) => ticketLevel4 = value,
                            autocorrect: false,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.black,
                                labelStyle: TextStyle(color: Colors.white),
                                labelText: "status 4",
                                hintText: "VIP 4",
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                                border: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))))
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 80,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            onChanged: (value) =>
                            ticketPrice4 = int.parse(value),
                            validator: (value) => validateField(value.toString()),
                            autocorrect: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: '\$',
                              errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              hoverColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              border: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5)))),
                        ),
                      ),
                    ],
                  )
                      : Container(),
                  numberOfLevels >= 5
                      ?SizedBox(height: 20,): Container(),
                  numberOfLevels >= 5
                      ? Row(
                    children: [
                      Ticket(
                        radius: 8.0,
                        clipShadows: [ClipShadow(color: Colors.black)],
                        child:
                        Container(
                            width: 30,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.purpleAccent
                            ),
                            padding: EdgeInsets.all(2),
                            child:
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 2,
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.white)
                              ),
                            )
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        width: 210,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            validator: (value) => validateField(value.toString()),
                            maxLines: null,
                            onChanged: (value) => ticketLevel5 = value,
                            autocorrect: false,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.black,
                                labelStyle: TextStyle(color: Colors.white),
                                labelText: "status 5",
                                hintText: "VIP 5",
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                                border: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.transparent),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5))))),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 80,
                        child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            onChanged: (value) =>
                            ticketPrice5 = int.parse(value),
                            autocorrect: false,
                            validator: (value) => validateField(value.toString()),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: '\$',
                              errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              hoverColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                              border: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.transparent),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5)))),
                        ),
                      ),
                    ],
                  )
                      : Container(),
                ],)
              ],),
              ),
              SizedBox(
                height: 10,
              ),
              errorMessage == null
                  ? Container()
                  : Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              RawMaterialButton(
                onPressed: () async {
                  List<bool> paymentMethods = [allowVenmo, allowZelle, allowPayPal, allowCashapp, allowOther1, allowOther2, payAtDoor];
                  List<String> paymentHandles = [venmo, zelle, paypal,cashApp, otherPaymentMethod1, otherPaymentMethod2, payAtDoorDetails];
                  List<String> ticketLevels = [ticketLevel1, ticketLevel2, ticketLevel3, ticketLevel4, ticketLevel5];
                  List<int> ticketPrices = [ticketPrice1, ticketPrice2, ticketPrice3, ticketPrice4, ticketPrice5];
                  bool onePaymentSelected = false;
                  for (var method in paymentMethods){
                    if (method){
                      onePaymentSelected = true;
                    }
                  }
                  if (free) {
                    onePaymentSelected = true;
                  }
                  if (_createPaymentDetailsFormKey.currentState.validate() && onePaymentSelected) {
                    Map paymentInfoObject = makePaymentInfoObject(paymentMethods, paymentHandles);
                    Map ticketInfoObject = makeTicketInfoObject(ticketLevels, ticketPrices);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context) => ReviewInformation(
                          plotAddress: widget.plotAddress,
                          plotName: widget.plotName,
                          hostName: widget.hostName,
                          contactDetails: widget.contactDetails,
                          plotDescription: widget.plotDescription,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                          startDate: widget.startDate,
                          sharedPrefData: widget.sharedPrefData,
                          plotPrivacy: widget.plotPrivacy,
                          plotImage: widget.plotImage,
                          free: free,
                          signature: widget.signature,
                          minimumBidPrice: minimumBidPrice,
                          canBid: canBid,
                          ticketLevelsAndPrices: ticketInfoObject,
                          paymentMethods: paymentInfoObject,
                        )
                    ));
                  } else {
                    setState(() {
                      errorMessage = 'you must provide at least one payment method';
                    });
                  }
                },
                elevation: 2.0,
                constraints: BoxConstraints(minWidth: 130, minHeight: 40),
                fillColor: Colors.purple,
                child: Text("next", style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                ),),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
