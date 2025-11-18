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

  factory User.fromJson(Map<String, dynamic> json) {
    
    final userData = json['user'] ?? json;

    return User(
      id: userData['id'],
      name: userData['name'],
      image: userData['image'] != null
        ? "$imageURL/${userData['image']}"
        : null,
      email: userData['email'],
      token: json['token'], 
    );
  }
}
