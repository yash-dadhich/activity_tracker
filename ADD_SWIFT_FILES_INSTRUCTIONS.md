# How to Add Swift Plugin Files to Xcode

## The Problem
The Swift plugin files (`MonitoringPlugin.swift` and `PermissionPlugin.swift`) exist in the `macos/Runner/` folder but aren't part of the Xcode project, so they don't get compiled.

## The Solution - Follow These Steps:

### Step 1: Xcode Should Now Be Open
If not, run: `open macos/Runner.xcworkspace`

### Step 2: Add the Swift Files

1. **In Xcode's left sidebar (Project Navigator)**, you should see:
   ```
   Runner
   ├── Runner
   │   ├── AppDelegate.swift
   │   ├── MainFlutterWindow.swift
   │   └── ... other files
   ```

2. **Right-click on the "Runner" folder** (the one with the blue icon, inside the Runner project)

3. **Select "Add Files to Runner..."**

4. **Navigate to the `macos/Runner/` folder** in your project

5. **Select BOTH files:**
   - ✅ `MonitoringPlugin.swift`
   - ✅ `PermissionPlugin.swift`

6. **IMPORTANT - Check these settings in the dialog:**
   - ✅ **"Runner" target is CHECKED** (in the "Add to targets" section)
   - ❌ **"Copy items if needed" is UNCHECKED** (we don't want to copy, just reference)
   - ✅ **"Create groups" is selected** (not "Create folder references")

7. **Click "Add"**

### Step 3: Verify Files Were Added

After adding, you should see in the Project Navigator:
```
Runner
├── Runner
│   ├── AppDelegate.swift
│   ├── MainFlutterWindow.swift
│   ├── MonitoringPlugin.swift      ← NEW
│   ├── PermissionPlugin.swift      ← NEW
│   └── ... other files
```

### Step 4: Clean and Build

1. In Xcode menu: **Product → Clean Build Folder** (or press `Cmd+Shift+K`)

2. **Close Xcode**

3. **In terminal, run:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d macos
   ```

## If You Still Get Errors

### Error: "Cannot find 'MonitoringPlugin' in scope"

This means the files weren't added correctly. Try again and make sure:
- The "Runner" target is checked
- The files appear in the Project Navigator
- You cleaned the build folder

### Alternative Method: Edit project.pbxproj Directly

If the GUI method doesn't work, I can help you edit the Xcode project file directly. Let me know!

## Quick Test

After adding the files and rebuilding, the app should:
1. ✅ Build successfully
2. ✅ Launch without errors
3. ✅ "Open System Preferences" button should work

## Visual Guide

```
┌─────────────────────────────────────┐
│ Xcode Window                        │
├─────────────────────────────────────┤
│                                     │
│  Project Navigator (Left Sidebar)  │
│  ┌───────────────────────────────┐ │
│  │ Runner (project)              │ │
│  │ ├─ Runner (folder) ← RIGHT CLICK HERE
│  │ │  ├─ AppDelegate.swift       │ │
│  │ │  ├─ MainFlutterWindow.swift │ │
│  │ │  └─ ...                     │ │
│  │ └─ ...                        │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘

Then: Add Files to Runner... → Select both .swift files
```

## Need Help?

If you're stuck, let me know and I can:
1. Create a script to modify the Xcode project file directly
2. Provide more detailed screenshots/instructions
3. Help debug any other issues
