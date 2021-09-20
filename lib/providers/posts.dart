import 'dart:convert';
import 'dart:io';

import 'package:namaste/util/constant.dart';

import 'http_exception.dart';
import '../models/post.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Posts with ChangeNotifier {
  List<Post> _items = [];
  // var _showFavoritesOnly = false;

  List<Post> get items {
    return [..._items];
  }


  List<Post> videoById(String userId) {
    return _items.where((video) => video.userId == userId).toList();
  }

  Post videofindById(int id) {
    return _items.firstWhere((vid) => vid.id == id);
  }

  List<Post> allUserVideos(String userId, int i, int total) {
    var userVideos = _items.where((video) => video.userId == userId).toList();
    return userVideos.getRange(i, total).toList();
  }

  Future<void> fetchPosts() async {
    const url = '$baseUrl/get-all-posts';
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body);
      final List<Post> loadedVideos = [];
      extractedData['data'].forEach((videoData) {
        loadedVideos.add(Post(
          id: videoData['id'],
          userId: videoData['userId'],
          description: videoData['description'],
          location: videoData['location'],
          postUrl: videoData['video_url'],
          // thumbnail: videoData['thumbnail'],
          isVideo: videoData['is_video'],
          views: videoData['views'],
          createdAt: videoData['created_at'],
        ));
      });
      _items = loadedVideos;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addPost(
    String userId,
    String description,
    String location,
    int isVideo,
    File postFile,
  ) async {
    const _url = '$baseUrl/store-post';
    
    try {
      FormData formData = new FormData.fromMap({
        "userId": userId,
        "description": description,
        "location": location,
        "isVideo": isVideo,
        "post": await MultipartFile.fromFile(postFile.path),
        // "thumbnail": await MultipartFile.fromFile(thumbnailFile),
      });
      print(formData);
      Response response = await Dio().post(
        _url,
        data: formData,
      );
      print("Video response: $response");
      print(response.data['id']);
      final newVideo = Post(
        userId: userId,
        description: description,
        location: location,
        isVideo: isVideo,
        id: response.data['id'],
        postUrl: response.data['video_url'],
        // thumbnail: response.data['thumbnail'],
        // isVideo: response.data['thumbnail'],
        views: response.data['views'],
        // sectionId: response.data['section_id'],
        createdAt: response.data['created_at'],
      );
      _items.add(newVideo);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteVideo(int id) async {
    print(id.toString());
    final url = '$baseUrl/delete-post/$id';
    final existingUserIndex = _items.indexWhere((vid) => vid.id == id);
    var existingUser = _items[existingUserIndex];
    _items.removeAt(existingUserIndex);
    notifyListeners();
    final response = await http.delete(url);
    print(response.body);
    if (response.statusCode >= 400) {
      _items.insert(existingUserIndex, existingUser);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingUser = null;
  }
}
