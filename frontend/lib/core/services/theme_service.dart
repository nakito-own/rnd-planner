import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  static const String _fontFamily = 'YandexSansText';
  
  static ThemeMode _currentTheme = ThemeMode.system;
  static GlobalKey<State<StatefulWidget>>? _appKey;
  
  static final Map<String, TextStyle> _styleCache = {};
  
  static ThemeMode get currentTheme => _currentTheme;
  
  static void setAppKey(GlobalKey<State<StatefulWidget>> key) {
    _appKey = key;
  }
  
  static Future<void> initializeTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    
    if (themeIndex != null) {
      _currentTheme = ThemeMode.values[themeIndex];
    }
    
    _preloadStyles();
  }
  
  static Future<void> _saveTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }
  
  static Future<void> toggleTheme() async {
    switch (_currentTheme) {
      case ThemeMode.light:
        _currentTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _currentTheme = ThemeMode.light;
        break;
      case ThemeMode.system:
        _currentTheme = ThemeMode.light;
        break;
    }
    await _saveTheme(_currentTheme);
    _notifyApp();
  }
  
  static Future<void> setTheme(ThemeMode theme) async {
    _currentTheme = theme;
    await _saveTheme(theme);
    _notifyApp();
  }
  
  static void _notifyApp() {
    if (_appKey?.currentState != null) {
      _appKey!.currentState!.setState(() {});
    }
  }
  
  static IconData getThemeIcon() {
    switch (_currentTheme) {
      case ThemeMode.light:
        return CupertinoIcons.moon_fill;
      case ThemeMode.dark:
        return CupertinoIcons.sun_max_fill;
      case ThemeMode.system:
        return CupertinoIcons.brightness;
    }
  }
  
  static String getThemeName() {
    switch (_currentTheme) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  static String get fontFamily => _fontFamily;
  
  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final cacheKey = '${fontSize ?? 16}_${fontWeight?.value ?? 400}_${color?.value ?? 0}_${letterSpacing ?? 0}_${height ?? 1.0}';
    
    if (_styleCache.containsKey(cacheKey)) {
      return _styleCache[cacheKey]!;
    }
    
    final style = TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
    
    _styleCache[cacheKey] = style;
    return style;
  }
  
  static TextStyle get headingStyle => getTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get subheadingStyle => getTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get bodyStyle => getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static TextStyle get captionStyle => getTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  
  static TextStyle get thinStyle => getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w100,
  );
  
  static TextStyle get mediumStyle => getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get italicStyle => getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );
  
  static TextStyle get displayStyle => getTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static TextStyle get buttonStyle => getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  static void _preloadStyles() {
    headingStyle;
    subheadingStyle;
    bodyStyle;
    captionStyle;
    thinStyle;
    mediumStyle;
    italicStyle;
    displayStyle;
    buttonStyle;
  }
  
  static void clearStyleCache() {
    _styleCache.clear();
  }
  
  static int get cacheSize => _styleCache.length;
}
