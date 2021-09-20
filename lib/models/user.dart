import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  final int id;
  final String uId;
  final String name;
  final String email;
  final String username;
  final int verified;
  final String gender;
  final String bio;
  final String profileUrl;
  final String block;

  User({
    @required this.id,
    @required this.uId,
    @required this.name,
    @required this.email,
    this.username,
    this.profileUrl,
    this.verified,
    this.gender,
    this.bio,
    this.block,
  });

  // void toggleFavoriteStatus() {
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  // }
}
