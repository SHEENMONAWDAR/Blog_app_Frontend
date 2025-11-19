import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  State<AllPostsPage> createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<PostProvider>().fetchAllPosts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostProvider>();
    final posts = provider.allPosts;

    return Scaffold(
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(
                  child: Text(
                    "No posts found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: provider.fetchAllPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

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
                                    fontWeight: FontWeight.w600),
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

                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          post.is_liked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: post.is_liked
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<PostProvider>()
                                              .toggleLike(post);
                                        },
                                      ),
                                      Text("${post.likes_count}"),
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
