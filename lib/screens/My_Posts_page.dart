import 'dart:io';
import 'package:blog_app/constant.dart';
import 'package:blog_app/models/api_response.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/screens/Login.dart';
import 'package:blog_app/services/post_service.dart';
import 'package:blog_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List<Post> _posts = [];
  bool _loading = true;
  final Set<int> _likedPosts = {};

  // =============================================================
  // 🔹 Fetch posts using service layer
  // =============================================================
Future<void> _getPosts() async {
  setState(() => _loading = true);

  int userId = await getUserId();

  ApiResponse response = await getUserPosts(userId);

  if (response.error == null) {
    final posts = response.data as List<Post>;

    setState(() {
      _posts = posts;
      _likedPosts.clear();
      for (var p in posts) {
        if (p.is_liked) _likedPosts.add(p.id!);
      }
      _loading = false;
    });
  } else if (response.error == unauthorized) {
    await logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  } else {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.error!)));
  }
}


  // =============================================================
  // 🔹 Like / Unlike
  // =============================================================
  Future<void> _toggleLike(Post post) async {
    final wasLiked = _likedPosts.contains(post.id);

    // Optimistic UI
    setState(() {
      if (wasLiked) {
        _likedPosts.remove(post.id!);
        post.likes_count--;
      } else {
        _likedPosts.add(post.id!);
        post.likes_count++;
      }
    });

    ApiResponse res = await likeUnlikePost(post.id!);

    if (res.error == null) {
      final data = res.data as Map<String, dynamic>;
      setState(() {
        post.likes_count = data['likes_count'];
        if (data['is_liked']) {
          _likedPosts.add(post.id!);
        } else {
          _likedPosts.remove(post.id!);
        }
      });
    } else {
      // Revert on error
      setState(() {
        if (wasLiked) {
          _likedPosts.add(post.id!);
          post.likes_count++;
        } else {
          _likedPosts.remove(post.id!);
          post.likes_count--;
        }
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.error!)));
    }
  }

  // =============================================================
  // 🔹 Delete Post
  // =============================================================
  Future<void> _deletePost(int postId) async {
    bool confirm = await _showDeleteDialog();
    if (!confirm) return;

    setState(() => _loading = true);

    ApiResponse res = await deletePost(postId);

    if (res.error == null) {
      await _getPosts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted")),
      );
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.error!)));
    }
  }

  // =============================================================
  // 🔹 Edit Post
  // =============================================================
  Future<void> _editPost(Post post) async {
    final controller = TextEditingController(text: post.body);
    File? selectedImage;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Post"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              selectedImage != null
                  ? Image.file(selectedImage!, height: 120)
                  : (post.image != null && post.image!.isNotEmpty)
                      ? Image.network(post.image!, height: 120)
                      : const Text("No image"),
              TextButton.icon(
                onPressed: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() => selectedImage = File(picked.path));
                  }
                },
                icon: const Icon(Icons.photo),
                label: const Text("Change Image"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _loading = true);

                ApiResponse res = await updatePost(
                  post.id!,
                  controller.text.trim(),
                  selectedImage,
                );

                if (res.error == null) {
                  await _getPosts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post updated")),
                  );
                } else {
                  setState(() => _loading = false);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(res.error!)));
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }


  // =============================================================
  // 🔹 Delete dialog
  // =============================================================
  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Post"),
            content: const Text("Are you sure?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    _getPosts();
  }

  // =============================================================
  // 🔹 UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Posts"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        final isLiked = _likedPosts.contains(post.id);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: post.image != null &&
                                          post.image!.isNotEmpty
                                      ? Image.network(
                                          post.image!,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 180,
                                          width: double.infinity,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                              Icons.image_outlined,
                                              size: 40),
                                        ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        post.body ?? "",
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            isLiked ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () => _toggleLike(post),
                                    ),
                                    Text("${post.likes_count}")
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Post #${post.id} • User ${post.userId}",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == "edit") {
                                          _editPost(post);
                                        } else if (value == "delete") {
                                          _deletePost(post.id!);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: "edit",
                                          child: Text("Edit"),
                                        ),
                                        PopupMenuItem(
                                          value: "delete",
                                          child: Text("Delete",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    )
                                  ],
                                )
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
