import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  static const String _onboardingKey = 'has_completed_onboarding';
  static const String _userNameKey = 'user_profile_name';
  static const String _userEmailKey = 'user_profile_email';
  static const String _userCurrencyKey = 'user_currency_symbol';
  static const String _isLoggedInKey = 'user_is_logged_in';

  String _userName = 'Christian';
  String _userEmail = 'christian@example.com';
  String _currency = '\$';
  bool _hasCompletedOnboarding = false;
  bool _isLoggedIn = true;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get currency => _currency;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoggedIn => _isLoggedIn;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = prefs.getBool(_onboardingKey) ?? false;
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? true;
      _userName = prefs.getString(_userNameKey) ?? 'Christian';
      _userEmail = prefs.getString(_userEmailKey) ?? 'christian@example.com';
      _currency = prefs.getString(_userCurrencyKey) ?? '\$';
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setOnboardingCompleted() async {
    _hasCompletedOnboarding = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {}
  }

  Future<void> setLoggedIn(bool value) async {
    _isLoggedIn = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, value);
    } catch (_) {}
  }

  Future<void> updateProfile({required String name, required String email}) async {
    _userName = name;
    _userEmail = email;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userEmailKey, email);
    } catch (_) {}
  }

  Future<void> setCurrency(String newCurrency) async {
    _currency = newCurrency;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userCurrencyKey, newCurrency);
    } catch (_) {}
  }
}
