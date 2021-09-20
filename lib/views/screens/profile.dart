
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:namaste/auth/controllers/authentications.dart';
import 'package:namaste/auth/pages/loginScreen.dart';
import 'package:namaste/models/user.dart';
import 'package:namaste/providers/follows.dart';
import 'package:namaste/providers/posts.dart';
import 'package:namaste/providers/user_notifications.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/util/local_notification.dart';
import 'package:namaste/views/widgets/ImageFromVideo.dart';
import 'package:namaste/views/widgets/list_follower_screen.dart';
import 'package:namaste/views/widgets/post_item.dart';
import 'package:namaste/util/shimmer/shimmer.dart';

import '../profile_edit_screen.dart';
import 'Inbox/Chat/services/database.dart';
import 'Inbox/Chat/views/chat.dart';

class UserProfile extends StatelessWidget {
  final String currentUserId;

  const UserProfile({Key key, this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        Provider.of<Users>(context, listen: false).fetchUsers(),
      ]),
      builder: (
        ctx,
        dataSnapshot,
      ) {
        try {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Theme(
              data: ThemeData.light(),
              child: CupertinoActivityIndicator(
                animating: true,
                radius: 20,
              ),
            ));
          } else {
            return Profile(currentUserId: currentUserId, userId: currentUserId);
          }
        } catch (error) {
          print(error);
          return AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        }
      },
    );
  }
}

class Profile extends StatefulWidget {
  final String currentUserId;
  final String userId;

  const Profile({Key key, this.currentUserId, this.userId}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DatabaseMethods databaseMethods = new DatabaseMethods();

  

  Future<void> _addFollow(String userId, String followedUserId) async {
    await Provider.of<Follows>(context, listen: false)
        .addFollow(
      userId,
      followedUserId,
    )
        .then((value) {
      LocalNotification.success(
        context,
        message: 'Following start',
        inPostCallback: true,
      );
      setState(() {});
    });
    String type = "follow";
    String value = "started following you.";
    int isVideo = 2;
    String thumbUrl = "";

    await Provider.of<UserNotifications>(context, listen: false)
        .addPushNotification(
            userId, followedUserId, type, value, isVideo, thumbUrl);
  }

  Future<void> _unFollow(int id) async {
    await Provider.of<Follows>(context, listen: false)
        .deleteFollow(id)
        .then((value) {
      LocalNotification.success(
        context,
        message: 'Removed from following',
        inPostCallback: true,
      );
      setState(() {});
    });
  }

  // Future<void> _deleteAllCache() async {
  //   await _flutterVideoCompress.deleteAllCache();
  // }

  void _showLoginScreen() {
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  _navigateEditProfile(BuildContext context, User loadedUser) async {
    // var result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => ProfileEdit(
    //             currentUser: loadedUser,
    //           )),
    // );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var loadedUser = Provider.of<Users>(
      context,
      listen: false,
    ).userfindById(widget.userId);
    var loadedPosts = Provider.of<Posts>(
      context,
      listen: false,
    ).videoById(widget.userId);

    bool ownProfile = widget.currentUserId == widget.userId;

    var userFollowersCount = Provider.of<Follows>(
          context,
          listen: false,
        )
            .followersByUserId(
              widget.userId,
            )
            .length ??
        0;
    var userFollowingsCount = Provider.of<Follows>(
          context,
          listen: false,
        )
            .followingsByUserId(
              widget.userId,
            )
            .length ??
        0;
    var currentUserFollow = Provider.of<Follows>(
          context,
          listen: false,
        ).followFindByUserId(widget.userId, widget.currentUserId).length ??
        0;
    var followUser = currentUserFollow > 0
        ? Provider.of<Follows>(
            context,
            listen: false,
          ).followFindByUserId(widget.userId, widget.currentUserId)
        : null;

    var loadedVideos = Provider.of<Posts>(
      context,
      listen: false,
    ).videoById(widget.userId).reversed.toList();
    return Scaffold(
      appBar: AppBar(
        actions: [
          ownProfile
              ? IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    signOutUser().then((value) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false);
                    });
                  })
              : SizedBox.shrink()
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.02),
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  loadedUser.profileUrl,
                ),
                radius: 50,
              ),
              SizedBox(height: 10),
              Text(
                loadedUser.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 3),
              loadedUser.bio == null
                  ? Text("Whoever is happy will make others happy too.")
                  : Text(
                      loadedUser.bio,
                      // style: TextStyle(),
                    ),
              SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ownProfile
                      ? SizedBox.shrink()
                      : FlatButton(
                          child: Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                          color: Colors.grey,
                          onPressed: () {
                            sendMessage(widget.currentUserId, loadedUser.uId);
                          },
                        ),
                  SizedBox(width: 10),
                  ownProfile
                      ? FlatButton(
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileEdit(currentUser: loadedUser)));
                            setState(() {});
                          },
                        )
                      : currentUserFollow > 0
                          ? FlatButton(
                              child: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 30,
                              ),
                              color: Colors.red,
                              onPressed: () {
                                _unFollow(followUser.elementAt(0).id);
                              },
                            )
                          : FlatButton(
                              child: Icon(
                                Icons.add,
                                size: 30,
                                color: Colors.white,
                              ),
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                _addFollow(widget.currentUserId, widget.userId);
                              },
                            ),
                ],
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildCategory("Posts", loadedPosts.length),
                    InkWell(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListFollowerScreen(
                                        currentUserId: widget.currentUserId,
                                        userId: widget.userId,
                                        tabIndex: 0,
                                      )));
                          setState(() {});
                        },
                        child: _buildCategory("Followers", userFollowersCount)),
                    InkWell(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListFollowerScreen(
                                        currentUserId: widget.currentUserId,
                                        userId: widget.userId,
                                        tabIndex: 1,
                                      )));
                          setState(() {});
                        },
                        child:
                            _buildCategory("Following", userFollowingsCount)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                // padding: EdgeInsets.all(3),
                itemCount: loadedVideos.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200 / 300,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserPosts(
                                    // loadedPosts: loadedVideos,
                                    currentUserId: widget.currentUserId,
                                    userId: widget.userId,
                                    selectedIndex: index,
                                  )));
                      setState(() {});
                    },
                    child: Padding(
                      padding: EdgeInsets.all(2.0),
                      child: loadedVideos[index].isVideo == 1
                          ? ImageShowFromVideo(
                              videoUrl: loadedVideos[index].postUrl,
                            )
                          : Image.network(
                              loadedVideos[index].postUrl,
                              fit: BoxFit.cover,
                            ),
                      // Image.asset(
                      //   "assets/images/cm${random.nextInt(10)}.jpeg",
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String title, int number) {
    var _number = NumberFormat.compact().format(number);
    return Column(
      children: <Widget>[
        Text(
          "$_number",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(),
        ),
      ],
    );
  }

  sendMessage(String myId, String sendUserId) {
    List<String> users = [myId, sendUserId];

    String chatRoomId = getChatRoomId(myId, sendUserId);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
    };

    databaseMethods.addChatRoom(chatRoom, chatRoomId);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                chatRoomId: chatRoomId,
                currentUserId: myId,
                sendUserId: sendUserId)));
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }
}

class UserPosts extends StatefulWidget {
  // final List<Post> loadedPosts;
  final String currentUserId;
  final String userId;
  final int selectedIndex;

  const UserPosts(
      {Key key,
      // this.loadedPosts,
      this.currentUserId,
      this.selectedIndex,
      this.userId})
      : super(key: key);

  @override
  _UserPostsState createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: Future.wait([
            Provider.of<Posts>(context, listen: false).fetchPosts(),
            Provider.of<Users>(context, listen: false).fetchUsers(),
            // Provider.of<Reactions>(context, listen: false).fetchReactions(),
            // Provider.of<Comments>(context, listen: false).fetchComments(),
            // Provider.of<Follows>(context, listen: false).fetchFollows(),
          ]),
          builder: (
            ctx,
            dataSnapshot,
          ) {
            try {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                    body: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Card(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[400],
                                highlightColor: Colors.grey[100],
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //                   <--- left side
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  )),
                                  margin: EdgeInsets.only(
                                    top: 15,
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: 15, left: 5),
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                left: 10,
                                              ),
                                              height: 24,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Container(
                                            height: 10,
                                            margin: EdgeInsets.only(right: 10),
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        height: 200,
                                        color: Colors.grey,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 24),
                                        child: Container(
                                          height: 24,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        })

                    //     Center(
                    //         child: Theme(
                    //   data: ThemeData.light(),
                    //   child: CupertinoActivityIndicator(
                    //     animating: true,
                    //     radius: 20,
                    //   ),
                    // ))
                    );

                // } else if (dataSnapshot.hasData == null) {
                //   return EmptyBoxScreen();
              } else {
                var loadedPosts = Provider.of<Posts>(
                  context,
                  listen: false,
                ).videoById(widget.userId).reversed.toList();
                return ScrollablePositionedList.builder(
                  initialScrollIndex: widget.selectedIndex,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  itemCount: loadedPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PostItem(
                      notifyParent: refresh,
                      post: loadedPosts[index],
                      currentUserId: widget.currentUserId,
                    );
                  },
                );
              }
            } catch (error) {
              print(error);
              return AlertDialog(
                title: Text('An error occurred!'),
                content: Text('Something went wrong.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              );
            }
          }),
    );
  }
}
//   refresh() {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Posts"),
//         centerTitle: true,
//       ),
//       body: ScrollablePositionedList.builder(
//         initialScrollIndex: widget.selectedIndex,
//         padding: EdgeInsets.symmetric(horizontal: 5),
//         itemCount: widget.loadedPosts.length,
//         itemBuilder: (BuildContext context, int index) {
//           return PostItem(
//             notifyParent: refresh,
//             post: widget.loadedPosts[index],
//             currentUserId: widget.currentUserId,
//           );
//         },
//       ),
//     );
//   }
// }
