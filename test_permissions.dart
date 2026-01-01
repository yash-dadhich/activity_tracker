import 'package:flutter/services.dart';
import 'dart:io';

void main() async {
  if (!Platform.isMacOS) {
    print('This test is for macOS only');
    return;
  }

  const platform = MethodChannel('com.activitytracker/permissions');
  
  print('🧪 Testing Permission Service Method Channel...\n');
  
  // Test 1: Check Screen Recording Permission
  try {
    print('1️⃣ Testing checkScreenRecording...');
    final bool hasScreenRecording = await platform.invokeMethod('checkScreenRecording');
    print('   Result: $hasScreenRecording');
    print('   ✅ Method works!\n');
  } catch (e) {
    print('   ❌ Error: $e\n');
  }
  
  // Test 2: Check Accessibility Permission
  try {
    print('2️⃣ Testing checkAccessibility...');
    final bool hasAccessibility = await platform.invokeMethod('checkAccessibility');
    print('   Result: $hasAccessibility');
    print('   ✅ Method works!\n');
  } catch (e) {
    print('   ❌ Error: $e\n');
  }
  
  // Test 3: Open System Preferences
  try {
    print('3️⃣ Testing openSystemPreferences...');
    await platform.invokeMethod('openSystemPreferences');
    print('   ✅ Method called successfully!');
    print('   Check if System Preferences opened.\n');
  } catch (e) {
    print('   ❌ Error: $e\n');
  }
  
  print('🎉 Test complete!');
  print('\nIf you see errors above, the plugins are not registered correctly.');
  print('Run: ./fix_macos_plugins.sh');
}
