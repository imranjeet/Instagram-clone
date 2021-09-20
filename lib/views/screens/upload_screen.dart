import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:namaste/providers/posts.dart';
import 'package:namaste/util/local_notification.dart';
import 'package:namaste/views/widgets/video_player_page.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class UploadScreen extends StatefulWidget {
  final String currentUserId;

  const UploadScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with AutomaticKeepAliveClientMixin<UploadScreen> {
  File _image;
  File _video;

  bool uploading = false;
  String postId = Uuid().v4();

  TextEditingController discriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  final picker = ImagePicker();

  Future captureImageWithCamera() async {
    Navigator.pop(context);
    final imageFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      _image = File(imageFile.path);
    });
  }

  Future imageFromGallery() async {
    Navigator.pop(context);
    final imageFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = File(imageFile.path);
    });
  }

  captureVideoWithCamera() async {
    Navigator.pop(context);
    final videoFile = await picker.getVideo(
      source: ImageSource.camera,
    );
    setState(() {
      _video = File(videoFile.path);
    });
  }

  videoFromGallery() async {
    Navigator.pop(context);
    final videoFile = await picker.getVideo(
      source: ImageSource.gallery,
    );
    setState(() {
      _video = File(videoFile.path);
    });
  }

  takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title:
                Text("New Post", style: TextStyle(fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Take a picture",
                  style: TextStyle(),
                ),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Select from gallery",
                  style: TextStyle(),
                ),
                onPressed: imageFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  takeVideo(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title:
                Text("New Post", style: TextStyle(fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Take a short video",
                  style: TextStyle(),
                ),
                onPressed: captureVideoWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Select short video from gallery",
                  style: TextStyle(),
                ),
                onPressed: videoFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  displayUploadScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create Post"),
        // automaticallyImplyLeading: false,
        // leading: IconButton(
        //     icon: Icon(Icons.close),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     }),
      ),
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add_photo_alternate,
                    size: 100.0,
                    color: Colors.red,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Text(
                        "Upload Image",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      onPressed: () => takeImage(context),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.video_call,
                    size: 100.0,
                    color: Colors.red,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Text(
                        "Upload Video",
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      onPressed: () => takeVideo(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  clearPostInfo() {
    locationTextEditingController.clear();
    discriptionTextEditingController.clear();

    setState(() {
      _image = null;
      _video = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlacemark = placemark[0];
    String completeAddressInfo =
        '${mPlacemark.subThoroughfare} ${mPlacemark.thoroughfare}, ${mPlacemark.subLocality} ${mPlacemark.locality}, ${mPlacemark.subAdministrativeArea} ${mPlacemark.administrativeArea}, ${mPlacemark.postalCode} ${mPlacemark.country},';
    String specificAddress = '${mPlacemark.locality}, ${mPlacemark.country}';
    print("completeAddressInfo: $completeAddressInfo");
    print(specificAddress);
    locationTextEditingController.text = specificAddress;
  }

  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(icon: Icon(Icons.arrow_back), onPressed: clearPostInfo),
        title: Text(
          "New Post",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        // actions: <Widget>[
        //   FlatButton(
        //     onPressed: uploading
        //         ? null
        //         : () => _uploadPost(
        //             context,
        //             widget.currentUserId,
        //             discriptionTextEditingController.text,
        //             locationTextEditingController.text,
        //             _image == null ? 1 : 2,
        //             _image == null ? _video : _image),
        //     child: Text(
        //       "Share",
        //       style: TextStyle(
        //           color: Colors.black,
        //           fontWeight: FontWeight.bold,
        //           fontSize: 16.0),
        //     ),
        //   ),
        // ],
      ),
      body: uploading
          ? Center(
              child: Theme(
                data: ThemeData.light(),
                child: CupertinoActivityIndicator(
                  animating: true,
                  radius: 20,
                ),
              ),
            )
          : ListView(
              children: <Widget>[
                Container(
                  height: 230.0,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: _image == null
                        ? VideoPlayerScreen(
                            videoPlayerController:
                                VideoPlayerController.file(_video))
                        : AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: FileImage(_image),
                                fit: BoxFit.cover,
                              )),
                            ),
                          ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 12.0)),
                ListTile(
                  // leading: CircleAvatar(
                  //   backgroundImage:
                  //       CachedNetworkImageProvider(widget.gCurrentUser.url),
                  // ),
                  title: Container(
                    width: 250.0,
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: discriptionTextEditingController,
                      decoration: InputDecoration(
                        hintText: "Say something about post..",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.person_pin_circle,
                    size: 36.0,
                  ),
                  title: Container(
                    width: 250.0,
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: locationTextEditingController,
                      decoration: InputDecoration(
                        hintText: "Write the location here..",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50.0,
                  width: 110.0,
                  alignment: Alignment.center,
                  child: RaisedButton.icon(
                    onPressed: getCurrentLocation,
                    icon: Icon(Icons.location_on),
                    label: Text("Get my current location"),
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35.0),
                    ),
                  ),
                ),
                Container(
                  height: 160.0,
                  width: 60.0,
                  alignment: Alignment.center,
                  child: RaisedButton.icon(
                    onPressed: uploading
                        ? null
                        : () => _uploadPost(
                            context,
                            widget.currentUserId,
                            discriptionTextEditingController.text,
                            locationTextEditingController.text,
                            _image == null ? 1 : 2,
                            _image == null ? _video : _image),
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "Post",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // if (_image == null || _video == null) {
    //   return displayUploadScreen();
    // } else if (_image != null) {}
    return _image == null && _video == null
        ? displayUploadScreen()
        : displayUploadFormScreen();
  }

  Future<void> _uploadPost(
    BuildContext context,
    String userId,
    String description,
    String location,
    int isVideo,
    File postFile,
  ) async {
    // showLoaderDialog(context, "Uploading...");

    await Provider.of<Posts>(context, listen: false)
        .addPost(
      userId,
      description,
      location,
      isVideo,
      postFile,
    )
        .then((value) {
      LocalNotification.success(
        context,
        message: 'Video uploaded successfully',
        inPostCallback: true,
      );
      setState(() {});
      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 1;
      });
    });
    // String type = "comment";
    // String value = "replied: $comment";

    // await Provider.of<UserNotifications>(context, listen: false)
    //     .addPushNotification(_currentUserId, widget.video.userId, type, value,
    //         widget.video.thumbnail);
  }
}
