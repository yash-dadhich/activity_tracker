@echo off
echo Starting Enterprise Productivity Monitor Demo...
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed
echo.

REM Install Node.js dependencies for mock backend
echo 📦 Installing backend dependencies...
npm install express cors jsonwebtoken

REM Start mock backend in background
echo 🚀 Starting mock backend server...
start /b node mock_backend.js

REM Wait a moment for server to start
timeout /t 3 /nobreak >nul

REM Get Flutter dependencies
echo 📱 Getting Flutter dependencies...
flutter pub get

REM Run Flutter app
echo 🎯 Starting Flutter application...
echo.
echo 🌟 Demo Accounts:
echo    Employee: employee@demo.com / Demo123!
echo    Manager:  manager@demo.com / Demo123!
echo    Admin:    admin@demo.com / Demo123!
echo.
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:3000/v1 --dart-define=MOCK_DATA=true

pause