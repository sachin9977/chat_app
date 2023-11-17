import 'package:flutter/material.dart';

class MyProvider extends ChangeNotifier {
  String _myData = 'Initial data';

  String get myData => _myData;

  void updateData(String newData) {
    _myData = newData;
    notifyListeners();
  }
}
