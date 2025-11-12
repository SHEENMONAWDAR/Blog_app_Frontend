import 'dart:io';
import 'package:blog_app/constant.dart';
import 'package:blog_app/models/api_response.dart';
import 'package:blog_app/screens/Home.dart';
import 'package:blog_app/screens/Login.dart';
import 'package:blog_app/services/post_service.dart';
import 'package:blog_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 

class AddPostsPage extends StatefulWidget {
  const AddPostsPage({super.key});

  @override
  State<AddPostsPage> createState() => _AddPostsPageState();
}

class _AddPostsPageState extends State<AddPostsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bodyController = TextEditingController();

  bool _loading = false;
  File? _imageFile;

  // 🔹 Pick Image from Gallery or Camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // 🔹 Function to Create Post
  void _createPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      ApiResponse response = await createPost(_bodyController.text, _imageFile);

      setState(() => _loading = false);

      if (response.error == null) {
        // Successfully created post
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post added successfully!")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      } else if (response.error == unauthorized) {
        // If token expired or invalid → Go back to login
        logout().then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        });
      } else {
        // Show error
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${response.error}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Post"),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Write something new ✍️",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 20),

                // 🔸 Body Field
                TextFormField(
                  controller: _bodyController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Post content",
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.article_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty
                      ? "Please enter post content"
                      : null,
                ),
                const SizedBox(height: 20),

                // 🔸 Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.indigo),
                    ),
                    child: _imageFile == null
                        ? const Center(
                            child: Text(
                              "Tap to select image",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Submit Button
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _createPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.cloud_upload, color: Colors.white),
                          label: const Text(
                            "Publish Post",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
