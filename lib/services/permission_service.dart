import 'dart:io';
import 'package:flutter/services.dart';

class PermissionService {
  static const platform = MethodChannel('com.activitytracker/permissions');

  Future<bool> checkScreenRecordingPermission() async {
    if (!Platform.isMacOS) return true;
    
    try {
      final bool hasPermission = await platform.invokeMethod('checkScreenRecording');
      return hasPermission;
    } catch (e) {
      print('Error checking screen recording permission: $e');
      return false;
    }
  }

  Future<bool> checkAccessibilityPermission() async {
    if (!Platform.isMacOS) return true;
    
    try {
      final bool hasPermission = await platform.invokeMethod('checkAccessibility');
      return hasPermission;
    } catch (e) {
      print('Error checking accessibility permission: $e');
      return false;
    }
  }

  Future<void> requestScreenRecordingPermission() async {
    if (!Platform.isMacOS) return;
    
    try {
      await platform.invokeMethod('requestScreenRecording');
    } catch (e) {
      print('Error requesting screen recording permission: $e');
    }
  }

  Future<void> requestAccessibilityPermission() async {
    if (!Platform.isMacOS) return;
    
    try {
      await platform.invokeMethod('requestAccessibility');
    } catch (e) {
      print('Error requesting accessibility permission: $e');
    }
  }

  Future<void> openSystemPreferences() async {
    if (!Platform.isMacOS) return;
    
    try {
      print('🔧 Attempting to open System Preferences...');
      await platform.invokeMethod('openSystemPreferences');
      print('✅ System Preferences call completed');
    } catch (e) {
      print('❌ Error opening system preferences: $e');
      rethrow;
    }
  }

  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'screenRecording': await checkScreenRecordingPermission(),
      'accessibility': await checkAccessibilityPermission(),
    };
  }
}
