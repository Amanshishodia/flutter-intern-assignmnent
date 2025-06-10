import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String themeBoxName = 'theme_preferences';
  static const String themeModeKey = 'theme_mode';

  late ThemeMode _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    final box = await Hive.openBox(themeBoxName);
    final savedThemeMode = box.get(themeModeKey);

    if (savedThemeMode == null) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.values[savedThemeMode];
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final box = await Hive.openBox(themeBoxName);
    await box.put(themeModeKey, mode.index);
  }

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }
}