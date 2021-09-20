import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namaste/models/user_notification.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/views/screens/profile.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class NotificationListItem extends StatelessWidget {
  final UserNotification userNotification;
  final String currentUserId;

  const NotificationListItem(
      {Key key, this.userNotification, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var notificationUser = Provider.of<Users>(
      context,
      listen: false,
    ).userfindById(userNotification.myUserId);
    // bool ownProfile = currentUserId == notificationUser.uId;
    DateTime notificationtime = DateTime.parse(userNotification.createdAt);
    return Container(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 6,
            ),
            leading: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(
                              currentUserId: currentUserId,
                              userId: notificationUser.uId,
                            )));
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage:
                    CachedNetworkImageProvider(notificationUser.profileUrl),
              ),
            ),
            title: RichText(
              text: TextSpan(
                  text: "${notificationUser.name}: ",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600),
                  children: <TextSpan>[
                    TextSpan(
                      text: userNotification.value,
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    )
                  ]),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              timeago.format(notificationtime),
            ),
            trailing: userNotification.optionalImageUrl == null
                ? SizedBox.shrink()
                : userNotification.isVideo == 1
                    ? Container(
                        width: 50,
                        height: 100,
                        child: NotificationImage(
                          videoUrl: userNotification.optionalImageUrl,
                        ),
                      )
                    : CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: 50,
                        height: 100,
                        imageUrl: userNotification.optionalImageUrl,
                      ),
            // Image.network(
            //     userNotification.optionalImageUrl,
            //     width: 50,
            //     height: 100,
            //   )
          ),
          Divider(),
        ],
      ),
    );
  }
}

class NotificationImage extends StatefulWidget {
  final String videoUrl;

  const NotificationImage({Key key, this.videoUrl}) : super(key: key);
  @override
  _NotificationImageState createState() => _NotificationImageState();
}

class _NotificationImageState extends State<NotificationImage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 1 / 2, child: VideoPlayer(_controller));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
