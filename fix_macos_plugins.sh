#!/bin/bash

echo "🔧 Fixing macOS Plugin Registration..."
echo ""

# Step 1: Clean everything
echo "1️⃣ Cleaning build artifacts..."
flutter clean
rm -rf macos/Flutter/ephemeral/
rm -rf build/

# Step 2: Get dependencies
echo ""
echo "2️⃣ Getting Flutter dependencies..."
flutter pub get

# Step 3: Check if Swift files exist
echo ""
echo "3️⃣ Checking Swift plugin files..."
if [ -f "macos/Runner/MonitoringPlugin.swift" ]; then
    echo "✅ MonitoringPlugin.swift found"
else
    echo "❌ MonitoringPlugin.swift NOT found"
fi

if [ -f "macos/Runner/PermissionPlugin.swift" ]; then
    echo "✅ PermissionPlugin.swift found"
else
    echo "❌ PermissionPlugin.swift NOT found"
fi

if [ -f "macos/Runner/AppDelegate.swift" ]; then
    echo "✅ AppDelegate.swift found"
else
    echo "❌ AppDelegate.swift NOT found"
fi

# Step 4: Check AppDelegate content
echo ""
echo "4️⃣ Checking AppDelegate registration..."
if grep -q "MonitoringPlugin.register" macos/Runner/AppDelegate.swift; then
    echo "✅ MonitoringPlugin is registered"
else
    echo "❌ MonitoringPlugin is NOT registered"
    echo "   Please add plugin registration to AppDelegate.swift"
fi

if grep -q "PermissionPlugin.register" macos/Runner/AppDelegate.swift; then
    echo "✅ PermissionPlugin is registered"
else
    echo "❌ PermissionPlugin is NOT registered"
    echo "   Please add plugin registration to AppDelegate.swift"
fi

# Step 5: Build and run
echo ""
echo "5️⃣ Building and running..."
echo ""
echo "If the build succeeds, test the 'Open System Preferences' button."
echo "Watch the console for any error messages."
echo ""

flutter run -d macos

echo ""
echo "🎉 Done!"
