import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:namaste/models/post.dart';
import 'package:namaste/providers/comments.dart';
import 'package:namaste/providers/posts.dart';
import 'package:namaste/providers/reactions.dart';
import 'package:namaste/providers/user_notifications.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/util/local_notification.dart';
import 'package:namaste/views/screens/comment_screen.dart';
import 'package:namaste/views/screens/profile.dart';
import 'package:video_player/video_player.dart';

import 'video_player_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostItem extends StatefulWidget {
  final Function() notifyParent;
  final Post post;
  final String currentUserId;

  PostItem({Key key, this.post, this.currentUserId, this.notifyParent}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  // var showHeart = true;
  Future<void> addLike(int _videoId, String _currentUserId, int _number) async {
    await Provider.of<Reactions>(context, listen: false)
        .addLike(_videoId, _currentUserId, _number)
        .then((value) {
      LocalNotification.success(
        context,
        message: 'Added to Like post',
        inPostCallback: true,
      );
      setState(() {});
    });

    String type = "like";
    String value = "liked your post.";
    int isVideo = widget.post.isVideo;
    if (_currentUserId != widget.post.userId) {
      await Provider.of<UserNotifications>(context, listen: false)
          .addPushNotification(_currentUserId, widget.post.userId, type, value,
              isVideo, widget.post.postUrl);
    }
  }


  Future<void> _deleteReaction(int id) async {
    await Provider.of<Reactions>(context, listen: false)
        .deleteReaction(id)
        .then((value) {
      LocalNotification.success(
        context,
        message: 'Removed from Liked videos',
        inPostCallback: true,
      );
      setState(() {});
    });
  }

  Future<void> _deteteVideos(int id) async {
    await Provider.of<Posts>(context, listen: false)
        .deleteVideo(id)
        .then((value) {
      LocalNotification.success(
        context,
        message: 'Post delete',
        inPostCallback: true,
      );
      setState(() {});
    });
    // await Provider.of<Posts>(context, listen: false).fetchPosts();
    widget.notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    DateTime myDatetime = DateTime.parse(widget.post.createdAt);
    var postUser = Provider.of<Users>(
      context,
      listen: false,
    ).userfindById(widget.post.userId);

    var videoLikesCount = Provider.of<Reactions>(
          context,
          listen: false,
        )
            .reactionByVideoId(
              widget.post.id,
            )
            .length ??
        0;
    var _formattedNumberLikes = NumberFormat.compact().format(videoLikesCount);
    var currentUserLikes = Provider.of<Reactions>(
      context,
      listen: false,
    ).reactionfindByuserId(widget.post.id, widget.currentUserId).length;
    var userLike = currentUserLikes > 0
        ? Provider.of<Reactions>(
            context,
            listen: false,
          ).reactionfindByuserId(widget.post.id, widget.currentUserId)
        : null;

    var videoCommentsCount = Provider.of<Comments>(
          context,
          listen: false,
        )
            .commetByVideoId(
              widget.post.id,
            )
            .length ??
        0;

    var _formattedNumberComments =
        NumberFormat.compact().format(videoCommentsCount);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                ListTile(
                  leading: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(
                                    currentUserId: widget.currentUserId,
                                    userId: postUser.uId,
                                  )));
                    },
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        postUser.profileUrl,
                      ),
                    ),
                  ),
                  contentPadding: EdgeInsets.only(left: 5.0, right: 5.0),
                  title: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(
                                    currentUserId: widget.currentUserId,
                                    userId: postUser.uId,
                                  )));
                    },
                    child: Text(
                      postUser.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: widget.post.location == null
                      ? SizedBox.shrink()
                      : Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              size: 15,
                              color: Colors.grey,
                            ),
                            Text(
                              widget.post.location,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(top: 15.0, right: 30.0),
                    child: Text(
                      timeago.format(myDatetime),
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                widget.currentUserId == widget.post.userId
                    ? Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton<int>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              height: 15,
                              value: 1,
                              child: Text(
                                "delete",
                              ),
                            ),
                          ],
                          onSelected: (selection) {
                            switch (selection) {
                              case 1:
                                _deteteVideos(widget.post.id);
                                break;
                            }
                          },
                          icon: Icon(
                            Icons.more_vert,
                            size: 30,
                            color: Colors.black,
                          ),
                          offset: Offset(0, 50),
                        ))
                    : SizedBox.shrink(),
              ],
            ),
            widget.post.description == null
                ? SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0, left: 8.0, right: 8.0),
                    child: Text(
                      widget.post.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                    ),
                  ),
            widget.post.isVideo == 1
                ? GestureDetector(
                    onDoubleTap: () => () {},
                    child: VideoPlayerScreen(
                        videoPlayerController:
                            VideoPlayerController.network(widget.post.postUrl)),
                  )
                : GestureDetector(
                    onDoubleTap: () => () {},
                    child: Image.network(
                      widget.post.postUrl,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    currentUserLikes > 0
                        ? InkWell(
                            onTap: () {
                              _deleteReaction(userLike.elementAt(0).id);
                            },
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 35,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              addLike(widget.post.id, widget.currentUserId, 1);
                            },
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                              size: 35,
                            ),
                          ),
                    Text(
                      "$_formattedNumberLikes",
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentBottomSheet(
                                  post: widget.post,
                                  currentUserId: widget.currentUserId),
                            ));
                        setState(() {});
                        // showBottomSheet(
                        //   context: context,
                        //   builder: (ctx) => CommentBottomSheet(
                        //       post: widget.post,
                        //       currentUserId: widget.currentUserId),
                        // );
                      },
                      child: Icon(
                        Icons.comment,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),
                    Text(
                      "$_formattedNumberComments",
                    ),
                  ],
                ),
                IconButton(icon: Icon(Icons.share), onPressed: () {}),
              ],
            ),
            
          ],
        ),
        // onTap: () {},
      ),
    );
  }
}
