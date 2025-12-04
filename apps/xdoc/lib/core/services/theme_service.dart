import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isDarkMode = true; // Default to dark mode

  bool get isDarkMode => _isDarkMode;

  // Theme color getters - Warmer, less white light theme
  Color get backgroundColor =>
      _isDarkMode ? Colors.grey[900]! : const Color(0xFFF0F2F5);
  Color get surfaceColor =>
      _isDarkMode ? Colors.grey[850]! : const Color(0xFFF8F9FA);
  Color get cardColor =>
      _isDarkMode ? Colors.grey[800]! : const Color(0xFFEDF2F7);
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF2D3748);
  Color get subtitleColor =>
      _isDarkMode ? Colors.white70 : const Color(0xFF4A5568);
  Color get primaryAccent =>
      _isDarkMode ? Colors.blueAccent : const Color(0xFF2B6CB0);
  Color get secondaryAccent =>
      _isDarkMode ? Colors.blue[300]! : const Color(0xFF4299E1);
  Color get borderColor =>
      _isDarkMode ? Colors.grey[700]! : const Color(0xFFCBD5E0);

  Future<void> initializeTheme() async {
    try {
      final savedTheme = await _storage.read(key: 'theme_mode');
      if (savedTheme != null) {
        _isDarkMode = savedTheme == 'dark';
        notifyListeners();
      }
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    try {
      await _storage.write(
        key: 'theme_mode',
        value: _isDarkMode ? 'dark' : 'light',
      );
    } catch (e) {
      print('Error saving theme preference: $e');
    }
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    try {
      await _storage.write(
        key: 'theme_mode',
        value: _isDarkMode ? 'dark' : 'light',
      );
    } catch (e) {
      print('Error saving theme preference: $e');
    }
    notifyListeners();
  }
}
