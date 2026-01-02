import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:window_manager/window_manager.dart';
import '../models/activity_log.dart';
import '../models/monitoring_config.dart';
import 'windows_activity_tracker.dart';

class MonitoringService {
  static const platform = MethodChannel('com.activitytracker/monitoring');
  
  Timer? _screenshotTimer;
  Timer? _activityTimer;
  final _uuid = const Uuid();
  final _screenCapturer = ScreenCapturer.instance;
  
  // Windows-specific tracker
  WindowsActivityTracker? _windowsTracker;
  
  // Callback for activity updates
  Function(ActivityLog)? onActivityTracked;
  Function(String, int)? onInputActivity;
  
  // Track input activity manually (fallback)
  int _keystrokeCount = 0;
  int _mouseClickCount = 0;
  DateTime _lastActivityTime = DateTime.now();

  Future<void> startMonitoring(MonitoringConfig config) async {
    try {
      print('🚀 Starting monitoring with config: ${config.toJson()}');
      
      // For macOS, use native methods
      if (Platform.isMacOS) {
        await platform.invokeMethod('startMonitoring', config.toJson());
        print('✅ Native monitoring started (macOS)');
      } else if (Platform.isWindows) {
        // Start Windows activity tracker
        _windowsTracker = WindowsActivityTracker();
        _windowsTracker!.startTracking();
        print('✅ Windows activity tracker started');
      } else {
        print('✅ Using Flutter plugins for monitoring (Linux)');
      }
      
      // Start periodic screenshot capture
      if (config.screenshotEnabled) {
        print('📸 Screenshot capture enabled, interval: ${config.screenshotInterval}s');
        _screenshotTimer = Timer.periodic(
          Duration(seconds: config.screenshotInterval),
          (_) {
            print('⏰ Screenshot timer triggered');
            captureScreenshot();
          },
        );
      } else {
        print('⚠️ Screenshot capture is disabled');
      }

      // Start activity tracking
      print('📊 Starting activity tracking (every 5 seconds)');
      _activityTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) async {
          print('⏰ Activity tracking timer triggered');
          final log = await trackActivity();
          onActivityTracked?.call(log);
        },
      );
    } catch (e) {
      print('❌ Error starting monitoring: $e');
    }
  }

  Future<void> stopMonitoring() async {
    try {
      if (Platform.isMacOS) {
        await platform.invokeMethod('stopMonitoring');
      } else if (Platform.isWindows) {
        _windowsTracker?.stopTracking();
        _windowsTracker = null;
      }
      _screenshotTimer?.cancel();
      _activityTimer?.cancel();
    } catch (e) {
      print('Error stopping monitoring: $e');
    }
  }

  Future<String?> captureScreenshot() async {
    try {
      print('📸 Attempting to capture screenshot...');
      
      if (Platform.isMacOS) {
        // Use native method for macOS
        final String? path = await platform.invokeMethod('captureScreenshot');
        if (path != null) {
          print('✅ Screenshot captured (macOS): $path');
        }
        return path;
      } else {
        // Use screen_capturer plugin for Windows/Linux
        final capturedData = await _screenCapturer.capture(
          mode: CaptureMode.screen,
          imagePath: 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
          silent: true,
        );
        
        if (capturedData != null && capturedData.imagePath != null) {
          print('✅ Screenshot captured: ${capturedData.imagePath}');
          return capturedData.imagePath;
        } else {
          print('⚠️ Screenshot returned null');
          return null;
        }
      }
    } catch (e) {
      print('❌ Error capturing screenshot: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getActiveWindow() async {
    try {
      print('🪟 Getting active window...');
      
      if (Platform.isMacOS) {
        // Use native method for macOS
        final Map<dynamic, dynamic> result = await platform.invokeMethod('getActiveWindow');
        final windowInfo = {
          'title': result['title'] ?? 'Unknown',
          'application': result['application'] ?? 'Unknown',
        };
        print('✅ Active window (macOS): ${windowInfo['application']} - ${windowInfo['title']}');
        return windowInfo;
      } else if (Platform.isWindows && _windowsTracker != null) {
        // Use Windows tracker
        final title = _windowsTracker!.getActiveWindowTitle();
        final app = _windowsTracker!.getActiveProcessName();
        final windowInfo = {
          'title': title,
          'application': app,
        };
        print('✅ Active window (Windows): $app - $title');
        return windowInfo;
      } else {
        // Fallback
        try {
          final title = await windowManager.getTitle();
          final windowInfo = {
            'title': title.isNotEmpty ? title : 'Activity Tracker',
            'application': 'Activity Tracker',
          };
          print('✅ Active window (fallback): ${windowInfo['application']}');
          return windowInfo;
        } catch (e) {
          return {
            'title': 'Unknown',
            'application': 'Unknown',
          };
        }
      }
    } catch (e) {
      print('❌ Error getting active window: $e');
      return {'title': 'Unknown', 'application': 'Unknown'};
    }
  }

  Future<Map<String, int>> getInputActivity() async {
    try {
      if (Platform.isMacOS) {
        // Use native method for macOS
        final Map<dynamic, dynamic> result = await platform.invokeMethod('getInputActivity');
        return {
          'keystrokes': result['keystrokes'] ?? 0,
          'mouseClicks': result['mouseClicks'] ?? 0,
        };
      } else if (Platform.isWindows && _windowsTracker != null) {
        // Use Windows tracker
        return _windowsTracker!.getAndResetCounts();
      } else {
        // Fallback
        final result = {
          'keystrokes': _keystrokeCount,
          'mouseClicks': _mouseClickCount,
        };
        _keystrokeCount = 0;
        _mouseClickCount = 0;
        return result;
      }
    } catch (e) {
      print('Error getting input activity: $e');
      return {'keystrokes': 0, 'mouseClicks': 0};
    }
  }

  Future<bool> isSystemIdle(int thresholdSeconds) async {
    try {
      if (Platform.isMacOS) {
        // Use native method for macOS
        final bool idle = await platform.invokeMethod('isSystemIdle', {'threshold': thresholdSeconds});
        return idle;
      } else if (Platform.isWindows && _windowsTracker != null) {
        // Use Windows tracker
        return _windowsTracker!.isIdle(thresholdSeconds);
      } else {
        // Fallback
        final idleTime = DateTime.now().difference(_lastActivityTime).inSeconds;
        return idleTime >= thresholdSeconds;
      }
    } catch (e) {
      print('Error checking idle status: $e');
      return false;
    }
  }

  Future<ActivityLog> trackActivity() async {
    print('📊 Tracking activity...');
    final windowInfo = await getActiveWindow();
    final inputActivity = await getInputActivity();
    final isIdle = await isSystemIdle(300);

    final log = ActivityLog(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      activeWindow: windowInfo['title'],
      applicationName: windowInfo['application'],
      keystrokes: inputActivity['keystrokes']!,
      mouseClicks: inputActivity['mouseClicks']!,
      isIdle: isIdle,
    );
    
    print('✅ Activity log created: ${log.applicationName} (keystrokes: ${log.keystrokes}, clicks: ${log.mouseClicks}, idle: ${log.isIdle})');
    return log;
  }
  
  // Method to manually track activity (can be called from UI)
  void recordKeystroke() {
    _keystrokeCount++;
    _lastActivityTime = DateTime.now();
  }
  
  void recordMouseClick() {
    _mouseClickCount++;
    _lastActivityTime = DateTime.now();
  }
}
