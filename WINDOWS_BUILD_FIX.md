# Windows Build Fix - Silent Screenshot

**Issue:** Linker error `LNK2019: unresolved external symbol AddPlugin`  
**Solution:** Modified plugin registration to work with embedded plugin  
**Status:** ✅ FIXED

---

## 🔧 CHANGES MADE

### 1. Modified `monitoring_plugin.h`
- Removed inheritance from `flutter::Plugin`
- Plugin is now standalone class

### 2. Modified `monitoring_plugin.cpp`
- Removed `registrar->AddPlugin()` call
- Plugin now stored in static variable to keep it alive

### 3. Modified `flutter_window.cpp`
- Added manual plugin registration
- Calls `MonitoringPlugin::RegisterWithRegistrar()` after other plugins

### 4. Updated `CMakeLists.txt`
- Added monitoring_plugin.cpp and silent_screenshot.cpp
- Added required libraries: d3d11.lib, dxgi.lib, windowscodecs.lib

---

## 🚀 BUILD INSTRUCTIONS

### Clean Build:
```bash
# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build for Windows
flutter build windows --release
```

### Debug Build:
```bash
flutter run -d windows
```

---

## ✅ VERIFICATION

### Check Build Success:
```bash
# Should complete without errors
flutter build windows --release

# Check executable exists
ls build/windows/x64/runner/Release/poc_activity_tracker.exe
```

### Test Silent Screenshot:
1. Run the app
2. Enable monitoring
3. Screenshots should be captured silently
4. No screen flashing or blinking

---

## 📝 TECHNICAL DETAILS

### Why This Fix Works:

**Problem:**
- Plugin was trying to use `flutter::Plugin` base class
- `AddPlugin()` method not available when embedding plugin directly
- Linker couldn't find the symbol

**Solution:**
- Removed `flutter::Plugin` inheritance
- Store plugin in static variable instead of registrar
- Register manually in `flutter_window.cpp`

### Plugin Registration Flow:
```cpp
// In flutter_window.cpp
RegisterPlugins(engine);  // Generated plugins

// Manual registration
MonitoringPlugin::RegisterWithRegistrar(
    engine->GetRegistrarForPlugin("MonitoringPlugin")
);
```

---

## 🔍 TROUBLESHOOTING

### Issue: Still Getting Linker Errors
**Solution:**
```bash
# Delete build folder
rm -rf build/

# Clean Flutter
flutter clean

# Rebuild
flutter build windows
```

### Issue: Plugin Not Working
**Check:**
1. Plugin is registered in `flutter_window.cpp`
2. Method channel name matches: `com.activitytracker/monitoring`
3. Plugin files are in CMakeLists.txt

### Issue: Missing Libraries
**Error:** `cannot open file 'd3d11.lib'`

**Solution:**
- Install Windows SDK
- Visual Studio Installer → Modify → Windows SDK
- Rebuild project

---

## ✅ SUMMARY

**Before:**
- ❌ Linker error: unresolved external symbol
- ❌ Build failed

**After:**
- ✅ Build succeeds
- ✅ Plugin registers correctly
- ✅ Silent screenshot works

---

**Status:** ✅ FIXED - Build now completes successfully!
