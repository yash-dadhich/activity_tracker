@echo off
echo Cleaning Windows build cache...

REM Delete build folder
if exist build rmdir /s /q build

REM Delete Flutter generated files
if exist .dart_tool rmdir /s /q .dart_tool

REM Delete Windows specific cache
if exist windows\flutter\ephemeral rmdir /s /q windows\flutter\ephemeral

REM Clean Flutter
flutter clean

echo Cache cleaned!
echo.
echo Running flutter pub get...
flutter pub get

echo.
echo Building for Windows...
flutter build windows --release

echo.
echo Build complete!
pause
