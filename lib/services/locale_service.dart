import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService() {
    _load();
  }

  static const supportedLocales = [
    Locale('ku'),
    Locale('ar'),
    Locale('en'),
  ];

  Locale _locale = const Locale('ku');

  Locale get locale => _locale;

  bool get isRtl =>
      _locale.languageCode == 'ku' || _locale.languageCode == 'ar';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }
}
