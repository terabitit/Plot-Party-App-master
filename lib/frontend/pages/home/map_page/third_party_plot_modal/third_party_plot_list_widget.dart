import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/third_party_plot_data.dart';
import 'package:plots/frontend/pages/home/map_page/third_party_plot_modal/third_party_plot_details.dart';

class ThirdPartyPlotListWidget extends StatelessWidget {
  final ThirdPartyPlotData thirdPartyPlotData;

  const ThirdPartyPlotListWidget({Key key, this.thirdPartyPlotData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => ThirdPartyPlotDetails(
          thirdPartyPlotData: thirdPartyPlotData,
        )
      ));
    },
      padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
      child:Column(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: 150
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20,),
                      CircleAvatar(
                          radius: 45,
                          child: CachedNetworkImage(
                            imageUrl: thirdPartyPlotData.picture,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 90.0,
                              height: 90.0,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                strokeWidth: 4.0
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          )
                      ),
                      SizedBox(height: 5,),
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Container(
                              constraints: BoxConstraints(
                                maxHeight: 25,
                                minWidth: 25,
                                maxWidth: 25,
                                minHeight: 25,
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
                          Container(
                            margin: EdgeInsets.only(right: 5,left:5,top: 4,bottom: 4),
                            width: 1,
                            height: 20,
                            color: Colors.white,
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 60
                            ),
                            child: Text(
                              thirdPartyPlotData.instagramUsername,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,),
                            ),
                          ),
                        ],),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Text(
                          thirdPartyPlotData.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,),
                        ),
                      ),
                      Container(
                        width: 150,
                        child: Text(
                          thirdPartyPlotData.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      children: [
                        FirebaseAuth.instance.currentUser.uid == 'ab9p7hF2ULZE0fBuokxuNRDr9pC3' ?
                        IconButton(icon: Icon(Icons.remove, color: Colors.red,), onPressed: (){
                          FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                          firestoreFunctions.removeThirdPartyPlot(thirdPartyPlotData.id);
                        },) :
                        SizedBox(height: 30,),
                      Text(thirdPartyPlotData.likes.toString(), style: TextStyle(
                        color: Colors.green,
                        fontSize: 25,
                      ),),
                      Icon(Icons.thumb_up, color: Colors.green, size: 15,),
                        Icon(Icons.thumb_down, color: Colors.red, size: 15,),
                        Text(thirdPartyPlotData.dislikes.toString(), style: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                        ),),
                      ],),
                  ),
                )
              ],
            ),
          ),
        Divider(thickness: 2, color: Colors.grey,),
        ],
      ),
    );
  }
}
