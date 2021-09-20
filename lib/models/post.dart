import 'package:flutter/foundation.dart';

class Post {
  int id;
  String userId;
  String description;
  String location;
  String postUrl;
  // String thumbnail;
  int isVideo;
  int views;
  String createdAt;

  Post({
    @required this.id,
    @required this.userId,
    @required this.description,
    @required this.location,
    @required this.postUrl,
    // @required this.thumbnail,
    @required this.isVideo,
    @required this.views,
    @required this.createdAt,
  });
}
