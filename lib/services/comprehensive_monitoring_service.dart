import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/activity_session.dart';
import '../core/storage/secure_storage.dart';

class ComprehensiveMonitoringService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('comprehensive_monitoring');
  
  bool _isMonitoring = false;
  Timer? _screenshotTimer;
  Timer? _activityTimer;
  Timer? _keystrokeTimer;
  
  final SecureStorage _storage = SecureStorage();
  
  // Activity tracking data
  final List<ActivityEvent> _activities = [];
  final List<KeystrokeEvent> _keystrokes = [];
  final List<MouseEvent> _mouseEvents = [];
  final List<ScreenEvent> _screenEvents = [];
  final List<ApplicationEvent> _applicationEvents = [];
  final List<FileEvent> _fileEvents = [];
  final List<BrowserEvent> _browserEvents = [];
  final List<ScreenshotEvent> _screenshots = [];
  
  // Current session data
  String? _currentApplication;
  String? _currentWindow;
  String? _currentUrl;
  DateTime? _sessionStart;
  Map<String, Duration> _applicationTimeTracking = {};
  Map<String, Duration> _websiteTimeTracking = {};
  
  // Getters
  bool get isMonitoring => _isMonitoring;
  List<ActivityEvent> get activities => List.unmodifiable(_activities);
  List<KeystrokeEvent> get keystrokes => List.unmodifiable(_keystrokes);
  List<MouseEvent> get mouseEvents => List.unmodifiable(_mouseEvents);
  List<ScreenEvent> get screenEvents => List.unmodifiable(_screenEvents);
  List<ApplicationEvent> get applicationEvents => List.unmodifiable(_applicationEvents);
  List<FileEvent> get fileEvents => List.unmodifiable(_fileEvents);
  List<BrowserEvent> get browserEvents => List.unmodifiable(_browserEvents);
  List<ScreenshotEvent> get screenshots => List.unmodifiable(_screenshots);
  
  Map<String, Duration> get applicationTimeTracking => Map.unmodifiable(_applicationTimeTracking);
  Map<String, Duration> get websiteTimeTracking => Map.unmodifiable(_websiteTimeTracking);

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    try {
      _isMonitoring = true;
      _sessionStart = DateTime.now();
      
      // Use mock data to avoid permission issues for now
      debugPrint('🔍 Starting monitoring with mock data for demo');
      _startMockDataGeneration();
      
      // Start periodic screenshot capture
      _startScreenshotCapture();
      
      // Start activity tracking
      _startActivityTracking();
      
      // Start keystroke monitoring
      _startKeystrokeMonitoring();
      
      debugPrint('🔍 Comprehensive monitoring started');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to start monitoring: $e');
      _isMonitoring = false;
      notifyListeners();
    }
  }

  void _startMockDataGeneration() {
    // Generate mock data every few seconds for demo purposes
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isMonitoring) {
        timer.cancel();
        return;
      }
      
      _generateMockKeystroke();
      _generateMockMouseEvent();
      _generateMockApplicationEvent();
      
      // Occasionally generate other events
      if (DateTime.now().second % 10 == 0) {
        _generateMockBrowserEvent();
        _generateMockFileEvent();
      }
    });
  }

  void _generateMockKeystroke() {
    final keys = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'space', 'enter'];
    final apps = ['Visual Studio Code', 'Safari', 'Terminal', 'Finder'];
    final windows = ['main.dart', 'Google Search', 'Terminal', 'Desktop'];
    
    final keystroke = KeystrokeEvent(
      id: 'mock_key_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      key: keys[DateTime.now().millisecond % keys.length],
      keyCode: DateTime.now().millisecond % 256,
      modifiers: DateTime.now().second % 4 == 0 ? ['shift'] : [],
      application: apps[DateTime.now().second % apps.length],
      window: windows[DateTime.now().second % windows.length],
      isSpecialKey: DateTime.now().second % 5 == 0,
      metadata: {
        'typing_speed': 2.5 + (DateTime.now().millisecond % 100) / 100,
        'key_duration': 0.1 + (DateTime.now().millisecond % 50) / 1000,
      },
    );
    
    _keystrokes.add(keystroke);
    if (_keystrokes.length > 1000) _keystrokes.removeAt(0);
  }

  void _generateMockMouseEvent() {
    final eventTypes = ['click', 'move', 'scroll'];
    final buttons = ['left', 'right', 'middle'];
    final apps = ['Visual Studio Code', 'Safari', 'Terminal', 'Finder'];
    
    final mouseEvent = MouseEvent(
      id: 'mock_mouse_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: eventTypes[DateTime.now().second % eventTypes.length],
      x: (DateTime.now().millisecond % 1920).toDouble(),
      y: (DateTime.now().microsecond % 1080).toDouble(),
      button: buttons[DateTime.now().second % buttons.length],
      clickCount: 1 + (DateTime.now().second % 3),
      application: apps[DateTime.now().second % apps.length],
      window: 'Main Window',
      metadata: {
        'scroll_delta': DateTime.now().second % 2 == 0 ? 5.0 : -3.0,
      },
    );
    
    _mouseEvents.add(mouseEvent);
    if (_mouseEvents.length > 500) _mouseEvents.removeAt(0);
  }

  void _generateMockApplicationEvent() {
    final apps = [
      'Visual Studio Code', 'Safari', 'Terminal', 'Finder', 'Slack', 
      'Chrome', 'Xcode', 'Figma', 'Notion', 'Spotify'
    ];
    
    final app = apps[DateTime.now().second % apps.length];
    _currentApplication = app;
    
    final appEvent = ApplicationEvent(
      id: 'mock_app_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      applicationName: app,
      applicationPath: '/Applications/$app.app',
      processId: 1000 + (DateTime.now().second % 9000),
      eventType: 'focus_gained',
      version: '1.${DateTime.now().day}.${DateTime.now().hour}',
      metadata: {
        'bundle_id': 'com.company.${app.toLowerCase().replaceAll(' ', '')}',
        'memory_usage': 50 + (DateTime.now().second % 200),
        'cpu_usage': (DateTime.now().second % 50).toDouble(),
      },
    );
    
    _applicationEvents.add(appEvent);
    if (_applicationEvents.length > 100) _applicationEvents.removeAt(0);
    
    // Update time tracking
    _updateApplicationTimeTracking(app);
  }

  void _generateMockBrowserEvent() {
    final urls = [
      'https://github.com/flutter/flutter',
      'https://stackoverflow.com/questions/flutter',
      'https://pub.dev/packages/provider',
      'https://docs.flutter.dev',
      'https://www.google.com/search?q=flutter+monitoring',
    ];
    
    final url = urls[DateTime.now().second % urls.length];
    final domain = Uri.parse(url).host;
    _currentUrl = url;
    
    final browserEvent = BrowserEvent(
      id: 'mock_browser_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: 'navigation',
      url: url,
      title: 'Flutter Development - $domain',
      domain: domain,
      browserName: 'Safari',
      tabId: 'tab_${DateTime.now().second % 5}',
      metadata: {
        'referrer': 'https://www.google.com',
        'load_time': 1.2 + (DateTime.now().millisecond % 100) / 100,
        'scroll_position': DateTime.now().second % 1000,
      },
    );
    
    _browserEvents.add(browserEvent);
    if (_browserEvents.length > 50) _browserEvents.removeAt(0);
    
    // Update website time tracking
    _updateWebsiteTimeTracking(url);
  }

  void _generateMockFileEvent() {
    final operations = ['open', 'save', 'create', 'delete'];
    final files = [
      'main.dart', 'pubspec.yaml', 'README.md', 'config.json',
      'styles.css', 'index.html', 'app.js', 'data.csv'
    ];
    final extensions = ['dart', 'yaml', 'md', 'json', 'css', 'html', 'js', 'csv'];
    
    final fileName = files[DateTime.now().second % files.length];
    final extension = extensions[DateTime.now().second % extensions.length];
    
    final fileEvent = FileEvent(
      id: 'mock_file_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: 'file_access',
      filePath: '/Users/developer/projects/flutter_app/$fileName',
      fileName: fileName,
      fileExtension: extension,
      fileSize: 1024 + (DateTime.now().second % 10000),
      application: _currentApplication ?? 'Visual Studio Code',
      operation: operations[DateTime.now().second % operations.length],
      metadata: {
        'file_type': 'text',
        'last_modified': DateTime.now().subtract(Duration(hours: DateTime.now().hour % 24)).toIso8601String(),
        'permissions': 'rw-r--r--',
      },
    );
    
    _fileEvents.add(fileEvent);
    if (_fileEvents.length > 50) _fileEvents.removeAt(0);
  }

  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    
    // Stop all timers
    _screenshotTimer?.cancel();
    _activityTimer?.cancel();
    _keystrokeTimer?.cancel();
    
    // Save session data
    await _saveSessionData();
    
    // Stop native monitoring
    await _stopNativeMonitoring();
    
    debugPrint('🛑 Comprehensive monitoring stopped');
    notifyListeners();
  }

  Future<void> _initializeNativeMonitoring() async {
    try {
      await _channel.invokeMethod('startMonitoring');
      
      // Set up method call handler for native events
      _channel.setMethodCallHandler(_handleNativeEvent);
    } catch (e) {
      debugPrint('Failed to initialize native monitoring: $e');
    }
  }

  Future<void> _stopNativeMonitoring() async {
    try {
      await _channel.invokeMethod('stopMonitoring');
    } catch (e) {
      debugPrint('Failed to stop native monitoring: $e');
    }
  }

  Future<dynamic> _handleNativeEvent(MethodCall call) async {
    final Map<String, dynamic> data = Map<String, dynamic>.from(call.arguments);
    
    switch (call.method) {
      case 'onKeystroke':
        _handleKeystroke(data);
        break;
      case 'onMouseEvent':
        _handleMouseEvent(data);
        break;
      case 'onApplicationChange':
        _handleApplicationChange(data);
        break;
      case 'onWindowChange':
        _handleWindowChange(data);
        break;
      case 'onFileAccess':
        _handleFileAccess(data);
        break;
      case 'onBrowserActivity':
        _handleBrowserActivity(data);
        break;
      case 'onScreenChange':
        _handleScreenChange(data);
        break;
      case 'onIdleStateChange':
        _handleIdleStateChange(data);
        break;
    }
  }

  void _startScreenshotCapture() {
    _screenshotTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_isMonitoring) return;
      
      try {
        await _captureScreenshot();
      } catch (e) {
        debugPrint('Screenshot capture failed: $e');
      }
    });
  }

  void _startActivityTracking() {
    _activityTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isMonitoring) return;
      
      try {
        await _trackCurrentActivity();
      } catch (e) {
        debugPrint('Activity tracking failed: $e');
      }
    });
  }

  void _startKeystrokeMonitoring() {
    _keystrokeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!_isMonitoring) return;
      
      try {
        await _checkKeystrokeActivity();
      } catch (e) {
        debugPrint('Keystroke monitoring failed: $e');
      }
    });
  }

  Future<void> _captureScreenshot() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final screenshotsDir = Directory('${directory.path}/screenshots');
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'screenshot_$timestamp.png';
      final filepath = '${screenshotsDir.path}/$filename';
      
      // Capture screenshot using native method
      final screenshotData = await _channel.invokeMethod('captureScreenshot');
      
      if (screenshotData != null) {
        final file = File(filepath);
        await file.writeAsBytes(screenshotData);
        
        final screenshotEvent = ScreenshotEvent(
          id: 'screenshot_$timestamp',
          timestamp: DateTime.now(),
          filePath: filepath,
          fileSize: screenshotData.length,
          currentApplication: _currentApplication,
          currentWindow: _currentWindow,
          currentUrl: _currentUrl,
          metadata: {
            'screen_resolution': await _getScreenResolution(),
            'active_monitors': await _getActiveMonitors(),
          },
        );
        
        _screenshots.add(screenshotEvent);
        
        // Keep only last 100 screenshots in memory
        if (_screenshots.length > 100) {
          _screenshots.removeAt(0);
        }
        
        debugPrint('📸 Screenshot captured: $filename');
      }
    } catch (e) {
      debugPrint('Screenshot capture error: $e');
    }
  }

  Future<void> _trackCurrentActivity() async {
    try {
      // Get current application info
      final appInfo = await _channel.invokeMethod('getCurrentApplication');
      if (appInfo != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(appInfo);
        _handleApplicationChange(data);
      }
      
      // Get current window info
      final windowInfo = await _channel.invokeMethod('getCurrentWindow');
      if (windowInfo != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(windowInfo);
        _handleWindowChange(data);
      }
      
      // Get browser activity if applicable
      if (_currentApplication?.toLowerCase().contains('browser') == true ||
          _currentApplication?.toLowerCase().contains('chrome') == true ||
          _currentApplication?.toLowerCase().contains('firefox') == true ||
          _currentApplication?.toLowerCase().contains('safari') == true) {
        final browserInfo = await _channel.invokeMethod('getBrowserActivity');
        if (browserInfo != null) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(browserInfo);
          _handleBrowserActivity(data);
        }
      }
    } catch (e) {
      debugPrint('Activity tracking error: $e');
    }
  }

  Future<void> _checkKeystrokeActivity() async {
    try {
      final keystrokeData = await _channel.invokeMethod('getRecentKeystrokes');
      if (keystrokeData != null) {
        final List<dynamic> keystrokes = keystrokeData;
        for (final keystroke in keystrokes) {
          _handleKeystroke(Map<String, dynamic>.from(keystroke));
        }
      }
    } catch (e) {
      debugPrint('Keystroke check error: $e');
    }
  }

  void _handleKeystroke(Map<String, dynamic> data) {
    final keystrokeEvent = KeystrokeEvent(
      id: 'keystroke_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      key: data['key'] ?? '',
      keyCode: data['keyCode'] ?? 0,
      modifiers: List<String>.from(data['modifiers'] ?? []),
      application: _currentApplication ?? 'Unknown',
      window: _currentWindow ?? 'Unknown',
      isSpecialKey: data['isSpecialKey'] ?? false,
      metadata: {
        'typing_speed': data['typingSpeed'],
        'key_duration': data['keyDuration'],
      },
    );
    
    _keystrokes.add(keystrokeEvent);
    
    // Keep only last 1000 keystrokes in memory
    if (_keystrokes.length > 1000) {
      _keystrokes.removeAt(0);
    }
    
    debugPrint('⌨️ Keystroke: ${keystrokeEvent.key} in ${keystrokeEvent.application}');
  }

  void _handleMouseEvent(Map<String, dynamic> data) {
    final mouseEvent = MouseEvent(
      id: 'mouse_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: data['eventType'] ?? 'unknown',
      x: data['x']?.toDouble() ?? 0.0,
      y: data['y']?.toDouble() ?? 0.0,
      button: data['button'] ?? 'left',
      clickCount: data['clickCount'] ?? 1,
      application: _currentApplication ?? 'Unknown',
      window: _currentWindow ?? 'Unknown',
      metadata: {
        'scroll_delta': data['scrollDelta'],
        'drag_distance': data['dragDistance'],
      },
    );
    
    _mouseEvents.add(mouseEvent);
    
    // Keep only last 500 mouse events in memory
    if (_mouseEvents.length > 500) {
      _mouseEvents.removeAt(0);
    }
    
    debugPrint('🖱️ Mouse ${mouseEvent.eventType} at (${mouseEvent.x}, ${mouseEvent.y})');
  }

  void _handleApplicationChange(Map<String, dynamic> data) {
    final previousApp = _currentApplication;
    _currentApplication = data['applicationName'];
    
    if (previousApp != null && previousApp != _currentApplication) {
      // Update time tracking for previous app
      _updateApplicationTimeTracking(previousApp);
    }
    
    final appEvent = ApplicationEvent(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      applicationName: _currentApplication ?? 'Unknown',
      applicationPath: data['applicationPath'] ?? '',
      processId: data['processId'] ?? 0,
      eventType: 'focus_gained',
      version: data['version'] ?? '',
      metadata: {
        'bundle_id': data['bundleId'],
        'memory_usage': data['memoryUsage'],
        'cpu_usage': data['cpuUsage'],
      },
    );
    
    _applicationEvents.add(appEvent);
    
    debugPrint('🖥️ Application changed to: ${_currentApplication}');
  }

  void _handleWindowChange(Map<String, dynamic> data) {
    _currentWindow = data['windowTitle'];
    
    final screenEvent = ScreenEvent(
      id: 'screen_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: 'window_change',
      windowTitle: _currentWindow ?? 'Unknown',
      applicationName: _currentApplication ?? 'Unknown',
      windowId: data['windowId']?.toString() ?? '',
      metadata: {
        'window_bounds': data['windowBounds'],
        'is_fullscreen': data['isFullscreen'],
        'is_minimized': data['isMinimized'],
      },
    );
    
    _screenEvents.add(screenEvent);
    
    debugPrint('🪟 Window changed to: ${_currentWindow}');
  }

  void _handleFileAccess(Map<String, dynamic> data) {
    final fileEvent = FileEvent(
      id: 'file_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: data['eventType'] ?? 'unknown',
      filePath: data['filePath'] ?? '',
      fileName: data['fileName'] ?? '',
      fileExtension: data['fileExtension'] ?? '',
      fileSize: data['fileSize'] ?? 0,
      application: _currentApplication ?? 'Unknown',
      operation: data['operation'] ?? 'unknown',
      metadata: {
        'file_type': data['fileType'],
        'last_modified': data['lastModified'],
        'permissions': data['permissions'],
      },
    );
    
    _fileEvents.add(fileEvent);
    
    debugPrint('📁 File ${fileEvent.operation}: ${fileEvent.fileName}');
  }

  void _handleBrowserActivity(Map<String, dynamic> data) {
    final previousUrl = _currentUrl;
    _currentUrl = data['url'];
    
    if (previousUrl != null && previousUrl != _currentUrl) {
      // Update time tracking for previous URL
      _updateWebsiteTimeTracking(previousUrl);
    }
    
    final browserEvent = BrowserEvent(
      id: 'browser_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: data['eventType'] ?? 'navigation',
      url: _currentUrl ?? '',
      title: data['title'] ?? '',
      domain: data['domain'] ?? '',
      browserName: data['browserName'] ?? _currentApplication ?? 'Unknown',
      tabId: data['tabId']?.toString() ?? '',
      metadata: {
        'referrer': data['referrer'],
        'load_time': data['loadTime'],
        'scroll_position': data['scrollPosition'],
        'form_interactions': data['formInteractions'],
      },
    );
    
    _browserEvents.add(browserEvent);
    
    debugPrint('🌐 Browser activity: ${browserEvent.url}');
  }

  void _handleScreenChange(Map<String, dynamic> data) {
    final screenEvent = ScreenEvent(
      id: 'screen_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: data['eventType'] ?? 'unknown',
      windowTitle: data['windowTitle'] ?? _currentWindow ?? 'Unknown',
      applicationName: _currentApplication ?? 'Unknown',
      windowId: data['windowId']?.toString() ?? '',
      metadata: {
        'screen_resolution': data['screenResolution'],
        'monitor_count': data['monitorCount'],
        'primary_monitor': data['primaryMonitor'],
      },
    );
    
    _screenEvents.add(screenEvent);
    
    debugPrint('🖥️ Screen event: ${screenEvent.eventType}');
  }

  void _handleIdleStateChange(Map<String, dynamic> data) {
    final isIdle = data['isIdle'] ?? false;
    final idleDuration = data['idleDuration'] ?? 0;
    
    final activityEvent = ActivityEvent(
      id: 'idle_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: 'session_${_sessionStart?.millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      eventType: isIdle ? 'idle_start' : 'idle_end',
      data: {
        'idle_duration': idleDuration,
        'idle_threshold': data['idleThreshold'],
      },
    );
    
    _activities.add(activityEvent);
    
    debugPrint('😴 Idle state changed: ${isIdle ? 'Started' : 'Ended'} (${idleDuration}s)');
  }

  void _updateApplicationTimeTracking(String appName) {
    final now = DateTime.now();
    final sessionDuration = _sessionStart != null ? now.difference(_sessionStart!) : Duration.zero;
    
    _applicationTimeTracking[appName] = (_applicationTimeTracking[appName] ?? Duration.zero) + 
        const Duration(seconds: 5); // Approximate time since last check
  }

  void _updateWebsiteTimeTracking(String url) {
    final domain = Uri.tryParse(url)?.host ?? url;
    _websiteTimeTracking[domain] = (_websiteTimeTracking[domain] ?? Duration.zero) + 
        const Duration(seconds: 5); // Approximate time since last check
  }

  Future<Map<String, dynamic>> _getScreenResolution() async {
    try {
      return await _channel.invokeMethod('getScreenResolution') ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> _getActiveMonitors() async {
    try {
      return await _channel.invokeMethod('getActiveMonitors') ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveSessionData() async {
    try {
      final sessionData = {
        'session_start': _sessionStart?.toIso8601String(),
        'session_end': DateTime.now().toIso8601String(),
        'activities': _activities.map((e) => e.toJson()).toList(),
        'keystrokes': _keystrokes.map((e) => e.toJson()).toList(),
        'mouse_events': _mouseEvents.map((e) => e.toJson()).toList(),
        'screen_events': _screenEvents.map((e) => e.toJson()).toList(),
        'application_events': _applicationEvents.map((e) => e.toJson()).toList(),
        'file_events': _fileEvents.map((e) => e.toJson()).toList(),
        'browser_events': _browserEvents.map((e) => e.toJson()).toList(),
        'screenshots': _screenshots.map((e) => e.toJson()).toList(),
        'application_time_tracking': _applicationTimeTracking.map((k, v) => MapEntry(k, v.inSeconds)),
        'website_time_tracking': _websiteTimeTracking.map((k, v) => MapEntry(k, v.inSeconds)),
      };
      
      final sessionJson = jsonEncode(sessionData);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _storage.write('session_$timestamp', sessionJson);
      
      debugPrint('💾 Session data saved');
    } catch (e) {
      debugPrint('Failed to save session data: $e');
    }
  }

  // Analytics methods
  Map<String, dynamic> getProductivityAnalytics() {
    final totalTime = _applicationTimeTracking.values.fold<Duration>(
      Duration.zero, (sum, duration) => sum + duration
    );
    
    // Classify applications as productive, neutral, or distracting
    final productiveApps = ['Visual Studio Code', 'Xcode', 'IntelliJ', 'Terminal', 'Figma'];
    final distractingApps = ['YouTube', 'Facebook', 'Twitter', 'Instagram', 'TikTok'];
    
    Duration productiveTime = Duration.zero;
    Duration distractingTime = Duration.zero;
    Duration neutralTime = Duration.zero;
    
    for (final entry in _applicationTimeTracking.entries) {
      final appName = entry.key.toLowerCase();
      final duration = entry.value;
      
      if (productiveApps.any((app) => appName.contains(app.toLowerCase()))) {
        productiveTime += duration;
      } else if (distractingApps.any((app) => appName.contains(app.toLowerCase()))) {
        distractingTime += duration;
      } else {
        neutralTime += duration;
      }
    }
    
    final productivityScore = totalTime.inSeconds > 0 
        ? (productiveTime.inSeconds / totalTime.inSeconds) 
        : 0.0;
    
    return {
      'total_time': totalTime.inSeconds,
      'productive_time': productiveTime.inSeconds,
      'distracting_time': distractingTime.inSeconds,
      'neutral_time': neutralTime.inSeconds,
      'productivity_score': productivityScore,
      'keystroke_count': _keystrokes.length,
      'mouse_click_count': _mouseEvents.where((e) => e.eventType == 'click').length,
      'application_switches': _applicationEvents.length,
      'file_operations': _fileEvents.length,
      'website_visits': _browserEvents.length,
      'screenshots_taken': _screenshots.length,
    };
  }

  List<Map<String, dynamic>> getDetailedActivityLog() {
    final allEvents = <Map<String, dynamic>>[];
    
    // Add all events with timestamps for chronological sorting
    allEvents.addAll(_activities.map((e) => {'type': 'activity', 'data': e.toJson()}));
    allEvents.addAll(_keystrokes.map((e) => {'type': 'keystroke', 'data': e.toJson()}));
    allEvents.addAll(_mouseEvents.map((e) => {'type': 'mouse', 'data': e.toJson()}));
    allEvents.addAll(_screenEvents.map((e) => {'type': 'screen', 'data': e.toJson()}));
    allEvents.addAll(_applicationEvents.map((e) => {'type': 'application', 'data': e.toJson()}));
    allEvents.addAll(_fileEvents.map((e) => {'type': 'file', 'data': e.toJson()}));
    allEvents.addAll(_browserEvents.map((e) => {'type': 'browser', 'data': e.toJson()}));
    allEvents.addAll(_screenshots.map((e) => {'type': 'screenshot', 'data': e.toJson()}));
    
    // Sort by timestamp
    allEvents.sort((a, b) {
      final aTime = DateTime.parse(a['data']['timestamp']);
      final bTime = DateTime.parse(b['data']['timestamp']);
      return aTime.compareTo(bTime);
    });
    
    return allEvents;
  }
}

// Event classes with toJson methods
class KeystrokeEvent {
  final String id;
  final DateTime timestamp;
  final String key;
  final int keyCode;
  final List<String> modifiers;
  final String application;
  final String window;
  final bool isSpecialKey;
  final Map<String, dynamic> metadata;

  KeystrokeEvent({
    required this.id,
    required this.timestamp,
    required this.key,
    required this.keyCode,
    required this.modifiers,
    required this.application,
    required this.window,
    required this.isSpecialKey,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'key': key,
    'keyCode': keyCode,
    'modifiers': modifiers,
    'application': application,
    'window': window,
    'isSpecialKey': isSpecialKey,
    'metadata': metadata,
  };
}

class MouseEvent {
  final String id;
  final DateTime timestamp;
  final String eventType;
  final double x;
  final double y;
  final String button;
  final int clickCount;
  final String application;
  final String window;
  final Map<String, dynamic> metadata;

  MouseEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.x,
    required this.y,
    required this.button,
    required this.clickCount,
    required this.application,
    required this.window,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'eventType': eventType,
    'x': x,
    'y': y,
    'button': button,
    'clickCount': clickCount,
    'application': application,
    'window': window,
    'metadata': metadata,
  };
}

class ScreenEvent {
  final String id;
  final DateTime timestamp;
  final String eventType;
  final String windowTitle;
  final String applicationName;
  final String windowId;
  final Map<String, dynamic> metadata;

  ScreenEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.windowTitle,
    required this.applicationName,
    required this.windowId,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'eventType': eventType,
    'windowTitle': windowTitle,
    'applicationName': applicationName,
    'windowId': windowId,
    'metadata': metadata,
  };
}

class ApplicationEvent {
  final String id;
  final DateTime timestamp;
  final String applicationName;
  final String applicationPath;
  final int processId;
  final String eventType;
  final String version;
  final Map<String, dynamic> metadata;

  ApplicationEvent({
    required this.id,
    required this.timestamp,
    required this.applicationName,
    required this.applicationPath,
    required this.processId,
    required this.eventType,
    required this.version,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'applicationName': applicationName,
    'applicationPath': applicationPath,
    'processId': processId,
    'eventType': eventType,
    'version': version,
    'metadata': metadata,
  };
}

class FileEvent {
  final String id;
  final DateTime timestamp;
  final String eventType;
  final String filePath;
  final String fileName;
  final String fileExtension;
  final int fileSize;
  final String application;
  final String operation;
  final Map<String, dynamic> metadata;

  FileEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.filePath,
    required this.fileName,
    required this.fileExtension,
    required this.fileSize,
    required this.application,
    required this.operation,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'eventType': eventType,
    'filePath': filePath,
    'fileName': fileName,
    'fileExtension': fileExtension,
    'fileSize': fileSize,
    'application': application,
    'operation': operation,
    'metadata': metadata,
  };
}

class BrowserEvent {
  final String id;
  final DateTime timestamp;
  final String eventType;
  final String url;
  final String title;
  final String domain;
  final String browserName;
  final String tabId;
  final Map<String, dynamic> metadata;

  BrowserEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.url,
    required this.title,
    required this.domain,
    required this.browserName,
    required this.tabId,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'eventType': eventType,
    'url': url,
    'title': title,
    'domain': domain,
    'browserName': browserName,
    'tabId': tabId,
    'metadata': metadata,
  };
}

class ScreenshotEvent {
  final String id;
  final DateTime timestamp;
  final String filePath;
  final int fileSize;
  final String? currentApplication;
  final String? currentWindow;
  final String? currentUrl;
  final Map<String, dynamic> metadata;

  ScreenshotEvent({
    required this.id,
    required this.timestamp,
    required this.filePath,
    required this.fileSize,
    this.currentApplication,
    this.currentWindow,
    this.currentUrl,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'filePath': filePath,
    'fileSize': fileSize,
    'currentApplication': currentApplication,
    'currentWindow': currentWindow,
    'currentUrl': currentUrl,
    'metadata': metadata,
  };
}