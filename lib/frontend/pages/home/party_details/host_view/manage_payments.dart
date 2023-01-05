import 'dart:io';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/review_information.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/three_step_widget.dart';
import 'package:plots/frontend/pages/home/home.dart';

class ManagePayments extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final FirestorePlotData plotData;
  final int numberOfTicketLevels;

  const ManagePayments({Key key, this.sharedPrefData, this.plotData, this.numberOfTicketLevels}) : super(key: key);

  @override
  _ManagePaymentsState createState() => _ManagePaymentsState();
}

class _ManagePaymentsState extends State<ManagePayments> {
  final _editPaymentDetailsFormKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final failSnackbar = SnackBar(content: Text('error. try again.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);
  final successSnackbar = SnackBar(content: Text('success!', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,);
  final ScrollController _scrollController = ScrollController();


  bool canBid = false;
  int minimumBidPrice;
  bool free = false;

  // For ticket Prices, change price up there to minimum bidding price
  String ticketLevel1 = "general admission";
  String ticketLevel2;
  String ticketLevel3;
  String ticketLevel4;
  String ticketLevel5;
  int ticketPrice1 = 0;
  int ticketPrice2 = 0;
  int ticketPrice3 = 0;
  int ticketPrice4 = 0;
  int ticketPrice5 = 0;
  int numberOfLevels = 1;

  //for money
  bool payAtDoor = true;
  String payAtDoorDetails;

  bool allowVenmo = false;
  bool allowZelle = false;
  bool allowPayPal = false;
  bool allowCashapp = false;
  bool allowOther1 = false;
  bool allowOther2 = false;
  String venmo;
  String zelle;
  String paypal;
  String cashApp;
  String otherPaymentMethod1;
  String otherPaymentMethod2;

  String errorMessage;


  @override
  void initState() {
    super.initState();
    free = widget.plotData.free;
    canBid = widget.plotData.canBid;
    minimumBidPrice = widget.plotData.minimumBidPrice;
    numberOfLevels = widget.numberOfTicketLevels;
    if(widget.numberOfTicketLevels >= 1){
      ticketLevel1 = widget.plotData.ticketLevelsAndPrices.keys.toList()[0];
      ticketPrice1 = widget.plotData.ticketLevelsAndPrices.values.toList()[0];
    }
    if(widget.numberOfTicketLevels >= 2){
      ticketLevel2 = widget.plotData.ticketLevelsAndPrices.keys.toList()[1];
      ticketPrice2 = widget.plotData.ticketLevelsAndPrices.values.toList()[1];
    }
    if(widget.numberOfTicketLevels >= 3){
      ticketLevel3 = widget.plotData.ticketLevelsAndPrices.keys.toList()[2];
      ticketPrice3 = widget.plotData.ticketLevelsAndPrices.values.toList()[2];
    }
    if(widget.numberOfTicketLevels >= 4){
      ticketLevel4 = widget.plotData.ticketLevelsAndPrices.keys.toList()[3];
      ticketPrice4 = widget.plotData.ticketLevelsAndPrices.values.toList()[3];
    }
    if(widget.numberOfTicketLevels >= 5){
      ticketLevel5 = widget.plotData.ticketLevelsAndPrices.keys.toList()[4];
      ticketPrice5 = widget.plotData.ticketLevelsAndPrices.values.toList()[4];
    }
    if(widget.plotData.paymentMethods['Pay at Door'] != null) {
      payAtDoor = true;
      payAtDoorDetails = widget.plotData.paymentMethods['Pay at Door'];
    }
    if(widget.plotData.paymentMethods['Venmo'] != null) {
      allowVenmo = true;
      venmo = widget.plotData.paymentMethods['Venmo'];
    }
    if(widget.plotData.paymentMethods['Zelle'] != null) {
      allowZelle = true;
      zelle = widget.plotData.paymentMethods['Zelle'];
    }
    if(widget.plotData.paymentMethods['PayPal'] != null) {
      allowPayPal = true;
      paypal = widget.plotData.paymentMethods['PayPal'];
    }
    if(widget.plotData.paymentMethods['Cash App'] != null) {
      allowCashapp = true;
      cashApp = widget.plotData.paymentMethods['Cash App'];
    }
    if(widget.plotData.paymentMethods['Other1'] != null) {
      allowOther1 = true;
      otherPaymentMethod1 = widget.plotData.paymentMethods['Other1'];
    }
    if(widget.plotData.paymentMethods['Other2'] != null) {
      allowOther2 = true;
      otherPaymentMethod2 = widget.plotData.paymentMethods['Other2'];
    }
  }


  Map makePaymentInfoObject (List paymentMethods, List paymentHandles){
    Map<String, String> paymentInfoObject = {};
    List paymentGateways = ['Venmo', 'Zelle', 'PayPal', 'Other1', 'Other2', 'Pay at Door'];
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
      return "Missing Field";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("edit payment methods", style: TextStyle(
          fontSize: 20
        ),),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: ()async{
            Navigator.pushAndRemoveUntil(context, PageTransition(
              type: PageTransitionType.leftToRight,
              child: Home(
                initialTabIndex: 0,
                sharedPrefData: widget.sharedPrefData,
              ),
            ), (route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _editPaymentDetailsFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                    initialValue: minimumBidPrice == null ? '0' : minimumBidPrice.toString(),
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
                  SizedBox(
                    height: 5,
                  ),
                  Divider(thickness: 2,),
                  SizedBox(
                    height: 5,
                  ),
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
                      initialValue: venmo,
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
                      initialValue: zelle,
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
                      initialValue: cashApp,
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
                      initialValue: paypal,
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
                    initialValue: payAtDoorDetails,
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
                    initialValue: otherPaymentMethod1,
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
                    initialValue: otherPaymentMethod2,
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
                            initialValue: ticketLevel1.toString() == null ? 'general admission' :ticketLevel1.toString(),
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
                          width: 80,
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            initialValue: ticketPrice1 == null ? '0' :ticketPrice1.toString(),
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
                              initialValue: ticketLevel2 == null ? '' :ticketLevel2.toString(),
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
                            initialValue: ticketPrice2 == null ? '0' :ticketPrice2.toString(),
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
                              initialValue: ticketLevel3 == null ? '' :ticketLevel3.toString(),

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
                            initialValue: ticketPrice3 == null ? '0' :ticketPrice3.toString(),
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
                              initialValue: ticketLevel4 == null ? '' :ticketLevel4.toString(),

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
                            initialValue: ticketPrice4 == null ? '0' :ticketPrice4.toString(),

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
                              initialValue: ticketLevel5 == null ? '' :ticketLevel5.toString(),
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
                            initialValue: ticketPrice5 == null ? '0' :ticketPrice5.toString(),
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
                    List<bool> paymentMethods = [
                      allowVenmo,
                      allowZelle,
                      allowPayPal,
                      allowOther1,
                      allowOther2,
                      payAtDoor
                    ];
                    List<String> paymentHandles = [
                      venmo,
                      zelle,
                      paypal,
                      otherPaymentMethod1,
                      otherPaymentMethod2,
                      payAtDoorDetails
                    ];
                    List<String> ticketLevels = [
                      ticketLevel1,
                      ticketLevel2,
                      ticketLevel3,
                      ticketLevel4,
                      ticketLevel5
                    ];
                    List<int> ticketPrices = [
                      ticketPrice1,
                      ticketPrice2,
                      ticketPrice3,
                      ticketPrice4,
                      ticketPrice5
                    ];
                    bool onePaymentSelected = false;
                    for (var method in paymentMethods) {
                      if (method) {
                        onePaymentSelected = true;
                      }
                    }
                    if (free) {
                      onePaymentSelected = true;
                    }
                    if (_editPaymentDetailsFormKey.currentState.validate() &&
                        onePaymentSelected) {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          backgroundColor: Color(0xff1e1e1e),
                          title:  Text("are you sure you want to edit?", style: TextStyle(
                            fontSize: 20, color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),),
                          actions: [
                        IconButton(icon: Icon(Icons.close, color: Colors.grey,), onPressed: (){
                        Navigator.pop(context);
                        }),
                        TextButton(
                        child: Text("upload edits", style: TextStyle(
                        fontSize: 20, color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        ),),
                        onPressed: ()async{
                          try{

                            Map paymentInfoObject = makePaymentInfoObject(
                                paymentMethods, paymentHandles);
                            Map ticketInfoObject = makeTicketInfoObject(
                                ticketLevels, ticketPrices);
                            if (minimumBidPrice != widget.plotData.minimumBidPrice) {
                              await _firestore.collection('plots')
                                  .doc(widget.sharedPrefData.plotCode)
                                  .update({
                                'minimumBidPrice': minimumBidPrice,
                              });
                            }
                            if (canBid != widget.plotData.canBid) {
                              await _firestore.collection('plots')
                                  .doc(widget.sharedPrefData.plotCode)
                                  .update({
                                'canBid': canBid,
                              });
                            }
                            if (free != widget.plotData.free) {
                              await _firestore.collection('plots')
                                  .doc(widget.sharedPrefData.plotCode)
                                  .update({
                                'free': free,
                                'ticketLevelsAndPrices': ticketInfoObject,
                                'paymentMethods': paymentInfoObject,
                              });
                            }
                            if (ticketInfoObject !=
                                widget.plotData.ticketLevelsAndPrices) {
                              await _firestore.collection('plots')
                                  .doc(widget.sharedPrefData.plotCode)
                                  .update({
                                'ticketLevelsAndPrices': ticketInfoObject,
                                'paymentMethods': paymentInfoObject,
                              });
                            }
                            if (paymentInfoObject != widget.plotData.paymentMethods) {
                              await _firestore.collection('plots')
                                  .doc(widget.sharedPrefData.plotCode)
                                  .update({
                                'paymentMethods': paymentInfoObject,
                              });
                            }
                            ScaffoldMessenger.of(context).showSnackBar(successSnackbar);
                            Navigator.pop(context);
                          } catch (e){
                            ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
                            Navigator.pop(context);
                            print(e.toString());
                          }
                        }
                        )
                          ],
                        );
                      });
                  } else {
                      setState(() {
                        errorMessage =
                        'you must provide at least one payment method';
                      });
                    }
                },
                elevation: 2.0,
                constraints: BoxConstraints(minWidth: 130, minHeight: 40),
                fillColor: Colors.purple,
                child: Text("edit ", style: TextStyle(
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
