import 'package:flutter/material.dart';
import 'package:namaste/views/screens/Inbox/Chat/views/chatrooms.dart';

class DirectMessageScreen extends StatelessWidget {
  final String currentUserId;

  const DirectMessageScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("direct"),
        centerTitle: true,
      ),
      body: ChatRoom(currentUserId: currentUserId),
    );
  }
}
