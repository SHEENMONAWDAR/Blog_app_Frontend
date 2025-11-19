import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? user;

  void setUser(User u) {
    user = u;
    notifyListeners();
  }
}
