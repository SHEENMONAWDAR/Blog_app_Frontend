import 'package:blog_app/constant.dart';

class Post {
  int? id;
  String? body;
  String? image;
  int? userId;
  String? createdAt;
  String? updatedAt;
  int likes_count;
  bool is_liked;
  int comments_count;

  // nested user
  String? postedByName;
  String? postedByImage;

  Post({
    this.id,
    this.body,
    this.image,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.likes_count = 0,
    this.is_liked = false,
    this.comments_count = 0,
    this.postedByName,
    this.postedByImage,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return Post(
      id: json['id'],
      body: json['body'],
      userId: json['user_id'],
      image: json['image'] != null
          ? "$imageURL/storage/${json['image']}"
          : null,
      likes_count: json['likes_count'] ?? 0,
      comments_count: json['comments_count'] ?? 0,
      is_liked: json['is_liked'] ?? false,
      postedByName: user['name'],
      postedByImage: user['image'] != null
          ? "$imageURL/storage/${user['image']}"
          : null,
    );
  }
}
