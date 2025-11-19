import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';

import 'All_post_page.dart';
import 'My_Posts_page.dart';
import 'profile.dart';
import 'Add_Posts_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  final List<Widget> pages = const [
    AllPostsPage(),
    MyPostsPage(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final currentPage = nav.currentPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Blog App"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: pages[currentPage],

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPostsPage()),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: (index) {
          nav.changePage(index);

          // auto refresh posts when switching tabs
          final postProvider = context.read<PostProvider>();
          if (index == 0) postProvider.fetchAllPosts();
          if (index == 1) postProvider.fetchMyPosts();
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.public), label: "All Posts"),
          NavigationDestination(
              icon: Icon(Icons.book), label: "My Posts"),
          NavigationDestination(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
