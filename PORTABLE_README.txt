================================================================================
                    ACTIVITY TRACKER - PORTABLE EDITION
                              Version 1.0.0
================================================================================

QUICK START
-----------
1. Double-click "poc_activity_tracker.exe" to run
2. Configure your settings
3. Toggle monitoring ON
4. The app will track activity in the background

REQUIREMENTS
------------
- Windows 10 or later (64-bit)
- No installation required
- No admin rights required (for basic usage)
- Approximately 50 MB disk space

FIRST RUN
---------
On first run, Windows may show a security warning:
  "Windows protected your PC"
  
To proceed:
  1. Click "More info"
  2. Click "Run anyway"
  
This is normal for unsigned applications and is safe to proceed.

FEATURES
--------
✓ Screenshot Capture
  - Automatic screenshots at configurable intervals
  - Default: Every 5 minutes
  - Can be disabled in settings

✓ Active Window Tracking
  - Monitors which applications are being used
  - Tracks window titles
  - Updates in real-time

✓ Keyboard Activity Monitoring
  - Counts keystrokes (does NOT log actual keys)
  - Privacy-friendly - only counts, not content
  - Can be disabled in settings

✓ Mouse Activity Monitoring
  - Counts mouse clicks
  - Tracks activity levels
  - Can be disabled in settings

✓ Idle Detection
  - Automatically detects when user is inactive
  - Configurable idle threshold
  - Default: 5 minutes

✓ Configurable Settings
  - Adjust all monitoring parameters
  - Enable/disable individual features
  - Configure server upload (optional)

USAGE
-----
1. Launch Application
   - Double-click poc_activity_tracker.exe
   - The app window will open

2. Configure Settings (Optional)
   - Click the settings icon (gear)
   - Adjust screenshot interval
   - Enable/disable features
   - Click "Save Settings"

3. Start Monitoring
   - Toggle the monitoring switch to ON
   - The status will change to "Active"
   - Activity tracking begins immediately

4. View Activity
   - See real-time statistics on the home screen
   - View activity logs in the list
   - Monitor current application

5. Stop Monitoring
   - Toggle the monitoring switch to OFF
   - Activity tracking stops

SETTINGS
--------
Screenshot Interval:
  - How often to capture screenshots
  - Range: 1 second to 1 hour
  - Default: 300 seconds (5 minutes)

Feature Toggles:
  - Screenshot Capture: ON/OFF
  - Keystroke Tracking: ON/OFF
  - Mouse Tracking: ON/OFF
  - Application Tracking: ON/OFF

Server Configuration (Optional):
  - Server URL: Where to upload data
  - API Key: Authentication for server
  - Leave blank for local-only operation

DATA STORAGE
------------
Screenshots:
  - Saved in the same folder as the executable
  - Named: screenshot_YYYYMMDD_HHMMSS.png
  - Can be deleted manually

Activity Logs:
  - Stored in memory while app is running
  - Cleared when app is closed
  - Last 100 entries kept in memory

Settings:
  - Saved in Windows registry
  - Persist between app restarts
  - Can be reset by deleting registry keys

PRIVACY
-------
What is tracked:
  ✓ Active window titles
  ✓ Application names
  ✓ Keystroke counts (NOT actual keys)
  ✓ Mouse click counts
  ✓ Screenshots (if enabled)
  ✓ Idle time

What is NOT tracked:
  ✗ Actual keystrokes or passwords
  ✗ Personal information
  ✗ Browser history
  ✗ File contents
  ✗ Network activity

Data Privacy:
  - All data stored locally by default
  - No cloud upload unless server configured
  - User has full control over data
  - Can be deleted by removing the folder

UNINSTALL
---------
To remove the application:
  1. Close the application
  2. Delete the entire folder
  3. (Optional) Clean registry:
     - Run: regedit
     - Navigate to: HKEY_CURRENT_USER\Software\poc_activity_tracker
     - Delete the key

No other cleanup needed - it's portable!

TROUBLESHOOTING
---------------
Problem: App doesn't start
Solution: 
  - Ensure Windows 10 or later (64-bit)
  - Install Visual C++ Redistributable:
    https://aka.ms/vs/17/release/vc_redist.x64.exe
  - Run as Administrator

Problem: Screenshots not saving
Solution:
  - Check folder permissions
  - Ensure enough disk space
  - Run as Administrator

Problem: No activity logs appearing
Solution:
  - Make sure monitoring is started (toggle ON)
  - Check that features are enabled in settings
  - Try switching between applications

Problem: Antivirus blocks the app
Solution:
  - Add to antivirus exceptions
  - Contact your IT department
  - This is expected for monitoring software

Problem: High CPU usage
Solution:
  - Increase screenshot interval
  - Disable unused features
  - Close other applications

SYSTEM REQUIREMENTS
-------------------
Minimum:
  - Windows 10 (64-bit)
  - 2 GB RAM
  - 100 MB free disk space
  - 1280x720 screen resolution

Recommended:
  - Windows 11 (64-bit)
  - 4 GB RAM
  - 500 MB free disk space
  - 1920x1080 screen resolution

LEGAL & COMPLIANCE
------------------
This software is designed for legitimate employee monitoring purposes.

Before use, ensure:
  ✓ Employees are informed of monitoring
  ✓ Written consent is obtained
  ✓ Compliance with local labor laws
  ✓ Privacy policy is in place
  ✓ Data protection regulations are followed

Misuse of this software for unauthorized surveillance is prohibited
and may be illegal in your jurisdiction.

SUPPORT
-------
For technical support:
  - Contact your IT administrator
  - Check company support portal
  - Review documentation included with the software

For general questions:
  - See the full documentation
  - Check the project README
  - Contact your system administrator

VERSION INFORMATION
-------------------
Version: 1.0.0
Platform: Windows 10/11 (64-bit)
Type: Portable (no installation required)
License: Enterprise Use Only

CREDITS
-------
Built with Flutter framework
Developed for enterprise employee monitoring
Copyright © 2025. All rights reserved.

================================================================================
                         Thank you for using Activity Tracker!
================================================================================
