import 'package:blog_app/constant.dart';
import 'package:blog_app/models/api_response.dart';
import 'package:blog_app/services/user_service.dart';
import 'package:flutter/material.dart';

import 'Home.dart';
import 'Login.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  void _loadUserInfo() async {
    await Future.delayed(const Duration(seconds: 1));

    String token = await getToken();

    if (!mounted) return; // prevent crash on unmounted widget

    if (token.isEmpty) {
      _goTo(const Login());
      return;
    }

    ApiResponse res = await getUserDetail();

    if (!mounted) return;

    if (res.error == null) {
      _goTo(const Home());
    } else if (res.error == unauthorized) {
      _goTo(const Login());
    } else {
      _showError(res.error!);
    }
  }

  void _goTo(Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void initState() {
    super.initState();

    // ⚠ Prevent calling Navigator before first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
