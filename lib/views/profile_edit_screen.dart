import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:namaste/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/util/local_notification.dart';

class ProfileEdit extends StatefulWidget {
  final User currentUser;

  const ProfileEdit({Key key, this.currentUser}) : super(key: key);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // final name = TextEditingController();
  // final bio = TextEditingController();

  File _image;
  final picker = ImagePicker();

  bool _validate = false;
  bool _load = false;

  @override
  void initState() {
    super.initState();
    profileNameTextEditingController.text = widget.currentUser.name;
    bioTextEditingController.text = widget.currentUser.bio;
  }

  Future<void> updateProfile(
    BuildContext context,
  ) async {
    await Provider.of<Users>(context, listen: false)
        .updateProfile(
            widget.currentUser.id,
            profileNameTextEditingController.text.isEmpty
                ? widget.currentUser.name
                : profileNameTextEditingController.text,
            bioTextEditingController.text,
            _image)
        .then((value) {
      setState(() {
        _load = false;
      });
      LocalNotification.success(
        context,
        message: 'Profile updated',
        inPostCallback: true,
      );
      Navigator.pop(context, true);
    });
  }

  // void showInSnackBar(String value) {
  //   _scaffoldKey.currentState
  //       .showSnackBar(new SnackBar(content: new Text(value)));
  // }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget loadingIndicator = _load
        ? new Center(
            child: Theme(
            data: ThemeData.light(),
            child: CupertinoActivityIndicator(
              animating: true,
              radius: 20,
            ),
          ))
        : new Container();

    return Scaffold(
      // key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          loadingIndicator,
          // new Align(
          //   child: loadingIndicator,
          //   alignment: FractionalOffset.center,
          // ),
          Container(
            // color: Colors.white,
            height: size.height * .4,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(widget.currentUser.profileUrl),
                    fit: BoxFit.cover)),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.grey.withOpacity(0.1),
                  // child: Text(
                  //   "Blur Background Image in Flutter",
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  // ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.pop(context, false);
                          },
                        ),
                        Text(
                          "EDIT PROFILE",
                          style: GoogleFonts.mcLaren(
                            textStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // GestureDetector(
                        //   child: Icon(
                        //     Icons.exit_to_app,
                        //     color: Colors.white,
                        //   ),
                        //   onTap: () => signOutUser().then((value) {
                        //     Navigator.of(context).pushAndRemoveUntil(
                        //         MaterialPageRoute(
                        //             builder: (context) => FirstScreen()),
                        //         (Route<dynamic> route) => false);
                        //   }),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * .05,
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(70.0),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2.0,
                                ),
                              ]),
                          child: Stack(
                            children: <Widget>[
                              Hero(
                                tag: 'profile',
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundImage: _image == null
                                      ? widget.currentUser.profileUrl == null
                                          ? AssetImage(
                                              'assets/images/profile-image.png',
                                            )
                                          : NetworkImage(
                                              widget.currentUser.profileUrl)
                                      : FileImage(_image),
                                ),
                              ),
                              Positioned(
                                right: 0.0,
                                bottom: 0.0,
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    // color: Colors.blueGrey[100],
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: FloatingActionButton(
                                    // heroTag: null,
                                    elevation: 2.0,
                                    backgroundColor: Colors.pink,
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    onPressed: _getImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: size.height * 0.1,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          width: size.width * .85,
                          height: size.height * .13,
                          child: TextFormField(
                            controller: profileNameTextEditingController,
                            decoration: InputDecoration(
                              labelText: "Your name",
                              // hintText: "John",
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                tooltip: 'Close',
                                onPressed: () {
                                  profileNameTextEditingController.clear();
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.0), // #7449D1
                              ),
                            ),
                            validator: (val) {
                              if (val.length < 3) {
                                return "Please Enter a valid first name!";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 45, vertical: 1),
                          child: TextField(
                            maxLines: 2,
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            controller: bioTextEditingController,
                            decoration: InputDecoration(
                              labelText: 'Bio',
                              fillColor: Colors.black,
                              labelStyle: TextStyle(color: Colors.black),
                              prefixStyle: TextStyle(color: Colors.black),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                tooltip: 'Close',
                                onPressed: () {
                                  bioTextEditingController.clear();
                                },
                              ),
                              errorText:
                                  _validate ? 'name can\'t be empty!' : null,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * .05,
                        ),
                        RaisedButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 5),
                          color: Colors.pink,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white70, width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () {
                            updateProfile(
                              context,
                            );
                            setState(() {
                              _load = true;
                            });
                          },
                          child: Text(
                            "Update",
                          ),
                        ),
                        SizedBox(
                          height: size.height * .03,
                        ),
                        // RaisedButton(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 3),
                        //   color: Colors.blue,
                        //   shape: RoundedRectangleBorder(
                        //     side: BorderSide(color: Colors.white70, width: 1),
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   onPressed: () => signOutUser().then((value) {
                        //     Navigator.of(context).pushAndRemoveUntil(
                        //         MaterialPageRoute(
                        //             builder: (context) => FirstScreen()),
                        //         (Route<dynamic> route) => false);
                        //   }),
                        //   // _logOut(context),
                        //   child: Text(
                        //     "Sign Out",
                        //     style: TextStyle(fontSize: 18, color: Colors.white),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _getImage() async {
    final image = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    print(image.toString());

    setState(() {
      if (!mounted) {
        return;
      }
      _image = File(image.path);
    });

    // File croppedImage = await ImageCropper.cropImage(
    //   sourcePath: _image.path,
    //   aspectRatio: CropAspectRatio(
    //     ratioX: 1,
    //     ratioY: 1,
    //   ),
    //   // aspectRatioPresets: [
    //   //   CropAspectRatioPreset.square,
    //   // ],
    //   androidUiSettings: AndroidUiSettings(
    //     toolbarTitle: 'Image Cropper',
    //     toolbarColor: Colors.black,
    //     toolbarWidgetColor: Colors.white,
    //     initAspectRatio: CropAspectRatioPreset.square,
    //     lockAspectRatio: true,
    //   ),
    //   // iosUiSettings: IOSUiSettings(
    //   //   minimumAspectRatio: 1.0,
    //   // ),
    // );

    // print(croppedImage.toString());

    // setState(() {
    //   _image = croppedImage ?? _image;
    // });
  }
}
