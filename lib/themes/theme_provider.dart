import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lobbytalk/themes/light_mode.dart';

import 'dark_mode.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themedata) {
    _themeData = themedata;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    }
    else{
      themeData == lightMode;
    }
  }
}