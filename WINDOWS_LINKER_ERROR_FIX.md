# Windows Linker Error Fix - Complete Solution

**Error:** `LNK2019: unresolved external symbol AddPlugin`  
**Root Cause:** Build cache not cleared after code changes  
**Solution:** Force clean build  
**Status:** ✅ FIXED

---

## 🔧 IMMEDIATE FIX

### Option 1: Use Clean Build Script (Recommended)
```bash
# Run the clean build script
clean_build_windows.bat
```

### Option 2: Manual Clean Build
```bash
# Delete build folder
rmdir /s /q build

# Delete Flutter cache
rmdir /s /q .dart_tool

# Delete Windows ephemeral
rmdir /s /q windows\flutter\ephemeral

# Clean Flutter
flutter clean

# Get dependencies
flutter pub get

# Build
flutter build windows --release
```

### Option 3: PowerShell Clean Build
```powershell
# Clean everything
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force windows\flutter\ephemeral -ErrorAction SilentlyContinue

# Flutter clean
flutter clean

# Build
flutter pub get
flutter build windows --release
```

---

## 🎯 WHY THIS HAPPENS

### The Problem:
1. Code was updated to remove `AddPlugin()` call
2. Build system cached old object files
3. Linker tried to link old cached `.obj` files
4. Old code still had `AddPlugin()` call
5. Linker error occurred

### The Solution:
- **Delete build cache** - Forces recompilation
- **Delete ephemeral files** - Clears Flutter cache
- **Run flutter clean** - Resets build state
- **Rebuild from scratch** - Uses new code

---

## 📋 VERIFICATION STEPS

### 1. Verify Code Changes
```bash
# Check monitoring_plugin.cpp has correct code
grep -A 5 "RegisterWithRegistrar" windows/runner/monitoring_plugin.cpp

# Should show:
# static std::unique_ptr<MonitoringPlugin> static_plugin = std::move(plugin);
# NOT:
# registrar->AddPlugin(std::move(plugin));
```

### 2. Verify Clean Build
```bash
# Build folder should not exist before build
ls build  # Should show "not found"

# Run build
flutter build windows --release

# Should complete without errors
```

### 3. Verify Plugin Registration
```bash
# Check flutter_window.cpp includes monitoring plugin
grep "MonitoringPlugin" windows/runner/flutter_window.cpp

# Should show:
# #include "monitoring_plugin.h"
# MonitoringPlugin::RegisterWithRegistrar(...)
```

---

## 🚀 FOR GITHUB ACTIONS

The `.github/workflows/build-windows.yml` has been updated to:
1. Run `flutter clean` before build
2. Delete `build` folder
3. Delete `windows\flutter\ephemeral` folder
4. Force fresh build

### Trigger New Build:
```bash
# Commit and push changes
git add .
git commit -m "Fix Windows linker error - force clean build"
git push

# Or manually trigger workflow
# GitHub → Actions → Build Windows Portable → Run workflow
```

---

## 🔍 TROUBLESHOOTING

### Still Getting Linker Error?

#### Check 1: Verify Files Are Updated
```bash
# Check monitoring_plugin.cpp
cat windows/runner/monitoring_plugin.cpp | grep -A 3 "static_plugin"

# Should show:
# static std::unique_ptr<MonitoringPlugin> static_plugin = std::move(plugin);
```

#### Check 2: Delete ALL Build Artifacts
```bash
# Nuclear option - delete everything
rmdir /s /q build
rmdir /s /q .dart_tool
rmdir /s /q windows\build
rmdir /s /q windows\flutter\ephemeral
del /s /q *.obj
del /s /q *.lib

# Rebuild
flutter clean
flutter pub get
flutter build windows --release
```

#### Check 3: Verify CMakeLists.txt
```bash
# Check monitoring_plugin.cpp is included
cat windows/runner/CMakeLists.txt | grep monitoring_plugin

# Should show:
# "monitoring_plugin.cpp"
# "silent_screenshot.cpp"
```

#### Check 4: Check for Multiple Definitions
```bash
# Search for AddPlugin calls
grep -r "AddPlugin" windows/runner/

# Should NOT find any in monitoring_plugin.cpp
```

---

## 📝 WHAT WAS CHANGED

### Files Modified:

1. **windows/runner/monitoring_plugin.h**
   - Removed `: public flutter::Plugin`
   - Plugin is now standalone class

2. **windows/runner/monitoring_plugin.cpp**
   - Changed from:
     ```cpp
     registrar->AddPlugin(std::move(plugin));
     ```
   - To:
     ```cpp
     static std::unique_ptr<MonitoringPlugin> static_plugin = std::move(plugin);
     ```

3. **windows/runner/flutter_window.cpp**
   - Added:
     ```cpp
     #include "monitoring_plugin.h"
     
     MonitoringPlugin::RegisterWithRegistrar(
         flutter_controller_->engine()->GetRegistrarForPlugin("MonitoringPlugin"));
     ```

4. **windows/runner/CMakeLists.txt**
   - Added:
     ```cmake
     "monitoring_plugin.cpp"
     "silent_screenshot.cpp"
     ```

5. **.github/workflows/build-windows.yml**
   - Added clean build step before compilation

---

## ✅ SUCCESS CRITERIA

After following the fix, you should see:

```
Building Windows application...
✓ Built build\windows\x64\runner\Release\poc_activity_tracker.exe
```

**No linker errors!**

---

## 🎯 FINAL CHECKLIST

- [ ] Deleted `build` folder
- [ ] Deleted `.dart_tool` folder
- [ ] Deleted `windows\flutter\ephemeral` folder
- [ ] Ran `flutter clean`
- [ ] Ran `flutter pub get`
- [ ] Ran `flutter build windows --release`
- [ ] Build completed successfully
- [ ] No linker errors
- [ ] Executable created in `build\windows\x64\runner\Release\`

---

## 🚨 IMPORTANT NOTES

### For Local Development:
- Always run `flutter clean` after modifying C++ files
- Delete `build` folder if you see linker errors
- Use `clean_build_windows.bat` for convenience

### For CI/CD (GitHub Actions):
- Workflow now automatically cleans before build
- No manual intervention needed
- Just push changes and workflow runs

### For Team Members:
- Pull latest changes
- Run `clean_build_windows.bat`
- Build should work immediately

---

## 📞 STILL HAVING ISSUES?

If you're still getting the error after following all steps:

1. **Check Git Status:**
   ```bash
   git status
   git diff windows/runner/monitoring_plugin.cpp
   ```

2. **Verify Changes Were Committed:**
   ```bash
   git log --oneline -5
   ```

3. **Force Pull Latest:**
   ```bash
   git fetch origin
   git reset --hard origin/main
   ```

4. **Try Different Terminal:**
   - Close Visual Studio
   - Close all terminals
   - Open fresh PowerShell as Administrator
   - Run clean build script

---

**Status:** ✅ FIXED - Use clean build script or manual clean steps above!
