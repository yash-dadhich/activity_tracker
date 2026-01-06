import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../../domain/entities/user.dart';

class AuthManager extends ChangeNotifier {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthManager({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
  }) : _apiClient = apiClient, _secureStorage = secureStorage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;

  // Role-based access checks
  bool get isEmployee => _currentUser?.role == UserRole.employee;
  bool get isManager => _currentUser?.role == UserRole.manager || isAdmin;
  bool get isAdmin => _currentUser?.role == UserRole.admin || isSuperAdmin;
  bool get isSuperAdmin => _currentUser?.role == UserRole.superAdmin;

  bool canViewTeamData() => isManager;
  bool canManageUsers() => isAdmin;
  bool canViewDepartmentData() => isAdmin;
  bool canViewAllData() => isSuperAdmin;

  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Load stored tokens
      _accessToken = await _secureStorage.read(_accessTokenKey);
      _refreshToken = await _secureStorage.read(_refreshTokenKey);
      
      if (_accessToken != null) {
        // Check if token is valid
        if (!JwtDecoder.isExpired(_accessToken!)) {
          // Load user data
          final userDataJson = await _secureStorage.read(_userDataKey);
          if (userDataJson != null) {
            final userData = jsonDecode(userDataJson);
            _currentUser = User.fromJson(userData);
            _isAuthenticated = true;
            
            // Set API client token
            _apiClient.setAuthToken(_accessToken!);
          }
        } else if (_refreshToken != null) {
          // Try to refresh token
          await _refreshAccessToken();
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      await _clearAuthData();
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    Map<String, dynamic>? deviceInfo,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
        'deviceInfo': deviceInfo ?? _getDeviceInfo(),
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // Store tokens
        _accessToken = data['accessToken'];
        _refreshToken = data['refreshToken'];
        
        await _secureStorage.write(_accessTokenKey, _accessToken!);
        await _secureStorage.write(_refreshTokenKey, _refreshToken!);
        
        // Store user data
        _currentUser = User.fromJson(data['user']);
        await _secureStorage.write(_userDataKey, jsonEncode(_currentUser!.toJson()));
        
        // Set API client token
        _apiClient.setAuthToken(_accessToken!);
        
        _isAuthenticated = true;
        notifyListeners();
        
        return AuthResult.success();
      } else {
        return AuthResult.failure(response.data['error'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return AuthResult.failure('Network error occurred');
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String departmentId,
    UserRole role = UserRole.employee,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _apiClient.post('/auth/register', data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'departmentId': departmentId,
        'role': role.toString().split('.').last,
      });

      if (response.data['success'] == true) {
        return AuthResult.success(message: response.data['message']);
      } else {
        return AuthResult.failure(response.data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      return AuthResult.failure('Network error occurred');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      if (_refreshToken != null) {
        await _apiClient.post('/auth/logout', data: {
          'refreshToken': _refreshToken,
        });
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
    }
    
    await _clearAuthData();
    _setLoading(false);
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await _apiClient.post('/auth/refresh', data: {
        'refreshToken': _refreshToken,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _accessToken = data['accessToken'];
        
        await _secureStorage.write(_accessTokenKey, _accessToken!);
        _apiClient.setAuthToken(_accessToken!);
        
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }
    
    return false;
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!_isAuthenticated) {
      return AuthResult.failure('User not authenticated');
    }
    
    _setLoading(true);
    
    try {
      final response = await _apiClient.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response.data['success'] == true) {
        // Force logout to re-authenticate with new password
        await logout();
        return AuthResult.success(message: 'Password changed successfully. Please log in again.');
      } else {
        return AuthResult.failure(response.data['error'] ?? 'Password change failed');
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      return AuthResult.failure('Network error occurred');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserPreferences(UserPreferences preferences) async {
    if (_currentUser == null) return;
    
    try {
      final response = await _apiClient.put('/users/preferences', data: preferences.toJson());
      
      if (response.data['success'] == true) {
        _currentUser = _currentUser!.copyWith(preferences: preferences);
        await _secureStorage.write(_userDataKey, jsonEncode(_currentUser!.toJson()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update preferences error: $e');
    }
  }

  Future<void> updatePrivacySettings(PrivacySettings privacySettings) async {
    if (_currentUser == null) return;
    
    try {
      final response = await _apiClient.put('/users/privacy-settings', data: privacySettings.toJson());
      
      if (response.data['success'] == true) {
        _currentUser = _currentUser!.copyWith(privacySettings: privacySettings);
        await _secureStorage.write(_userDataKey, jsonEncode(_currentUser!.toJson()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update privacy settings error: $e');
    }
  }

  bool hasValidConsent() {
    return _currentUser?.privacySettings.hasValidConsent ?? false;
  }

  bool canPerformAction(String action) {
    if (_currentUser == null) return false;
    
    switch (action) {
      case 'view_team_data':
        return canViewTeamData();
      case 'manage_users':
        return canManageUsers();
      case 'view_department_data':
        return canViewDepartmentData();
      case 'view_all_data':
        return canViewAllData();
      case 'capture_screenshots':
        return _currentUser!.privacySettings.allowScreenshots;
      case 'track_location':
        return _currentUser!.privacySettings.allowLocationTracking;
      case 'track_apps':
        return _currentUser!.privacySettings.allowAppTracking;
      case 'track_websites':
        return _currentUser!.privacySettings.allowWebsiteTracking;
      case 'track_idle':
        return _currentUser!.privacySettings.allowIdleTracking;
      default:
        return false;
    }
  }

  Future<void> _clearAuthData() async {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _isAuthenticated = false;
    
    await _secureStorage.delete(_accessTokenKey);
    await _secureStorage.delete(_refreshTokenKey);
    await _secureStorage.delete(_userDataKey);
    
    _apiClient.clearAuthToken();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Map<String, dynamic> _getDeviceInfo() {
    return {
      'platform': defaultTargetPlatform.name,
      'timestamp': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0', // TODO: Get from package info
    };
  }
}

class AuthResult {
  final bool success;
  final String? message;
  final String? error;

  AuthResult._({
    required this.success,
    this.message,
    this.error,
  });

  factory AuthResult.success({String? message}) {
    return AuthResult._(success: true, message: message);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }
}

// Extension to add JSON serialization to User entity
extension UserJson on User {
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.employee,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => UserStatus.active,
      ),
      departmentId: json['departmentId'],
      managerId: json['managerId'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      preferences: UserPreferences.fromJson(json['preferences']),
      privacySettings: PrivacySettings.fromJson(json['privacySettings']),
    );
  }
}

extension UserPreferencesJson on UserPreferences {
  static UserPreferences fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'system',
      language: json['language'] ?? 'en',
      timezone: json['timezone'] ?? 'UTC',
      enableNotifications: json['enableNotifications'] ?? true,
      enableSounds: json['enableSounds'] ?? true,
      screenshotInterval: Duration(seconds: json['screenshotInterval'] ?? 300),
      enableLocationTracking: json['enableLocationTracking'] ?? false,
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
    );
  }
}

extension PrivacySettingsJson on PrivacySettings {
  static PrivacySettings fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      consentGiven: json['consentGiven'] ?? false,
      consentDate: json['consentDate'] != null ? DateTime.parse(json['consentDate']) : null,
      allowScreenshots: json['allowScreenshots'] ?? false,
      allowLocationTracking: json['allowLocationTracking'] ?? false,
      allowAppTracking: json['allowAppTracking'] ?? false,
      allowWebsiteTracking: json['allowWebsiteTracking'] ?? false,
      allowIdleTracking: json['allowIdleTracking'] ?? false,
      shareDataWithManager: json['shareDataWithManager'] ?? false,
      shareDataWithHR: json['shareDataWithHR'] ?? false,
      dataProcessingPurposes: List<String>.from(json['dataProcessingPurposes'] ?? []),
      dataRetentionUntil: json['dataRetentionUntil'] != null ? DateTime.parse(json['dataRetentionUntil']) : null,
    );
  }
}