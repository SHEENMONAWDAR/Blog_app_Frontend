import 'dart:convert';
import 'package:blog_app/constant.dart';
import 'package:blog_app/models/api_response.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/screens/Login.dart';
import 'package:blog_app/services/post_service.dart';
import 'package:blog_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  State<AllPostsPage> createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  List<Post> _posts = [];
  bool _loading = true;
  final Set<int> _likedPosts = {}; // store liked IDs locally

  // 🔹 Fetch all posts
  Future<void> _getPosts() async {
    setState(() => _loading = true);

    try {
      String token = await getToken();
      final response = await http.get(
        Uri.parse(postsURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          final data = jsonDecode(response.body);
          List<dynamic> postsJson = data['posts'] ?? [];

          setState(() {
            _posts = postsJson.map((p) => Post.fromJson(p)).toList();
            _likedPosts.clear();
            for (var post in _posts) {
              if (post.is_liked) {
                _likedPosts.add(post.id!);
              }
            }

            _loading = false;
          });
          break;

        case 401:
          await logout();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            );
          }
          break;

        default:
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong (${response.statusCode})'),
            ),
          );
      }
    } catch (e) {
      print("❌ Error in _getPosts(): $e");
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error. Please try again later.')),
      );
    }
  }

  // 🔹 Toggle Like/Unlike
  Future<void> _toggleLike(Post post) async {
    final int postId = post.id!;
    final bool wasLiked = _likedPosts.contains(postId);

    // Optimistic UI update
    setState(() {
      if (wasLiked) {
        _likedPosts.remove(postId);
        post.likes_count -= 1;
      } else {
        _likedPosts.add(postId);
        post.likes_count += 1;
      }
    });

    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null && response.data != null) {
      // ✅ Sync from backend response
      final data = response.data as Map<String, dynamic>;
      setState(() {
        post.likes_count = data['likes_count'] ?? post.likes_count;
        if (data['is_liked'] == true) {
          _likedPosts.add(postId);
        } else {
          _likedPosts.remove(postId);
        }
      });
    } else {
      // ❌ Revert if failed
      setState(() {
        if (wasLiked) {
          _likedPosts.add(postId);
          post.likes_count += 1;
        } else {
          _likedPosts.remove(postId);
          post.likes_count -= 1;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${response.error ?? "Unknown error"}')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Posts"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _getPosts,
              child: _posts.isEmpty
                  ? const Center(
                      child: Text(
                        "No posts found 😢",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        final isLiked = _likedPosts.contains(post.id);

                        return Card(
                          elevation: 4,
                          shadowColor: Colors.indigo.shade100,
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🖼️ Post Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child:
                                      post.image != null &&
                                          post.image!.isNotEmpty
                                      ? Image.network(
                                          post.image!,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.fill,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                height: 180,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          height: 180,
                                          width: double.infinity,
                                          color: Colors.indigo.shade50,
                                          child: const Icon(
                                            Icons.image_outlined,
                                            size: 50,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 10),

                                // 📝 Post Body + ❤️ Like
                                Row(
                                   mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        post.body ?? '',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isLiked
                                            ? Colors.red
                                            : Colors.grey.shade600,
                                        size: 26,
                                      ),
                                      onPressed: () => _toggleLike(post),
                                    ),
                                    Text("${post.likes_count}"),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // 👤 Post Info + Menu
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Post #${post.id} • User ${post.userId}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
