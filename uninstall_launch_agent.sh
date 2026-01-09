#!/bin/bash

# Uninstall Launch Agent
# This script removes the launch agent that auto-restarts the app

echo "🗑️  Uninstalling Employee Monitoring Launch Agent"
echo "================================================"
echo ""

PLIST_PATH="$HOME/Library/LaunchAgents/com.company.monitoring.plist"

if [ ! -f "$PLIST_PATH" ]; then
    echo "❌ Launch agent not found"
    echo "   Nothing to uninstall"
    exit 0
fi

echo "🔄 Unloading launch agent..."
launchctl unload "$PLIST_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Launch agent unloaded"
else
    echo "⚠️  Failed to unload (may not be loaded)"
fi

echo "🗑️  Removing configuration file..."
rm "$PLIST_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Configuration file removed"
else
    echo "❌ Failed to remove configuration file"
    exit 1
fi

echo ""
echo "================================================"
echo "✅ Uninstallation Complete!"
echo ""
echo "The app will no longer:"
echo "  • Auto-start on login"
echo "  • Auto-restart if force quit"
echo ""
