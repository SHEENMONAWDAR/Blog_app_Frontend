import 'package:blog_app/constant.dart';

class User {
  int? id;
  String? name;
  String? image;
  String? email;
  String? token;

  User({
    this.id,
    this.name,
    this.image,
    this.email,
    this.token,
  });

  // ✅ Correct conversion from backend JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // handle both full API response and plain user map
    final userData = json['user'] ?? json;

    return User(
      id: userData['id'],
      name: userData['name'],
      image: userData['image'] != null
        ? "$imageURL/${userData['image']}"
        : null,
      email: userData['email'],
      token: json['token'], // token will be null for non-login responses
    );
  }
}
