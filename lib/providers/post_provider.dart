import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/api_response.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';

class PostProvider extends ChangeNotifier {
  List<Post> allPosts = [];
  List<Post> myPosts = [];

  bool loading = false;

  Future<void> fetchAllPosts() async {
    loading = true;
    notifyListeners();

    ApiResponse res = await getPosts();

    loading = false;

    if (res.error == null) {
      allPosts = res.data as List<Post>;
    }

    notifyListeners();
  }

  Future<void> fetchMyPosts() async {
    loading = true;
    notifyListeners();

    int uid = await getUserId();
    ApiResponse res = await getUserPosts(uid);

    loading = false;

    if (res.error == null) {
      myPosts = res.data as List<Post>;
    }

    notifyListeners();
  }


  Future<String?> addPost(String body, image) async {
    loading = true;
    notifyListeners();

    ApiResponse res = await createPost(body, image);

    loading = false;

    if (res.error == null) {
      await fetchAllPosts();
      await fetchMyPosts();
      notifyListeners();
      return null;
    }

    notifyListeners();
    return res.error;
  }


  Future<String?> deletePostById(int id) async {
    ApiResponse res = await deletePost(id);

    if (res.error == null) {
      await fetchAllPosts();
      await fetchMyPosts();
      notifyListeners();
      return null;
    }

    notifyListeners();
    return res.error;
  }

Future<void> toggleLike(Post post) async {
  post.is_liked = !post.is_liked;
  post.likes_count += post.is_liked ? 1 : -1;

  notifyListeners();

  await likeUnlikePost(post.id!);
}

}
