import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static final AdminService instance = AdminService._internal();
  AdminService._internal();

  static const String _prefAdminPinKey = 'admin_security_pin';
  static const String _defaultPin = '2026';

  // Configured Admin Emails for Instant In-App Recognition
  static const List<String> _adminEmails = [
    'admin@thefreshyard.shop',
    'omar@thefreshyard.shop',
    'admin@freshyard.com',
    'ceo@thefreshyard.shop',
  ];

  bool _isAdminUnlocked = false;
  bool get isAdminUnlocked => _isAdminUnlocked;

  bool isEmailAdmin(String? email) {
    if (email == null || email.isEmpty) return false;
    final clean = email.trim().toLowerCase();
    return _adminEmails.contains(clean) || clean.startsWith('admin@');
  }

  Future<bool> verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_prefAdminPinKey) ?? _defaultPin;
    final isValid = enteredPin.trim() == savedPin.trim();
    if (isValid) {
      _isAdminUnlocked = true;
    }
    return isValid;
  }

  Future<void> changePin(String newPin) async {
    if (newPin.trim().length >= 4) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefAdminPinKey, newPin.trim());
    }
  }

  void unlockAdmin() {
    _isAdminUnlocked = true;
  }

  void lockAdmin() {
    _isAdminUnlocked = false;
  }
}
