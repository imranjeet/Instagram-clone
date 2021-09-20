import 'dart:convert';
import 'dart:io';

import 'package:namaste/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namaste/util/constant.dart';

class Users with ChangeNotifier {
  List<User> _items = [];

  List<User> get items {
    return [..._items];
  }

  User userfindById(String uid) {
    return _items.firstWhere((usr) => usr.uId == uid);
  }

  bool isUserExist(String uid) {
    var user = _items.where((usr) => usr.uId == uid);
    if (user.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> fetchUsers() async {
    const url = '$baseUrl/get-users';
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body);
      final List<User> loadedUsers = [];
      extractedData['data'].forEach((data) {
        loadedUsers.add(User(
          id: data['id'],
          uId: data['uid'],
          name: data['name'],
          email: data['email'],
          username: data['username'],
          verified: data['verified'],
          bio: data['bio'],
          profileUrl: data['profile_pic'],
          block: data['block'],
        ));
      });
      _items = loadedUsers;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addGoogleUser(
    String uid,
    String name,
    String email,
    String profileUrl,
  ) async {
    const _url = '$baseUrl/store-google-user';
    try {
      FormData formData = new FormData.fromMap({
        "uid": uid,
        "name": name,
        "email": email,
        "profileUrl": profileUrl,
      });
      Response response = await Dio().post(
        _url,
        data: formData,
      );
      print("Video response: $response");
      print(response.data['id']);
      final newUser = User(
        uId: uid,
        name: name,
        email: email,
        profileUrl: profileUrl,
        id: response.data['id'],
        username: response.data['username'],
        verified: response.data['verified'],
        gender: response.data['gender'],
        bio: response.data['bio'],
        block: response.data['block'],
      );
      _items.add(newUser);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProfile(int userId, String _name, 
      String _bio, File _image) async {
    final userIndex = _items.indexWhere((user) => user.id == userId);
    try {
      FormData formData = new FormData.fromMap({
        "name": _name,
        // "username": _username,
        "bio": _bio,
        "profile_pic":
            _image == null ? "" : await MultipartFile.fromFile(_image.path),
      });

      Response response = await Dio().post(
        "$baseUrl/update-user/$userId",
        data: formData,
      );

      final newUser = User(
        id: response.data['id'],
        uId: response.data['uid'],
        name: response.data['name'],
        email: response.data['email'],
        profileUrl: response.data['profile_pic'],
        // username: response.data['username'],
        verified: response.data['verified'],
        gender: response.data['gender'],
        bio: response.data['bio'],
        block: response.data['block'],
      );
      _items[userIndex] = newUser;
      notifyListeners();
    } catch (e) {
      print(" error expectation Caugch: $e");
    }
  }

  // Future<void> updateProduct(String id, User newUser) async {
  //   final userIndex = _items.indexWhere((prod) => prod.id == id);
  //   if (userIndex >= 0) {
  //     final url = 'http://agni-api.infous.xyz/api/';
  //     await http.patch(url,
  //         body: json.encode({
  //           'id': newUser.id,
  //           'name': newUser.name,
  //           'email': newUser.email,
  //           'password': newUser.password,
  //         }));
  //     _items[userIndex] = newUser;
  //     notifyListeners();
  //   } else {
  //     print('...');
  //   }
  // }

  // Future<void> deleteUser(String id) async {
  //   final url = 'http://agni-api.infous.xyz/api/';
  //   final existingUserIndex = _items.indexWhere((usr) => usr.id == id);
  //   var existingUser = _items[existingUserIndex];
  //   _items.removeAt(existingUserIndex);
  //   notifyListeners();
  //   final response = await http.delete(url);
  //   if (response.statusCode >= 400) {
  //     _items.insert(existingUserIndex, existingUser);
  //     notifyListeners();
  //     throw HttpException('Could not delete product.');
  //   }
  //   existingUser = null;
  // }
}
