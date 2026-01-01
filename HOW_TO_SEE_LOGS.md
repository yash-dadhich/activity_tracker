# How to See Logs and Test the App

## Step 1: Stop Any Running Instances

If the app is already running, stop it first:
```bash
# Find and kill any running Flutter processes
pkill -f flutter
pkill -f "poc_activity_tracker"
```

## Step 2: Run with Verbose Logging

```bash
flutter run -d macos
```

Keep this terminal window open and visible so you can see the logs.

## Step 3: Test the Features

### Test 1: Check Permissions
1. When the app launches, you should see:
   ```
   🔧 Attempting to open System Preferences...
   ```
2. Click "Open System Preferences" button
3. Look for:
   ```
   🔧 openSystemPreferences called
   Opened ... successfully
   ✅ System Preferences call completed
   ```

### Test 2: Grant Permissions (if needed)
1. In System Settings → Privacy & Security
2. Add the app to Screen Recording
3. Add the app to Accessibility
4. Click "Recheck Permissions" in the app

### Test 3: Start Monitoring
1. Toggle the monitoring switch ON
2. You should see:
   ```
   🎛️ Monitoring toggle changed to: true
   ▶️ Starting monitoring...
   🚀 Starting monitoring with config: {...}
   ✅ Native monitoring started
   📸 Screenshot capture enabled, interval: 2s
   📊 Starting activity tracking (every 5 seconds)
   ✅ Monitoring started
   ```

### Test 4: Watch Activity Tracking
Every 5 seconds, you should see:
```
⏰ Activity tracking timer triggered
📊 Tracking activity...
🪟 Getting active window...
✅ Active window: [App Name] - [Window Title]
✅ Activity log created: [App Name] (keystrokes: X, clicks: Y, idle: false)
📝 Activity tracked, adding to provider
```

### Test 5: Watch Screenshot Capture
Every 2 seconds (or your configured interval), you should see:
```
⏰ Screenshot timer triggered
📸 Attempting to capture screenshot...
✅ Screenshot captured: /path/to/screenshot.png
```

OR if there's an error:
```
❌ Error capturing screenshot: [error message]
```

## What Each Emoji Means

- 🚀 = Starting something
- ✅ = Success
- ❌ = Error
- ⚠️ = Warning
- 🔧 = System operation
- 📸 = Screenshot
- 🪟 = Window tracking
- 📊 = Activity tracking
- ⏰ = Timer triggered
- 📝 = Data saved
- 🎛️ = UI interaction
- 💾 = Settings saved
- ▶️ = Start
- ⏸️ = Stop

## Common Issues and What to Look For

### Issue: No logs at all
**Look for:** Any error messages when the app starts
**Solution:** Make sure you're running `flutter run -d macos` and watching that terminal

### Issue: "Cannot find 'MonitoringPlugin' in scope"
**Look for:** Build errors
**Solution:** The Swift files aren't added to Xcode project. Run the Python script again.

### Issue: Monitoring starts but no activity logs
**Look for:** 
```
⏰ Activity tracking timer triggered
```
If you see this but nothing after, the native methods aren't working.

**Solution:** Check permissions are granted

### Issue: Screenshots not capturing
**Look for:**
```
❌ Error capturing screenshot: [error]
```
**Solution:** Grant Screen Recording permission

### Issue: No keystroke/click counts
**Look for:**
```
✅ Activity log created: [App Name] (keystrokes: 0, clicks: 0, idle: false)
```
If counts are always 0, Accessibility permission isn't granted.

**Solution:** Grant Accessibility permission

## Expected Log Flow

When everything is working correctly, you should see this pattern:

```
[App starts]
🔧 Attempting to open System Preferences...

[User clicks "Open System Preferences"]
🔧 openSystemPreferences called
Opened Settings app successfully
✅ System Preferences call completed

[User grants permissions and clicks "Recheck Permissions"]
[Permissions screen disappears, main screen loads]

[User toggles monitoring ON]
🎛️ Monitoring toggle changed to: true
▶️ Starting monitoring...
🚀 Starting monitoring with config: {screenshotEnabled: true, screenshotInterval: 2, ...}
✅ Native monitoring started
📸 Screenshot capture enabled, interval: 2s
📊 Starting activity tracking (every 5 seconds)
✅ Monitoring started

[Every 2 seconds]
⏰ Screenshot timer triggered
📸 Attempting to capture screenshot...
✅ Screenshot captured: /Users/.../screenshot_20260101_123456.png

[Every 5 seconds]
⏰ Activity tracking timer triggered
📊 Tracking activity...
🪟 Getting active window...
✅ Active window: Activity Tracker - Activity Tracker
✅ Activity log created: Activity Tracker (keystrokes: 5, clicks: 2, idle: false)
📝 Activity tracked, adding to provider
```

## Debugging Tips

1. **Clear logs:** Press Ctrl+L in the terminal to clear old logs

2. **Filter logs:** Use grep to see only specific logs:
   ```bash
   flutter run -d macos 2>&1 | grep "📸\|📊\|❌"
   ```

3. **Save logs to file:**
   ```bash
   flutter run -d macos 2>&1 | tee app_logs.txt
   ```

4. **Check if timers are running:**
   Look for the ⏰ emoji appearing regularly

5. **Verify permissions:**
   ```bash
   # Check Screen Recording permission
   # Check Accessibility permission
   # Both should show green checkmarks in the app
   ```

## Quick Test Checklist

- [ ] App builds without errors
- [ ] App launches successfully
- [ ] "Open System Preferences" button works (see logs)
- [ ] Permissions can be granted
- [ ] Monitoring toggle works (see logs)
- [ ] Activity tracking timer fires every 5 seconds (see logs)
- [ ] Screenshot timer fires at configured interval (see logs)
- [ ] Active window is detected (see logs)
- [ ] Activity logs appear in the UI
- [ ] Statistics update in the UI

## Still Not Seeing Logs?

If you're still not seeing any logs after following these steps:

1. Make sure you're looking at the correct terminal window
2. Try hot restart: Press 'R' in the terminal
3. Try full restart: Press 'q' to quit, then run again
4. Check if the app is actually running (you should see the window)
5. Make sure you've saved all files and rebuilt

## Need More Help?

Run this command to check everything:
```bash
flutter doctor -v
```

And check:
- Flutter version
- Xcode version
- macOS version
- Any warnings or errors
