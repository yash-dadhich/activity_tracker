# How to Build Windows App (From Your Mac)

Since you're currently on macOS, you have a few options to build the Windows version:

## Option 1: Use a Windows Machine (Recommended)

### Step 1: Transfer Project to Windows

**Method A: Using Git**
```bash
# On Mac: Push to Git
git add .
git commit -m "Ready for Windows build"
git push

# On Windows: Clone
git clone <your-repo-url>
cd poc_activity_tracker
```

**Method B: Using ZIP**
```bash
# On Mac: Create ZIP
zip -r poc_activity_tracker.zip . -x "*.git*" -x "*build/*" -x "*.dart_tool/*"

# Transfer ZIP to Windows via:
# - USB drive
# - Email
# - Cloud storage (Google Drive, Dropbox, etc.)
# - Network share

# On Windows: Extract ZIP
```

### Step 2: Install Prerequisites on Windows

1. **Install Flutter:**
   - Download from: https://docs.flutter.dev/get-started/install/windows
   - Extract to `C:\flutter`
   - Add to PATH: `C:\flutter\bin`

2. **Install Visual Studio 2022:**
   - Download Community Edition (free)
   - Install "Desktop development with C++" workload
   - Install Windows 10 SDK

3. **Verify installation:**
   ```cmd
   flutter doctor
   ```

### Step 3: Build on Windows

```cmd
# Navigate to project
cd poc_activity_tracker

# Run the build script
build_windows_portable.bat
```

### Step 4: Get the ZIP File

The script creates: `ActivityTracker_Windows_Portable.zip`

Transfer this back to your Mac or share it directly.

---

## Option 2: Use Windows VM on Mac

### Using Parallels Desktop

1. **Install Parallels Desktop** (paid, ~$100/year)
2. **Create Windows 11 VM**
3. **Install Flutter and Visual Studio** in the VM
4. **Share Mac folder** with VM
5. **Build in the VM**

### Using VMware Fusion

1. **Install VMware Fusion** (paid, ~$200)
2. **Create Windows 11 VM**
3. **Install prerequisites**
4. **Build in the VM**

### Using VirtualBox (Free)

1. **Install VirtualBox** (free)
2. **Create Windows 11 VM**
3. **Install prerequisites**
4. **Build in the VM**

**Note:** VirtualBox is slower but free.

---

## Option 3: Use Cloud Build Service

### GitHub Actions (Free for public repos)

Create `.github/workflows/build-windows.yml`:

```yaml
name: Build Windows

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build Windows
      run: flutter build windows --release
    
    - name: Create portable package
      run: |
        mkdir ActivityTracker_Windows_Portable
        xcopy /E /I /Y "build\windows\x64\runner\Release\*" "ActivityTracker_Windows_Portable\"
    
    - name: Create ZIP
      run: Compress-Archive -Path "ActivityTracker_Windows_Portable\*" -DestinationPath "ActivityTracker_Windows_Portable.zip"
    
    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: windows-portable
        path: ActivityTracker_Windows_Portable.zip
```

**Then:**
1. Push to GitHub
2. Go to Actions tab
3. Download the built ZIP file

---

## Option 4: Ask Someone with Windows

If you have a colleague or friend with Windows:

1. **Send them the project** (ZIP or Git)
2. **Send them these instructions:**
   - Install Flutter
   - Install Visual Studio
   - Run `build_windows_portable.bat`
3. **They send you back** the ZIP file

---

## Option 5: Use Remote Windows Machine

### AWS WorkSpaces

1. **Create Windows WorkSpace** (~$25/month)
2. **Connect from Mac**
3. **Install prerequisites**
4. **Build the app**
5. **Download the ZIP**

### Azure Virtual Desktop

Similar to AWS WorkSpaces.

### Paperspace

Cloud Windows desktop (~$10/month).

---

## Recommended Approach

**For one-time build:**
- Use GitHub Actions (free, automated)
- Or ask someone with Windows

**For regular development:**
- Use Parallels Desktop (best performance)
- Or use a physical Windows machine

---

## What You Need to Send

If someone else is building for you, send them:

1. **The project files** (ZIP or Git repo)
2. **This file:** `BUILD_ON_WINDOWS.md`
3. **The build script:** `build_windows_portable.bat`
4. **Instructions:** "Just run build_windows_portable.bat"

They'll send you back: `ActivityTracker_Windows_Portable.zip`

---

## Alternative: Pre-built Version

If you can't build on Windows right now, I can provide you with:

1. **Build instructions** for when you have access to Windows
2. **GitHub Actions workflow** for automated builds
3. **Docker-based build** (advanced, requires Windows containers)

---

## Quick Start (When You Have Windows Access)

```cmd
REM 1. Install Flutter and Visual Studio
REM 2. Open Command Prompt in project folder
REM 3. Run:

build_windows_portable.bat

REM 4. Done! Share ActivityTracker_Windows_Portable.zip
```

---

## File Size

The final ZIP will be approximately:
- **Compressed:** 15-25 MB
- **Extracted:** 40-60 MB

Small enough to email or share easily.

---

## Testing Before Distribution

Before sharing the ZIP, test it on a clean Windows machine:

1. Extract to a new folder
2. Run `poc_activity_tracker.exe`
3. Verify all features work
4. Check for any missing DLL errors

---

## Need Help?

If you're stuck, you can:

1. **Use GitHub Actions** (easiest, no Windows needed)
2. **Find a Windows machine** (library, friend, work)
3. **Use a cloud Windows VM** (AWS, Azure, Paperspace)
4. **Wait until you have Windows access**

The project is ready to build - you just need a Windows environment!
