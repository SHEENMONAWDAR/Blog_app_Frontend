import 'package:flutter/material.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5, // Example: later you can load this from API
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.article, color: Colors.blue),
            title: Text(
              "Post Title ${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "This is a short description of post ${index + 1}.",
              style: const TextStyle(fontSize: 13),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          ),
        );
      },
    );
  }
}
