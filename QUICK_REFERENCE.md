# Activity Tracker - Quick Reference

## 🚀 Quick Start Commands

```bash
# Install dependencies
flutter pub get

# Run on Windows
flutter run -d windows

# Run on macOS
flutter run -d macos

# Build for production
flutter build windows --release
flutter build macos --release
```

## 📁 Project Structure

```
lib/
├── main.dart                      # Entry point
├── models/                        # Data models
│   ├── activity_log.dart
│   └── monitoring_config.dart
├── providers/                     # State management
│   └── activity_provider.dart
├── screens/                       # UI
│   ├── home_screen.dart
│   └── settings_screen.dart
└── services/                      # Business logic
    ├── monitoring_service.dart
    └── permission_service.dart

windows/runner/                    # Windows native (C++)
├── monitoring_plugin.cpp
└── monitoring_plugin.h

macos/Runner/                      # macOS native (Swift)
├── MonitoringPlugin.swift
└── PermissionPlugin.swift
```

## 🔧 Key Features

| Feature | Windows | macOS | Implementation |
|---------|---------|-------|----------------|
| Screenshots | ✅ | ✅ | GDI+ / CGDisplayCreateImage |
| Window Tracking | ✅ | ✅ | Win32 API / NSWorkspace |
| Keyboard Tracking | ✅ | ✅ | Hooks / Event Tap |
| Mouse Tracking | ✅ | ✅ | Hooks / Event Tap |
| Idle Detection | ✅ | ✅ | GetLastInputInfo / CGEventSource |

## 🔐 macOS Permissions Required

1. **Screen Recording**
   - System Preferences → Security & Privacy → Privacy → Screen Recording
   - Check "Activity Tracker"

2. **Accessibility**
   - System Preferences → Security & Privacy → Privacy → Accessibility
   - Check "Activity Tracker"

## 📝 Configuration

### Default Settings
- Screenshot Interval: 300 seconds (5 minutes)
- Idle Threshold: 300 seconds (5 minutes)
- All tracking features: Enabled

### Modify in Settings Screen
- Toggle features on/off
- Adjust intervals
- Configure server URL and API key

## 🛠️ Platform Channels

### Monitoring Channel
```dart
MethodChannel('com.activitytracker/monitoring')
```

**Methods:**
- `startMonitoring(config)` - Start monitoring
- `stopMonitoring()` - Stop monitoring
- `captureScreenshot()` - Take screenshot
- `getActiveWindow()` - Get active window info
- `getInputActivity()` - Get keystroke/click counts
- `isSystemIdle(threshold)` - Check if system is idle

### Permission Channel (macOS only)
```dart
MethodChannel('com.activitytracker/permissions')
```

**Methods:**
- `checkScreenRecording()` - Check permission status
- `checkAccessibility()` - Check permission status
- `requestScreenRecording()` - Request permission
- `requestAccessibility()` - Request permission
- `openSystemPreferences()` - Open settings

## 🐛 Common Issues

### Windows

**Build fails:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build windows
```

**Screenshots not working:**
- Run as Administrator
- Check antivirus settings

### macOS

**Permissions not working:**
```bash
# Reset permissions
tccutil reset ScreenCapture
tccutil reset Accessibility
```

**Build fails:**
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean
flutter build macos
```

## 📊 State Management

Using Provider pattern:

```dart
// Access provider
final provider = context.read<ActivityProvider>();

// Watch for changes
Consumer<ActivityProvider>(
  builder: (context, provider, child) {
    return Text('Status: ${provider.isMonitoring}');
  },
)
```

## 🔄 Data Flow

```
User Action
    ↓
Flutter UI (Dart)
    ↓
Method Channel
    ↓
Native Plugin (C++/Swift)
    ↓
OS APIs (Win32/Cocoa)
    ↓
Return Data
    ↓
Update Provider
    ↓
UI Updates
```

## 📦 Dependencies

**Core:**
- `provider` - State management
- `window_manager` - Window control
- `tray_manager` - System tray

**Platform:**
- `ffi` - Native interop
- `win32` - Windows APIs
- `screen_capturer` - Screenshots

**Storage:**
- `shared_preferences` - Settings
- `path_provider` - File paths
- `sqflite` - Local database

**Network:**
- `http` - API calls
- `dio` - Advanced HTTP
- `encrypt` - Data encryption

## 🎯 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 📱 Build Outputs

### Windows
```
build/windows/runner/Release/
├── poc_activity_tracker.exe
├── flutter_windows.dll
└── data/
```

### macOS
```
build/macos/Build/Products/Release/
└── poc_activity_tracker.app
```

## 🔒 Security Notes

1. **Never commit:**
   - API keys
   - Certificates
   - Private keys
   - User data

2. **Always encrypt:**
   - Screenshots before upload
   - API communication (HTTPS)
   - Stored credentials

3. **Implement:**
   - Certificate pinning
   - Token rotation
   - Audit logging

## 📚 Documentation

- [Setup Guide](SETUP_GUIDE.md) - Development setup
- [Deployment Guide](DEPLOYMENT.md) - Production deployment
- [README](README.md) - Project overview

## 🆘 Support

**Development Issues:**
- Check SETUP_GUIDE.md
- Review platform-specific docs
- Check Flutter documentation

**Deployment Issues:**
- Check DEPLOYMENT.md
- Review MDM documentation
- Contact IT support

## 💡 Tips

1. **Development:**
   - Use hot reload for UI changes
   - Test on both platforms regularly
   - Keep native code minimal

2. **Debugging:**
   - Check platform channel logs
   - Use Flutter DevTools
   - Monitor native logs (Console.app on macOS)

3. **Performance:**
   - Optimize screenshot intervals
   - Batch API uploads
   - Use background isolates for heavy work

## 🔄 Version History

- **v1.0.0** - Initial release
  - Windows and macOS support
  - Core monitoring features
  - Basic UI

## 📞 Quick Links

- Flutter Docs: https://docs.flutter.dev
- Win32 API: https://learn.microsoft.com/en-us/windows/win32/
- macOS APIs: https://developer.apple.com/documentation/
- Provider Package: https://pub.dev/packages/provider
