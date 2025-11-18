import 'package:flutter/material.dart';
import 'package:blog_app/models/api_response.dart';
import 'package:blog_app/models/user.dart';
import 'package:blog_app/services/user_service.dart';
import 'package:blog_app/screens/Login.dart'; 

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _loading = true;
  User? _user;

  // 🔹 Fetch user details
  Future<void> _getUser() async {
    setState(() => _loading = true);
    ApiResponse response = await getUserDetail();

    if (response.error == null) {
      setState(() {
        _user = response.data as User;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  // 🔹 Logout function (using your logout logic)
  Future<void> _logoutUser() async {
    bool success = await logout(); 
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()), 
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text("No user data found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        // 🔹 Profile Image
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _user!.image != null &&
                                  _user!.image!.isNotEmpty
                              ? NetworkImage(_user!.image!)
                              : const AssetImage('assets/Profile.jpg')
                                  as ImageProvider,
                        ),
                        const SizedBox(height: 20),
                    
                        // 🔹 Name
                        Text(
                          _user!.name ?? "No name",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    
                        const SizedBox(height: 8),
                    
                        // 🔹 Email
                        Text(
                          _user!.email ?? "No email",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                    
                        const SizedBox(height: 40),
                    
                        // 🔹 Logout Button
                        ElevatedButton.icon(
                          onPressed: _logoutUser,
                          icon: const Icon(Icons.logout),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          label: const Text(
                            "Logout",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
