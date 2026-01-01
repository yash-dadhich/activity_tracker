# Activity Tracker - Setup Guide

## Quick Start

### Step 1: Install Dependencies

```bash
flutter pub get
```

### Step 2: Platform-Specific Setup

#### Windows Setup

1. **Build Requirements:**
   - Visual Studio 2019 or later with C++ desktop development tools
   - Windows 10 SDK

2. **Register the Plugin:**
   
   Edit `windows/runner/flutter_window.cpp` and add at the top:
   ```cpp
   #include "monitoring_plugin.h"
   ```
   
   Then in the `RegisterPlugins` function, add:
   ```cpp
   MonitoringPlugin::RegisterWithRegistrar(
       flutter_controller_->engine()->GetRegistrar("MonitoringPlugin"));
   ```

3. **Build and Run:**
   ```bash
   flutter run -d windows
   ```

#### macOS Setup

1. **Register the Plugins:**
   
   Edit `macos/Runner/AppDelegate.swift` and add:
   ```swift
   import FlutterMacOS
   
   @NSApplicationMain
   class AppDelegate: FlutterAppDelegate {
     override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
       return true
     }
     
     override func applicationDidFinishLaunching(_ notification: Notification) {
       let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
       MonitoringPlugin.register(with: controller.registrar(forPlugin: "MonitoringPlugin"))
       PermissionPlugin.register(with: controller.registrar(forPlugin: "PermissionPlugin"))
     }
   }
   ```

2. **Update Xcode Project:**
   - Open `macos/Runner.xcworkspace` in Xcode
   - Add `MonitoringPlugin.swift` and `PermissionPlugin.swift` to the project
   - Verify entitlements files are included

3. **Disable App Sandbox:**
   - In Xcode, select Runner target
   - Go to "Signing & Capabilities"
   - Remove "App Sandbox" capability (or set to false in entitlements)

4. **Build and Run:**
   ```bash
   flutter run -d macos
   ```

### Step 3: Configure Permissions (macOS Only)

On first launch on macOS:

1. The app will request Screen Recording permission
2. Go to System Preferences → Security & Privacy → Privacy
3. Select "Screen Recording" from the left sidebar
4. Check the box next to "Activity Tracker"
5. Select "Accessibility" from the left sidebar
6. Check the box next to "Activity Tracker"
7. Restart the application

## Development Workflow

### Running in Debug Mode

```bash
# Windows
flutter run -d windows --debug

# macOS
flutter run -d macos --debug
```

### Building for Production

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

### Testing

```bash
flutter test
```

## Project Structure

```
poc_activity_tracker/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   ├── activity_log.dart        # Activity data model
│   │   └── monitoring_config.dart   # Configuration model
│   ├── providers/
│   │   └── activity_provider.dart   # State management
│   ├── screens/
│   │   ├── home_screen.dart         # Main UI
│   │   └── settings_screen.dart     # Settings UI
│   └── services/
│       ├── monitoring_service.dart  # Monitoring logic
│       └── permission_service.dart  # Permission handling
├── windows/
│   └── runner/
│       ├── monitoring_plugin.cpp    # Windows native code
│       └── monitoring_plugin.h
├── macos/
│   └── Runner/
│       ├── MonitoringPlugin.swift   # macOS monitoring
│       ├── PermissionPlugin.swift   # macOS permissions
│       ├── Info.plist               # App metadata
│       ├── Release.entitlements     # Release permissions
│       └── DebugProfile.entitlements # Debug permissions
└── pubspec.yaml                     # Dependencies
```

## Key Features Implementation

### 1. Screenshot Capture

**Windows:** Uses GDI+ `BitBlt` to capture screen
**macOS:** Uses `CGDisplayCreateImage` API

Configurable interval in Settings (default: 5 minutes)

### 2. Active Window Tracking

**Windows:** `GetForegroundWindow()` + `GetWindowText()`
**macOS:** `NSWorkspace.shared.frontmostApplication`

Updates every 5 seconds

### 3. Keyboard & Mouse Tracking

**Windows:** Windows Hooks (`SetWindowsHookEx`)
**macOS:** Event Tap (`CGEvent.tapCreate`)

Counts keystrokes and clicks, resets after each read

### 4. Idle Detection

**Windows:** `GetLastInputInfo()`
**macOS:** `CGEventSource.secondsSinceLastEventType`

Configurable threshold (default: 5 minutes)

## Troubleshooting

### Windows Issues

**Problem:** Build fails with "cannot find gdiplus.lib"
**Solution:** Install Windows SDK and Visual Studio C++ tools

**Problem:** Hooks not working
**Solution:** Run as Administrator or check antivirus settings

### macOS Issues

**Problem:** "App is damaged and can't be opened"
**Solution:** Disable Gatekeeper temporarily:
```bash
sudo spctl --master-disable
```

**Problem:** Permissions not being requested
**Solution:** Check Info.plist has usage descriptions

**Problem:** Event tap not working
**Solution:** Ensure Accessibility permission is granted

### Common Issues

**Problem:** Screenshots not saving
**Solution:** Check file permissions and disk space

**Problem:** Data not uploading
**Solution:** Configure server URL and API key in Settings

## Next Steps

1. **Backend Integration:**
   - Implement server API for receiving activity data
   - Add authentication and encryption
   - Create admin dashboard

2. **Enhanced Features:**
   - Add application usage reports
   - Implement productivity scoring
   - Add screenshot blur for sensitive content
   - Create time-based rules

3. **Deployment:**
   - Code signing for Windows
   - Notarization for macOS
   - Create installers (MSI for Windows, PKG for macOS)
   - Setup auto-update mechanism

## Security Considerations

1. **Data Encryption:**
   - Encrypt screenshots before upload
   - Use HTTPS for all API communication
   - Implement certificate pinning

2. **Access Control:**
   - Require admin password for settings changes
   - Implement tamper detection
   - Log all configuration changes

3. **Privacy:**
   - Allow users to pause monitoring
   - Implement screenshot redaction for sensitive apps
   - Provide data export functionality

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review platform-specific documentation
3. Contact your development team

## License

Enterprise Use Only - See LICENSE file for details
