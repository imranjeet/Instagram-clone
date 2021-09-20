import 'package:namaste/models/comment.dart';
import 'package:namaste/models/post.dart';
import 'package:namaste/providers/comments.dart';
import 'package:namaste/providers/user_notifications.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/util/local_notification.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namaste/views/screens/profile.dart';
import 'package:namaste/views/widgets/empty_box.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentBottomSheet extends StatefulWidget {
  final Post post;
  final String currentUserId;

  const CommentBottomSheet({
    Key key,
    this.post,
    this.currentUserId,
  }) : super(key: key);
  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  TextEditingController _commentTextController = TextEditingController();

  Future<void> _addComment(
    int _videoId,
    String _currentUserId,
    String comment,
  ) async {
    await Provider.of<Comments>(context, listen: false)
        .addComment(_videoId, _currentUserId, comment)
        .then((value) {
      LocalNotification.success(
        context,
        message: 'Comment added',
        inPostCallback: true,
      );
      _commentTextController.clear();
      setState(() {});
    });
    String type = "comment";
    String value = "replied: $comment";
    int isVideo = widget.post.isVideo;

    if (_currentUserId != widget.post.userId) {
      await Provider.of<UserNotifications>(context, listen: false)
          .addPushNotification(_currentUserId, widget.post.userId, type, value,
              isVideo, widget.post.postUrl);
    }
  }

  Future<void> _deleteComment(int id) async {
    await Provider.of<Comments>(context, listen: false)
        .deleteComment(id)
        .then((value) {
      LocalNotification.success(
        context,
        message: 'Comment delete',
        inPostCallback: true,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[200],
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        title: Text(
          "Comments",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        // automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_list,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        // height: MediaQuery.of(context).size.height * 0.6,
        child: new Container(
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0))),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Text(
              //   "Comments",
              //   // style: kHeadingTextStyle,
              // ),
              Expanded(child: retrieveComments()),
              // Divider(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: ListTile(
                    title: TextFormField(
                      controller: _commentTextController,
                      decoration: InputDecoration(
                        labelText: "Write comment here...",
                        labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (val) {
                        if (val.length < 1) {
                          return "Comment can\'t be empty!";
                        } else {
                          return null;
                        }
                      },
                    ),
                    trailing: InkWell(
                      child: Icon(
                        Icons.send,
                        size: 28,
                        color: Colors.purple,
                      ),
                      onTap: () {
                        _addComment(
                          widget.post.id,
                          widget.currentUserId,
                          _commentTextController.text,
                        );
                        // widget.currentUserId == null
                        //     ? Navigator.pushNamed(context, '/login')
                        //     : _addComment(
                        //         widget.post.id,
                        //         widget.currentUserId,
                        //         _commentTextController.text,
                        //       );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  retrieveComments() {
    var videoCommentsCount = Provider.of<Comments>(
          context,
          listen: false,
        )
            .commetByVideoId(
              widget.post.id,
            )
            .length ??
        0;
    var commentData = videoCommentsCount > 0
        ? Provider.of<Comments>(context, listen: false)
            .commetByVideoId(widget.post.id)
        : null;
    return commentData == null
        ? Center(
            child: EmptyBoxScreen(
            boxHeight: 200,
          ))
        : Scrollbar(
            child: ListView.builder(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: commentData.length,
              itemBuilder: (ctx, i) => commentItem(commentData[i]),
            ),
          );
  }

  Widget commentItem(Comment comment) {
    var loadedUser = Provider.of<Users>(
      context,
      listen: false,
    ).userfindById(comment.userId);
    DateTime myDatetime = DateTime.parse(comment.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(loadedUser.name + ": " + comment.comment),
              leading: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(
                                userId: comment.userId,
                                currentUserId: widget.currentUserId,
                              )));
                },
                child: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(loadedUser.profileUrl),
                  // loadedUser.profileUrl == null
                  //     ? AssetImage(assetsProfileImage)
                  //     : CachedNetworkImageProvider(loadedUser.profileUrl),
                ),
              ),
              subtitle: Text(
                timeago.format(myDatetime),
              ),
              trailing: widget.currentUserId == comment.userId
                  ? PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          height: 25,
                          value: 1,
                          child: Text(
                            "delete",
                          ),
                        ),
                      ],
                      onSelected: (selection) {
                        switch (selection) {
                          case 1:
                            _deleteComment(comment.id);
                            break;
                        }
                      },
                      icon: Icon(Icons.more_vert),
                      offset: Offset(0, 100),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
