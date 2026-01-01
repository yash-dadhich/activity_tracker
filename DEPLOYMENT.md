# Deployment Guide - Activity Tracker

## Overview

This guide covers deploying the Activity Tracker application for enterprise use on Windows and macOS.

## Prerequisites

### Windows
- Windows 10/11 (64-bit)
- Visual Studio 2019+ with C++ tools
- Flutter SDK 3.10+
- Code signing certificate (optional but recommended)

### macOS
- macOS 10.15+ (Catalina or later)
- Xcode 13+
- Flutter SDK 3.10+
- Apple Developer Account ($99/year for code signing)

## Building for Production

### Windows Production Build

```bash
# Clean previous builds
flutter clean

# Build release version
flutter build windows --release

# Output location:
# build/windows/runner/Release/
```

**Files to distribute:**
- `poc_activity_tracker.exe` - Main executable
- `flutter_windows.dll` - Flutter runtime
- `data/` folder - Assets and resources

### macOS Production Build

```bash
# Clean previous builds
flutter clean

# Build release version
flutter build macos --release

# Output location:
# build/macos/Build/Products/Release/poc_activity_tracker.app
```

## Code Signing

### Windows Code Signing

1. **Obtain a Code Signing Certificate:**
   - Purchase from DigiCert, Sectigo, or similar CA
   - Or use self-signed for internal deployment

2. **Sign the Executable:**
   ```powershell
   signtool sign /f "certificate.pfx" /p "password" /t http://timestamp.digicert.com "poc_activity_tracker.exe"
   ```

3. **Verify Signature:**
   ```powershell
   signtool verify /pa "poc_activity_tracker.exe"
   ```

### macOS Code Signing & Notarization

1. **Sign the Application:**
   ```bash
   codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" --options runtime "poc_activity_tracker.app"
   ```

2. **Create a ZIP for Notarization:**
   ```bash
   ditto -c -k --keepParent "poc_activity_tracker.app" "poc_activity_tracker.zip"
   ```

3. **Submit for Notarization:**
   ```bash
   xcrun notarytool submit "poc_activity_tracker.zip" \
     --apple-id "your@email.com" \
     --team-id "TEAM_ID" \
     --password "app-specific-password" \
     --wait
   ```

4. **Staple the Notarization:**
   ```bash
   xcrun stapler staple "poc_activity_tracker.app"
   ```

5. **Verify:**
   ```bash
   spctl -a -vvv -t install "poc_activity_tracker.app"
   ```

## Creating Installers

### Windows Installer (MSI)

Using WiX Toolset:

1. **Install WiX Toolset:**
   ```powershell
   choco install wixtoolset
   ```

2. **Create installer.wxs:**
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
     <Product Id="*" Name="Activity Tracker" Language="1033" 
              Version="1.0.0.0" Manufacturer="Your Company" 
              UpgradeCode="YOUR-GUID-HERE">
       <Package InstallerVersion="200" Compressed="yes" 
                InstallScope="perMachine" />
       
       <MajorUpgrade DowngradeErrorMessage="A newer version is already installed." />
       <MediaTemplate EmbedCab="yes" />
       
       <Feature Id="ProductFeature" Title="Activity Tracker" Level="1">
         <ComponentGroupRef Id="ProductComponents" />
       </Feature>
     </Product>
     
     <Fragment>
       <Directory Id="TARGETDIR" Name="SourceDir">
         <Directory Id="ProgramFilesFolder">
           <Directory Id="INSTALLFOLDER" Name="Activity Tracker" />
         </Directory>
       </Directory>
     </Fragment>
     
     <Fragment>
       <ComponentGroup Id="ProductComponents" Directory="INSTALLFOLDER">
         <!-- Add your files here -->
       </ComponentGroup>
     </Fragment>
   </Wix>
   ```

3. **Build the installer:**
   ```powershell
   candle installer.wxs
   light installer.wixobj -out ActivityTracker.msi
   ```

### macOS Installer (PKG)

1. **Create a PKG:**
   ```bash
   productbuild --component "poc_activity_tracker.app" /Applications \
     --sign "Developer ID Installer: Your Name" \
     "ActivityTracker.pkg"
   ```

2. **Notarize the PKG:**
   ```bash
   xcrun notarytool submit "ActivityTracker.pkg" \
     --apple-id "your@email.com" \
     --team-id "TEAM_ID" \
     --password "app-specific-password" \
     --wait
   
   xcrun stapler staple "ActivityTracker.pkg"
   ```

### macOS DMG (Alternative)

```bash
# Create DMG
hdiutil create -volname "Activity Tracker" -srcfolder "poc_activity_tracker.app" \
  -ov -format UDZO "ActivityTracker.dmg"

# Sign DMG
codesign --sign "Developer ID Application: Your Name" "ActivityTracker.dmg"

# Notarize DMG
xcrun notarytool submit "ActivityTracker.dmg" \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait

xcrun stapler staple "ActivityTracker.dmg"
```

## Enterprise Deployment

### Windows - Group Policy Deployment

1. **Create MSI installer** (see above)

2. **Deploy via GPO:**
   - Open Group Policy Management
   - Create new GPO or edit existing
   - Navigate to: Computer Configuration → Policies → Software Settings → Software Installation
   - Right-click → New → Package
   - Select your MSI file
   - Choose "Assigned" deployment method

3. **Configure startup:**
   - Add registry key for auto-start:
   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
   Name: ActivityTracker
   Value: "C:\Program Files\Activity Tracker\poc_activity_tracker.exe"
   ```

### Windows - SCCM/Intune Deployment

1. **Package the application:**
   - Create MSI or MSIX package
   - Include all dependencies

2. **Deploy via Intune:**
   - Microsoft Endpoint Manager admin center
   - Apps → Windows → Add
   - Upload MSI/MSIX
   - Configure assignments and requirements

### macOS - MDM Deployment (Jamf, Intune, etc.)

1. **Create signed PKG** (see above)

2. **Upload to MDM:**
   - Jamf Pro: Computers → Packages → Upload
   - Intune: Apps → macOS → Add → Line-of-business app

3. **Create Configuration Profile:**
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
     <key>PayloadContent</key>
     <array>
       <dict>
         <key>PayloadType</key>
         <string>com.apple.TCC.configuration-profile-policy</string>
         <key>Services</key>
         <dict>
           <key>ScreenCapture</key>
           <array>
             <dict>
               <key>Allowed</key>
               <true/>
               <key>CodeRequirement</key>
               <string>identifier "com.yourcompany.activitytracker"</string>
             </dict>
           </array>
           <key>Accessibility</key>
           <array>
             <dict>
               <key>Allowed</key>
               <true/>
               <key>CodeRequirement</key>
               <string>identifier "com.yourcompany.activitytracker"</string>
             </dict>
           </array>
         </dict>
       </dict>
     </array>
   </dict>
   </plist>
   ```

4. **Deploy to devices:**
   - Assign to computer groups
   - Set as required installation

## Configuration Management

### Centralized Configuration

Create a configuration file that can be deployed via MDM:

**config.json:**
```json
{
  "serverUrl": "https://api.yourcompany.com/activity",
  "apiKey": "ENCRYPTED_API_KEY",
  "screenshotInterval": 300,
  "screenshotEnabled": true,
  "keystrokeTracking": true,
  "mouseTracking": true,
  "applicationTracking": true,
  "idleThreshold": 300,
  "allowUserDisable": false,
  "uploadInterval": 600
}
```

**Deployment locations:**
- Windows: `C:\ProgramData\ActivityTracker\config.json`
- macOS: `/Library/Application Support/ActivityTracker/config.json`

### Registry/Preferences Management

**Windows Registry:**
```reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\ActivityTracker]
"ServerUrl"="https://api.yourcompany.com/activity"
"ApiKey"="YOUR_API_KEY"
"ScreenshotInterval"=dword:0000012c
"AllowUserDisable"=dword:00000000
```

**macOS Preferences:**
```bash
sudo defaults write /Library/Preferences/com.yourcompany.activitytracker ServerUrl "https://api.yourcompany.com/activity"
sudo defaults write /Library/Preferences/com.yourcompany.activitytracker ApiKey "YOUR_API_KEY"
sudo defaults write /Library/Preferences/com.yourcompany.activitytracker ScreenshotInterval -int 300
```

## Auto-Update Mechanism

### Windows - Squirrel.Windows

1. **Add Squirrel.Windows to project**
2. **Create update server**
3. **Implement update check in app:**
   ```dart
   Future<void> checkForUpdates() async {
     // Call native method to check for updates
     final bool updateAvailable = await platform.invokeMethod('checkUpdates');
     if (updateAvailable) {
       // Download and install update
     }
   }
   ```

### macOS - Sparkle Framework

1. **Integrate Sparkle framework**
2. **Create appcast.xml:**
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
     <channel>
       <title>Activity Tracker Updates</title>
       <item>
         <title>Version 1.0.1</title>
         <sparkle:version>1.0.1</sparkle:version>
         <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
         <enclosure url="https://yourserver.com/ActivityTracker-1.0.1.dmg" 
                    sparkle:edSignature="SIGNATURE" 
                    type="application/octet-stream"/>
       </item>
     </channel>
   </rss>
   ```

## Monitoring & Logging

### Application Logs

**Windows:** `%APPDATA%\ActivityTracker\logs\`
**macOS:** `~/Library/Logs/ActivityTracker/`

### Centralized Logging

Implement logging to your backend:
```dart
Future<void> sendLog(String level, String message) async {
  await http.post(
    Uri.parse('${config.serverUrl}/logs'),
    headers: {'Authorization': 'Bearer ${config.apiKey}'},
    body: jsonEncode({
      'level': level,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'deviceId': await getDeviceId(),
    }),
  );
}
```

## Security Best Practices

1. **Encrypt API Keys:**
   - Never store plain text API keys
   - Use platform keychain/credential manager

2. **Secure Communication:**
   - Use HTTPS only
   - Implement certificate pinning
   - Validate server certificates

3. **Data Protection:**
   - Encrypt screenshots before upload
   - Use AES-256 encryption
   - Implement secure key exchange

4. **Access Control:**
   - Require admin rights for installation
   - Prevent user from disabling monitoring
   - Log all configuration changes

5. **Tamper Detection:**
   - Verify application integrity
   - Detect debugger attachment
   - Monitor for process termination

## Compliance Checklist

- [ ] Employee notification and consent obtained
- [ ] Privacy policy created and distributed
- [ ] Data retention policy defined
- [ ] GDPR/CCPA compliance verified
- [ ] Legal review completed
- [ ] IT security approval obtained
- [ ] Incident response plan created
- [ ] Data breach notification process defined

## Rollback Plan

### Windows
1. Keep previous MSI version
2. Deploy via GPO: `msiexec /x {PRODUCT_CODE} /qn`
3. Install previous version

### macOS
1. Keep previous PKG version
2. Remove current: `sudo rm -rf /Applications/poc_activity_tracker.app`
3. Install previous version

## Support & Maintenance

### Monitoring Deployment

- Track installation success rate
- Monitor application crashes
- Review user feedback
- Check server logs for errors

### Regular Updates

- Security patches: Monthly
- Feature updates: Quarterly
- Major versions: Annually

## Troubleshooting Deployment

### Windows Issues

**Problem:** MSI installation fails
**Solution:** Check Windows Installer logs: `%TEMP%\MSI*.log`

**Problem:** App doesn't start after deployment
**Solution:** Verify all DLLs are included, check Event Viewer

### macOS Issues

**Problem:** "App is damaged" error
**Solution:** Re-sign and notarize the application

**Problem:** Permissions not pre-approved via MDM
**Solution:** Verify Configuration Profile is correctly deployed

## Contact

For deployment support:
- IT Support: support@yourcompany.com
- Documentation: https://docs.yourcompany.com/activity-tracker
- Emergency: +1-XXX-XXX-XXXX
