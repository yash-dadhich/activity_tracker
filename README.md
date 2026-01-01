# Activity Tracker - Enterprise Employee Monitoring

A cross-platform desktop application for monitoring employee activity on Windows and macOS.

## Features

- **Screenshot Capture**: Automatic screenshots at configurable intervals
- **Active Window Tracking**: Monitor which applications and windows are active
- **Keyboard & Mouse Activity**: Track keystrokes and mouse clicks
- **Idle Detection**: Detect when the system is idle
- **System Tray Widget**: Minimizes to system tray for unobtrusive monitoring
- **Configurable Settings**: Customize monitoring intervals and features
- **Data Encryption**: Secure data transmission to server

## Platform Support

| Platform | Status | Features |
|----------|--------|----------|
| Windows  | ✅ Full Support | All features available |
| macOS    | ✅ Full Support | Requires explicit permissions |
| Linux    | 🚧 Planned | Coming soon |
| iOS      | ❌ Not Supported | Platform limitations |
| Web      | ❌ Not Supported | Browser sandbox restrictions |

## Requirements

### Windows
- Windows 10 or later (64-bit)
- No special permissions required

### macOS
- macOS 10.15 (Catalina) or later
- **Required Permissions:**
  - Screen Recording Permission
  - Accessibility Permission

## Installation

### Windows
1. Download the installer (`.exe` or `.msi`)
2. Run the installer
3. Launch the application

### macOS
1. Download the `.dmg` file
2. Drag the app to Applications folder
3. On first launch, grant required permissions:
   - Go to System Preferences → Security & Privacy → Privacy
   - Enable "Screen Recording" for Activity Tracker
   - Enable "Accessibility" for Activity Tracker
4. Restart the application

## Configuration

### Monitoring Settings

- **Screenshot Interval**: Set how often screenshots are captured (default: 5 minutes)
- **Keystroke Tracking**: Enable/disable keyboard activity monitoring
- **Mouse Tracking**: Enable/disable mouse activity monitoring
- **Application Tracking**: Enable/disable active application tracking

### Server Configuration

Configure the backend server URL and API key in Settings:
- **Server URL**: Your backend API endpoint
- **API Key**: Authentication key for secure communication

## Usage

1. **Start Monitoring**: Toggle the monitoring switch on the home screen
2. **View Activity**: See real-time activity logs and statistics
3. **Configure Settings**: Adjust monitoring parameters in Settings
4. **System Tray**: Minimize to system tray for background operation

## Privacy & Compliance

⚠️ **Important Legal Notice**

This software is designed for **enterprise employee monitoring** purposes. Before deployment:

1. **Employee Consent**: Ensure employees are informed and provide written consent
2. **Legal Compliance**: Verify compliance with local labor laws and regulations
3. **Data Protection**: Comply with GDPR, CCPA, and other privacy regulations
4. **Transparency**: Clearly communicate what is being monitored and why

### Recommended Practices

- Provide clear written notice to employees
- Obtain explicit consent before installation
- Use monitoring data only for legitimate business purposes
- Implement data retention policies
- Secure all collected data with encryption
- Provide employees access to their monitoring data

## Development

### Prerequisites

```bash
flutter --version  # Flutter 3.10.0 or later
```

### Setup

```bash
# Install dependencies
flutter pub get

# Run on Windows
flutter run -d windows

# Run on macOS
flutter run -d macos

# Build for production
flutter build windows --release
flutter build macos --release
```

### Architecture

```
lib/
├── models/          # Data models
├── services/        # Platform services
├── providers/       # State management
├── screens/         # UI screens
└── main.dart        # Entry point

windows/runner/      # Windows native code (C++)
macos/Runner/        # macOS native code (Swift)
```

## Troubleshooting

### macOS: Permissions Not Working

1. Open System Preferences → Security & Privacy
2. Go to Privacy tab
3. Select "Screen Recording" and "Accessibility"
4. Check the box next to Activity Tracker
5. Restart the application

### Windows: Screenshots Not Capturing

1. Check if antivirus is blocking the application
2. Run as Administrator (if required)
3. Verify disk space is available

### Data Not Uploading

1. Check server URL in Settings
2. Verify API key is correct
3. Check network connectivity
4. Review application logs

## License

Proprietary - Enterprise Use Only

## Support

For enterprise support and licensing inquiries, contact your IT administrator.

## Disclaimer

This software is provided for legitimate business purposes only. Misuse of this software for unauthorized surveillance or privacy violations is strictly prohibited and may be illegal in your jurisdiction.
