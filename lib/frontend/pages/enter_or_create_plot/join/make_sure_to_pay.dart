import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_approval.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';


class MakeSureToPay extends StatelessWidget {
  final int totalCost;
  final String paymentMethod;
  final String plusOnes;
  final Map allPaymentMethods;
  final Map allTicketLevelsAndPrices;
  final String status;
  final String ticketLevel;
  final String paymentDetails;

  const MakeSureToPay({Key key, this.totalCost, this.ticketLevel, this.allTicketLevelsAndPrices, this.paymentMethod, this.plusOnes, this.status,this.allPaymentMethods, this.paymentDetails}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Container(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16,right: 16),
        child: Column(
          children: [
            Text("go pay now if you are not paying at door.\n\nthe host needs to check and approve your payment in order for you to receive your ticket.",textAlign: TextAlign.center,  style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),),
            SizedBox(height: 20,),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: 'you have to pay ',
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                  )),
                  TextSpan(text: "\$${totalCost.toString()}", style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  )),
                  TextSpan(text: '\nthrough ', style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                  )),
                  TextSpan(text: "${paymentMethod == "Other1" || paymentMethod == "Other2" ? allPaymentMethods[paymentMethod]: paymentMethod }.", style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  )),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Text("send money to:", style: TextStyle(color: Colors.white, fontSize: 30),),
            SizedBox(height: 10,),
                    Column(
                        children:
                        allPaymentMethods.entries.map((entry) {
                          if (entry.key == paymentMethod){
                          if(entry.key != "Other1" && entry.key != "Other2"&& entry.key != "Pay at Door"){
                            return Column(children: [
                              GestureDetector(
                                onTap: (){
                                  showDialog(context: context, builder: (BuildContext context){
                                    return AlertDialog(
                                      backgroundColor: Color(0xff1e1e1e),
                                      title: Text(entry.key, style: TextStyle(color: entry.key == paymentMethod ? Colors.green : Colors.white, fontWeight: FontWeight.bold),),
                                      content:  Text(entry.value, style: TextStyle(color:entry.key == paymentMethod ? Colors.green :  Colors.white),),
                                      actions: [
                                        IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                                          Navigator.pop(context);
                                        })
                                      ],
                                    );
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  width:350,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                      color: Colors.black
                                  ),
                                  child: Row(children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 25,
                                        minWidth: 25,
                                        maxWidth: 25,
                                        minHeight: 25,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/images/${entry.key}-Logo.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Text(entry.key, style: TextStyle(fontSize: 16, color: entry.key == paymentMethod ? Colors.green : Colors.white),),
                                    Expanded(child: Container(),),
                                    Container(
                                      width: 175,
                                      child: Text(
                                        entry.value,
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: entry.key == paymentMethod ? Colors.green : Colors.white,
                                          fontSize: 16,),
                                      ),
                                    ),
                                    SizedBox(width: 5,)
                                  ],),
                                ),
                              ),
                              SizedBox(height: 10,)]);
                          }else return Container();
                          }else return Container();
                        }).toList()),
            Column(
                children:
                allPaymentMethods.entries.map((entry) {
                  if (entry.key == paymentMethod){
                  if(entry.key == "Other1" || entry.key == "Other2" || entry.key == "Pay at Door"){
                    return Column(children: [
                      GestureDetector(
                        onTap: (){
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(
                              backgroundColor: Color(0xff1e1e1e),
                              title: Text(entry.key == "Other1" || entry.key == "Other2" ? 'custom ${entry.key[5]}' : "pay at door", style: TextStyle(color: entry.key == paymentMethod ? Colors.green : Colors.white, fontWeight: FontWeight.bold),),
                              content:  Text(entry.value, style: TextStyle(color:entry.key == paymentMethod ? Colors.green :  Colors.white),),
                              actions: [
                                IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                                  Navigator.pop(context);
                                })
                              ],
                            );
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          width:350,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              color: Colors.black
                          ),
                          child: Row(children: [
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: 25,
                                minWidth: 25,
                                maxWidth: 25,
                                minHeight: 25,
                              ),
                              child: Container(
                                child:entry.key == "Other1" || entry.key == "Other2" ? Icon(Icons.info, color: Colors.white,) : Icon(Icons.sensor_door_outlined, color: Colors.white,),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text(entry.key == "Other1" || entry.key == "Other2" ? 'custom ${entry.key[5]}' : "pay at door", style: TextStyle(fontSize: 16, color: entry.key == paymentMethod ? Colors.green : Colors.white),),
                            Expanded(child: Container(),),
                            Container(
                              width: 175,
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: entry.key == paymentMethod ? Colors.green : Colors.white,
                                  fontSize: 16,),
                              ),
                            ),
                            SizedBox(width: 5,)
                          ],),
                        ),
                      ),
                      SizedBox(height: 10,)]);
                  }else return Container();
                  }else return Container();
                }).toList()),
              SizedBox(height: 10,),
            Row(children: [
              Expanded(child: Container(),),
              Ticket(radius: 15,
                  clipShadows: [ClipShadow(color: Colors.black)],
                  child: Container(
                      padding: EdgeInsets.only(left: 15),
                      height: 85,
                      width: 175,
                      color:   Color(0xff630094),
                      child: Row(
                        children: [
                          Text("\$${allTicketLevelsAndPrices[ticketLevel]}", style: TextStyle(
                              fontSize: 16,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold
                          ),),
                          SizedBox(width: 5,),
                          Container(
                            width: 90,
                            child: Text('$status',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          )

                        ],)
                  )),
              plusOnes == "none" ? Container() :  SizedBox(width: 10,),
              plusOnes == "none" ? Container() : Text(" x ${(int.parse(plusOnes[1]) + 1).toString()}", style: TextStyle(
                fontSize: 20,
                color: Colors.white
              ),),
              Expanded(child: Container(),),
            ],),
            SizedBox(height: 20,),
            NextButton(
              callback: ()async{
                showDialog(context: context, builder: (BuildContext context){
                  return AlertDialog(
                    backgroundColor: Color(0xff1e1e1e),
                    title: Text("did you pay the host?", style: TextStyle(
                      color: Colors.white,
                    ),textAlign: TextAlign.center,
                    ),
                    actions: [
                      IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                        Navigator.pop(context);
                      }),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                  primary: Colors.blue
                  ),
                        child: Text("done!", style: TextStyle(
                          color: Colors.white,
                          fontSize: 16
                        ),),
                        onPressed: ()async{
                          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
                          SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
                          bool firstTimeApproval = await sharedPrefsServices.isFirstTimeWaitingForApproval();
                          if (firstTimeApproval){
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                builder: (BuildContext context) => IntroScreensApproval( sharedPrefData: sharedPrefData,)
                            ), (route) => false);
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context, MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Home(initialTabIndex: 0,
                                      sharedPrefData: sharedPrefData,)
                            ), (route) => false);
                          }
                        },
                      )
                    ],
                  );
                });
              },
              text: "go party!!",
            )

          ],
        ),
      ),
    );
  }
}
