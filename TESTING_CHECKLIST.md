# Testing Checklist - Activity Tracker

## Pre-Testing Setup

### Windows
- [ ] Visual Studio 2019+ installed with C++ tools
- [ ] Windows 10 SDK installed
- [ ] Flutter SDK 3.10+ installed
- [ ] Dependencies installed: `flutter pub get`

### macOS
- [ ] Xcode 13+ installed
- [ ] Command Line Tools installed
- [ ] Flutter SDK 3.10+ installed
- [ ] Dependencies installed: `flutter pub get`

## Unit Testing

### Models
- [ ] `ActivityLog` serialization/deserialization
- [ ] `MonitoringConfig` serialization/deserialization
- [ ] `MonitoringConfig.copyWith()` works correctly

### Providers
- [ ] `ActivityProvider` state changes
- [ ] Start/stop monitoring toggles
- [ ] Activity log additions
- [ ] Daily stats reset

### Services
- [ ] `MonitoringService` method calls
- [ ] `PermissionService` method calls (macOS)

## Integration Testing

### Windows Platform

#### Screenshot Capture
- [ ] Screenshot captures successfully
- [ ] File is saved to correct location
- [ ] File format is PNG
- [ ] Screenshot contains screen content
- [ ] Multiple screenshots work
- [ ] Screenshots work on multi-monitor setup

#### Window Tracking
- [ ] Active window title is captured
- [ ] Application name is correct
- [ ] Updates when switching windows
- [ ] Handles windows with no title
- [ ] Works with all application types

#### Input Monitoring
- [ ] Keystroke count increments
- [ ] Mouse click count increments
- [ ] Counts reset after reading
- [ ] Works in all applications
- [ ] No keylogger false positives from antivirus

#### Idle Detection
- [ ] Detects idle state correctly
- [ ] Threshold is respected
- [ ] Returns to active state on input
- [ ] Works with different threshold values

#### System Tray
- [ ] App minimizes to tray
- [ ] Tray icon is visible
- [ ] Tray menu works
- [ ] Restore from tray works
- [ ] Exit from tray works

### macOS Platform

#### Permissions
- [ ] Screen Recording permission check works
- [ ] Accessibility permission check works
- [ ] Permission request dialogs appear
- [ ] System Preferences opens correctly
- [ ] App detects when permissions granted
- [ ] App handles denied permissions gracefully

#### Screenshot Capture
- [ ] Screenshot captures successfully (with permission)
- [ ] File is saved to correct location
- [ ] File format is PNG
- [ ] Screenshot contains screen content
- [ ] Multiple screenshots work
- [ ] Works on Retina displays
- [ ] Multi-monitor support

#### Window Tracking
- [ ] Active window title is captured
- [ ] Application name is correct
- [ ] Updates when switching windows
- [ ] Works with all application types
- [ ] Handles system applications

#### Input Monitoring
- [ ] Keystroke count increments (with permission)
- [ ] Mouse click count increments (with permission)
- [ ] Counts reset after reading
- [ ] Event tap works correctly
- [ ] No performance impact

#### Idle Detection
- [ ] Detects idle state correctly
- [ ] Threshold is respected
- [ ] Returns to active state on input
- [ ] Works with different threshold values

#### Menu Bar
- [ ] App shows in menu bar
- [ ] Menu bar icon is visible
- [ ] Menu works correctly
- [ ] Status updates in menu

## UI Testing

### Home Screen
- [ ] Displays correctly on launch
- [ ] Permission status shown (macOS)
- [ ] Monitoring toggle works
- [ ] Status indicator updates
- [ ] Current app name displays
- [ ] Statistics update in real-time
- [ ] Activity log populates
- [ ] Activity log scrolls correctly
- [ ] Settings button navigates correctly

### Settings Screen
- [ ] Opens from home screen
- [ ] All toggles work
- [ ] Text fields accept input
- [ ] Interval validation works
- [ ] Save button works
- [ ] Settings persist after restart
- [ ] Back button works
- [ ] Changes apply immediately

### Permission Screen (macOS)
- [ ] Shows permission status
- [ ] Permission items update
- [ ] Open System Preferences button works
- [ ] Recheck button works
- [ ] UI updates when permissions granted

## Functional Testing

### Monitoring Workflow
- [ ] Start monitoring from UI
- [ ] Screenshots captured at intervals
- [ ] Activity logs created
- [ ] Statistics increment
- [ ] Stop monitoring works
- [ ] Resume monitoring works
- [ ] Data persists between sessions

### Configuration
- [ ] Change screenshot interval
- [ ] Disable screenshot capture
- [ ] Disable keystroke tracking
- [ ] Disable mouse tracking
- [ ] Disable application tracking
- [ ] Changes take effect immediately
- [ ] Settings saved correctly

### Data Management
- [ ] Activity logs stored correctly
- [ ] Screenshots stored in correct location
- [ ] Old data can be cleared
- [ ] Data export works (if implemented)
- [ ] Data doesn't exceed storage limits

## Performance Testing

### Resource Usage
- [ ] CPU usage < 5% when idle
- [ ] CPU usage < 10% when capturing
- [ ] Memory usage < 200MB
- [ ] No memory leaks over time
- [ ] Disk I/O is reasonable
- [ ] Network usage is minimal

### Responsiveness
- [ ] UI remains responsive during capture
- [ ] No lag when switching screens
- [ ] Activity log scrolls smoothly
- [ ] Settings changes apply quickly
- [ ] App starts quickly (< 3 seconds)

### Stability
- [ ] No crashes during normal operation
- [ ] Handles errors gracefully
- [ ] Recovers from permission denial
- [ ] Handles disk full scenario
- [ ] Handles network errors
- [ ] Runs for 24+ hours without issues

## Security Testing

### Data Protection
- [ ] Screenshots stored securely
- [ ] API keys encrypted
- [ ] No sensitive data in logs
- [ ] HTTPS used for API calls
- [ ] Credentials not in memory dumps

### Access Control
- [ ] Settings require authentication (if implemented)
- [ ] Cannot disable monitoring without auth
- [ ] Configuration changes logged
- [ ] Tamper detection works (if implemented)

## Compatibility Testing

### Windows Versions
- [ ] Windows 10 (21H2)
- [ ] Windows 10 (22H2)
- [ ] Windows 11 (21H2)
- [ ] Windows 11 (22H2)
- [ ] Windows 11 (23H2)

### macOS Versions
- [ ] macOS 10.15 (Catalina)
- [ ] macOS 11 (Big Sur)
- [ ] macOS 12 (Monterey)
- [ ] macOS 13 (Ventura)
- [ ] macOS 14 (Sonoma)
- [ ] macOS 15 (Sequoia)

### Screen Resolutions
- [ ] 1920x1080 (Full HD)
- [ ] 2560x1440 (2K)
- [ ] 3840x2160 (4K)
- [ ] Retina displays (macOS)
- [ ] Multi-monitor setups

### Hardware
- [ ] Intel processors
- [ ] AMD processors
- [ ] Apple Silicon (M1/M2/M3)
- [ ] Low-end hardware (4GB RAM)
- [ ] High-end hardware (16GB+ RAM)

## Edge Cases

### Error Scenarios
- [ ] No internet connection
- [ ] Server unreachable
- [ ] Invalid API key
- [ ] Disk full
- [ ] Permissions revoked during operation
- [ ] System sleep/wake
- [ ] User logout/login
- [ ] Fast user switching

### Boundary Conditions
- [ ] Screenshot interval = 1 second
- [ ] Screenshot interval = 1 hour
- [ ] 1000+ activity logs
- [ ] Very long window titles
- [ ] Special characters in window titles
- [ ] Non-English characters
- [ ] Empty/null values

### Stress Testing
- [ ] Rapid window switching
- [ ] Continuous keyboard input
- [ ] Continuous mouse input
- [ ] Multiple screenshots in quick succession
- [ ] Long running session (24+ hours)
- [ ] High system load

## Deployment Testing

### Installation
- [ ] Fresh install works
- [ ] Upgrade from previous version works
- [ ] Uninstall removes all files
- [ ] Reinstall works after uninstall
- [ ] Silent install works (enterprise)

### Auto-start
- [ ] Starts on system boot
- [ ] Starts minimized
- [ ] Monitoring starts automatically
- [ ] Settings preserved after restart

### Updates
- [ ] Update check works
- [ ] Update download works
- [ ] Update installation works
- [ ] Settings preserved after update
- [ ] Data preserved after update

## User Acceptance Testing

### Usability
- [ ] UI is intuitive
- [ ] Icons are clear
- [ ] Text is readable
- [ ] Colors are appropriate
- [ ] Layout is logical
- [ ] Navigation is easy

### Documentation
- [ ] README is clear
- [ ] Setup guide is accurate
- [ ] Deployment guide is complete
- [ ] Troubleshooting helps
- [ ] Screenshots are current

### User Feedback
- [ ] Employees understand monitoring
- [ ] Managers can access data
- [ ] IT can deploy easily
- [ ] Support requests are minimal

## Compliance Testing

### Legal
- [ ] Privacy policy displayed
- [ ] Consent mechanism works
- [ ] Data retention policy enforced
- [ ] User can access their data
- [ ] User can request deletion

### Regulatory
- [ ] GDPR compliance (if applicable)
- [ ] CCPA compliance (if applicable)
- [ ] Industry-specific compliance
- [ ] Audit trail maintained

## Final Checklist

### Before Release
- [ ] All critical bugs fixed
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Code signed (Windows/macOS)
- [ ] Notarized (macOS)
- [ ] Installers created
- [ ] Release notes written
- [ ] Support plan in place

### Post-Release
- [ ] Monitor crash reports
- [ ] Track user feedback
- [ ] Monitor performance metrics
- [ ] Plan updates and fixes

## Test Results

### Test Summary
- Total Tests: ___
- Passed: ___
- Failed: ___
- Blocked: ___
- Not Tested: ___

### Critical Issues
1. 
2. 
3. 

### Known Limitations
1. 
2. 
3. 

### Sign-off

**Tested By:** _______________
**Date:** _______________
**Version:** _______________
**Platform:** _______________
**Status:** ☐ Pass ☐ Fail ☐ Pass with Issues

---

## Notes

Use this checklist for each release and platform. Document any issues found and track them in your issue tracking system.
