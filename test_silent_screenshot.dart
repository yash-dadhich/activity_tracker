import 'dart:io';
import 'lib/services/silent_screenshot_service.dart';

/// Test script for silent screenshot functionality
/// Run with: dart run test_silent_screenshot.dart
void main() async {
  print('🧪 Testing Silent Screenshot Service\n');
  
  if (!Platform.isWindows) {
    print('❌ This test only works on Windows');
    print('   Current platform: ${Platform.operatingSystem}');
    exit(1);
  }
  
  print('✅ Running on Windows');
  print('📸 Attempting to capture screenshot...\n');
  
  final service = SilentScreenshotService();
  
  try {
    final startTime = DateTime.now();
    final filePath = await service.captureScreenshot();
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    if (filePath != null) {
      print('✅ SUCCESS!');
      print('   File saved: $filePath');
      print('   Capture time: ${duration.inMilliseconds}ms');
      
      // Check if file exists
      final file = File(filePath);
      if (await file.exists()) {
        final size = await file.length();
        print('   File size: ${(size / 1024).toStringAsFixed(2)} KB');
        print('\n📁 You can view the screenshot at:');
        print('   $filePath');
      } else {
        print('⚠️  File was reported as saved but does not exist');
      }
    } else {
      print('❌ FAILED');
      print('   Screenshot capture returned null');
      print('   Check console output above for error messages');
    }
  } catch (e, stackTrace) {
    print('❌ ERROR');
    print('   Exception: $e');
    print('   Stack trace:');
    print('   $stackTrace');
  }
  
  print('\n🏁 Test complete');
}
