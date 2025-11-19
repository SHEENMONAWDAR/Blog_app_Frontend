import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../models/post.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<PostProvider>().fetchMyPosts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostProvider>();
    final posts = provider.myPosts;

    return Scaffold(
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(
                  child: Text("No posts yet."),
                )
              : RefreshIndicator(
                  onRefresh: provider.fetchMyPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final Post post = posts[index];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post.image != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    post.image!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.fill,
                                  ),
                                ),

                              const SizedBox(height: 10),

                              Text(
                                post.body ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Post #${post.id}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600),
                                  ),

                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == "delete") {
                                        provider.deletePostById(post.id!);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: "delete",
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
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
