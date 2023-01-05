import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/bidding_and_plus_ones.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/join_free_plot.dart';


class FindInstagram extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final FirestorePlotData plotData;

  const FindInstagram({Key key, this.sharedPrefData, this.plotData}) : super(key: key);
  @override
  _FindInstagramState createState() => _FindInstagramState();
}

class _FindInstagramState extends State<FindInstagram> {
  TextEditingController controller = TextEditingController();
  final _instagramLookupForm = GlobalKey<FormState>();
  final failSnackbar = SnackBar(content: Text('Servor Error.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);
  final successSnackbar = SnackBar(content: Text('Success!', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,);

  String instaUsername;
  String followers;
  String following;
  String bio;
  String profilePic;

  String validateAnnouncement(String value,) {
    if (value.isEmpty) {
      return "The username can not be empty.";
    }
    return null;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("find instagram"), elevation: 0,),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text(authService.getAuthID()),
            Container(
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(15),
              child: Text("your instagram username may be viewed by the host and other guests.", style: TextStyle(
                fontSize: 22
              ),),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _instagramLookupForm,
                child: Column(children: [
                  TextFormField(
                      onChanged: (value) => instaUsername = value,
                      controller: controller,
                      style: TextStyle(
                        color: Colors.white
                      ),
                      cursorColor: Colors.white,
                      validator: (value) => validateAnnouncement(value),
                      decoration: InputDecoration(
                        // flashing container
                        // unfocus after you click background
                          filled: true,
                          fillColor: Colors.black,
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: "instagram username",
                          hintText: "@hamesjan",
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
                ],),
              ),
            ),
            // CustomButton(
            //   text: 'Search',
            //   color: Colors.purpleAccent,
            //   callback: ()async {
            //     if (_instagramLookupForm.currentState.validate()){
            //       try{
            //         FlutterInsta insta = FlutterInsta();
            //         InstaProfileData user = await insta.getProfileData(controller.text);
            //         //Get Profile Details(must be public)
            //         print(user.username);
            //         setState(() {
            //           instaUsername = user.username;
            //           followers = user.followers;
            //           following = user.following;
            //           bio = user.bio;
            //           profilePic = user.profilePicURL;
            //         });
            //       } catch(e){
            //         ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
            //         print(e.toString());
            //       }
            //
            //     }
            //   },
            // ),
            // SizedBox(height: 10,),
            // instaUsername == null ? Container(
            //   child: Text("Lurkin...", style: TextStyle(
            //     fontSize: 32,
            //     color: Colors.white
            // ) )):
            // profilePic == null ? Container(
            //   padding: EdgeInsets.all(16),
            //   child:
            // Container(width: 500, height: 200, decoration: BoxDecoration(
            //   borderRadius: BorderRadius.all(Radius.circular(15)),
            //   color: Colors.black,
            // ),
            //   child: Row(children: [
            //     SizedBox(width: 25,),
            //     Container(
            //         child: CircleAvatar(
            //             radius: 61,
            //             backgroundColor: Colors.purpleAccent,
            //             child:CircleAvatar(
            //                 radius: 60,
            //                 child: CachedNetworkImage(
            //                   imageUrl: profilePic,
            //                   imageBuilder: (context, imageProvider) => Container(
            //                     width: 120.0,
            //                     height: 120.0,
            //                     decoration: BoxDecoration(
            //                       shape: BoxShape.circle,
            //                       image: DecorationImage(
            //                           image: imageProvider, fit: BoxFit.cover),
            //                     ),
            //                   ),
            //                   placeholder: (context, url) => CircularProgressIndicator(),
            //                   errorWidget: (context, url, error) => Icon(Icons.error),
            //                 )
            //             )
            //         )),
            //     SizedBox(width: 25,),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         SizedBox(height: 10,),
            //         Row(
            //           children: [
            //             Column(children: [
            //               Text(followers, style: TextStyle(
            //                 fontSize: 20,
            //                 color: Colors.white,
            //                 fontWeight: FontWeight.bold
            //               ),),
            //               Text("Followers", style: TextStyle(
            //                   fontSize: 15,
            //                   color: Colors.white
            //               ),),
            //             ],),
            //             SizedBox(width: 20,),
            //             Column(children: [
            //               Text(following, style: TextStyle(
            //                   fontSize: 20,
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.bold
            //               ),),
            //               Text("Following", style: TextStyle(
            //                   fontSize: 15,
            //                   color: Colors.white
            //               ),),
            //             ],),
            //           ],
            //         ),
            //         SizedBox(height: 20,),
            //         Text(instaUsername,style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
            //         SizedBox(height: 10,),
            //         Text(bio,style: TextStyle(fontSize: 15, color: Colors.white),),
            //
            //       ],
            //     )
            //
            //   ],),
            //   ),
            // ) : Container(),
            NextButton(
              text: 'next',
              callback: ()async {
    if (_instagramLookupForm.currentState.validate()) {
      FocusScope.of(context).unfocus();
      showDialog(context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xff1e1e1e),
              title: Text('are you sure this is your username?', style: TextStyle(
                color: Colors.white
              ),),
              content: Text("@${controller.text}", style: TextStyle(
                  color: Colors.white
              ) ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white,),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),

                TextButton(onPressed: (){
                  List allTicketLevels = widget.plotData.ticketLevelsAndPrices.keys.toList();
                  List paymentMethodsList = widget.plotData.paymentMethods.keys.toList();
                  allTicketLevels.sort();
                  paymentMethodsList.sort();
                  !widget.plotData.free ?
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) => BiddingAndPlusOnes(
                        sharedPrefData: widget.sharedPrefData,
                        plotCode: widget.plotData.plotCode,
                        allowBidding: widget.plotData.canBid,
                        firstPaymentMethod: paymentMethodsList[0],
                        paymentMethodsList: paymentMethodsList,
                        firstTicketLevel: allTicketLevels[0],
                        allTicketLevels: allTicketLevels,
                        minimumBidPrice: widget.plotData.minimumBidPrice,
                        free: widget.plotData.free,
                        ticketLevelsAndPrices: widget.plotData.ticketLevelsAndPrices,
                        paymentMethods: widget.plotData.paymentMethods,
                        instaUsername: instaUsername,
                      )))
                      :Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) => JoinFreePlot(
                        sharedPrefData: widget.sharedPrefData,
                        plotCode: widget.plotData.plotCode,
                        instaUsername: instaUsername,
                      )));
                }, child: Text("Confirm", style: TextStyle(
                    color: Colors.blue,
                  fontWeight: FontWeight.bold
                ),)),
              ],
            );
          }
      );
    }
                }
            ),
    ],
        )
    );
  }
}
