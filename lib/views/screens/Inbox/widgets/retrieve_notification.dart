import 'package:flutter/cupertino.dart';
import 'package:namaste/providers/user_notifications.dart';
import 'package:namaste/providers/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namaste/views/widgets/empty_box.dart';

import 'notification_list_item.dart';

class RetrieveNotification extends StatelessWidget {
  final String currentUserId;

  const RetrieveNotification({Key key, this.currentUserId}) : super(key: key);

  Future<void> _refreshNotifications(BuildContext context) async {
    await Provider.of<UserNotifications>(context, listen: false)
        .fetchUserNotifications(currentUserId);
    await Provider.of<Users>(context, listen: false).fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        Provider.of<Users>(context, listen: false).fetchUsers(),
        Provider.of<UserNotifications>(context, listen: false)
            .fetchUserNotifications(currentUserId),
      ]),
      builder: (
        ctx,
        dataSnapshot,
      ) {
        try {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Theme(
              data: ThemeData.light(),
              child: CupertinoActivityIndicator(
                animating: true,
                radius: 20,
              ),
            ));
          } else if (dataSnapshot.hasData == null) {
            return EmptyBoxScreen();
          } else {
            return Consumer<UserNotifications>(
              builder: (ctx, notiData, child) => RefreshIndicator(
                  backgroundColor: Colors.white,
                  onRefresh: () => _refreshNotifications(context),
                  child: notiData.reversedItems.length == 0
                      ? EmptyBoxScreen()
                      : Scrollbar(
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: notiData.reversedItems.length,
                            itemBuilder: (context, i) {
                              return NotificationListItem(
                                  userNotification: notiData.reversedItems[i],
                                  currentUserId: currentUserId);
                            },
                          ),
                        )),
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
      },
    );
  }
}
