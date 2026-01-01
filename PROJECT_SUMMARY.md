# Activity Tracker - Project Summary

## 🎯 Project Overview

**Activity Tracker** is an enterprise-grade employee monitoring application built with Flutter for Windows and macOS desktop platforms. It captures screenshots, tracks active applications, monitors keyboard/mouse activity, and detects system idle time.

## ✨ Key Features

### Core Monitoring Capabilities
- ✅ **Screenshot Capture** - Automatic screenshots at configurable intervals
- ✅ **Active Window Tracking** - Real-time monitoring of active applications and window titles
- ✅ **Keyboard Activity** - Keystroke counting (not keylogging - counts only)
- ✅ **Mouse Activity** - Mouse click tracking
- ✅ **Idle Detection** - Automatic detection of user inactivity
- ✅ **System Tray Integration** - Minimizes to system tray for background operation

### User Interface
- ✅ **Dashboard** - Real-time activity statistics and status
- ✅ **Activity Log** - Historical view of tracked activities
- ✅ **Settings Panel** - Configurable monitoring parameters
- ✅ **Permission Manager** - macOS permission status and requests

### Configuration
- ✅ **Flexible Settings** - Adjust intervals, enable/disable features
- ✅ **Server Integration** - Configure backend API endpoint
- ✅ **Secure Storage** - Encrypted API keys and credentials

## 🏗️ Architecture

### Technology Stack
- **Framework:** Flutter 3.10+
- **Language:** Dart (UI), C++ (Windows), Swift (macOS)
- **State Management:** Provider pattern
- **Platform Channels:** Method channels for native integration

### Project Structure
```
poc_activity_tracker/
├── lib/                          # Flutter/Dart code
│   ├── main.dart                 # Application entry point
│   ├── models/                   # Data models
│   ├── providers/                # State management
│   ├── screens/                  # UI screens
│   └── services/                 # Business logic
├── windows/runner/               # Windows native code (C++)
├── macos/Runner/                 # macOS native code (Swift)
├── assets/                       # Images, icons, resources
└── docs/                         # Documentation
```

### Native Implementations

#### Windows (C++)
- **API Used:** Win32 API, GDI+
- **Screenshot:** `BitBlt`, `CreateCompatibleBitmap`
- **Window Tracking:** `GetForegroundWindow`, `GetWindowText`
- **Input Monitoring:** `SetWindowsHookEx` (keyboard/mouse hooks)
- **Idle Detection:** `GetLastInputInfo`

#### macOS (Swift)
- **API Used:** Cocoa, Core Graphics, ApplicationServices
- **Screenshot:** `CGDisplayCreateImage`
- **Window Tracking:** `NSWorkspace`, `CGWindowListCopyWindowInfo`
- **Input Monitoring:** `CGEvent.tapCreate` (event tap)
- **Idle Detection:** `CGEventSource.secondsSinceLastEventType`

## 📋 Platform Support Matrix

| Feature | Windows | macOS | Notes |
|---------|---------|-------|-------|
| Screenshot Capture | ✅ Full | ✅ Full | Requires Screen Recording permission on macOS |
| Window Tracking | ✅ Full | ✅ Full | Works out of box |
| Keyboard Tracking | ✅ Full | ✅ Full | Requires Accessibility permission on macOS |
| Mouse Tracking | ✅ Full | ✅ Full | Requires Accessibility permission on macOS |
| Idle Detection | ✅ Full | ✅ Full | Works out of box |
| System Tray | ✅ Full | ✅ Full | Menu bar on macOS |
| Auto-start | ✅ Full | ✅ Full | Via registry/login items |
| Background Mode | ✅ Full | ✅ Full | Runs in background |

## 🔐 Security & Privacy

### Data Protection
- Screenshots stored locally before upload
- API communication over HTTPS
- Encrypted credential storage
- Secure token-based authentication

### Compliance Features
- User notification system
- Configurable data retention
- Audit logging
- Privacy policy integration

### macOS Permissions
**Required:**
- Screen Recording (for screenshots)
- Accessibility (for input monitoring)

**Requested at runtime with clear explanations**

### Windows Permissions
- No special permissions required
- May require admin rights for installation
- Some antivirus software may flag hooks (false positive)

## 🚀 Deployment Options

### Distribution Methods

#### Windows
1. **Direct Download** - Standalone EXE with dependencies
2. **MSI Installer** - Windows Installer package
3. **Group Policy** - Enterprise GPO deployment
4. **SCCM/Intune** - Microsoft Endpoint Manager

#### macOS
1. **Direct Download** - DMG disk image
2. **PKG Installer** - macOS installer package
3. **MDM Deployment** - Jamf, Intune, Workspace ONE
4. **Configuration Profiles** - Pre-approve permissions

### Code Signing

#### Windows
- Optional but recommended
- Use DigiCert, Sectigo, or similar CA
- Prevents SmartScreen warnings

#### macOS
- **Required for distribution**
- Apple Developer Account needed ($99/year)
- Notarization required for macOS 10.15+
- Prevents "damaged app" errors

## 📊 Use Cases

### Primary Use Case: Enterprise Employee Monitoring
- Track employee productivity
- Monitor application usage
- Ensure compliance with company policies
- Generate activity reports

### Deployment Scenarios
1. **Remote Workers** - Monitor work-from-home employees
2. **Office Environments** - Track in-office productivity
3. **Contractors** - Verify billable hours
4. **Compliance** - Ensure regulatory compliance

## ⚖️ Legal Considerations

### Requirements
✅ **Employee Notification** - Must inform employees of monitoring
✅ **Written Consent** - Obtain explicit consent before deployment
✅ **Privacy Policy** - Clear documentation of data collection
✅ **Data Protection** - Comply with GDPR, CCPA, etc.
✅ **Purpose Limitation** - Use data only for stated purposes

### Restrictions
❌ **Personal Devices** - Generally not allowed without consent
❌ **Off-Hours Monitoring** - May be restricted by law
❌ **Sensitive Data** - Healthcare, financial data may have special rules
❌ **Keylogging** - Some jurisdictions ban keystroke logging

## 🛠️ Development Workflow

### Setup (5 minutes)
```bash
git clone <repository>
cd poc_activity_tracker
flutter pub get
flutter run -d windows  # or macos
```

### Build (2 minutes)
```bash
flutter build windows --release
flutter build macos --release
```

### Test
```bash
flutter test
```

## 📈 Future Enhancements

### Planned Features
- [ ] Web dashboard for managers
- [ ] Real-time activity streaming
- [ ] AI-powered productivity insights
- [ ] Application categorization
- [ ] Time tracking reports
- [ ] Screenshot OCR for content analysis
- [ ] Multi-monitor support
- [ ] Video recording option
- [ ] Webcam capture
- [ ] Network activity monitoring

### Platform Expansion
- [ ] Linux support
- [ ] Mobile companion app (view-only)
- [ ] Browser extension

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview and features |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Development environment setup |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Production deployment guide |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Quick command reference |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | This document |

## 🎓 Learning Resources

### Flutter
- [Flutter Documentation](https://docs.flutter.dev)
- [Flutter Desktop](https://docs.flutter.dev/desktop)
- [Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)

### Windows Development
- [Win32 API](https://learn.microsoft.com/en-us/windows/win32/)
- [Windows Hooks](https://learn.microsoft.com/en-us/windows/win32/winmsg/hooks)
- [GDI+](https://learn.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-gdi-start)

### macOS Development
- [macOS Developer](https://developer.apple.com/macos/)
- [Core Graphics](https://developer.apple.com/documentation/coregraphics)
- [Accessibility](https://developer.apple.com/documentation/accessibility)

## 🤝 Contributing

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Comment complex logic
- Write unit tests for new features

### Pull Request Process
1. Fork the repository
2. Create feature branch
3. Implement changes
4. Add tests
5. Update documentation
6. Submit pull request

## 📞 Support

### For Developers
- Review documentation in `/docs`
- Check troubleshooting sections
- Review platform-specific guides

### For IT Administrators
- See DEPLOYMENT.md for deployment guides
- Check MDM integration documentation
- Review security best practices

### For End Users
- Contact your IT department
- Review company monitoring policy
- Check privacy policy

## 📊 Project Statistics

- **Lines of Code:** ~3,000+ (Dart + Native)
- **Files:** 20+ source files
- **Platforms:** 2 (Windows, macOS)
- **Dependencies:** 15+ packages
- **Development Time:** ~40 hours (initial version)

## 🏆 Key Achievements

✅ Cross-platform desktop monitoring
✅ Native performance with Flutter UI
✅ Enterprise-ready architecture
✅ Comprehensive documentation
✅ Security-first design
✅ MDM deployment support
✅ Configurable and extensible

## 🔄 Version History

### v1.0.0 (Current)
- Initial release
- Windows and macOS support
- Core monitoring features
- Basic UI and settings
- Permission management
- Documentation complete

## 📝 License

**Proprietary - Enterprise Use Only**

This software is designed for enterprise employee monitoring and is subject to:
- Company policies
- Local labor laws
- Privacy regulations
- Employee consent requirements

## ⚠️ Disclaimer

This software is provided for legitimate business purposes only. Users are responsible for:
- Obtaining proper employee consent
- Complying with applicable laws
- Protecting collected data
- Using data ethically and legally

Misuse of this software for unauthorized surveillance or privacy violations is strictly prohibited and may be illegal in your jurisdiction.

---

**Built with Flutter 💙**

For questions or support, contact your development team or IT administrator.
