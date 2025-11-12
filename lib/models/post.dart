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

  Post({
    this.id,
    this.body,
    this.image,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.likes_count=0,
    this.is_liked =false
  });

factory Post.fromJson(Map<String, dynamic> json) {
  return Post(
    id: json['id'],
    body: json['body'],
    userId: json['user_id'],
    image: json['image'] != null
        ? "$imageURL/${json['image']}"
        : null,
    likes_count: json['likes_count'] ?? 0,
    is_liked: json['is_liked'] ?? false,
  );
}

}
