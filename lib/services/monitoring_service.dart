import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/activity_log.dart';
import '../models/monitoring_config.dart';

class MonitoringService {
  static const platform = MethodChannel('com.activitytracker/monitoring');
  
  Timer? _screenshotTimer;
  Timer? _activityTimer;
  final _uuid = const Uuid();
  
  // Callback for activity updates
  Function(ActivityLog)? onActivityTracked;
  Function(String, int)? onInputActivity;

  Future<void> startMonitoring(MonitoringConfig config) async {
    try {
      print('🚀 Starting monitoring with config: ${config.toJson()}');
      await platform.invokeMethod('startMonitoring', config.toJson());
      print('✅ Native monitoring started');
      
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
      await platform.invokeMethod('stopMonitoring');
      _screenshotTimer?.cancel();
      _activityTimer?.cancel();
    } catch (e) {
      print('Error stopping monitoring: $e');
    }
  }

  Future<String?> captureScreenshot() async {
    try {
      print('📸 Attempting to capture screenshot...');
      final String? path = await platform.invokeMethod('captureScreenshot');
      if (path != null) {
        print('✅ Screenshot captured: $path');
      } else {
        print('⚠️ Screenshot returned null');
      }
      return path;
    } catch (e) {
      print('❌ Error capturing screenshot: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getActiveWindow() async {
    try {
      print('🪟 Getting active window...');
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getActiveWindow');
      final windowInfo = {
        'title': result['title'] ?? 'Unknown',
        'application': result['application'] ?? 'Unknown',
      };
      print('✅ Active window: ${windowInfo['application']} - ${windowInfo['title']}');
      return windowInfo;
    } catch (e) {
      print('❌ Error getting active window: $e');
      return {'title': 'Unknown', 'application': 'Unknown'};
    }
  }

  Future<Map<String, int>> getInputActivity() async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getInputActivity');
      return {
        'keystrokes': result['keystrokes'] ?? 0,
        'mouseClicks': result['mouseClicks'] ?? 0,
      };
    } catch (e) {
      print('Error getting input activity: $e');
      return {'keystrokes': 0, 'mouseClicks': 0};
    }
  }

  Future<bool> isSystemIdle(int thresholdSeconds) async {
    try {
      final bool idle = await platform.invokeMethod('isSystemIdle', {'threshold': thresholdSeconds});
      return idle;
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
}
