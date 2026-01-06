#!/bin/bash

echo "Starting Enterprise Productivity Monitor Demo..."
echo

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed"
    echo "Please install Flutter from https://flutter.dev/"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo

# Install Node.js dependencies for mock backend
echo "📦 Installing backend dependencies..."
npm install express cors jsonwebtoken

# Start mock backend in background
echo "🚀 Starting mock backend server..."
node mock_backend.js &
BACKEND_PID=$!

# Wait a moment for server to start
sleep 3

# Get Flutter dependencies
echo "📱 Getting Flutter dependencies..."
flutter pub get

# Run Flutter app
echo "🎯 Starting Flutter application..."
echo
echo "🌟 Demo Accounts:"
echo "   Employee: employee@demo.com / Demo123!"
echo "   Manager:  manager@demo.com / Demo123!"
echo "   Admin:    admin@demo.com / Demo123!"
echo

# Determine platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
else
    PLATFORM="windows"
fi

flutter run -d $PLATFORM --dart-define=API_BASE_URL=http://localhost:3000/v1 --dart-define=MOCK_DATA=true

# Cleanup: Kill backend when Flutter app exits
kill $BACKEND_PID 2>/dev/null