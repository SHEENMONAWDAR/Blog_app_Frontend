import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blog_app/constant.dart';
import 'package:blog_app/models/api_response.dart';
import 'package:blog_app/models/user.dart';

/// 🔹 LOGIN (includes saving user + token automatically)
Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();

  try {
    final response = await http.post(
      Uri.parse(loginURL),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body);
        User user = User.fromJson(data);
        apiResponse.data = user;

        // ✅ Save user and token here automatically
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('token', user.token ?? '');
        await pref.setInt('userId', user.id ?? 0);
        await pref.setString('userName', user.name ?? '');
        await pref.setString('userEmail', user.email ?? '');
        await pref.setString('userImage', user.image ?? '');
        break;

      case 422:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;

      case 401:
        apiResponse.error = 'Invalid email or password';
        break;

      default:
        apiResponse.error = 'Something went wrong (${response.statusCode})';
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

/// 🔹 REGISTER
Future<ApiResponse> register(String name, String email, String password, {File? imageFile}) async {
  ApiResponse apiResponse = ApiResponse();

  try {
    var uri = Uri.parse(registerURL);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';

    // 🔹 Regular form fields
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['password_confirmation'] = password;

    // 🔹 Add image file if provided
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    // 🔹 Send request
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var data = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      User user = User.fromJson(data);
      apiResponse.data = user;

      // 🔹 Save to SharedPreferences
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('token', user.token ?? '');
      await pref.setInt('userId', user.id ?? 0);
      await pref.setString('userName', user.name ?? '');
      await pref.setString('userEmail', user.email ?? '');
      await pref.setString('userImage', user.image ?? '');
    } else if (response.statusCode == 422) {
      final errors = data['errors'];
      apiResponse.error = errors[errors.keys.first][0];
    } else if (response.statusCode == 403) {
      apiResponse.error = data['message'];
    } else {
      apiResponse.error = somethingWentWrong;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}


/// 🔹 GET USER DETAIL
Future<ApiResponse> getUserDetail() async {
  ApiResponse apiResponse = ApiResponse();

  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse(userURL),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
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

/// 🔹 GET TOKEN
Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

/// 🔹 GET USER ID
Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId') ?? 0;
}

/// 🔹 LOGOUT
Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.clear(); 
}
