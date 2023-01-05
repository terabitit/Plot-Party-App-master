import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/login/verify_success_page.dart';


class UploadProfilePic extends StatefulWidget {
  final SharedPrefData sharedPrefData;

  const UploadProfilePic({Key key, this.sharedPrefData}) : super(key: key);
  @override
  _UploadProfilePicState createState() => _UploadProfilePicState();
}

class _UploadProfilePicState extends State<UploadProfilePic> {
  final ImagePicker _picker = ImagePicker();
  String errorMessage;
  File _image;
  final failSnackbar = SnackBar(content: Text('error. try Again.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);
  final successSnackbar = SnackBar(content: Text('success!', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,);

  Future getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 80,
        maxHeight: 480, maxWidth: 640,
        );
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera,imageQuality: 80,
        maxHeight: 480, maxWidth: 640,
        preferredCameraDevice: CameraDevice.front);
    setState(() {
      _image = File(pickedFile.path);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, leading: Container(),),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Text("upload profile pic", style: TextStyle(color: Colors.white, fontSize: 25),),
              Text("your profile pic will be used to identify you.",textAlign: TextAlign.center, style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontStyle: FontStyle.italic
              ),),
              SizedBox(height: 15,),
              CircleAvatar(
                radius: 152,
                backgroundColor: Color(0xff1e1e1e),
                child: Container(
                    width: 300.0,
                    height: 300.0,
                    decoration:  BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff1e1e1e),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image:  _image != null ? FileImage(_image) : AssetImage('assets/images/no-image-available.jpeg')
                        )
                    )
                ),
              ),
              Row(children: [
                Expanded(child:Container(),),
                RawMaterialButton(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
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
              errorMessage == null ? Container() :Container(
                padding: EdgeInsets.only(top: 10,bottom: 10),
                child: Text(errorMessage,textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 32,
                  color: Colors.red
                ),),
              ),
              NextButton(
                text: 'upload image',
                callback: (){
                  try{
                    if (_image != null) {
                      String filename = '${widget.sharedPrefData.authID}.jpg';
                      FirebaseStorage storage = FirebaseStorage.instance;
                      Reference ref = storage.ref().child(filename);
                      UploadTask uploadTask = ref.putFile(_image);
                      uploadTask.then((res) async{
                        var str = await res.ref.getDownloadURL();
                        FirestoreFunctions firestorefunctions = FirestoreFunctions();
                        await firestorefunctions.updateUserInfo(authID: widget.sharedPrefData.authID, fields: ['profilePicURL'], newValues: [str]);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(successSnackbar);
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => VerifySucessPage(
                              )
                          ));
                    }else {
                      setState(() {
                        errorMessage = "a profile picture is required.";
                      });
                    }

                  } catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
