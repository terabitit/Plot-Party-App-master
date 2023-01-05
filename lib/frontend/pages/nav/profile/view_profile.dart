import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';

class ViewProfile extends StatelessWidget {
  final SharedPrefData sharedPrefData;
  final String profilePicURL;

  const ViewProfile({Key key, this.sharedPrefData, this.profilePicURL}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("your profile", style: TextStyle(color: Colors.white, fontSize: 20),),
      ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left:16,right: 16),
          child:SafeArea(child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: MediaQuery.of(context).size.width,),
              Text("tap profile picture to enlarge",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12
                ),),
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
                                    imageUrl: profilePicURL,
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
                        imageUrl: profilePicURL,
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
              Text(sharedPrefData.username,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.white
                ),),
              SizedBox(height: 10,),
              Text(sharedPrefData.phoneNumber,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey
                ),),
              SizedBox(height: 20,),
            ],
          )
          ),
        )
    );
  }
}
