import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Центральное хранилище пользовательских настроек.
/// Всё сохраняется в SharedPreferences и переживает перезапуск приложения.
class AppSettings extends ChangeNotifier {
  bool vibrationEnabled = true;
  bool soundEnabled = true;
  Color themeColor = Colors.teal;

  // НОВОЕ: тема день/ночь/системная
  ThemeMode themeMode = ThemeMode.system;

  // НОВОЕ: настраиваемая цель счётчика тасбиха.
  // По умолчанию 33 — классическое число для тасбиха после намаза.
  int dailyGoal = 33;
  static const List<int> presetGoals = [33, 99];

  final List<Color> availableColors = [
    Colors.teal,
    Colors.blue,
    Colors.deepPurple,
    Colors.red,
    Colors.orange,
  ];

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    soundEnabled = prefs.getBool('sound_enabled') ?? true;

    final colorValue = prefs.getInt('theme_color') ?? Colors.teal.toARGB32();
    themeColor = Color(colorValue);

    final themeModeIndex = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
    themeMode = ThemeMode.values[themeModeIndex];

    dailyGoal = prefs.getInt('daily_goal') ?? 33;

    notifyListeners();
  }

  Future<void> toggleVibration(bool value) async {
    vibrationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', value);
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    notifyListeners();
  }

  Future<void> changeThemeColor(Color color) async {
    themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', color.toARGB32());
    notifyListeners();
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> changeDailyGoal(int goal) async {
    if (goal <= 0) return; // защита от некорректного ввода
    dailyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal', goal);
    notifyListeners();
  }
}
