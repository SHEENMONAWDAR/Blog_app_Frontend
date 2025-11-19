import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int currentPage = 0;

  void changePage(int index) {
    currentPage = index;
    notifyListeners();
  }
}
