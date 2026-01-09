import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AdminPasswordService {
  // TODO: In production, store this securely and allow admins to change it
  static const String _defaultPassword = '123456';
  static String _hashedPassword = '';

  static void initialize() {
    // Hash the default password
    _hashedPassword = _hashPassword(_defaultPassword);
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool validatePassword(String password) {
    final hashedInput = _hashPassword(password);
    return hashedInput == _hashedPassword;
  }

  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!validatePassword(currentPassword)) {
      return false;
    }

    _hashedPassword = _hashPassword(newPassword);
    // TODO: Store in secure storage
    return true;
  }

  static bool isDefaultPassword() {
    return _hashedPassword == _hashPassword(_defaultPassword);
  }
}
