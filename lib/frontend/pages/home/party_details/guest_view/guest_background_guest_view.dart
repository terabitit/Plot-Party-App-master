import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/party_details/guest_view/list_of_guests_guest_view.dart';
import 'package:url_launcher/url_launcher.dart';


class GuestBackgroundGuestView extends StatefulWidget {
  final GuestInfoObject guestInfoObject;
  final String plotCode;
  final List guestUsernames;
  final SharedPrefData sharedPrefData;

  const GuestBackgroundGuestView({Key key, this.guestInfoObject, this.plotCode, this.sharedPrefData, this.guestUsernames}) : super(key: key);
  @override
  _GuestBackgroundGuestViewState createState() => _GuestBackgroundGuestViewState();
}

class _GuestBackgroundGuestViewState extends State<GuestBackgroundGuestView> {
  bool paid;
  final failSnackbar = SnackBar(content: Text('unable to open instagram.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left:16,right: 16),
          child:SafeArea(child: Column(
            children: [
              Row(children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white,),
                    onPressed: ()async{
                      Navigator.pop(context);
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
                                    imageUrl: widget.guestInfoObject.profilePicURL,
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
                          maxHeight: 300,
                          minWidth: 300,
                          maxWidth: 300,
                          minHeight: 300
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.guestInfoObject.profilePicURL,
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
                              maxHeight: 300,
                              minWidth: 300,
                              maxWidth: 300,
                              minHeight: 300
                          ),
                          child: CircularProgressIndicator(),
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
                    Text(widget.guestInfoObject.username,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white
                      ),),
                  ),

                  Container(
                    width: 250,
                    child: Text(widget.guestInfoObject.status,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 20, color: Colors.grey
                      ),),
                  ),
                ],),
                Expanded(child: Container(),),
              ],),
              SizedBox(height: 20,),
              Row(children: [
                Expanded(child: Container(),),
                Container(
                  child: Column(
                    children: [
                      Text(widget.guestInfoObject.plusOnes, style: TextStyle(
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
                        Text("\$${widget.guestInfoObject.price.toString()}", style: TextStyle(
                            fontSize: 20,
                            color: Colors.green
                        ),),
                        Text('price', style: TextStyle(fontSize: 20, color: Colors.grey),)
                      ],
                    )
                ),
                Expanded(child: Container(),),
              ],),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: ()async{
                  var url = 'https://www.instagram.com/${widget.guestInfoObject.instaUsername}/';
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
                        widget.guestInfoObject.instaUsername,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,),
                      ),
                    ),
                  ],),
                ),
              ),
            ],
          )
          ),
        )
    );
  }
}

