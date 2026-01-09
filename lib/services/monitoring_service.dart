import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/activity_log.dart';
import '../models/monitoring_config.dart';

class MonitoringService {
  static const platform = MethodChannel('com.activitytracker/monitoring');
  
  Timer? _screenshotTimer;
  final _uuid = const Uuid();
  
  // Callback for screenshot capture
  Function(String)? onScreenshotCaptured;
  
  // Screenshots folder path
  String? _screenshotsPath;

  Future<void> startMonitoring(MonitoringConfig config) async {
    try {
      print('🚀 Starting screenshot monitoring');
      
      // Create screenshots directory
      await _createScreenshotsDirectory();
      
      // Start periodic screenshot capture
      if (config.screenshotEnabled) {
        print('📸 Screenshot capture enabled, interval: ${config.screenshotInterval}s');
        _screenshotTimer = Timer.periodic(
          Duration(seconds: config.screenshotInterval),
          (_) async {
            print('⏰ Screenshot timer triggered');
            final path = await captureScreenshot();
            if (path != null) {
              onScreenshotCaptured?.call(path);
            }
          },
        );
      } else {
        print('⚠️ Screenshot capture is disabled');
      }
    } catch (e) {
      print('❌ Error starting monitoring: $e');
    }
  }

  Future<void> stopMonitoring() async {
    try {
      _screenshotTimer?.cancel();
      print('✅ Screenshot monitoring stopped');
    } catch (e) {
      print('Error stopping monitoring: $e');
    }
  }

  Future<void> _createScreenshotsDirectory() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      _screenshotsPath = path.join(documentsDir.path, 'screenshots', 'activity_tracker');
      
      final directory = Directory(_screenshotsPath!);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('📁 Created screenshots directory: $_screenshotsPath');
      } else {
        print('📁 Screenshots directory exists: $_screenshotsPath');
      }
    } catch (e) {
      print('❌ Error creating screenshots directory: $e');
    }
  }

  Future<String?> captureScreenshot() async {
    try {
      print('📸 Attempting to capture screenshot...');
      
      if (_screenshotsPath == null) {
        await _createScreenshotsDirectory();
      }
      
      final timestamp = DateTime.now();
      final filename = 'screenshot_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}_${timestamp.second.toString().padLeft(2, '0')}.png';
      final fullPath = path.join(_screenshotsPath!, filename);
      
      if (Platform.isMacOS) {
        // Use native method for macOS
        final String? nativePath = await platform.invokeMethod('captureScreenshot');
        if (nativePath != null) {
          // Move the file to our desired location
          final sourceFile = File(nativePath);
          if (await sourceFile.exists()) {
            await sourceFile.copy(fullPath);
            await sourceFile.delete();
            print('✅ Screenshot captured and moved to: $fullPath');
            return fullPath;
          }
        }
      } else {
        // Use native platform method for screenshot
        try {
          final result = await platform.invokeMethod('captureScreenshot');
          if (result != null) {
            print('✅ Screenshot captured: $fullPath');
            return fullPath;
          }
        } catch (e) {
          print('⚠️ Native screenshot failed: $e');
        }
      }
      
      print('⚠️ Screenshot capture failed');
      return null;
    } catch (e) {
      print('❌ Error capturing screenshot: $e');
      return null;
    }
  }

  String? get screenshotsDirectory => _screenshotsPath;
}
