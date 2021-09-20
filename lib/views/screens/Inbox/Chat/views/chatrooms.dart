
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namaste/providers/users.dart';
import 'package:namaste/views/screens/Inbox/Chat/helper/constants.dart';
import 'package:namaste/views/screens/Inbox/Chat/services/database.dart';
import 'package:namaste/views/widgets/empty_box.dart';

import '../helperfunctions.dart';
import 'chat.dart';

class ChatRoom extends StatefulWidget {
  final String currentUserId;

  const ChatRoom({Key key, this.currentUserId}) : super(key: key);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatRooms;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                    userId: snapshot.data.documents[index].data['chatRoomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(widget.currentUserId, ""),
                    currentUserId: widget.currentUserId,
                    chatRoomId:
                        snapshot.data.documents[index].data["chatRoomId"],
                  );
                })
            : EmptyBoxScreen();
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserChats(widget.currentUserId).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${widget.currentUserId}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: chatRoomsList(),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userId;
  final String currentUserId;
  final String chatRoomId;

  ChatRoomsTile({this.userId, @required this.chatRoomId, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    var loadedUser = Provider.of<Users>(
      context,
      listen: false,
    ).userfindById(userId);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                  chatUser: loadedUser,
                      chatRoomId: chatRoomId,
                      currentUserId: currentUserId,
                      sendUserId: userId,
                    )));
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(loadedUser.profileUrl)),
                SizedBox(
                  width: 12,
                ),
                Text(loadedUser.name,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w300))
              ],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
