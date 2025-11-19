import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  User? user;
  bool loading = false;
  String? token;

  AuthProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString('token');

    if (token != null && token!.isNotEmpty) {
      ApiResponse res = await getUserDetail();
      if (res.error == null) user = res.data as User;
    }

    notifyListeners();
  }

  Future<String?> loginUser(String email, String password) async {
    loading = true;
    notifyListeners();

    ApiResponse res = await login(email, password);

    loading = false;

    if (res.error == null) {
      user = res.data as User;
      await loadUser();
      notifyListeners();
      return null;
    }

    notifyListeners();
    return res.error;
  }

  Future<String?> registerUser(
      String name, String email, String password, File? image) async {
    loading = true;
    notifyListeners();

    ApiResponse res =
        await register(name, email, password, imageFile: image);

    loading = false;

    if (res.error == null) {
      user = res.data as User;
      await loadUser();
      notifyListeners();
      return null;
    }

    notifyListeners();
    return res.error;
  }

  Future<void> logoutUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();

    user = null;
    token = null;

    notifyListeners();
  }
}
