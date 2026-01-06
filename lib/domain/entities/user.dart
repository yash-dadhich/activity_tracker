import 'package:equatable/equatable.dart';

enum UserRole { employee, manager, admin, superAdmin }

enum UserStatus { active, inactive, suspended, pending }

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final UserStatus status;
  final String departmentId;
  final String? managerId;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final UserPreferences preferences;
  final PrivacySettings privacySettings;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    required this.departmentId,
    this.managerId,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    required this.preferences,
    required this.privacySettings,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  bool get isManager => role == UserRole.manager || isAdmin;
  bool get canViewTeamData => isManager;
  bool get canManageUsers => isAdmin;

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    UserStatus? status,
    String? departmentId,
    String? managerId,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
    PrivacySettings? privacySettings,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      status: status ?? this.status,
      departmentId: departmentId ?? this.departmentId,
      managerId: managerId ?? this.managerId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'departmentId': departmentId,
      'managerId': managerId,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences.toJson(),
      'privacySettings': privacySettings.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        status,
        departmentId,
        managerId,
        profileImageUrl,
        createdAt,
        updatedAt,
        lastLoginAt,
        preferences,
        privacySettings,
      ];
}

class UserPreferences extends Equatable {
  final String theme; // 'light', 'dark', 'system'
  final String language;
  final String timezone;
  final bool enableNotifications;
  final bool enableSounds;
  final Duration screenshotInterval;
  final bool enableLocationTracking;
  final Map<String, dynamic> customSettings;

  const UserPreferences({
    this.theme = 'system',
    this.language = 'en',
    this.timezone = 'UTC',
    this.enableNotifications = true,
    this.enableSounds = true,
    this.screenshotInterval = const Duration(minutes: 5),
    this.enableLocationTracking = false,
    this.customSettings = const {},
  });

  UserPreferences copyWith({
    String? theme,
    String? language,
    String? timezone,
    bool? enableNotifications,
    bool? enableSounds,
    Duration? screenshotInterval,
    bool? enableLocationTracking,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSounds: enableSounds ?? this.enableSounds,
      screenshotInterval: screenshotInterval ?? this.screenshotInterval,
      enableLocationTracking: enableLocationTracking ?? this.enableLocationTracking,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'timezone': timezone,
      'enableNotifications': enableNotifications,
      'enableSounds': enableSounds,
      'screenshotInterval': screenshotInterval.inSeconds,
      'enableLocationTracking': enableLocationTracking,
      'customSettings': customSettings,
    };
  }

  @override
  List<Object?> get props => [
        theme,
        language,
        timezone,
        enableNotifications,
        enableSounds,
        screenshotInterval,
        enableLocationTracking,
        customSettings,
      ];
}

class PrivacySettings extends Equatable {
  final bool consentGiven;
  final DateTime? consentDate;
  final bool allowScreenshots;
  final bool allowLocationTracking;
  final bool allowAppTracking;
  final bool allowWebsiteTracking;
  final bool allowIdleTracking;
  final bool shareDataWithManager;
  final bool shareDataWithHR;
  final List<String> dataProcessingPurposes;
  final DateTime? dataRetentionUntil;

  const PrivacySettings({
    this.consentGiven = false,
    this.consentDate,
    this.allowScreenshots = false,
    this.allowLocationTracking = false,
    this.allowAppTracking = false,
    this.allowWebsiteTracking = false,
    this.allowIdleTracking = false,
    this.shareDataWithManager = false,
    this.shareDataWithHR = false,
    this.dataProcessingPurposes = const [],
    this.dataRetentionUntil,
  });

  bool get hasValidConsent {
    if (!consentGiven || consentDate == null) return false;
    
    final now = DateTime.now();
    final consentExpiry = consentDate!.add(const Duration(days: 365));
    return now.isBefore(consentExpiry);
  }

  PrivacySettings copyWith({
    bool? consentGiven,
    DateTime? consentDate,
    bool? allowScreenshots,
    bool? allowLocationTracking,
    bool? allowAppTracking,
    bool? allowWebsiteTracking,
    bool? allowIdleTracking,
    bool? shareDataWithManager,
    bool? shareDataWithHR,
    List<String>? dataProcessingPurposes,
    DateTime? dataRetentionUntil,
  }) {
    return PrivacySettings(
      consentGiven: consentGiven ?? this.consentGiven,
      consentDate: consentDate ?? this.consentDate,
      allowScreenshots: allowScreenshots ?? this.allowScreenshots,
      allowLocationTracking: allowLocationTracking ?? this.allowLocationTracking,
      allowAppTracking: allowAppTracking ?? this.allowAppTracking,
      allowWebsiteTracking: allowWebsiteTracking ?? this.allowWebsiteTracking,
      allowIdleTracking: allowIdleTracking ?? this.allowIdleTracking,
      shareDataWithManager: shareDataWithManager ?? this.shareDataWithManager,
      shareDataWithHR: shareDataWithHR ?? this.shareDataWithHR,
      dataProcessingPurposes: dataProcessingPurposes ?? this.dataProcessingPurposes,
      dataRetentionUntil: dataRetentionUntil ?? this.dataRetentionUntil,
    );
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() {
    return {
      'consentGiven': consentGiven,
      'consentDate': consentDate?.toIso8601String(),
      'allowScreenshots': allowScreenshots,
      'allowLocationTracking': allowLocationTracking,
      'allowAppTracking': allowAppTracking,
      'allowWebsiteTracking': allowWebsiteTracking,
      'allowIdleTracking': allowIdleTracking,
      'shareDataWithManager': shareDataWithManager,
      'shareDataWithHR': shareDataWithHR,
      'dataProcessingPurposes': dataProcessingPurposes,
      'dataRetentionUntil': dataRetentionUntil?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        consentGiven,
        consentDate,
        allowScreenshots,
        allowLocationTracking,
        allowAppTracking,
        allowWebsiteTracking,
        allowIdleTracking,
        shareDataWithManager,
        shareDataWithHR,
        dataProcessingPurposes,
        dataRetentionUntil,
      ];
}