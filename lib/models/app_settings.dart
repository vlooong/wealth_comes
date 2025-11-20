import 'package:flutter/material.dart';

class AppSettings {
  ThemeMode themeMode;
  Locale locale;
  bool notificationsEnabled;
  bool showChart;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('zh', 'CN'),
    this.notificationsEnabled = true,
    this.showChart = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'locale': locale.languageCode,
      'notificationsEnabled': notificationsEnabled,
      'showChart': showChart,
    };
  }

  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      locale: Locale(json['locale'] ?? 'zh', 'CN'),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      showChart: json['showChart'] ?? true,
    );
  }
}
