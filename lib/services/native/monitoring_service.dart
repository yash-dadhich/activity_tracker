import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/activity_session.dart';
import '../../domain/entities/user.dart';
import '../ai/productivity_classifier.dart';
import '../security/encryption_service.dart';

class MonitoringService {
  static const MethodChannel _channel = MethodChannel('com.enterprise.productivity/monitoring');
  static const EventChannel _eventChannel = EventChannel('com.enterprise.productivity/monitoring_events');
  
  final ProductivityClassifier _classifier = ProductivityClassifier();
  final EncryptionService _encryption = EncryptionService();
  final _uuid = const Uuid();
  
  Timer? _monitoringTimer;
  StreamSubscription? _eventSubscription;
  ActivitySession? _currentSession;
  
  // Callbacks
  Function(ActivitySession)? onSessionStarted;
  Function(ActivitySession)? onSessionEnded;
  Function(ActivityEvent)? onActivityEvent;
  Function(Screenshot)? onScreenshotCaptured;
  
  bool _isMonitoring = false;
  User? _currentUser;

  bool get isMonitoring => _isMonitoring;
  ActivitySession? get currentSession => _currentSession;

  Future<void> initialize(User user) async {
    _currentUser = user;
    await _setupNativeChannels();
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring || _currentUser == null) return;
    
    try {
      // Check permissions first
      final hasPermissions = await _checkPermissions();
      if (!hasPermissions) {
        throw Exception('Required permissions not granted');
      }

      // Start native monitoring
      await _channel.invokeMethod('startMonitoring', {
        'userId': _currentUser!.id,
        'screenshotInterval': _currentUser!.preferences.screenshotInterval.inSeconds,
        'enableScreenshots': _currentUser!.privacySettings.allowScreenshots,
        'enableLocationTracking': _currentUser!.privacySettings.allowLocationTracking,
        'enableAppTracking': _currentUser!.privacySettings.allowAppTracking,
        'enableWebsiteTracking': _currentUser!.privacySettings.allowWebsiteTracking,
      });

      // Start event listening
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        _handleNativeEvent,
        onError: _handleEventError,
      );

      // Start periodic monitoring
      _monitoringTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _performMonitoringCycle(),
      );

      _isMonitoring = true;
      print('✅ Monitoring started for user: ${_currentUser!.fullName}');
    } catch (e) {
      print('❌ Failed to start monitoring: $e');
      rethrow;
    }
  }

  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    try {
      // End current session
      if (_currentSession != null) {
        await _endCurrentSession();
      }

      // Stop native monitoring
      await _channel.invokeMethod('stopMonitoring');

      // Cancel timers and subscriptions
      _monitoringTimer?.cancel();
      _eventSubscription?.cancel();

      _isMonitoring = false;
      print('✅ Monitoring stopped');
    } catch (e) {
      print('❌ Failed to stop monitoring: $e');
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      final permissions = await _channel.invokeMapMethod<String, bool>('checkPermissions');
      
      if (Platform.isMacOS) {
        return permissions?['screenRecording'] == true && 
               permissions?['accessibility'] == true;
      } else if (Platform.isWindows) {
        return permissions?['systemAccess'] == true;
      } else if (Platform.isLinux) {
        return permissions?['x11Access'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Permission check failed: $e');
      return false;
    }
  }

  Future<void> _setupNativeChannels() async {
    try {
      await _channel.invokeMethod('initialize', {
        'userId': _currentUser!.id,
        'deviceId': await _getDeviceId(),
      });
    } catch (e) {
      print('❌ Failed to setup native channels: $e');
    }
  }

  Future<String> _getDeviceId() async {
    try {
      return await _channel.invokeMethod('getDeviceId') ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  void _handleNativeEvent(dynamic event) {
    try {
      final eventMap = Map<String, dynamic>.from(event);
      final eventType = eventMap['type'] as String;

      switch (eventType) {
        case 'activity_change':
          _handleActivityChange(eventMap);
          break;
        case 'screenshot_captured':
          _handleScreenshotCaptured(eventMap);
          break;
        case 'idle_state_change':
          _handleIdleStateChange(eventMap);
          break;
        case 'location_update':
          _handleLocationUpdate(eventMap);
          break;
        default:
          print('Unknown event type: $eventType');
      }
    } catch (e) {
      print('❌ Error handling native event: $e');
    }
  }

  void _handleEventError(dynamic error) {
    print('❌ Native event stream error: $error');
  }

  Future<void> _performMonitoringCycle() async {
    try {
      // Get current activity info
      final activityInfo = await _channel.invokeMapMethod<String, dynamic>('getCurrentActivity');
      
      if (activityInfo != null) {
        await _processActivityInfo(activityInfo);
      }
    } catch (e) {
      print('❌ Monitoring cycle error: $e');
    }
  }

  Future<void> _processActivityInfo(Map<String, dynamic> info) async {
    final title = info['title'] as String? ?? 'Unknown';
    final applicationName = info['application'] as String? ?? 'Unknown';
    final isIdle = info['isIdle'] as bool? ?? false;

    // Classify activity
    final category = await _classifier.classifyActivity(
      applicationName: applicationName,
      windowTitle: title,
      isIdle: isIdle,
    );

    // Check if we need to start a new session
    if (_shouldStartNewSession(applicationName, title, isIdle)) {
      await _startNewSession(
        title: title,
        applicationName: applicationName,
        isIdle: isIdle,
        category: category,
      );
    } else if (_currentSession != null) {
      // Update current session
      _updateCurrentSession(info);
    }
  }

  bool _shouldStartNewSession(String applicationName, String title, bool isIdle) {
    if (_currentSession == null) return true;
    
    // Start new session if activity changed significantly
    return _currentSession!.applicationName != applicationName ||
           _currentSession!.title != title ||
           _currentSession!.isIdle != isIdle;
  }

  Future<void> _startNewSession({
    required String title,
    required String applicationName,
    required bool isIdle,
    required ProductivityCategory category,
  }) async {
    // End current session if exists
    if (_currentSession != null) {
      await _endCurrentSession();
    }

    // Create new session
    final session = ActivitySession(
      id: _uuid.v4(),
      userId: _currentUser!.id,
      deviceId: await _getDeviceId(),
      startTime: DateTime.now(),
      duration: Duration.zero,
      type: _getActivityType(applicationName),
      category: category,
      title: title,
      applicationName: applicationName,
      isIdle: isIdle,
      events: [],
    );

    _currentSession = session;
    onSessionStarted?.call(session);
    
    print('🚀 Started new session: $applicationName - $title');
  }

  void _updateCurrentSession(Map<String, dynamic> info) {
    if (_currentSession == null) return;

    // Add activity event
    final event = ActivityEvent(
      id: _uuid.v4(),
      sessionId: _currentSession!.id,
      timestamp: DateTime.now(),
      eventType: 'activity_update',
      data: info,
    );

    _currentSession = _currentSession!.copyWith(
      events: [..._currentSession!.events, event],
      duration: DateTime.now().difference(_currentSession!.startTime),
    );

    onActivityEvent?.call(event);
  }

  Future<void> _endCurrentSession() async {
    if (_currentSession == null) return;

    final endedSession = _currentSession!.copyWith(
      endTime: DateTime.now(),
      duration: DateTime.now().difference(_currentSession!.startTime),
    );

    onSessionEnded?.call(endedSession);
    _currentSession = null;
    
    print('🏁 Ended session: ${endedSession.applicationName} (${endedSession.duration})');
  }

  ActivityType _getActivityType(String applicationName) {
    final app = applicationName.toLowerCase();
    
    if (app.contains('browser') || app.contains('chrome') || app.contains('firefox') || app.contains('safari')) {
      return ActivityType.website;
    } else if (app.contains('zoom') || app.contains('teams') || app.contains('meet')) {
      return ActivityType.meeting;
    } else if (app.contains('idle') || app.contains('screensaver')) {
      return ActivityType.idle;
    } else {
      return ActivityType.application;
    }
  }

  void _handleActivityChange(Map<String, dynamic> event) {
    // Handle activity change events from native side
    print('📱 Activity changed: ${event['application']} - ${event['title']}');
  }

  void _handleScreenshotCaptured(Map<String, dynamic> event) async {
    if (!_currentUser!.privacySettings.allowScreenshots) return;

    try {
      final filePath = event['filePath'] as String;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(event['timestamp'] as int);
      
      // Encrypt screenshot if required
      String? encryptionKey;
      if (_currentUser!.privacySettings.consentGiven) {
        encryptionKey = await _encryption.encryptFile(filePath);
      }

      final screenshot = Screenshot(
        id: _uuid.v4(),
        sessionId: _currentSession?.id ?? 'no-session',
        userId: _currentUser!.id,
        timestamp: timestamp,
        filePath: filePath,
        fileSize: event['fileSize'] as int? ?? 0,
        isEncrypted: encryptionKey != null,
        encryptionKey: encryptionKey,
        privacyLevel: PrivacyLevel.standard,
      );

      onScreenshotCaptured?.call(screenshot);
      print('📸 Screenshot captured and encrypted');
    } catch (e) {
      print('❌ Screenshot handling error: $e');
    }
  }

  void _handleIdleStateChange(Map<String, dynamic> event) {
    final isIdle = event['isIdle'] as bool;
    print('😴 Idle state changed: $isIdle');
    
    if (isIdle && _currentSession != null && !_currentSession!.isIdle) {
      // Start idle session
      _startNewSession(
        title: 'System Idle',
        applicationName: 'System',
        isIdle: true,
        category: ProductivityCategory.neutral,
      );
    }
  }

  void _handleLocationUpdate(Map<String, dynamic> event) {
    if (!_currentUser!.privacySettings.allowLocationTracking) return;

    final location = Location(
      latitude: event['latitude'] as double,
      longitude: event['longitude'] as double,
      accuracy: event['accuracy'] as double?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(event['timestamp'] as int),
    );

    print('📍 Location updated: ${location.latitude}, ${location.longitude}');
  }

  Future<void> captureScreenshotManually() async {
    if (!_currentUser!.privacySettings.allowScreenshots) {
      throw Exception('Screenshots not allowed by user privacy settings');
    }

    try {
      await _channel.invokeMethod('captureScreenshot');
    } catch (e) {
      print('❌ Manual screenshot capture failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      return await _channel.invokeMapMethod<String, dynamic>('getSystemInfo') ?? {};
    } catch (e) {
      print('❌ Failed to get system info: $e');
      return {};
    }
  }

  void dispose() {
    stopMonitoring();
  }
}