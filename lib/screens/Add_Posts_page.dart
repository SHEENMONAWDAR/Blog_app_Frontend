import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';

class AddPostsPage extends StatefulWidget {
  const AddPostsPage({super.key});

  @override
  State<AddPostsPage> createState() => _AddPostsPageState();
}

class _AddPostsPageState extends State<AddPostsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bodyController = TextEditingController();

  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PostProvider>();
    final error = await provider.addPost(_bodyController.text, _imageFile);

    if (error == null) {
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<PostProvider>().loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Post"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _bodyController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Write something...",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty)
                          ? "Please enter post text"
                          : null,
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: _imageFile == null
                        ? const Center(
                            child: Text("Tap to select image"),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _createPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        ),
                        icon: const Icon(Icons.cloud_upload, color: Colors.white),
                        label: const Text(
                          "Publish Post",
                          style: TextStyle(color: Colors.white),
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
