# Quick Test Guide - Invisible Screenshot

## 🚀 Quick Start (5 Minutes)

This guide will help you test the invisible screenshot functionality immediately.

---

## ✅ Prerequisites

- Windows 10 or 11
- Flutter installed
- This project already has all dependencies

---

## 📋 Step-by-Step Testing

### 1. Build the Application (2 minutes)

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for Windows
flutter build windows --release
```

**Expected output:**
```
✓ Built build\windows\x64\runner\Release\poc_activity_tracker.exe
```

### 2. Run the Application (1 minute)

**Option A: Run from Flutter**
```bash
flutter run -d windows
```

**Option B: Run the executable**
```bash
.\build\windows\x64\runner\Release\poc_activity_tracker.exe
```

### 3. Enable Screenshot Monitoring (30 seconds)

1. Open the app
2. Click on **Settings** (gear icon)
3. Find **Screenshot Monitoring** section
4. Toggle **Enable Screenshots** to ON
5. Set **Interval** to **10 seconds** (for quick testing)
6. Click **Save Settings**
7. Go back to **Home** screen
8. Click **Start Monitoring**

### 4. Verify Invisible Capture (1 minute)

**Watch carefully:**
- ❌ You should NOT see any Snipping Tool
- ❌ You should NOT see any screen flash
- ❌ You should NOT see any notifications
- ❌ You should NOT see any visual feedback

**Wait 10 seconds**, then check the screenshots folder:

```
C:\Users\[YourUsername]\Documents\screenshots\activity_tracker\
```

**You should see:**
- PNG files with timestamps
- File size: ~500KB - 2MB each
- New file every 10 seconds

### 5. Alternative: Run Test Script (30 seconds)

```bash
dart run test_silent_screenshot.dart
```

**Expected output:**
```
🧪 Testing Silent Screenshot Service

✅ Running on Windows
📸 Attempting to capture screenshot...

✅ SUCCESS!
   File saved: C:\Users\...\screenshot_20260112_143022.png
   Capture time: 234ms
   File size: 1.23 MB

📁 You can view the screenshot at:
   C:\Users\...\screenshot_20260112_143022.png

🏁 Test complete
```

---

## ✅ Success Indicators

### Visual Test
- [ ] No Snipping Tool appeared
- [ ] No screen flash or blink
- [ ] No notifications
- [ ] No cursor change
- [ ] No sound

### File Test
- [ ] Screenshot file created
- [ ] File has correct timestamp
- [ ] File size is reasonable (500KB-2MB)
- [ ] Image opens correctly
- [ ] Image shows full screen

### Console Test
Look for these messages:
```
🚀 Starting screenshot monitoring
📸 Screenshot capture enabled, interval: 10s
⏰ Screenshot timer triggered
🔇 Using silent screenshot service for Windows
✅ Silent screenshot captured: [path]
```

---

## 🔧 Troubleshooting

### Problem: No screenshots created

**Check:**
1. Is monitoring enabled? (Home screen should show "Monitoring Active")
2. Check console for error messages
3. Verify folder exists: `Documents\screenshots\activity_tracker\`
4. Check disk space

**Solution:**
```bash
# Run with verbose logging
flutter run -d windows -v
```

### Problem: Build errors

**Solution:**
```bash
flutter clean
flutter pub get
flutter build windows --release
```

### Problem: "GdiplusStartup failed"

**Cause:** GDI+ not available (rare on Windows 10/11)

**Solution:**
- Verify Windows version: `winver`
- Update Windows
- Check if gdiplus.dll exists: `C:\Windows\System32\gdiplus.dll`

### Problem: Screenshots are visible (Snipping Tool appears)

**Cause:** Not using silent screenshot service

**Check:**
1. Verify you're on Windows (not macOS/Linux)
2. Check console for "Using silent screenshot service for Windows"
3. Verify `silent_screenshot_service.dart` exists

---

## 📊 Performance Check

### Normal Behavior
- **CPU spike**: 1-2% for < 1 second during capture
- **Memory**: +50MB temporarily during capture
- **Disk write**: ~1MB per screenshot
- **Capture time**: 200-500ms

### Warning Signs
- ❌ CPU stays high (>5%) after capture
- ❌ Memory keeps increasing
- ❌ Capture takes >2 seconds
- ❌ Files are >5MB

If you see warning signs, check console for errors.

---

## 🎯 What to Test

### Basic Functionality
- [ ] Screenshot captures without visual feedback
- [ ] Files are created with correct timestamps
- [ ] Files contain actual screen content
- [ ] Timer works (captures every X seconds)
- [ ] Start/Stop monitoring works

### Edge Cases
- [ ] Multiple monitors (currently captures primary only)
- [ ] High DPI displays
- [ ] Different screen resolutions
- [ ] Rapid start/stop
- [ ] Long running (24+ hours)

### Integration
- [ ] Monitoring service integration
- [ ] Settings persistence
- [ ] System tray functionality
- [ ] App restart (monitoring state)

---

## 📸 Example Screenshot Locations

```
C:\Users\YourName\Documents\screenshots\activity_tracker\
├── screenshot_20260112_140530.png
├── screenshot_20260112_140540.png
├── screenshot_20260112_140550.png
└── screenshot_20260112_140600.png
```

---

## 🔍 Verification Checklist

After testing, verify:

### Technical
- [x] Code compiles without errors
- [ ] App runs without crashes
- [ ] Screenshots captured invisibly
- [ ] Files created correctly
- [ ] No memory leaks
- [ ] No resource leaks

### User Experience
- [ ] No visual feedback during capture
- [ ] App remains responsive
- [ ] Settings save correctly
- [ ] Monitoring starts/stops properly
- [ ] System tray works

### Legal (Before Production)
- [ ] Read LEGAL_COMPLIANCE_WARNING.md
- [ ] Consult with lawyer
- [ ] Create monitoring policy
- [ ] Obtain employee consent
- [ ] Implement security measures

---

## 📞 Next Steps

### If Testing Succeeds ✅
1. Read `LEGAL_COMPLIANCE_WARNING.md`
2. Consult with employment lawyer
3. Create monitoring policy
4. Implement backend upload
5. Add data encryption
6. Deploy to test environment

### If Testing Fails ❌
1. Check console logs for errors
2. Review `INVISIBLE_SCREENSHOT_IMPLEMENTATION.md`
3. Verify Windows version (10/11 required)
4. Check antivirus isn't blocking
5. Try running as Administrator

---

## 💡 Tips

### For Development
- Use 10-second interval for testing
- Use 5-minute interval for production
- Monitor disk space usage
- Implement auto-deletion after 30 days

### For Deployment
- Test on actual employee machines first
- Start with small pilot group
- Monitor system performance
- Collect feedback
- Adjust settings as needed

### For Compliance
- Document everything
- Keep consent forms
- Regular policy reviews
- Employee communication
- Audit data access

---

## ⚠️ Important Reminders

1. **Legal First**: Read legal documentation before deploying
2. **Employee Consent**: Always obtain written consent
3. **Transparency**: Employees must know they're monitored
4. **Security**: Encrypt data, limit access, audit logs
5. **Testing**: Test thoroughly before production deployment

---

## ✅ Quick Test Summary

**Total Time**: ~5 minutes

1. Build app (2 min)
2. Run app (1 min)
3. Enable monitoring (30 sec)
4. Verify capture (1 min)
5. Check files (30 sec)

**Success = No visual feedback + Files created**

---

**Ready to test? Start with Step 1 above!**

**Questions?** Check `INVISIBLE_SCREENSHOT_IMPLEMENTATION.md` for detailed troubleshooting.

**Legal concerns?** Read `LEGAL_COMPLIANCE_WARNING.md` immediately.
