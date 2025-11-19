import 'dart:convert';
import 'dart:io';
import 'package:blog_app/constant.dart';
import 'package:blog_app/models/api_response.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/services/user_service.dart';
import 'package:http/http.dart' as http;

// 🔹 Create a new Post
Future<ApiResponse> createPost(String body, File? image) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    var uri = Uri.parse(postsURL);

    var request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['body'] = body;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    var response = await request.send();
    var responseBody = await http.Response.fromStream(response);

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(responseBody.body);
        break;
      case 422:
        apiResponse.error = jsonDecode(
          responseBody.body,
        )['errors'][jsonDecode(responseBody.body)['errors'].keys.first][0];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

// 🔹 Update an existing Post
Future<ApiResponse> updatePost(int postId, String body, File? image) async {
  ApiResponse apiResponse = ApiResponse();

  try {
    String token = await getToken();
    var uri = Uri.parse('$postsURL/$postId');

    var request = http.MultipartRequest('POST', uri);
    request.fields['_method'] = 'PUT';
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['body'] = body;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    var response = await request.send();
    var responseBody = await http.Response.fromStream(response);

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(responseBody.body);
        break;
      case 422:
        apiResponse.error = jsonDecode(
          responseBody.body,
        )['errors'][jsonDecode(responseBody.body)['errors'].keys.first][0];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

// 🔹 Get all Posts
Future<ApiResponse> getPosts() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse(postsURL),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body);

        // 👇 backend returns { "posts": [...] }
        if (data is Map<String, dynamic> && data['posts'] is List) {
          apiResponse.data =
              (data['posts'] as List).map((p) => Post.fromJson(p)).toList();
        }

        break;

      case 401:
        apiResponse.error = unauthorized;
        break;

      default:
        apiResponse.error = somethingWentWrong;
    }
  } catch (e) {
    print("❌ Error in getPosts(): $e");
    apiResponse.error = serverError;
  }

  return apiResponse;
}


// 🔹 Get posts by specific user
Future<ApiResponse> getUserPosts(int userId) async {
  ApiResponse apiResponse = ApiResponse();

  try {
    String token = await getToken();

    final response = await http.get(
      Uri.parse('$postsURL/user/$userId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body);

        // backend returns: { "posts": [...] }
        apiResponse.data =
            (data['posts'] as List).map((p) => Post.fromJson(p)).toList();
        break;

      case 401:
        apiResponse.error = unauthorized;
        break;

      default:
        apiResponse.error = somethingWentWrong;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}



// 🔹 Delete Post
Future<ApiResponse> deletePost(int postId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.delete(
      Uri.parse('$postsURL/$postId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

switch (response.statusCode) {
  case 200:
    apiResponse.data = jsonDecode(response.body)['message'];
    break;
  case 401:
    apiResponse.error = unauthorized;
    break;
  case 403:
    apiResponse.error = 'Access denied';
    break;
  case 404:
    apiResponse.error = 'Post not found';
    break;
  default:
    print('Response code: ${response.statusCode}');
    print('Body: ${response.body}');
    apiResponse.error = somethingWentWrong;
    break;
}
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

// 🔹 Like or Unlike Post
Future<ApiResponse> likeUnlikePost(int postId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(
      Uri.parse('$postsURL/$postId/likes'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body);
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}
