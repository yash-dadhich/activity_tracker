class AppConstants {
  // App Information
  static const String appName = 'Enterprise Productivity Monitor';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001/v1',
  );
  
  static const String wsUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://api.enterprise-productivity.com/ws',
  );
  
  // Authentication
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 8);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Monitoring Configuration
  static const Duration defaultScreenshotInterval = Duration(minutes: 5);
  static const Duration defaultActivityInterval = Duration(seconds: 5);
  static const Duration defaultIdleThreshold = Duration(minutes: 5);
  static const Duration maxIdleTime = Duration(hours: 2);
  
  // File Upload Limits
  static const int maxScreenshotSize = 10 * 1024 * 1024; // 10MB
  static const int maxFileUploadSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageFormats = ['png', 'jpg', 'jpeg'];
  static const List<String> allowedDocumentFormats = ['pdf', 'doc', 'docx', 'txt'];
  
  // Privacy & Compliance
  static const Duration consentValidityPeriod = Duration(days: 365);
  static const Duration dataRetentionPeriod = Duration(days: 90);
  static const Duration auditLogRetention = Duration(days: 2555); // 7 years
  
  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const int maxRecentItems = 10;
  static const int itemsPerPage = 20;
  
  // Productivity Scoring
  static const double productiveWeight = 1.0;
  static const double neutralWeight = 0.5;
  static const double distractingWeight = 0.1;
  static const double personalWeight = 0.3;
  
  // Alert Thresholds
  static const double lowProductivityThreshold = 0.4;
  static const double highProductivityThreshold = 0.8;
  static const Duration prolongedIdleThreshold = Duration(minutes: 30);
  static const Duration excessiveDistractingThreshold = Duration(hours: 2);
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
  static const Duration offlineDataRetention = Duration(days: 7);
  
  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Encryption
  static const String encryptionAlgorithm = 'AES-256-GCM';
  static const int keySize = 256;
  static const int ivSize = 16;
  
  // Database
  static const String databaseName = 'enterprise_productivity.db';
  static const int databaseVersion = 1;
  static const int maxDatabaseSize = 100 * 1024 * 1024; // 100MB
  
  // Logging
  static const bool enableDebugLogging = bool.fromEnvironment('DEBUG', defaultValue: false);
  static const bool enableAnalytics = bool.fromEnvironment('ANALYTICS', defaultValue: true);
  static const Duration logRetentionPeriod = Duration(days: 30);
  
  // Feature Flags
  static const bool enableAIClassification = bool.fromEnvironment('AI_CLASSIFICATION', defaultValue: true);
  static const bool enableLocationTracking = bool.fromEnvironment('LOCATION_TRACKING', defaultValue: false);
  static const bool enableBiometricAuth = bool.fromEnvironment('BIOMETRIC_AUTH', defaultValue: true);
  static const bool enableOfflineMode = bool.fromEnvironment('OFFLINE_MODE', defaultValue: true);
  
  // Notification Configuration
  static const Duration notificationDisplayDuration = Duration(seconds: 5);
  static const int maxNotifications = 5;
  static const bool enablePushNotifications = true;
  
  // Performance Monitoring
  static const Duration performanceMetricInterval = Duration(minutes: 1);
  static const int maxPerformanceMetrics = 1000;
  static const double cpuThreshold = 80.0;
  static const double memoryThreshold = 85.0;
  
  // Accessibility
  static const Duration accessibilityTimeout = Duration(seconds: 10);
  static const double minTouchTargetSize = 44.0;
  static const double textScaleFactor = 1.0;
  
  // Localization
  static const String defaultLocale = 'en_US';
  static const List<String> supportedLocales = [
    'en_US',
    'es_ES',
    'fr_FR',
    'de_DE',
    'it_IT',
    'pt_BR',
    'ja_JP',
    'ko_KR',
    'zh_CN',
  ];
  
  // Error Messages
  static const String genericErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String authErrorMessage = 'Authentication failed. Please log in again.';
  static const String permissionErrorMessage = 'Permission denied. Please check your access rights.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful';
  static const String dataUploadSuccessMessage = 'Data uploaded successfully';
  static const String settingsUpdatedMessage = 'Settings updated successfully';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  
  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'h:mm a';
  
  // Chart Configuration
  static const int maxChartDataPoints = 100;
  static const Duration chartAnimationDuration = Duration(milliseconds: 800);
  static const double chartLineWidth = 2.0;
  
  // Export Configuration
  static const List<String> exportFormats = ['pdf', 'csv', 'xlsx', 'json'];
  static const int maxExportRecords = 10000;
  static const Duration exportTimeout = Duration(minutes: 5);
  
  // Sync Configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration forceSyncInterval = Duration(hours: 4);
  static const int maxSyncRetries = 5;
  static const Duration syncTimeout = Duration(minutes: 2);
  
  // Security Configuration
  static const Duration certificatePinningTimeout = Duration(seconds: 30);
  static const List<String> pinnedCertificates = [
    // Production certificate fingerprints would go here
  ];
  
  // Development Configuration
  static const bool enableMockData = bool.fromEnvironment('MOCK_DATA', defaultValue: true);
  static const bool enableDebugOverlay = bool.fromEnvironment('DEBUG_OVERLAY', defaultValue: false);
  static const bool skipAuthentication = bool.fromEnvironment('SKIP_AUTH', defaultValue: false);
  
  // Platform-specific Configuration
  static const Map<String, dynamic> windowsConfig = {
    'minWindowWidth': 800.0,
    'minWindowHeight': 600.0,
    'defaultWindowWidth': 1200.0,
    'defaultWindowHeight': 800.0,
    'enableSystemTray': true,
    'enableAutoStart': true,
  };
  
  static const Map<String, dynamic> macosConfig = {
    'minWindowWidth': 800.0,
    'minWindowHeight': 600.0,
    'defaultWindowWidth': 1200.0,
    'defaultWindowHeight': 800.0,
    'enableMenuBar': true,
    'enableAutoStart': true,
  };
  
  static const Map<String, dynamic> linuxConfig = {
    'minWindowWidth': 800.0,
    'minWindowHeight': 600.0,
    'defaultWindowWidth': 1200.0,
    'defaultWindowHeight': 800.0,
    'enableSystemTray': true,
    'enableAutoStart': false,
  };
  
  // Theme Configuration
  static const Map<String, dynamic> lightTheme = {
    'primaryColor': 0xFF2196F3,
    'secondaryColor': 0xFF03DAC6,
    'backgroundColor': 0xFFFFFFFF,
    'surfaceColor': 0xFFF5F5F5,
    'errorColor': 0xFFB00020,
    'onPrimaryColor': 0xFFFFFFFF,
    'onSecondaryColor': 0xFF000000,
    'onBackgroundColor': 0xFF000000,
    'onSurfaceColor': 0xFF000000,
    'onErrorColor': 0xFFFFFFFF,
  };
  
  static const Map<String, dynamic> darkTheme = {
    'primaryColor': 0xFF1976D2,
    'secondaryColor': 0xFF03DAC6,
    'backgroundColor': 0xFF121212,
    'surfaceColor': 0xFF1E1E1E,
    'errorColor': 0xFFCF6679,
    'onPrimaryColor': 0xFFFFFFFF,
    'onSecondaryColor': 0xFF000000,
    'onBackgroundColor': 0xFFFFFFFF,
    'onSurfaceColor': 0xFFFFFFFF,
    'onErrorColor': 0xFF000000,
  };
  
  // Productivity Categories
  static const Map<String, Map<String, dynamic>> productivityCategories = {
    'productive': {
      'color': 0xFF4CAF50,
      'icon': 'trending_up',
      'weight': 1.0,
      'description': 'Work-related activities that contribute to productivity',
    },
    'neutral': {
      'color': 0xFFFF9800,
      'icon': 'remove',
      'weight': 0.5,
      'description': 'Activities that are neither productive nor distracting',
    },
    'distracting': {
      'color': 0xFFF44336,
      'icon': 'trending_down',
      'weight': 0.1,
      'description': 'Activities that detract from productivity',
    },
    'personal': {
      'color': 0xFF9C27B0,
      'icon': 'person',
      'weight': 0.3,
      'description': 'Personal activities during work hours',
    },
    'unknown': {
      'color': 0xFF607D8B,
      'icon': 'help',
      'weight': 0.5,
      'description': 'Activities that could not be classified',
    },
  };
  
  // Help & Support
  static const String supportEmail = 'support@enterprise-productivity.com';
  static const String documentationUrl = 'https://docs.enterprise-productivity.com';
  static const String privacyPolicyUrl = 'https://enterprise-productivity.com/privacy';
  static const String termsOfServiceUrl = 'https://enterprise-productivity.com/terms';
  static const String statusPageUrl = 'https://status.enterprise-productivity.com';
  
  // Analytics Events
  static const String loginEvent = 'user_login';
  static const String logoutEvent = 'user_logout';
  static const String screenshotCapturedEvent = 'screenshot_captured';
  static const String activityRecordedEvent = 'activity_recorded';
  static const String settingsChangedEvent = 'settings_changed';
  static const String errorOccurredEvent = 'error_occurred';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String cacheKey = 'app_cache';
  static const String lastSyncKey = 'last_sync';
  
  // Prevent instantiation
  AppConstants._();
}