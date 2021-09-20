import 'package:flutter/foundation.dart';

class Follow with ChangeNotifier {
  final int id;
  final String userId;
  final String followUserId;

  Follow({
    @required this.id,
    @required this.userId,
    @required this.followUserId,
  });
}
