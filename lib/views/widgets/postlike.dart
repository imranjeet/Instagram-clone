
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:social_app_ui/models/post.dart';

// class PostLike extends StatefulWidget {
//   final String currentUserId;
//   final Post post;

//   const PostLike({Key key, this.currentUserId, this.post}) : super(key: key);

  

//   @override
//   _PostLikeState createState() => _PostLikeState();
// }

// class _PostLikeState extends State<PostLike> {
//   Future<void> updateLike(
//       int _videoId, String _currentUserId, int _number) async {
//     await Provider.of<Reactions>(context, listen: false)
//         .addLike(_videoId, _currentUserId, _number)
//         .then((value) {
//       LocalNotification.success(
//         context,
//         message: 'Added to Like videos',
//         inPostCallback: true,
//       );
//       setState(() {});
//     });

//     String type = "like";
//     String value = "liked your video.";

//     await Provider.of<UserNotifications>(context, listen: false)
//         .addPushNotification(_currentUserId, widget.videoUserId, type, value,
//             widget.optionalImageUrl);
//   }

//   Future<void> _deleteReaction(int id) async {
//     await Provider.of<Reactions>(context, listen: false)
//         .deleteReaction(id)
//         .then((value) {
//       LocalNotification.success(
//         context,
//         message: 'Removed from Liked videos',
//         inPostCallback: true,
//       );
//       setState(() {});
//     });
//   }

//   void _showLoginScreen() {
//     Navigator.push(
//         context, MaterialPageRoute(builder: (context) => LoginScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     var videoLikesCount = Provider.of<Reactions>(
//           context,
//           listen: false,
//         )
//             .reactionByVideoId(
//               widget.videoId,
//             )
//             .length ??
//         0;
//     var _formattedNumber = NumberFormat.compact().format(videoLikesCount);
//     var currentUserLikes = Provider.of<Reactions>(
//       context,
//       listen: false,
//     ).reactionfindByuserId(widget.videoId, widget.currentUserId).length;
//     var userLike = currentUserLikes > 0
//         ? Provider.of<Reactions>(
//             context,
//             listen: false,
//           ).reactionfindByuserId(widget.videoId, widget.currentUserId)
//         : null;

//     return Padding(
//       padding: EdgeInsets.only(top: 10, bottom: 10),
//       child: Column(
//         children: <Widget>[
//           currentUserLikes > 0
//               ? InkWell(
//                   onTap: () async {
//                     // FirebaseUser user =
//                     //     await FirebaseAuth.instance.currentUser();
//                     widget.currentUserId == null
//                         ? _showLoginScreen()
//                         : _deleteReaction(userLike.elementAt(0).id);
//                   },
//                   child: Icon(
//                     Icons.favorite,
//                     color: Colors.red,
//                     size: 35,
//                   ),
//                 )
//               : InkWell(
//                   onTap: () {
//                     widget.currentUserId == null
//                         ? _showLoginScreen()
//                         : updateLike(widget.videoId, widget.currentUserId, 1);
//                   },
//                   child: Icon(
//                     Icons.favorite_border,
//                     color: Colors.red,
//                     size: 35,
//                   ),
//                 ),
//           Padding(
//             padding: EdgeInsets.only(
//               top: 1.0,
//             ),
//             child: Text(
//               "$_formattedNumber",
//               style: TextStyle(fontSize: 10, color: Colors.white),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
