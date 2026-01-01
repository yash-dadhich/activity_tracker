# macOS Troubleshooting Guide

## "Open System Preferences" Button Not Working

### Quick Fix Steps:

1. **Stop the app** (if running)

2. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d macos
   ```

3. **Check the console output** for any error messages when you click the button

### If Still Not Working:

#### Step 1: Verify Plugins Are Registered

Check that `macos/Runner/AppDelegate.swift` contains:

```swift
override func applicationDidFinishLaunching(_ notification: Notification) {
  let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
  
  // Register custom plugins
  MonitoringPlugin.register(with: controller.registrar(forPlugin: "MonitoringPlugin"))
  PermissionPlugin.register(with: controller.registrar(forPlugin: "PermissionPlugin"))
}
```

#### Step 2: Add Swift Files to Xcode Project

The Swift plugin files need to be part of the Xcode project:

1. Open the project in Xcode:
   ```bash
   open macos/Runner.xcworkspace
   ```

2. In Xcode's left sidebar (Project Navigator), right-click on "Runner" folder

3. Select "Add Files to Runner..."

4. Navigate to `macos/Runner/` and select:
   - `MonitoringPlugin.swift`
   - `PermissionPlugin.swift`

5. **Important:** Make sure:
   - ✅ "Runner" target is checked
   - ❌ "Copy items if needed" is UNCHECKED

6. Click "Add"

7. Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)

8. Close Xcode and run from terminal:
   ```bash
   flutter run -d macos
   ```

#### Step 3: Check Console for Errors

When you click "Open System Preferences", check the terminal/console for:
- Error messages
- "Opened ... successfully" messages
- Any Swift/Objective-C errors

#### Step 4: Manual Workaround

If the button still doesn't work, users can manually open System Preferences:

**macOS 13+ (Ventura/Sonoma/Sequoia):**
1. Open "System Settings" from the Apple menu
2. Go to "Privacy & Security"
3. Scroll down to "Screen Recording" and add the app
4. Scroll down to "Accessibility" and add the app

**macOS 12 and earlier (Monterey and below):**
1. Open "System Preferences" from the Apple menu
2. Go to "Security & Privacy"
3. Click the "Privacy" tab
4. Select "Screen Recording" from the left sidebar
5. Click the lock icon and enter your password
6. Check the box next to "Activity Tracker"
7. Select "Accessibility" from the left sidebar
8. Check the box next to "Activity Tracker"

## Common Issues

### Issue: "Method channel not found" error

**Solution:** The plugins aren't registered. Follow Step 1 above.

### Issue: Swift files not compiling

**Solution:** 
1. Make sure Swift files are added to Xcode project (Step 2)
2. Check for syntax errors in the Swift files
3. Verify Xcode version is 13+

### Issue: App crashes when clicking button

**Solution:**
1. Check console for crash logs
2. Verify AppDelegate.swift is correct
3. Make sure both plugins are registered

### Issue: Button does nothing (no error, no action)

**Solution:**
1. Add debug print statements:
   ```dart
   // In home_screen.dart
   onPressed: () async {
     print('Button clicked');
     final permissionService = context.read<PermissionService>();
     print('Calling openSystemPreferences');
     await permissionService.openSystemPreferences();
     print('Call completed');
   },
   ```

2. Run and check console output

3. If you see "Button clicked" but nothing else, the method channel isn't working

## Testing the Fix

After applying fixes, test:

1. ✅ Click "Open System Preferences" button
2. ✅ System Preferences/Settings should open
3. ✅ Should navigate to Privacy & Security section (or close to it)
4. ✅ No errors in console

## Alternative: Use Terminal Commands

You can also open System Preferences from terminal:

```bash
# macOS 13+
open "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension"

# macOS 12 and earlier
open "x-apple.systempreferences:com.apple.preference.security?Privacy"

# Fallback
open "/System/Applications/System Preferences.app"
```

## Debug Mode

Add this to `PermissionPlugin.swift` to see what's happening:

```swift
func openSystemPreferences() {
    print("🔧 openSystemPreferences called")
    
    // ... existing code ...
    
    print("✅ Attempted to open System Preferences")
}
```

Then watch the console when clicking the button.

## Still Not Working?

If none of the above works:

1. **Check macOS version:**
   ```bash
   sw_vers
   ```

2. **Check if app has any permissions:**
   ```bash
   tccutil reset All com.yourcompany.activitytracker
   ```

3. **Try running with verbose logging:**
   ```bash
   flutter run -d macos -v
   ```

4. **Check Xcode build logs:**
   - Open Xcode
   - Product → Build
   - Check for any Swift compilation errors

## Contact Support

If you've tried everything and it still doesn't work, provide:
- macOS version
- Flutter version (`flutter --version`)
- Console output when clicking button
- Any error messages from Xcode
