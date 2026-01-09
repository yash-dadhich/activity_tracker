#!/bin/bash

# Install Launch Agent for Auto-Restart
# This script installs a macOS launch agent that will:
# 1. Auto-start the app on login
# 2. Auto-restart the app if it crashes or is force quit

echo "🚀 Installing Employee Monitoring Launch Agent"
echo "=============================================="
echo ""

# Get the app path
APP_NAME="poc_activity_tracker"
APP_PATH="$(pwd)/build/macos/Build/Products/Debug/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at: $APP_PATH"
    echo "   Please build the app first with: flutter build macos"
    exit 1
fi

echo "✅ Found app at: $APP_PATH"
echo ""

# Create launch agent plist
PLIST_PATH="$HOME/Library/LaunchAgents/com.company.monitoring.plist"

echo "📝 Creating launch agent configuration..."

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.company.monitoring</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>$APP_PATH/Contents/MacOS/$APP_NAME</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/monitoring-app.log</string>
    
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/monitoring-app-error.log</string>
    
    <key>ThrottleInterval</key>
    <integer>10</integer>
</dict>
</plist>
EOF

echo "✅ Launch agent configuration created"
echo ""

# Load the launch agent
echo "🔄 Loading launch agent..."
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Launch agent loaded successfully"
else
    echo "❌ Failed to load launch agent"
    exit 1
fi

echo ""
echo "=============================================="
echo "✅ Installation Complete!"
echo ""
echo "The app will now:"
echo "  • Auto-start on login"
echo "  • Auto-restart if force quit"
echo "  • Auto-restart if it crashes"
echo ""
echo "Logs location:"
echo "  • Output: ~/Library/Logs/monitoring-app.log"
echo "  • Errors: ~/Library/Logs/monitoring-app-error.log"
echo ""
echo "To uninstall:"
echo "  ./uninstall_launch_agent.sh"
echo ""
echo "To check status:"
echo "  launchctl list | grep com.company.monitoring"
echo ""
