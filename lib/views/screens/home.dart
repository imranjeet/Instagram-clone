import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namaste/providers/comments.dart';
import 'package:namaste/providers/follows.dart';
import 'package:namaste/providers/posts.dart';
import 'package:namaste/providers/reactions.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/views/widgets/post_item.dart';
import 'package:namaste/util/shimmer/shimmer.dart';

import '../directMessage.dart';
import 'dart:math' as math;

class Home extends StatefulWidget {
  final String currentUserId;

  Home({Key key, this.currentUserId}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> _refreshPosts(BuildContext context) async {
    await Provider.of<Posts>(context, listen: false).fetchPosts();
    await Provider.of<Users>(context, listen: false).fetchUsers();
    await Provider.of<Reactions>(context, listen: false).fetchReactions();
    await Provider.of<Comments>(context, listen: false).fetchComments();
    await Provider.of<Follows>(context, listen: false).fetchFollows();
    setState(() {});
  }

  refresh() {
    setState(() {});
  }

  // @override
  // void initState() {
  //   super.initState();
  //   FacebookAudienceNetwork.init(
  //     testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6",
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Feeds"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Transform.rotate(
              angle: math.pi / -5,
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  // size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DirectMessageScreen(
                              currentUserId: widget.currentUserId)));
                },
              ),
            ),
          ],
        ),

        body: FutureBuilder(
            future: Future.wait([
              Provider.of<Posts>(context, listen: false).fetchPosts(),
              Provider.of<Users>(context, listen: false).fetchUsers(),
              Provider.of<Reactions>(context, listen: false).fetchReactions(),
              Provider.of<Comments>(context, listen: false).fetchComments(),
              Provider.of<Follows>(context, listen: false).fetchFollows(),
            ]),
            builder: (
              ctx,
              dataSnapshot,
            ) {
              try {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                      // backgroundColor: Colors.black,
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
                                              margin:
                                                  EdgeInsets.only(right: 10),
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
                  ).items
                    ..shuffle();
                  return RefreshIndicator(
                    backgroundColor: Colors.white,
                    onRefresh: () => _refreshPosts(context),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      itemCount: loadedPosts.length,
                      itemBuilder: (BuildContext context, int index) {
                        // var _num = ((index + 1) ~/ 2).toInt();
                        // if (_num.isEven && _num != 0) {
                        //   return Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: SizedBox(
                        //       width: double.infinity,
                        //       height: 100,
                        //       child: FacebookNativeAd(
                        //         placementId: "YOUR_PLACEMENT_ID",
                        //         adType: NativeAdType.NATIVE_AD,
                        //         width: double.infinity,
                        //         height: 100,
                        //         backgroundColor: Colors.blue,
                        //         titleColor: Colors.white,
                        //         descriptionColor: Colors.white,
                        //         buttonColor: Colors.deepPurple,
                        //         buttonTitleColor: Colors.white,
                        //         buttonBorderColor: Colors.white,
                        //         keepAlive:
                        //             true, //set true if you do not want adview to refresh on widget rebuild
                        //         keepExpandedWhileLoading:
                        //             false, // set false if you want to collapse the native ad view when the ad is loading
                        //         expandAnimationDuraion:
                        //             300, //in milliseconds. Expands the adview with animation when ad is loaded
                        //         listener: (result, value) {
                        //           print("Native Ad: $result --> $value");
                        //         },
                        //       ),
                        //     ),
                        //   );
                        // }
                        return PostItem(
                          notifyParent: refresh,
                          post: loadedPosts[index],
                          currentUserId: widget.currentUserId,
                        );
                      },
                    ),
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

        // ListView.builder(
        //   padding: EdgeInsets.symmetric(horizontal: 20),
        //   itemCount: posts.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     Map post = posts[index];
        //     return PostItem(
        //       img: post['img'],
        //       name: post['name'],
        //       dp: post['dp'],
        //       time: post['time'],
        //     );
        //   },
        // ),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(
        //     Icons.add,
        //     color: Colors.white,
        //   ),
        //   onPressed: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) =>
        //                 UploadScreen(currentUserId: currentUserId)));
        //   },
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
