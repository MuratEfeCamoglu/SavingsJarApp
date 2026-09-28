import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the Biometric Lock preference and performs device authentication.
class SecurityProvider with ChangeNotifier {
  static const _key = 'biometricEnabled';
  final SharedPreferences _prefs;
  final LocalAuthentication _auth = LocalAuthentication();

  SecurityProvider(this._prefs);

  bool get biometricEnabled => _prefs.getBool(_key) ?? false;

  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('SecurityProvider.isSupported error: $e');
      return false;
    }
  }

  /// Prompts for biometrics (or the device PIN as fallback).
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      debugPrint('SecurityProvider.authenticate error: $e');
      return false;
    }
  }

  /// Enabling requires a successful authentication first, so users can't
  /// lock themselves out on a device that can't authenticate.
  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      if (!await isSupported()) return false;
      if (!await authenticate('Confirm to enable Biometric Lock')) return false;
    }
    await _prefs.setBool(_key, enabled);
    notifyListeners();
    return true;
  }
}
