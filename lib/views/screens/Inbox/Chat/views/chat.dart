import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:namaste/models/user.dart';
import 'package:namaste/views/screens/Inbox/Chat/services/database.dart';
import 'package:namaste/views/screens/Inbox/Chat/widget/widget.dart';

class Chat extends StatefulWidget {
  final User chatUser;
  final String chatRoomId;
  final String currentUserId;
  final String sendUserId;

  Chat({this.chatRoomId, this.currentUserId, this.sendUserId, this.chatUser});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    chatUser: widget.chatUser,
                    message: snapshot.data.documents[index].data["message"],
                    sendByMe: widget.currentUserId ==
                        snapshot.data.documents[index].data["sendBy"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage(String myId) {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": widget.currentUserId,
        "message": messageEditingController.text,
        'time': DateTime.now(),
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.chatUser.name),
        // title: ListTile(
        //   leading: CircleAvatar(
        //     radius: 20,
        //     backgroundImage:
        //         CachedNetworkImageProvider(widget.chatUser.profileUrl),
        //   ),
        //   title: Text(widget.chatUser.name),
        // ),
        centerTitle: true,
      ),
      // appBar: appBarMain(context),
      body: Container(
        // color: Colors.transparent,
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 75.0),
              child: chatMessages(),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                // color: Colors.purple[200],
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageEditingController,
                      style: simpleTextStyle(),
                      decoration: InputDecoration(
                        hintText: "Message...",
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF000000),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        // border: InputBorder.none
                      ),
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage(widget.currentUserId);
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.black12,
                                    Colors.black38,
                                    // const Color(0x36FFFFFF),
                                    // const Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight),
                              borderRadius: BorderRadius.circular(40)),
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "assets/images/send.png",
                            color: Colors.black,
                            height: 35,
                            width: 35,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final User chatUser;
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe, this.chatUser});

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!sendByMe)
          CircleAvatar(
              radius: 16, backgroundImage: NetworkImage(chatUser.profileUrl)),
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: 140),
          decoration: BoxDecoration(
            // color: sendByMe ? Colors.grey[100] : Theme.of(context).accentColor,
            borderRadius: sendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23))
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
          gradient: LinearGradient(
            colors: sendByMe
                ? [Colors.black12, Colors.purple]
                : [Colors.black12, Colors.blue],
          ),
            // borderRadius: sendByMe
            //     ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
            //     : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
        crossAxisAlignment:
            sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: TextStyle(color: sendByMe ? Colors.white : Colors.white),
            textAlign: sendByMe ? TextAlign.end : TextAlign.start,
          ),
        ],
      );
}
//     return Container(
//       padding: EdgeInsets.only(
//           top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
//       alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin:
//             sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
//         padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
//         decoration: BoxDecoration(
//           borderRadius: sendByMe
//               ? BorderRadius.only(
//                   topLeft: Radius.circular(23),
//                   topRight: Radius.circular(23),
//                   bottomLeft: Radius.circular(23))
//               : BorderRadius.only(
//                   topLeft: Radius.circular(23),
//                   topRight: Radius.circular(23),
//                   bottomRight: Radius.circular(23)),
//           gradient: LinearGradient(
//             colors: sendByMe
//                 ? [Colors.black12, Colors.black12]
//                 : [Colors.black12, Colors.black12],
//           ),
//         ),
//         child: Text(message,
//             textAlign: TextAlign.start,
//             style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontFamily: 'OverpassRegular',
//                 fontWeight: FontWeight.w300)),
//       ),
//     );
//   }
// }
