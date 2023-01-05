import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:plots/frontend/classes/third_party_plot_data.dart';
import 'package:plots/frontend/services/launch_apple_maps.dart';
import 'package:url_launcher/url_launcher.dart';


class ThirdPartyPlotDetails extends StatefulWidget {
  final ThirdPartyPlotData thirdPartyPlotData;

  const ThirdPartyPlotDetails({Key key, this.thirdPartyPlotData}) : super(key: key);
  @override
  _ThirdPartyPlotDetailsState createState() => _ThirdPartyPlotDetailsState();
}

class _ThirdPartyPlotDetailsState extends State<ThirdPartyPlotDetails> {
  bool liked = false;
  bool disliked = false;
  final failSnackbar = SnackBar(content: Text('unable to open instagram.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text("what's plots?", style: TextStyle(
        color: Colors.grey
      ),),),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
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
                                  imageUrl: widget.thirdPartyPlotData.picture,
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
                child:
                Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 4 + 25,
                      minHeight: MediaQuery.of(context).size.height / 4 + 25,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.thirdPartyPlotData.picture,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        alignment: Alignment.center,
                        color: Colors.black,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height / 4 + 25,
                          minHeight: MediaQuery.of(context).size.height / 4 + 25,
                        ),
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                            strokeWidth: 4.0
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding:EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        flex: 4,
                        child: Text(widget.thirdPartyPlotData.title, style: TextStyle(
                            fontSize: 32,
                            color: Colors.white
                        ),),),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25))
                            ),
                            primary: Colors.transparent
                          ),
                          onPressed: ()async{
                            if(!liked){
                              FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
                              var res = await firebaseFirestore.collection('thirdPartyPlots').doc(widget.thirdPartyPlotData.id).get();
                              int currLikes = res.data()['likes'];
                              await firebaseFirestore.collection('thirdPartyPlots').doc(widget.thirdPartyPlotData.id).update({
                                "likes": currLikes += 1
                              });
                              setState(() {
                                liked = true;
                                disliked = false;
                              });
                            }
                          },
                          child: Column(
                            children: [
                              SizedBox(height: 30,),
                              Text(liked ? (widget.thirdPartyPlotData.likes + 1).toString() : widget.thirdPartyPlotData.likes.toString(), style: TextStyle(
                                color: liked ? Colors.green : Colors.grey,
                                fontSize: 25,
                              ),),
                              Icon(Icons.thumb_up, color:liked? Colors.green :Colors.grey, size: 15,),
                              SizedBox(height: 30,),

                            ],),
                        ),),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25))
                              ),
                              primary: Colors.transparent
                          ),
                          onPressed: ()async{
                            if(!disliked){
                              FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
                              var res = await firebaseFirestore.collection('thirdPartyPlots').doc(widget.thirdPartyPlotData.id).get();
                              int dislikes = res.data()['dislikes'];
                              await firebaseFirestore.collection('thirdPartyPlots').doc(widget.thirdPartyPlotData.id).update({
                                "dislikes": dislikes += 1
                              });
                              setState(() {
                                liked = false;
                                disliked = true;
                              });
                            }
                          },
                          child: Column(
                            children: [
                              SizedBox(height: 30,),
                              Text(disliked ? (widget.thirdPartyPlotData.dislikes + 1).toString() : widget.thirdPartyPlotData.dislikes.toString(), style: TextStyle(
                                color: disliked ? Colors.red : Colors.grey,
                                fontSize: 25,
                              ),),
                              Icon(Icons.thumb_down, color:disliked? Colors.red :Colors.grey, size: 15,),
                              SizedBox(height: 30,),

                            ],),
                        ),)
                    ],),
                    SizedBox(height: 10,),
                    Text("description", style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20
                    ),),
                    Text(widget.thirdPartyPlotData.description, style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                    ),),
                    SizedBox(height: 10,),
                    Text("contact details", style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20
                    ),),
                    Text(widget.thirdPartyPlotData.contactInfo, style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                    ),),
                    SizedBox(height: 10,),
                    Text("price details", style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20
                    ),),
                    Text("${widget.thirdPartyPlotData.price}", style: TextStyle(
                        color: Colors.green,
                        fontSize: 20
                    ),),
                    SizedBox(height: 10,),
                    Text("more info", style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20
                    ),),
                    GestureDetector(
                      onTap: ()async{
                        var url = 'https://www.instagram.com/${widget.thirdPartyPlotData.instagramUsername}/';
                        if (await canLaunch(url)) {
                          await launch(
                            url,
                            universalLinksOnly: true,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
                        }
                      },
                      child: Row(children: [
                        Container(
                          child: Column(
                            children: [
                              Container(
                                  constraints: BoxConstraints(
                                    maxHeight: 50,
                                    minWidth: 50,
                                    maxWidth: 50,
                                    minHeight: 50,
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
                              Text("tap me!",textAlign: TextAlign.center, style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10
                              ),)
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                        ),
                        SizedBox(width: 15,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.thirdPartyPlotData.instagramUsername, style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20
                            ),),
                          ],)
                      ],),
                    ),
                    SizedBox(height: 10,),
                    Row(children: [
                      Container(
                        child:Icon(Icons.calendar_today, size: 50, color: Colors.white,),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xffB53D3D), Color(0xff630094)
                                ]
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      ),
                      SizedBox(width: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('dd MMMM, y').format(widget.thirdPartyPlotData.date ).toString(), style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16
                              ),),
                              SizedBox(height: 5,),
                              Text(DateFormat('EEEE, hh:mm a').format(widget.thirdPartyPlotData.date ).toString(), style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16
                              ),),
                            ],)
                        ],)
                    ],),
                    SizedBox(height: 10,),
                    Row(children: [
                      Container(
                        child:Icon(Icons.place, size: 50, color: Colors.white,),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xffB53D3D), Color(0xff630094)
                                ]
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      ),
                      SizedBox(width: 15,),
                      GestureDetector(
                        onTap: (){
                          if(widget.thirdPartyPlotData.addyProvided){
                            MapUtils.openMap(
                                widget.thirdPartyPlotData.lat, widget.thirdPartyPlotData.long, context);
                          }
                        },
                        child:
                            Container(
                              width: MediaQuery.of(context).size.width- 200,
                              child: Text(widget.thirdPartyPlotData.addyProvided ? widget.thirdPartyPlotData.addy : "contact host for address", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16
                              ),
                              overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                      )
                    ],),

                  ],
                ),)

            ],
          ),
        ),
      ),

    );
  }
}
