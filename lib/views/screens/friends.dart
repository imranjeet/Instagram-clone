import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:namaste/models/post.dart';
import 'package:namaste/providers/comments.dart';
import 'package:namaste/providers/follows.dart';
import 'package:namaste/providers/posts.dart';
import 'package:namaste/providers/reactions.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/util/constant.dart';
import 'package:namaste/views/screens/profile.dart';
import 'package:namaste/views/widgets/ImageFromVideo.dart';
import 'package:namaste/views/widgets/empty_box.dart';
import 'package:namaste/util/shimmer/shimmer.dart';
import 'package:namaste/views/widgets/post_item.dart';

class Friends extends StatefulWidget {
  final String currentUserId;

  const Friends({Key key, this.currentUserId}) : super(key: key);
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  Future<void> _refreshPosts(BuildContext context) async {
    await Provider.of<Posts>(context, listen: false).fetchPosts();
    await Provider.of<Users>(context, listen: false).fetchUsers();
    await Provider.of<Reactions>(context, listen: false).fetchReactions();
    await Provider.of<Comments>(context, listen: false).fetchComments();
    await Provider.of<Follows>(context, listen: false).fetchFollows();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // var loadedUser = Provider.of<Users>(
    //           context,
    //           listen: false,
    //         ).items;
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        centerTitle: true,
        // title: TextField(
        //   decoration: InputDecoration.collapsed(
        //     hintText: 'Search',
        //   ),
        // ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
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
                    body: SingleChildScrollView(
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      primary: false,
                      // padding: EdgeInsets.all(3),
                      itemCount: 12,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 200 / 300,
                      ),
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
                                // margin: EdgeInsets.only(
                                //   top: 15,
                                // ),
                                child: Container(
                                  // margin: EdgeInsets.only(top: 15),
                                  height: 200,
                                  color: Colors.grey,
                                ),
                                // child: Column(
                                //   children: <Widget>[
                                //     Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.center,
                                //       children: <Widget>[
                                //         Container(
                                //           margin: EdgeInsets.only(
                                //               right: 15, left: 5),
                                //           height: 40,
                                //           width: 40,
                                //           decoration: BoxDecoration(
                                //             shape: BoxShape.circle,
                                //             color: Colors.white,
                                //           ),
                                //         ),
                                //         Expanded(
                                //           child: Container(
                                //             padding: EdgeInsets.only(
                                //               left: 10,
                                //             ),
                                //             height: 24,
                                //             color: Colors.grey,
                                //           ),
                                //         ),
                                //         Container(
                                //           height: 10,
                                //           margin: EdgeInsets.only(right: 10),
                                //           color: Colors.grey,
                                //         )
                                //       ],
                                //     ),
                                //     Container(
                                //       margin: EdgeInsets.only(top: 15),
                                //       height: 200,
                                //       color: Colors.grey,
                                //     ),
                                //     Padding(
                                //       padding: const EdgeInsets.symmetric(
                                //           vertical: 10, horizontal: 24),
                                //       child: Container(
                                //         height: 24,
                                //         color: Colors.grey,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ),
                            ),
                          ),
                        );
                      }),
                ));
              } else if (dataSnapshot.hasData == null) {
                return EmptyBoxScreen();
              } else {
                var loadedPosts = Provider.of<Posts>(
                  context,
                  listen: false,
                ).items
                  ..shuffle();
                return RefreshIndicator(
                  backgroundColor: Colors.white,
                  onRefresh: () => _refreshPosts(context),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    primary: false,
                    // padding: EdgeInsets.all(3),
                    itemCount: loadedPosts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 200 / 300,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreenPosts(
                                        loadedPosts: loadedPosts,
                                        currentUserId: widget.currentUserId,
                                        selectedIndex: index,
                                      )));
                        },
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: loadedPosts[index].isVideo == 1
                              ? ImageShowFromVideo(
                                  videoUrl: loadedPosts[index].postUrl,
                                )
                              : CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: loadedPosts[index].postUrl,
                                ),
                          // Image.asset(
                          //   "assets/images/cm${random.nextInt(10)}.jpeg",
                          //   fit: BoxFit.cover,
                          // ),
                        ),
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
      // body: ListView.separated(
      //   padding: EdgeInsets.all(10),
      //   separatorBuilder: (BuildContext context, int index) {
      //     return Align(
      //       alignment: Alignment.centerRight,
      //       child: Container(
      //         height: 0.5,
      //         width: MediaQuery.of(context).size.width / 1.3,
      //         child: Divider(),
      //       ),
      //     );
      //   },
      //   itemCount: friends.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     Map friend = friends[index];
      //     return Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //       child: ListTile(
      //         leading: CircleAvatar(
      //           backgroundImage: AssetImage(
      //             friend['dp'],
      //           ),
      //           radius: 25,
      //         ),
      //         contentPadding: EdgeInsets.all(0),
      //         title: Text(friend['name']),
      //         subtitle: Text(friend['status']),
      //         trailing: friend['isAccept']
      //             ? FlatButton(
      //                 child: Text(
      //                   "Unfollow",
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                   ),
      //                 ),
      //                 color: Colors.grey,
      //                 onPressed: () {},
      //               )
      //             : FlatButton(
      //                 child: Text(
      //                   "Follow",
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                   ),
      //                 ),
      //                 color: Theme.of(context).accentColor,
      //                 onPressed: () {},
      //               ),
      //         onTap: () {},
      //       ),
      //     );
      //   },
      // ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {}

  @override
  Widget buildSuggestions(BuildContext context) {
    var loadedUser = Provider.of<Users>(
      context,
      listen: false,
    ).items;

    final suggestionList = query.isEmpty
        ? loadedUser
        : loadedUser
            .where((p) => p.name.toLowerCase().startsWith(query))
            .toList();
    return ListView.builder(
      itemBuilder: (ctx, i) => ListTile(
        onTap: () async {
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Profile(
                        userId: suggestionList[i].uId,
                        currentUserId: user.uid,
                      )));
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            suggestionList[i].profileUrl,
          ),
          radius: 25,
        ),
        title: RichText(
          text: TextSpan(
              text: suggestionList[i].name.substring(0, query.length),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: suggestionList[i].name.substring(query.length),
                  style: TextStyle(color: Colors.grey),
                ),
              ]),
        ),
        // title: Text(suggestionList[i].name),
      ),
      itemCount: suggestionList.length,
    );
  }
}

class SearchScreenPosts extends StatefulWidget {
  final List<Post> loadedPosts;
  final String currentUserId;
  // final String userId;
  final int selectedIndex;

  const SearchScreenPosts(
      {Key key, this.loadedPosts, this.currentUserId, this.selectedIndex})
      : super(key: key);
  @override
  _SearchScreenPostsState createState() => _SearchScreenPostsState();
}

class _SearchScreenPostsState extends State<SearchScreenPosts> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
        centerTitle: true,
      ),
      body: ScrollablePositionedList.builder(
        initialScrollIndex: widget.selectedIndex,
        padding: EdgeInsets.symmetric(horizontal: 5),
        itemCount: widget.loadedPosts.length,
        itemBuilder: (BuildContext context, int index) {
          return PostItem(
            notifyParent: refresh,
            post: widget.loadedPosts[index],
            currentUserId: widget.currentUserId,
          );
        },
      ),
    );
  }
}
