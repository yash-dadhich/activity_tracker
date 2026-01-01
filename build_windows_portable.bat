@echo off
echo ========================================
echo Building Activity Tracker for Windows
echo ========================================
echo.

REM Clean previous builds
echo [1/5] Cleaning previous builds...
call flutter clean
if errorlevel 1 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

REM Get dependencies
echo.
echo [2/5] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

REM Build release version
echo.
echo [3/5] Building Windows release...
call flutter build windows --release
if errorlevel 1 (
    echo ERROR: Flutter build failed
    pause
    exit /b 1
)

REM Create portable package directory
echo.
echo [4/5] Creating portable package...
set OUTPUT_DIR=ActivityTracker_Windows_Portable
if exist %OUTPUT_DIR% rmdir /s /q %OUTPUT_DIR%
mkdir %OUTPUT_DIR%

REM Copy build files
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "%OUTPUT_DIR%\"

REM Create README for the portable version
echo Creating portable README...
(
echo Activity Tracker - Windows Portable Edition
echo ==========================================
echo.
echo INSTALLATION:
echo 1. Extract this ZIP file to any folder
echo 2. Run poc_activity_tracker.exe
echo 3. Grant any permissions if prompted by Windows
echo.
echo REQUIREMENTS:
echo - Windows 10 or later ^(64-bit^)
echo - No installation required
echo - No admin rights required ^(for basic usage^)
echo.
echo FEATURES:
echo - Screenshot capture
echo - Active window tracking
echo - Keyboard and mouse activity monitoring
echo - Idle detection
echo - Configurable settings
echo.
echo FIRST RUN:
echo On first run, Windows Defender SmartScreen may show a warning.
echo Click "More info" and then "Run anyway" to proceed.
echo This is normal for unsigned applications.
echo.
echo USAGE:
echo 1. Launch the application
echo 2. Configure settings ^(screenshot interval, etc.^)
echo 3. Toggle monitoring ON
echo 4. The app will track activity in the background
echo.
echo DATA STORAGE:
echo - Screenshots: Same folder as the executable
echo - Activity logs: Stored in memory ^(cleared on restart^)
echo - Settings: Stored in Windows registry
echo.
echo UNINSTALL:
echo Simply delete the entire folder. No registry cleanup needed.
echo.
echo SUPPORT:
echo For issues or questions, contact your IT administrator.
echo.
echo Version: 1.0.0
echo Build Date: %date%
) > "%OUTPUT_DIR%\README.txt"

REM Create a batch file to run the app
(
echo @echo off
echo start poc_activity_tracker.exe
) > "%OUTPUT_DIR%\Run_Activity_Tracker.bat"

REM Create ZIP file
echo.
echo [5/5] Creating ZIP file...
powershell -command "Compress-Archive -Path '%OUTPUT_DIR%\*' -DestinationPath 'ActivityTracker_Windows_Portable.zip' -Force"

echo.
echo ========================================
echo BUILD COMPLETE!
echo ========================================
echo.
echo Portable package created:
echo   Folder: %OUTPUT_DIR%\
echo   ZIP:    ActivityTracker_Windows_Portable.zip
echo.
echo You can now share the ZIP file with other Windows users.
echo They just need to extract and run poc_activity_tracker.exe
echo.
pause
