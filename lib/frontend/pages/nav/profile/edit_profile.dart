import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/login/verify_success_page.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';


class EditProfile extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final String profilePicURL;
  final List takenUsernames;

  const EditProfile({Key key, this.sharedPrefData, this.profilePicURL, this.takenUsernames}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ImagePicker _picker = ImagePicker();
  File _image;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final failSnackbar = SnackBar(content: Text('error. try again.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);
  final successSnackbar = SnackBar(content: Text('success!', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,);
  String newUsername;
  final _editProfileFormState = GlobalKey<FormState>();


  Future getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery,
      imageQuality: 80,
         maxHeight: 480, maxWidth: 640
        );
    // print(File(pickedFile.path).readAsBytesSync().lengthInBytes.toString());
    setState(() {
      _image = File(pickedFile.path);
    });

  }

  Future getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera,
        imageQuality: 80,
        maxHeight: 480, maxWidth: 640,
      preferredCameraDevice: CameraDevice.front
    );
    // print(File(pickedFile.path).readAsBytesSync().lengthInBytes.toString());
    setState(() {
      _image = File(pickedFile.path);
    });
  }
  void _editProfile() async {
    Timer(Duration(milliseconds: 300), () async{
        if (_editProfileFormState.currentState.validate()){
          try{
            FirestoreFunctions firestorefunctions = FirestoreFunctions();
            SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
            if (_image != null) {
              String filename = '${widget.sharedPrefData.authID}.jpg';
              FirebaseStorage storage = FirebaseStorage.instance;
              Reference ref = storage.ref().child(filename);
              UploadTask uploadTask = ref.putFile(_image);
              uploadTask.then((res) async{
                var str = await res.ref.getDownloadURL();
                firestorefunctions.updateUserInfo(authID: widget.sharedPrefData.authID, fields: ['username', 'profilePicURL'], newValues: [newUsername,str]);
                // update Plot Info if guest is a part of a plot.
                // Updates host info in user is host, updates guest info if guest, updates security if security
                if(widget.sharedPrefData.joinedPlot) {
                  bool isHost = await firestorefunctions.isHost(widget.sharedPrefData.username, widget.sharedPrefData.plotCode);
                  bool isSecurity = await firestorefunctions.isSecurity(widget.sharedPrefData.username, widget.sharedPrefData.plotCode);
                  if (isHost) {
                    firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'hostName', newValue: newUsername);
                  } else {
                    firestorefunctions.updateGuestInfo(plotCode: widget.sharedPrefData.plotCode, field: 'username', newValue: newUsername);
                    firestorefunctions.updateGuestInfo(plotCode: widget.sharedPrefData.plotCode, field: 'profilePicURL', newValue: str);
                  }
                  if (isSecurity){
                    List security = await firestorefunctions.getSecurityList(widget.sharedPrefData.plotCode);
                    security.forEach((element) {
                      if (element == widget.sharedPrefData.username){
                        security.remove(element);
                      }
                    });
                    security.add(newUsername);
                    firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'security', newValue: security);
                  }
                }
                firestorefunctions.updateUserInfo(authID: widget.sharedPrefData.authID, fields: ['username'], newValues: [newUsername]);
                firestorefunctions.writeUsernameRecord(newUsername);
                sharedPrefsServices.setUsername(newUsername);
              });
            } else {
              firestorefunctions.updateUserInfo(authID: widget.sharedPrefData.authID, fields: ['username'], newValues: [newUsername]);
              firestorefunctions.writeUsernameRecord(newUsername);
              sharedPrefsServices.setUsername(newUsername);
              if(widget.sharedPrefData.joinedPlot) {
                bool isHost = await firestorefunctions.isHost(widget.sharedPrefData.username, widget.sharedPrefData.plotCode);
                bool isSecurity = await firestorefunctions.isSecurity(widget.sharedPrefData.username, widget.sharedPrefData.plotCode);
                if (isHost) {
                  firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode,  field: 'hostName', newValue: newUsername);
                } else {
                  firestorefunctions.updateGuestInfo(plotCode: widget.sharedPrefData.plotCode, authID: widget.sharedPrefData.authID, field: 'username', newValue: newUsername);
                }
                if (isSecurity){
                  List security = await firestorefunctions.getSecurityList(widget.sharedPrefData.plotCode);
                  security.forEach((element) {
                    if (element == widget.sharedPrefData.username){
                      security.remove(element);
                    }
                  });
                  security.add(newUsername);
                  firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'security', newValue: security);
                }
              }
            }
            ScaffoldMessenger.of(context).showSnackBar(successSnackbar);
            _btnController.success();
          } catch(e){
            ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
            _btnController.reset();
          }
        }
       else {
        _btnController.reset();
      }
    });
  }


  String validateUsername(String username,) {
    bool usernameInvalid = false;
    List acceptableCharacters = ['a', 'b', 'c', 'd', 'e', 'f', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8','9','0', '_', '.'];
    if (username.isNotEmpty) {
      for (var char in username.characters) {
        if (!acceptableCharacters.contains(char.toLowerCase())){
          usernameInvalid = true;
        }
      }
    }
    if (username.isEmpty || usernameInvalid) {
      return "invalid. try again.";
    }
    if (username == widget.sharedPrefData.username){
      return "username is the same.";
    }
    if (widget.takenUsernames.contains(username)) {
      return "that username is not available.";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("edit profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: ()async{
            SyncService syncService = SyncService();
            await syncService.syncSharedPrefsWithFirestore(authID: widget.sharedPrefData.authID);
            SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
            SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
            Navigator.pushAndRemoveUntil(context, PageTransition(
              type: PageTransitionType.leftToRight,
              child: Home(
                initialTabIndex: 1,
                sharedPrefData: sharedPrefData,
              ),
            ), (route) => false);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.blue,
              ),
               CircleAvatar(
                radius: 152,
                backgroundColor: Colors.transparent,
                child: _image == null ? GestureDetector(
                  onTap: (){ showDialog(context: context,
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
                                  imageUrl: widget.profilePicURL,
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
                  );},
                  child: CircleAvatar(
                      radius: 150,
                      child: CachedNetworkImage(
                        imageUrl: widget.profilePicURL,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 300.0,
                          height: 300.0,
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
                ): GestureDetector(
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
                                  child:  Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.contain,
                                              image: FileImage(_image)
                                          ))),
                                ),
                              )
                          );
                        }
                    );
                  },
                  child: Container(
                      width: 300.0,
                      height: 300.0,
                      decoration:  BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image:  FileImage(_image)
                          )
                      )
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Row(children: [
                Expanded(child:Container(),),
                RawMaterialButton(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(5),
                    child:Icon(Icons.camera_alt, color: Colors.white, size: 50,),
                    onPressed: ()async{
                      try{
                        await getImageFromCamera();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
                      }
                    }),
                RawMaterialButton(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                    child:Icon(Icons.image, color: Colors.white, size: 45,),
                    onPressed: ()async{
                      try{
                        await getImageFromGallery();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
                      }
                    }),
                Expanded(child:Container(),),
              ],),
              SizedBox(height: 5,),
              Container(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _editProfileFormState,
                  child: Column(children: [
                    TextFormField(
                        validator: (text) => validateUsername(text),
                        onChanged: (value) => newUsername = value,
                        initialValue: widget.sharedPrefData.username,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                          labelText: 'new username',
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
                              BorderRadius.all(Radius.circular(5)))),
                    ),
                  ],),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                  alignment: Alignment.center,
                  child:  RoundedLoadingButton(
                    color: Color(0xff630094),
                    width: 165,
                    height: 50,
                    borderRadius: 5,
                    child: Text('edit', style: TextStyle(color: Colors.white,fontSize: 16)),
                    controller: _btnController,
                    onPressed: _editProfile,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
