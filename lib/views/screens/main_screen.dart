import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namaste/providers/comments.dart';
import 'package:namaste/providers/follows.dart';
import 'package:namaste/providers/posts.dart';
import 'package:namaste/providers/reactions.dart';
import 'package:namaste/providers/user_notifications.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/util/dimen.dart';
import 'package:namaste/views/screens/upload_screen.dart';
import 'package:namaste/views/screens/friends.dart';
import 'package:namaste/views/screens/home.dart';
import 'package:namaste/views/screens/profile.dart';

import 'Inbox/screens/inbox_screen.dart';

class MainScreen extends StatefulWidget {
  final String currentUserId;

  const MainScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _isInit = true;
  PageController _pageController;
  int _selectedPage = 0;
  List<Widget> pageList = List<Widget>();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((token) {
      print("firebase_token: $token");
    });
    pushNotification();
    _pageController = PageController(initialPage: 0);
  }

  pushNotification() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // final int recipientId = message["data"]["id"];
        final String title = message["notification"]["title"];
        final String body = message["notification"]["body"];

        // if (recipientId == widget.currentUserId) {
        SnackBar snackBar = SnackBar(
          backgroundColor: Colors.purple,
          content: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                text: "$title: ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500),
                children: <TextSpan>[
                  TextSpan(
                    text: body,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  )
                ]),
          ),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    pageList.add(
      Home(currentUserId: widget.currentUserId),
    );
    pageList.add(
      Friends(currentUserId: widget.currentUserId),
    );
    pageList.add(
      UploadScreen(currentUserId: widget.currentUserId),
    );
    pageList.add(
      InboxScreen(currentUserId: widget.currentUserId),
    );
    pageList.add(
      UserProfile(currentUserId: widget.currentUserId),
    );
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Posts>(context).fetchPosts();
      Provider.of<Users>(context).fetchUsers();
      Provider.of<Reactions>(context).fetchReactions();
      Provider.of<Comments>(context).fetchComments();
      Provider.of<Follows>(context).fetchFollows();
      Provider.of<UserNotifications>(context, listen: false)
          .fetchUserNotifications(widget.currentUserId);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          color: Colors.white,
          height: 50,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Divider(
              //   height: 2,
              //   color: Colors.grey[700],
              // ),
              Container(
                // height: 45,
                child: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPage = 0;
                            });
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.home,
                                color: _selectedPage == 0
                                    ? Colors.blue
                                    : Colors.black,
                                size: 25,
                              ),
                              // Padding(
                              //   padding:
                              //       EdgeInsets.only(top: Dimen.textSpacing),
                              //   child: Text(
                              //     "Home",
                              //     style: TextStyle(
                              //         fontSize: Dimen.bottomNavigationTextSize,
                              //         color: Colors.black),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPage = 1;
                            });
                            // _interstitialAd
                            //   ..load()
                            //   ..show();
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.search,
                                color: _selectedPage == 1
                                    ? Colors.blue
                                    : Colors.black,
                                size: 25,
                              ),
                              // Padding(
                              //   padding:
                              //       EdgeInsets.only(top: Dimen.textSpacing),
                              //   child: Text(
                              //     "Discover",
                              //     style: TextStyle(
                              //         fontSize: Dimen.bottomNavigationTextSize,
                              //         color: Colors.black),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPage = 2;
                            });
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                  width: 45.0,
                                  height: 32.0,
                                  child: Stack(children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 10.0),
                                        width: 100,
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 250, 45, 108),
                                            borderRadius: BorderRadius.circular(
                                                Dimen.createButtonBorder))),
                                    Container(
                                        margin: EdgeInsets.only(right: 10.0),
                                        width: 200,
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 32, 211, 234),
                                            borderRadius: BorderRadius.circular(
                                                Dimen.createButtonBorder))),
                                    Center(
                                        child: Container(
                                      height: double.infinity,
                                      width: 38,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                              Dimen.createButtonBorder)),
                                      child: Icon(
                                        Icons.camera,
                                        size: 20.0,
                                        color: _selectedPage == 2
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                    )),
                                  ]))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPage = 3;
                            });
                            // _interstitialAd
                            //   ..load()
                            //   ..show();
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.notifications,
                                  color: _selectedPage == 3
                                      ? Colors.blue
                                      : Colors.black,
                                  size: 25),
                              // Padding(
                              //   padding:
                              //       EdgeInsets.only(top: Dimen.textSpacing),
                              //   child: Text(
                              //     "Inbox",
                              //     style: TextStyle(
                              //         fontSize: Dimen.bottomNavigationTextSize,
                              //         color: Colors.white),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPage = 4;
                            });
                            // _interstitialAd
                            //   ..load()
                            //   ..show();
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.person,
                                  color: _selectedPage == 4
                                      ? Colors.blue
                                      : Colors.black,
                                  size: 25),
                              // Padding(
                              //   padding:
                              //       EdgeInsets.only(top: Dimen.textSpacing),
                              //   child: Text(
                              //     "Me",
                              //     style: TextStyle(
                              //         fontSize: Dimen.bottomNavigationTextSize,
                              //         color: Colors.white),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedPage,
        children: pageList,
      ),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: "btn1",
      //   onPressed: () async {
      //     await Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) =>
      //                 UploadScreen(currentUserId: widget.currentUserId)));
      //     setState(() {});
      //   },
      //   child: Icon(
      //     Icons.camera,
      //     color: Colors.white,
      //     size: 35,
      //   ),
      //   backgroundColor: Colors.red,
      //   tooltip: 'Capture Picture',
      //   elevation: 8,
      //   splashColor: Colors.grey,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         physics: NeverScrollableScrollPhysics(),
//         controller: _pageController,
//         onPageChanged: onPageChanged,
//         children: <Widget>[
//           Home(currentUserId: widget.currentUserId),
//           Friends(currentUserId: widget.currentUserId),
//           Friends(currentUserId: widget.currentUserId),
//           // UploadScreen(
//           //   currentUserId: widget.currentUserId,
//           // ),
//           // Chats(),
//           // Notifications(),
//           InboxScreen(currentUserId: widget.currentUserId),
//           Profile(
//               currentUserId: widget.currentUserId,
//               userId: widget.currentUserId),
//         ],
//       ),
//       bottomNavigationBar: Theme(
//         data: Theme.of(context).copyWith(
//           // sets the background color of the `BottomNavigationBar`
//           canvasColor: Theme.of(context).primaryColor,
//           // sets the active color of the `BottomNavigationBar` if `Brightness` is light
//           primaryColor: Theme.of(context).accentColor,
//           textTheme: Theme.of(context).textTheme.copyWith(
//                 caption: TextStyle(color: Colors.grey[500]),
//               ),
//         ),
//         child: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           items: <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.home,
//               ),
//               // title: Text(""),
//               label: '',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.search,
//               ),
//               label: '',
//               // title: Text(""),
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.group,
//               ),
//               label: '',
//               // title: Text(""),
//             ),
//             BottomNavigationBarItem(
//               // icon: IconBadge(icon: Icons.notifications),
//               icon: Icon(Icons.notifications),
//               label: '',
//               // title: Text(""),
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person),
//               label: '',
//               // title: Text(""),
//             ),
//           ],
//           onTap: navigationTapped,
//           currentIndex: _page,
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         heroTag: "btn1",
//         onPressed: () async {
//           await Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       UploadScreen(currentUserId: widget.currentUserId)));
//           setState(() {});
//         },
//         child: Icon(
//           Icons.camera,
//           color: Colors.white,
//           size: 35,
//         ),
//         backgroundColor: Colors.red,
//         tooltip: 'Capture Picture',
//         elevation: 8,
//         splashColor: Colors.grey,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }

//   void navigationTapped(int page) {
//     _pageController.jumpToPage(page);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _pageController.dispose();
//   }

//   void onPageChanged(int page) {
//     setState(() {
//       this._page = page;
//     });
//   }
// }
