import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'Home.dart';
import '../providers/auth_provider.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> _init() async {
    // Wait a tick so providers initialize
    await Future.delayed(const Duration(milliseconds: 200));

    final auth = context.read<AuthProvider>();
    await auth.loadUser(); // ensures token + user loaded

    if (!mounted) return;

    if (auth.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // call after first frame to avoid navigator issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
