# Quick Fix for Windows Linker Error

## 🚀 ONE-LINE FIX

Run this in PowerShell:

```powershell
Remove-Item -Recurse -Force build,.dart_tool,windows\flutter\ephemeral -ErrorAction SilentlyContinue; flutter clean; flutter pub get; flutter build windows --release
```

Or use the batch file:

```bash
clean_build_windows.bat
```

---

## ✅ That's It!

The build should now complete successfully without linker errors.

---

## 📝 What This Does:

1. Deletes `build` folder (old compiled files)
2. Deletes `.dart_tool` folder (Dart cache)
3. Deletes `windows\flutter\ephemeral` (Flutter Windows cache)
4. Runs `flutter clean` (cleans Flutter build)
5. Runs `flutter pub get` (gets dependencies)
6. Runs `flutter build windows --release` (builds app)

---

## 🎯 Expected Output:

```
Building Windows application...
✓ Built build\windows\x64\runner\Release\poc_activity_tracker.exe
```

**No errors!**

---

For more details, see `WINDOWS_LINKER_ERROR_FIX.md`
