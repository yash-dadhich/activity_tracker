import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../ai/productivity_classifier.dart';
import '../../domain/entities/activity_session.dart';
import '../../domain/entities/user.dart';

class EnhancedMonitoringService {
  static const MethodChannel _channel = MethodChannel('com.enterprise.productivity/monitoring');
  
  final ProductivityClassifier _classifier;
  Timer? _activityTimer;
  Timer? _screenshotTimer;
  Timer? _idleTimer;
  
  // Callbacks
  Function(ActivitySession)? onActivityDetected;
  Function(String)? onScreenshotCaptured;
  Function(bool)? onIdleStateChanged;
  Function(Map<String, dynamic>)? onSystemInfoUpdated;
  
  // State
  bool _isMonitoring = false;
  bool _isIdle = false;
  DateTime? _lastActivity;
  String? _currentApplication;
  String? _currentWindowTitle;
  Map<String, int> _keystrokeCounts = {};
  Map<String, int> _mouseClickCounts = {};
  
  EnhancedMonitoringService() : _classifier = ProductivityClassifier();

  Future<void> initialize() async {
    await _classifier.initialize();
    
    // Set up native event listeners
    _channel.setMethodCallHandler(_handleNativeEvent);
  }

  Future<void> startMonitoring({
    required User user,
    Duration activityInterval = const Duration(seconds: 5),
    Duration screenshotInterval = const Duration(minutes: 5),
    Duration idleThreshold = const Duration(minutes: 5),
  }) async {
    if (_isMonitoring) return;

    try {
      // Start native monitoring
      await _channel.invokeMethod('startMonitoring', {
        'userId': user.id,
        'activityInterval': activityInterval.inSeconds,
        'screenshotInterval': screenshotInterval.inSeconds,
        'idleThreshold': idleThreshold.inSeconds,
        'permissions': {
          'screenshots': user.privacySettings.allowScreenshots,
          'applications': user.privacySettings.allowAppTracking,
          'websites': user.privacySettings.allowWebsiteTracking,
          'location': user.privacySettings.allowLocationTracking,
          'idle': user.privacySettings.allowIdleTracking,
        },
      });

      // Start periodic activity collection
      _activityTimer = Timer.periodic(activityInterval, (_) => _collectActivity());
      
      // Start screenshot capture if enabled
      if (user.privacySettings.allowScreenshots) {
        _screenshotTimer = Timer.periodic(screenshotInterval, (_) => _captureScreenshot());
      }
      
      // Start idle detection
      if (user.privacySettings.allowIdleTracking) {
        _idleTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkIdleState());
      }

      _isMonitoring = true;
      print('✅ Enhanced monitoring started');
    } catch (e) {
      print('❌ Error starting enhanced monitoring: $e');
      rethrow;
    }
  }

  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    try {
      await _channel.invokeMethod('stopMonitoring');
      
      _activityTimer?.cancel();
      _screenshotTimer?.cancel();
      _idleTimer?.cancel();
      
      _isMonitoring = false;
      print('✅ Enhanced monitoring stopped');
    } catch (e) {
      print('❌ Error stopping enhanced monitoring: $e');
    }
  }

  Future<void> _collectActivity() async {
    try {
      final activityData = await _channel.invokeMethod('getActivityData');
      
      if (activityData != null) {
        await _processActivityData(activityData);
      }
    } catch (e) {
      print('❌ Error collecting activity: $e');
    }
  }

  Future<void> _processActivityData(Map<dynamic, dynamic> data) async {
    try {
      final applicationName = data['applicationName'] as String?;
      final windowTitle = data['windowTitle'] as String?;
      final websiteUrl = data['websiteUrl'] as String?;
      final keystrokeCount = data['keystrokeCount'] as int? ?? 0;
      final mouseClickCount = data['mouseClickCount'] as int? ?? 0;
      final isIdle = data['isIdle'] as bool? ?? false;

      // Update activity tracking
      if (!isIdle) {
        _lastActivity = DateTime.now();
      }

      // Classify activity using AI
      ProductivityCategory category = ProductivityCategory.unknown;
      if (applicationName != null) {
        category = await _classifier.classifyActivity(
          applicationName: applicationName,
          windowTitle: windowTitle ?? '',
          isIdle: isIdle,
          websiteUrl: websiteUrl,
        );
      }

      // Create activity session
      final session = ActivitySession(
        id: _generateSessionId(),
        userId: '', // Will be set by caller
        deviceId: await _getDeviceId(),
        startTime: DateTime.now(),
        duration: const Duration(seconds: 5), // Collection interval
        type: _determineActivityType(applicationName, websiteUrl),
        category: category,
        title: windowTitle ?? applicationName ?? 'Unknown Activity',
        applicationName: applicationName,
        websiteUrl: websiteUrl,
        isIdle: isIdle,
        metadata: {
          'keystrokeCount': keystrokeCount,
          'mouseClickCount': mouseClickCount,
          'platform': Platform.operatingSystem,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Update counters
      if (applicationName != null) {
        _keystrokeCounts[applicationName] = 
            (_keystrokeCounts[applicationName] ?? 0) + keystrokeCount;
        _mouseClickCounts[applicationName] = 
            (_mouseClickCounts[applicationName] ?? 0) + mouseClickCount;
      }

      // Notify listeners
      onActivityDetected?.call(session);

      // Update current state
      _currentApplication = applicationName;
      _currentWindowTitle = windowTitle;

    } catch (e) {
      print('❌ Error processing activity data: $e');
    }
  }

  Future<void> _captureScreenshot() async {
    try {
      final screenshotPath = await _channel.invokeMethod('captureScreenshot', {
        'quality': 85,
        'maxWidth': 1920,
        'maxHeight': 1080,
        'includeMetadata': true,
      });

      if (screenshotPath != null) {
        onScreenshotCaptured?.call(screenshotPath);
      }
    } catch (e) {
      print('❌ Error capturing screenshot: $e');
    }
  }

  Future<void> _checkIdleState() async {
    try {
      final idleData = await _channel.invokeMethod('getIdleState');
      final isCurrentlyIdle = idleData['isIdle'] as bool? ?? false;
      final idleDuration = Duration(seconds: idleData['idleSeconds'] as int? ?? 0);

      if (_isIdle != isCurrentlyIdle) {
        _isIdle = isCurrentlyIdle;
        onIdleStateChanged?.call(_isIdle);
        
        print(_isIdle 
          ? '😴 User went idle (${idleDuration.inMinutes} minutes)'
          : '👋 User became active');
      }
    } catch (e) {
      print('❌ Error checking idle state: $e');
    }
  }

  Future<void> _handleNativeEvent(MethodCall call) async {
    switch (call.method) {
      case 'onApplicationChanged':
        await _handleApplicationChange(call.arguments);
        break;
      case 'onWindowChanged':
        await _handleWindowChange(call.arguments);
        break;
      case 'onUserInput':
        await _handleUserInput(call.arguments);
        break;
      case 'onSystemEvent':
        await _handleSystemEvent(call.arguments);
        break;
      default:
        print('🤷 Unknown native event: ${call.method}');
    }
  }

  Future<void> _handleApplicationChange(Map<dynamic, dynamic> data) async {
    final newApplication = data['applicationName'] as String?;
    
    if (newApplication != _currentApplication) {
      print('🔄 Application changed: $_currentApplication → $newApplication');
      _currentApplication = newApplication;
      
      // Trigger immediate activity collection
      await _collectActivity();
    }
  }

  Future<void> _handleWindowChange(Map<dynamic, dynamic> data) async {
    final newWindowTitle = data['windowTitle'] as String?;
    
    if (newWindowTitle != _currentWindowTitle) {
      print('🪟 Window changed: $newWindowTitle');
      _currentWindowTitle = newWindowTitle;
      
      // Trigger immediate activity collection
      await _collectActivity();
    }
  }

  Future<void> _handleUserInput(Map<dynamic, dynamic> data) async {
    final inputType = data['type'] as String?;
    final count = data['count'] as int? ?? 1;
    
    if (inputType == 'keystroke') {
      _keystrokeCounts[_currentApplication ?? 'unknown'] = 
          (_keystrokeCounts[_currentApplication ?? 'unknown'] ?? 0) + count;
    } else if (inputType == 'mouseClick') {
      _mouseClickCounts[_currentApplication ?? 'unknown'] = 
          (_mouseClickCounts[_currentApplication ?? 'unknown'] ?? 0) + count;
    }
    
    // Reset idle state on user input
    if (_isIdle) {
      _isIdle = false;
      onIdleStateChanged?.call(false);
    }
    
    _lastActivity = DateTime.now();
  }

  Future<void> _handleSystemEvent(Map<dynamic, dynamic> data) async {
    final eventType = data['type'] as String?;
    
    switch (eventType) {
      case 'screenLock':
        print('🔒 Screen locked');
        break;
      case 'screenUnlock':
        print('🔓 Screen unlocked');
        break;
      case 'systemSleep':
        print('😴 System going to sleep');
        break;
      case 'systemWake':
        print('👋 System waking up');
        break;
    }
    
    onSystemInfoUpdated?.call(data);
  }

  ActivityType _determineActivityType(String? applicationName, String? websiteUrl) {
    if (websiteUrl != null && websiteUrl.isNotEmpty) {
      return ActivityType.website;
    } else if (applicationName != null) {
      // Check for specific application types
      final appLower = applicationName.toLowerCase();
      
      if (appLower.contains('browser') || appLower.contains('chrome') || 
          appLower.contains('firefox') || appLower.contains('safari')) {
        return ActivityType.website;
      } else if (appLower.contains('zoom') || appLower.contains('teams') || 
                 appLower.contains('meet') || appLower.contains('skype')) {
        return ActivityType.meeting;
      } else if (appLower.contains('finder') || appLower.contains('explorer') || 
                 appLower.contains('file')) {
        return ActivityType.file;
      } else {
        return ActivityType.application;
      }
    }
    
    return ActivityType.system;
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${_currentApplication?.hashCode ?? 0}';
  }

  Future<String> _getDeviceId() async {
    try {
      return await _channel.invokeMethod('getDeviceId') ?? 'unknown_device';
    } catch (e) {
      return 'unknown_device';
    }
  }

  // Getters for current state
  bool get isMonitoring => _isMonitoring;
  bool get isIdle => _isIdle;
  DateTime? get lastActivity => _lastActivity;
  String? get currentApplication => _currentApplication;
  String? get currentWindowTitle => _currentWindowTitle;
  Map<String, int> get keystrokeCounts => Map.unmodifiable(_keystrokeCounts);
  Map<String, int> get mouseClickCounts => Map.unmodifiable(_mouseClickCounts);

  // Analytics methods
  Future<Map<String, dynamic>> getProductivityInsights({
    Duration period = const Duration(days: 7),
  }) async {
    return await _classifier.generateProductivityInsights(
      sessions: [], // Would be populated with actual sessions
      timeWindow: period,
    );
  }

  Future<double> calculateProductivityScore({
    Duration period = const Duration(days: 1),
  }) async {
    return await _classifier.calculateProductivityScore(
      sessions: [], // Would be populated with actual sessions
      timeWindow: period,
    );
  }

  void clearCache() {
    _classifier.clearCache();
    _keystrokeCounts.clear();
    _mouseClickCounts.clear();
  }

  void dispose() {
    stopMonitoring();
    _classifier.dispose();
  }
}