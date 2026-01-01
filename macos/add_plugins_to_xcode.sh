#!/bin/bash

# Script to add Swift plugin files to Xcode project
# Run this from the project root directory

echo "Adding Swift plugin files to Xcode project..."

# Open Xcode project
open macos/Runner.xcworkspace

echo ""
echo "Manual steps required:"
echo "1. In Xcode, right-click on 'Runner' folder in the left sidebar"
echo "2. Select 'Add Files to Runner...'"
echo "3. Navigate to macos/Runner/"
echo "4. Select both:"
echo "   - MonitoringPlugin.swift"
echo "   - PermissionPlugin.swift"
echo "5. Make sure 'Copy items if needed' is UNCHECKED"
echo "6. Make sure 'Runner' target is CHECKED"
echo "7. Click 'Add'"
echo "8. Clean build folder (Product → Clean Build Folder)"
echo "9. Run the app again"
echo ""
echo "Alternatively, you can rebuild from terminal:"
echo "  flutter clean"
echo "  flutter pub get"
echo "  flutter run -d macos"
