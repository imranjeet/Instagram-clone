import 'package:flutter/material.dart';
import 'package:namaste/views/screens/Inbox/widgets/retrieve_notification.dart';


class InboxScreen extends StatefulWidget {
  final String currentUserId;

  const InboxScreen({
    Key key,
    this.currentUserId,
  }) : super(key: key);
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  // TabController _tabController;
  // var _isInit = true;

  // @override
  // void initState() {
  //   _tabController = new TabController(length: 2, vsync: this, initialIndex: 0);
  //   super.initState();
  // }

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     Provider.of<Users>(context).fetchUsers();
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    // var userNotifications =
    //     Provider.of<UserNotifications>(context, listen: false)
    //         .fetchUserNotifications(widget.currentUserId);
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text(
          "Inbox",
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_list,
            ),
            onPressed: () {},
          ),
        ],
        // bottom: TabBar(
        //   unselectedLabelColor: Colors.black,
        //   indicatorColor: Theme.of(context).accentColor,
        //   labelColor: Theme.of(context).accentColor,
        //   tabs: [
        //     Padding(
        //       padding: const EdgeInsets.only(bottom: 15),
        //       child: Text(
        //         "Notifications",
        //         style: TextStyle(
        //           fontSize: 16,
        //           fontWeight: FontWeight.w400,
        //         ),
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.only(bottom: 15),
        //       child: Text(
        //         "Messages",
        //         style: TextStyle(
        //           fontSize: 16,
        //           fontWeight: FontWeight.w400,
        //         ),
        //       ),
        //     ),
        //   ],
        //   controller: _tabController,
        //   // indicatorColor: Colors.orange,
        //   indicatorSize: TabBarIndicatorSize.tab,
        // ),
        // bottomOpacity: 1,
      ),
      body: RetrieveNotification(currentUserId: widget.currentUserId),
      // TabBarView(
      //   children: [
      //     RetrieveNotification(currentUserId: widget.currentUserId),
      //     ChatRoom(currentUserId: widget.currentUserId),
      //   ],
      //   controller: _tabController,
      // ),
    );
  }
}
