import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/find_instagram.dart';
import 'package:plots/frontend/pages/home/party_details/guest_view/list_of_guests_guest_view.dart';
import 'package:plots/frontend/services/launch_apple_maps.dart';
import 'package:progress_indicators/progress_indicators.dart';

class PlotPreview extends StatefulWidget {
  final FirestorePlotData plotData;
  final String hostProfilePic;
  final SharedPrefData sharedPrefData;

  const PlotPreview({Key key, this.plotData, this.sharedPrefData, this.hostProfilePic}) : super(key: key);
  @override
  _PlotPreviewState createState() => _PlotPreviewState();
}

class _PlotPreviewState extends State<PlotPreview> {
  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
  Future<FirestorePlotData> plotInfo;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      overflow: Overflow.visible,
                      alignment: Alignment.center,
                      children: [
                        widget.plotData.flyerURL != '' ? Align(
                            alignment: Alignment.topCenter,
                            child:GestureDetector(
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
                                              imageUrl: widget.plotData.flyerURL,
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
                                color: Colors.black,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height / 5 + 25,
                                  minHeight: MediaQuery.of(context).size.height / 5 + 25,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: widget.plotData.flyerURL,
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
                                      maxHeight: 300,
                                      minHeight: 300,
                                    ),
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                        strokeWidth: 4.0
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                )
                            )))
                            : Align(
                          alignment: Alignment.topCenter,
                          child:Container(
                          color: Colors.black,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height / 5 + 25,
                            minHeight: MediaQuery.of(context).size.height / 5 + 25,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(25)),
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/no_plot_image.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: SafeArea(
                              child: Container(
                                  padding: EdgeInsets.only(top: 20, left: 5),
                                  child: RawMaterialButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }, // needed
                                    child: Icon(Icons.arrow_back_ios_outlined, color: Colors.white,size: 32,),
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(16),
                                    fillColor: Color(0xff1e1e1e),
                                  )

                              ),
                            )),
                         Positioned(
                           bottom: -25,
                                child:Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                    color: Colors.black
                                  ),
                              child:  Row(children: [
                                SizedBox(width: 10,),
                               widget.plotData.guests.length  == 0 ? Container() :
                                   widget.plotData.guests.length  == 1 ? CircleAvatar(
                                     child: CircleAvatar(
                                       radius: 25,
                                       child: CachedNetworkImage(
                                         imageUrl: widget.plotData.guests[0]['profilePicURL'],
                                         imageBuilder: (context, imageProvider) => Container(
                                           decoration: BoxDecoration(
                                             shape: BoxShape.circle,
                                             image: DecorationImage(
                                               image: imageProvider,
                                               fit: BoxFit.cover,
                                             ),
                                           ),
                                         ),
                                         placeholder: (context, url) => CircularProgressIndicator(
                                             valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                             strokeWidth: 4.0
                                         ),
                                         errorWidget: (context, url, error) => Icon(Icons.error),
                                       ), // Provide your custom image
                                     ),
                                   ):
                                       widget.plotData.guests.length  == 2 ?Container(
                                         width: 60,
                                         child:
                                         Stack(
                                           children: <Widget>[
                                             Align(
                                               alignment: Alignment.centerRight,
                                               child:
                                               CircleAvatar(
                                                 child: CircleAvatar(
                                                   radius: 25,
                                                   child: CachedNetworkImage(
                                                     imageUrl: widget.plotData.guests[0]['profilePicURL'],
                                                     imageBuilder: (context, imageProvider) => Container(
                                                       decoration: BoxDecoration(
                                                         shape: BoxShape.circle,
                                                         image: DecorationImage(
                                                           image: imageProvider,
                                                           fit: BoxFit.cover,
                                                         ),
                                                       ),
                                                     ),
                                                     placeholder: (context, url) => CircularProgressIndicator(
                                                         valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                         strokeWidth: 4.0
                                                     ),
                                                     errorWidget: (context, url, error) => Icon(Icons.error),
                                                   ), // Provide your custom image
                                                 ),
                                               ),
                                             ),
                                             Align(
                                               alignment: Alignment.centerLeft,
                                               child: CircleAvatar(
                                                 child: CircleAvatar(
                                                   radius: 25,
                                                   child: CachedNetworkImage(
                                                     imageUrl: widget.plotData.guests[1]['profilePicURL'],
                                                     imageBuilder: (context, imageProvider) => Container(
                                                       decoration: BoxDecoration(
                                                         shape: BoxShape.circle,
                                                         image: DecorationImage(
                                                           image: imageProvider,
                                                           fit: BoxFit.cover,
                                                         ),
                                                       ),
                                                     ),
                                                     placeholder: (context, url) => CircularProgressIndicator(
                                                         valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                         strokeWidth: 4.0
                                                     ),
                                                     errorWidget: (context, url, error) => Icon(Icons.error),
                                                   ), // Provide your custom image
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                       ):
                               widget.plotData.guests.length > 2 ?
                                   Container(
                                      width: 80,
                                      child:
                                    Stack(
                                        children: <Widget>[
                                           Align(
                                            alignment: Alignment.centerRight,
                                            child:
                                                CircleAvatar(
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    child: CachedNetworkImage(
                                                      imageUrl: widget.plotData.guests[0]['profilePicURL'],
                                                      imageBuilder: (context, imageProvider) => Container(
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          image: DecorationImage(
                                                            image: imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder: (context, url) => CircularProgressIndicator(
                                                          valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                          strokeWidth: 4.0
                                                      ),
                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                    ), // Provide your custom image
                                                  ),
                                                ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: CircleAvatar(
                                              child: CircleAvatar(
                                                radius: 25,
                                                child: CachedNetworkImage(
                                                  imageUrl: widget.plotData.guests[1]['profilePicURL'],
                                                  imageBuilder: (context, imageProvider) => Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) => CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                      strokeWidth: 4.0
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ), // Provide your custom image
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: CircleAvatar(
                                              child: CircleAvatar(
                                                radius: 25,
                                                child: CachedNetworkImage(
                                                  imageUrl: widget.plotData.guests[2]['profilePicURL'],
                                                  imageBuilder: (context, imageProvider) => Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) => CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                      strokeWidth: 4.0
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ), // Provide your custom image
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                 : Container(),
                                SizedBox(width: 10,),
                                Text('${widget.plotData.guests.length} attending', style: TextStyle(
                                    fontSize: 15
                                ),),SizedBox(width: 10,),
                            widget.plotData.guests.length == 0 ? Container():ButtonTheme(
            shape: StadiumBorder(),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                  primary: Colors.purple, elevation: 8),
            child: Text(
            "see all",
            style: TextStyle(fontSize: 17, color: Colors.white),
            ),
            onPressed: (){
              List guestsUsernames = [];
              widget.plotData.guests.forEach((element) {
                guestsUsernames.add(element['username']);
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ListOfGuestsGuestView(
                            sharedPrefData: widget.sharedPrefData,
                            plotCode: widget.plotData.plotCode,
                            guestsNames: guestsUsernames,
                            from: 'preview',
                          )));            },
            ),
            ), SizedBox(width: 10,),

                              ],),))
                      ],
                    ),SizedBox(height: 25,),
                    Container(padding: EdgeInsets.only(left:30, top: 10,right: 30),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.plotData.plotName,style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 25
                          ),),
                          SizedBox(height: 5,),
                          Row(children: [
                            widget.plotData.plotPrivacy == "open invite" ? Icon(Icons.lock_open, color: Colors.white,) : Icon(Icons.lock),
                            SizedBox(width: 5,),
                            Text(widget.plotData.plotPrivacy, style: TextStyle(
                              fontSize: 16, color: Colors.white
                            ),)
                          ],),
                          SizedBox(height: 15,),
                          Text("about event", style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),),
                          Text(widget.plotData.description,style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                          ),
                          ),
                          SizedBox(height: 10,),
                          CountdownTimer(
                            endTime: widget.plotData.startDate.millisecondsSinceEpoch +
                                1000 * 30,
                            widgetBuilder: (_, CurrentRemainingTime time) {
                              if (time == null) {
                                return Container(
                                      width: 350,
                                      height: 75,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.purpleAccent,
                                              Colors.deepPurpleAccent
                                            ]),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                      ),
                                      child: JumpingText(
                                        "time to rage!!!",
                                        style: TextStyle(
                                          fontSize: 32,
                                        ),
                                      ),
                                      // Define how long the animation should take.
                                    );
                              }
                              return Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          child:
                                        Column(
                                          children: [
                                            Text(
                                              '${time.days == null ? 0.toString() : time.days > 9 ? '': '0'}${time.days == null ?0.toString(): time.days}',
                                              style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'days',
                                              style: TextStyle(fontSize: 16,color: Colors.white),
                                            ),
                                          ],
                                        ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            color: Colors.black38
                                          ),
                                          padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                                        ),
                                        Container(
                                          child:
                                          Column(
                                            children: [
                                              Text(
                                                '${time.hours == null ? 0.toString() : time.hours>9 ? '': '0'}${time.hours == null ?0.toString(): time.hours}',
                                                style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'hrs',
                                                style: TextStyle(fontSize: 16,color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              color: Colors.black38
                                          ),
                                          padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                                        ),
                                        Container(
                                          child:
                                          Column(
                                            children: [
                                              Text(
                                                '${time.min == null ? 0.toString() : time.min>9 ? '': '0'}${time.min == null ?0.toString(): time.min}',
                                                style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'mins',
                                                style: TextStyle(fontSize: 16,color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              color: Colors.black38
                                          ),
                                          padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                                        ),
                                        Container(
                                          child:
                                          Column(
                                            children: [
                                              Text(
                                                '${time.sec == null ? 0.toString() : time.sec>9 ? '': '0'}${time.sec == null ?0.toString(): time.sec}',
                                                style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'secs',
                                                style: TextStyle(fontSize: 16,color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              color: Colors.black38
                                          ),
                                          padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                                        ),
                                      ],
                                    );
                            },
                          ),
                          SizedBox(height: 10,),
                          Row(children: [
                            Container(
                              child:Icon(Icons.calendar_today, size: 50, color: Colors.white,),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Color(0xff630094),
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                            ),
                            SizedBox(width: 15,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('dd MMMM, y').format(widget.plotData.startDate ).toString(), style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16
                                ),),
                                SizedBox(height: 5,),
                                Text(DateFormat('EEEE, hh:mm a').format(widget.plotData.startDate ).toString(), style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16
                                ),),
                              ],)
                          ],),
                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              widget.plotData.plotPrivacy != "open invite" ? print("none"):
                              MapUtils.openMap(
                                  widget.plotData.lat, widget.plotData.long, context);
                            },
                            child: Row(children: [
                              Container(
                                child:Icon(Icons.place, size: 50, color: Colors.white,),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color(0xff630094),
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                              ),
                              SizedBox(width: 15,),
                              widget.plotData.plotPrivacy != "open invite" ? Text("addy will be given\nafter approved", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16
                              ),):
                                  Expanded(
                                    child:Container(child:Text("${widget.plotData.plotAddress}", style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16
                                  ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ), ),
                                  ),
                              SizedBox(width: 10,),
                            ],),
                          ),
                          SizedBox(height: 10,),
                          Row(children: [
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
                                                  imageUrl: widget.hostProfilePic,
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
                                      maxHeight: 75,
                                      minWidth: 75,
                                      maxWidth: 75,
                                      minHeight: 75
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.hostProfilePic,
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)
                                          ),
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
                                            maxHeight: 75,
                                            minWidth: 75,
                                            maxWidth: 75,
                                            minHeight: 75
                                        ),
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                            strokeWidth: 4.0
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    )
                                )),
                            SizedBox(width: 15,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 200,
                                  child: Text("hosted by ${widget.plotData.hostName}", style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16
                                  ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  width: 200,
                                  child:Text(widget.plotData.contactDetails, style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16
                                ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ), ),
                              ],
                            ),
                            SizedBox(width: 10,),
                          ],)
                        ],),
                    ),
                    SizedBox(height: 20,),
                    widget.sharedPrefData.joinedPlot ? Container(
                      child: Text("You can not attend two parties at once.", style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16
                      ),),
                    ) : NextButton(
                      callback: (){
                        Navigator.push(context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => FindInstagram(
                            plotData: widget.plotData,
                            sharedPrefData: widget.sharedPrefData,)
                        ));
                      },
                      text: 'attend',
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              )
    );
  }
}
