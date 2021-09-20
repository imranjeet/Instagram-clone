import 'package:flutter/foundation.dart';

class Comment with ChangeNotifier {
  final int id;
  final int videoId;
  final String userId;
  final String comment;
  final String createdAt;

  Comment({
    @required this.id,
    @required this.videoId,
    @required this.userId,
    @required this.comment,
    @required this.createdAt,
  });
}
