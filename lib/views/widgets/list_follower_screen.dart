import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namaste/models/follow.dart';
import 'package:namaste/providers/follows.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/util/local_notification.dart';
import 'package:namaste/views/screens/profile.dart';

import 'empty_box.dart';


class ListFollowerScreen extends StatefulWidget {
  final String currentUserId;
  final String userId;
  final int tabIndex;

  const ListFollowerScreen(
      {Key key, this.tabIndex, this.currentUserId, this.userId})
      : super(key: key);
  @override
  _ListFollowerScreenState createState() => _ListFollowerScreenState();
}

class _ListFollowerScreenState extends State<ListFollowerScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(
        length: 2, vsync: this, initialIndex: widget.tabIndex);
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    var loadedUser = Provider.of<Users>(
      context,
      listen: false,
    ).userfindById(widget.userId);

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

    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text(
          loadedUser.username == null
              ? loadedUser.name == null ? "Followers" : loadedUser.name
              : "@${loadedUser.username}" ,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        // leading: IconButton(
        //     icon: Icon(
        //       Icons.arrow_back_ios,
        //       color: Colors.black,
        //     ),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     }),
        bottom: TabBar(
          unselectedLabelColor: Colors.black,
          labelColor: Colors.blue,
          tabs: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                "Followers",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                "Following",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
          controller: _tabController,
          indicatorColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        bottomOpacity: 1,
      ),
      body: TabBarView(
        children: [
          userFollowersCount == 0 ? EmptyBoxScreen() : retrieveFollowers(),
          userFollowingsCount == 0 ? EmptyBoxScreen() : retrieveFollowing(),
        ],
        controller: _tabController,
      ),
    );
  }

  retrieveFollowers() {
    var userFollowers = Provider.of<Follows>(
      context,
      listen: false,
    ).followersByUserId(
      widget.userId,
    );

    return ListView.builder(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: userFollowers.length,
      itemBuilder: (context, i) {
        bool isFollower = true;
        return itemListTile(
            userFollowers[i], userFollowers[i].userId, isFollower);
      },
    );
  }

  retrieveFollowing() {
    var userFollowings = Provider.of<Follows>(
      context,
      listen: false,
    ).followingsByUserId(
      widget.userId,
    );

    return ListView.builder(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: userFollowings.length,
      itemBuilder: (context, i) {
        bool isFollower = false;

        return itemListTile(
            userFollowings[i], userFollowings[i].followUserId, isFollower);
      },
    );
  }

  itemListTile(Follow item, String itemUserId, bool isFollower) {
    var loadedUser = Provider.of<Users>(
      context,
      listen: false,
    ).userfindById(itemUserId);
    bool ownLoadedProfile = widget.currentUserId == loadedUser.uId;
    bool ownProfile = widget.currentUserId == widget.userId;

    var currentUserFollow = Provider.of<Follows>(
          context,
          listen: false,
        ).followFindByUserId(loadedUser.uId, widget.currentUserId).length ??
        0;
    var userFollow = currentUserFollow > 0
        ? Provider.of<Follows>(
            context,
            listen: false,
          ).followFindByUserId(loadedUser.uId, widget.currentUserId)
        : null;
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profile(
                      currentUserId: widget.currentUserId,
                      userId: loadedUser.uId,
                    )));
      },
      child: Container(
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(loadedUser.profileUrl),
                // .profileUrl == null
                //     ? AssetImage(assetsProfileImage)
                //     : CachedNetworkImageProvider(loadedUser.profileUrl),
              ),
              title: Text(
                loadedUser.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                loadedUser.username == null
                    ? loadedUser.bio == null ? "" : loadedUser.bio
                    : "@${loadedUser.username}",
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: ownProfile
                  ? isFollower
                      ? currentUserFollow > 0
                          ? SizedBox.shrink()
                          : createButtonTitleAndFunction(
                              title: "Follow",
                              kColor: Colors.orange,
                              performFunction: () {
                                _addFollow(widget.currentUserId, loadedUser.uId);
                              },
                            )
                      : createButtonTitleAndFunction(
                          title: "Unfollow",
                          kColor: Colors.purple,
                          performFunction: () {
                            _unFollow(item.id);
                          },
                        )
                  : isFollower
                      ? currentUserFollow > 0
                          ? createButtonTitleAndFunction(
                              title: "Unfollow",
                              kColor: Colors.purple,
                              performFunction: () {
                                _unFollow(userFollow.elementAt(0).id);
                              },
                            )
                          : ownLoadedProfile
                              ? SizedBox.shrink()
                              : createButtonTitleAndFunction(
                                  title: "Follow",
                                  kColor: Colors.orange,
                                  performFunction: () {
                                    _addFollow(
                                        widget.currentUserId, loadedUser.uId);
                                  },
                                )
                      : currentUserFollow > 0
                          ? createButtonTitleAndFunction(
                              title: "Unfollow",
                              kColor: Colors.purple,
                              performFunction: () {
                                _unFollow(userFollow.elementAt(0).id);
                              },
                            )
                          : ownLoadedProfile
                              ? SizedBox.shrink()
                              : createButtonTitleAndFunction(
                                  title: "Follow",
                                  kColor: Colors.orange,
                                  performFunction: () {
                                    _addFollow(
                                        widget.currentUserId, loadedUser.uId);
                                  },
                                ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Container createButtonTitleAndFunction(
      {String title, Function performFunction, Color kColor}) {
    return Container(
      // padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
          onPressed: performFunction,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: MediaQuery.of(context).size.height * 0.042,
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16.0),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kColor,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6.0),
            ),
          )),
    );
  }
}
