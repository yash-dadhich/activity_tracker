# Windows Build Guide - Portable Distribution

## Quick Build (Automated)

### Option 1: Using the Build Script

1. **Run the build script:**
   ```cmd
   build_windows_portable.bat
   ```

2. **Wait for completion** (takes 2-5 minutes)

3. **Find the output:**
   - Folder: `ActivityTracker_Windows_Portable/`
   - ZIP: `ActivityTracker_Windows_Portable.zip`

4. **Share the ZIP file** with other Windows users

That's it! The ZIP file contains everything needed to run the app.

---

## Manual Build (Step by Step)

If the automated script doesn't work, follow these steps:

### Step 1: Clean and Prepare

```cmd
flutter clean
flutter pub get
```

### Step 2: Build Release Version

```cmd
flutter build windows --release
```

This creates the release build in: `build\windows\x64\runner\Release\`

### Step 3: Create Portable Package

1. **Create a new folder:**
   ```cmd
   mkdir ActivityTracker_Windows_Portable
   ```

2. **Copy all files from the Release folder:**
   ```cmd
   xcopy /E /I /Y "build\windows\x64\runner\Release\*" "ActivityTracker_Windows_Portable\"
   ```

3. **The folder should contain:**
   ```
   ActivityTracker_Windows_Portable/
   ├── poc_activity_tracker.exe    (Main executable)
   ├── flutter_windows.dll         (Flutter runtime)
   ├── data/                        (Assets and resources)
   └── ... (other DLL files)
   ```

### Step 4: Create ZIP File

**Using PowerShell:**
```powershell
Compress-Archive -Path "ActivityTracker_Windows_Portable\*" -DestinationPath "ActivityTracker_Windows_Portable.zip" -Force
```

**Or using 7-Zip:**
```cmd
7z a -tzip ActivityTracker_Windows_Portable.zip ActivityTracker_Windows_Portable\*
```

**Or using Windows Explorer:**
- Right-click the folder
- Select "Send to" → "Compressed (zipped) folder"

---

## What's Included in the Package

The portable package includes:

1. **poc_activity_tracker.exe** - Main application
2. **flutter_windows.dll** - Flutter runtime library
3. **data/** folder - Application assets and resources
4. **Other DLLs** - Required system libraries

**Total size:** Approximately 15-25 MB

---

## Distribution

### Sharing the ZIP File

You can share the ZIP file via:
- Email (if size permits)
- File sharing services (Google Drive, Dropbox, OneDrive)
- Network share
- USB drive
- Internal company portal

### Installation Instructions for End Users

**Include these instructions with the ZIP file:**

```
INSTALLATION INSTRUCTIONS
=========================

1. Extract the ZIP file to any folder on your computer
   (e.g., C:\ActivityTracker or Desktop\ActivityTracker)

2. Open the extracted folder

3. Double-click "poc_activity_tracker.exe" to run

4. If Windows SmartScreen appears:
   - Click "More info"
   - Click "Run anyway"
   (This is normal for unsigned applications)

5. The application will start

NO INSTALLATION REQUIRED - Just extract and run!
```

---

## First Run Experience

### Windows SmartScreen Warning

On first run, users may see:

```
Windows protected your PC
Microsoft Defender SmartScreen prevented an unrecognized app from starting.
```

**To bypass:**
1. Click "More info"
2. Click "Run anyway"

**Why this happens:**
- The app is not digitally signed
- Windows doesn't recognize the publisher
- This is normal for unsigned applications

**To avoid this warning:**
- Purchase a code signing certificate ($200-400/year)
- Sign the executable (see Code Signing section below)

### Antivirus Warnings

Some antivirus software may flag the app because:
- It monitors keyboard/mouse activity
- It captures screenshots
- It's an unsigned executable

**Solutions:**
1. Add the app to antivirus exceptions
2. Sign the executable with a code signing certificate
3. Distribute through company-approved channels

---

## Code Signing (Optional but Recommended)

To avoid SmartScreen warnings and build trust:

### Step 1: Get a Code Signing Certificate

**Options:**
- DigiCert ($200-400/year)
- Sectigo (formerly Comodo) ($200-300/year)
- GlobalSign ($200-350/year)

### Step 2: Sign the Executable

```cmd
signtool sign /f "certificate.pfx" /p "password" /t http://timestamp.digicert.com "poc_activity_tracker.exe"
```

### Step 3: Verify Signature

```cmd
signtool verify /pa "poc_activity_tracker.exe"
```

**Benefits:**
- No SmartScreen warnings
- Users trust the application
- Professional appearance
- Required for enterprise deployment

---

## Creating an Installer (Optional)

For a more professional distribution, create an installer:

### Using Inno Setup (Free)

1. **Download Inno Setup:** https://jrsoftware.org/isinfo.php

2. **Create installer script** (`installer.iss`):
   ```iss
   [Setup]
   AppName=Activity Tracker
   AppVersion=1.0.0
   DefaultDirName={pf}\ActivityTracker
   DefaultGroupName=Activity Tracker
   OutputDir=.
   OutputBaseFilename=ActivityTracker_Setup
   
   [Files]
   Source: "ActivityTracker_Windows_Portable\*"; DestDir: "{app}"; Flags: recursesubdirs
   
   [Icons]
   Name: "{group}\Activity Tracker"; Filename: "{app}\poc_activity_tracker.exe"
   Name: "{commondesktop}\Activity Tracker"; Filename: "{app}\poc_activity_tracker.exe"
   ```

3. **Compile the installer:**
   - Open Inno Setup
   - Load the script
   - Click "Compile"

4. **Result:** `ActivityTracker_Setup.exe`

### Using WiX Toolset (Advanced)

See DEPLOYMENT.md for WiX instructions.

---

## Testing the Portable Package

Before distributing, test on a clean Windows machine:

### Test Checklist

- [ ] Extract ZIP to a new folder
- [ ] Run poc_activity_tracker.exe
- [ ] App launches without errors
- [ ] All features work:
  - [ ] Screenshot capture
  - [ ] Window tracking
  - [ ] Keyboard/mouse monitoring
  - [ ] Settings can be changed
  - [ ] Monitoring can be started/stopped
- [ ] No missing DLL errors
- [ ] No file permission errors

### Test on Different Windows Versions

- [ ] Windows 10 (21H2)
- [ ] Windows 10 (22H2)
- [ ] Windows 11 (21H2)
- [ ] Windows 11 (22H2)
- [ ] Windows 11 (23H2)

---

## Troubleshooting

### "VCRUNTIME140.dll is missing"

**Solution:** Install Visual C++ Redistributable
- Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe
- Or include the DLL in your package

### "The application was unable to start correctly (0xc000007b)"

**Solution:** 
- Ensure you're running on 64-bit Windows
- Install Visual C++ Redistributable
- Rebuild the application

### App doesn't start (no error message)

**Solution:**
- Check Windows Event Viewer for errors
- Run from command prompt to see error messages:
  ```cmd
  poc_activity_tracker.exe
  ```

### Screenshots not saving

**Solution:**
- Check folder permissions
- Run as Administrator
- Check available disk space

---

## File Size Optimization

To reduce the ZIP file size:

### 1. Remove Debug Symbols

Already done in release build.

### 2. Compress with Better Algorithm

```cmd
7z a -tzip -mx=9 ActivityTracker_Windows_Portable.zip ActivityTracker_Windows_Portable\*
```

### 3. Remove Unnecessary Files

The release build already excludes:
- Debug symbols (.pdb files)
- Development files
- Unnecessary libraries

**Final size:** ~15-25 MB (compressed)

---

## Enterprise Deployment

For deploying to multiple machines:

### Option 1: Group Policy (GPO)

1. Create MSI installer (see DEPLOYMENT.md)
2. Deploy via GPO
3. Configure auto-start

### Option 2: SCCM/Intune

1. Package as MSI or MSIX
2. Upload to SCCM/Intune
3. Deploy to device collections

### Option 3: Silent Installation

Create a silent installer script:
```cmd
@echo off
xcopy /E /I /Y "\\server\share\ActivityTracker\*" "C:\Program Files\ActivityTracker\"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "ActivityTracker" /t REG_SZ /d "C:\Program Files\ActivityTracker\poc_activity_tracker.exe" /f
```

---

## Security Considerations

### For Distribution

1. **Scan for malware** before distributing
2. **Use HTTPS** for downloads
3. **Provide checksums** (SHA256) for verification
4. **Sign the executable** with a code signing certificate

### For Users

1. **Download from trusted sources** only
2. **Verify checksums** before running
3. **Check digital signature** (if signed)
4. **Run antivirus scan** on downloaded files

---

## Support and Maintenance

### Version Updates

To update the portable version:

1. Rebuild with new version
2. Update version number in README
3. Create new ZIP file
4. Distribute to users

### User Support

Provide users with:
- Installation instructions
- Troubleshooting guide
- Contact information
- FAQ document

---

## Summary

**To create a shareable Windows package:**

1. Run `build_windows_portable.bat`
2. Share `ActivityTracker_Windows_Portable.zip`
3. Users extract and run `poc_activity_tracker.exe`

**That's it!** No installation, no admin rights, no complexity.

---

## Quick Reference

```cmd
# Build
flutter build windows --release

# Package
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "ActivityTracker_Windows_Portable\"

# ZIP
Compress-Archive -Path "ActivityTracker_Windows_Portable\*" -DestinationPath "ActivityTracker_Windows_Portable.zip" -Force

# Done!
```

**Output:** `ActivityTracker_Windows_Portable.zip` (ready to share)
