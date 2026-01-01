# Windows Portable App - Complete Guide

## 🎯 What You Get

A **portable ZIP file** containing the Activity Tracker app that can be:
- ✅ Shared with any Windows user
- ✅ Run without installation
- ✅ Extracted to any folder
- ✅ Used without admin rights (for basic features)
- ✅ Distributed via email, USB, or network share

**File:** `ActivityTracker_Windows_Portable.zip` (~15-25 MB)

---

## 🚀 Three Ways to Build

### Option 1: GitHub Actions (Easiest - No Windows Needed!)

**Perfect if you don't have a Windows machine.**

1. **Push your code to GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **GitHub will automatically build** (or trigger manually):
   - Go to your repo on GitHub
   - Click "Actions" tab
   - Click "Build Windows Portable"
   - Click "Run workflow"

3. **Download the ZIP:**
   - Wait for build to complete (~5-10 minutes)
   - Click on the completed workflow
   - Download "ActivityTracker-Windows-Portable" artifact
   - Extract the downloaded ZIP to get your portable app ZIP

**That's it!** No Windows machine needed.

---

### Option 2: Build on Windows Machine

**If you have access to a Windows computer.**

1. **Transfer project to Windows** (USB, Git, cloud storage)

2. **Install prerequisites:**
   - Flutter SDK
   - Visual Studio 2022 (Community Edition)

3. **Run the build script:**
   ```cmd
   build_windows_portable.bat
   ```

4. **Get the output:**
   - `ActivityTracker_Windows_Portable.zip`

**Time:** ~5 minutes (after prerequisites installed)

---

### Option 3: Use Windows VM on Mac

**If you want to build locally on your Mac.**

1. **Install Parallels Desktop** or VirtualBox
2. **Create Windows 11 VM**
3. **Install Flutter and Visual Studio** in VM
4. **Build using the script**

**Time:** ~30 minutes setup + 5 minutes build

---

## 📦 What's in the ZIP

```
ActivityTracker_Windows_Portable.zip
└── (Extract to get:)
    ├── poc_activity_tracker.exe    ← Main app (run this)
    ├── flutter_windows.dll         ← Flutter runtime
    ├── data/                        ← App resources
    ├── README.txt                   ← User instructions
    └── ... (other required DLLs)
```

**Total size:** 15-25 MB compressed, 40-60 MB extracted

---

## 👥 How Users Install It

**Super simple - no installation needed!**

1. **Extract the ZIP** to any folder
2. **Double-click** `poc_activity_tracker.exe`
3. **Done!**

### First Run (Windows SmartScreen)

Users may see a warning:
```
Windows protected your PC
Microsoft Defender SmartScreen prevented an unrecognized app...
```

**To run:**
1. Click "More info"
2. Click "Run anyway"

**Why?** The app isn't digitally signed. This is normal for unsigned apps.

---

## ✨ Features That Work

Once running, users can:

✅ **Capture screenshots** at configurable intervals
✅ **Track active windows** and applications
✅ **Monitor keyboard activity** (counts only, not keylogging)
✅ **Monitor mouse activity** (click counts)
✅ **Detect idle time**
✅ **Configure all settings**
✅ **Run in background** (minimize to system tray)

---

## 🔧 Configuration

Users can configure:
- Screenshot interval (default: 5 minutes)
- Enable/disable each feature
- Server URL (optional - for uploading data)
- API key (optional - for authentication)

**Settings are saved** and persist between runs.

---

## 📊 Data Storage

- **Screenshots:** Saved in the same folder as the EXE
- **Activity logs:** Stored in memory (cleared on restart)
- **Settings:** Saved in Windows registry
- **No cloud upload** unless server URL is configured

---

## 🔒 Privacy & Security

### What's Tracked

- ✅ Active window titles
- ✅ Application names
- ✅ Keystroke counts (not actual keys)
- ✅ Mouse click counts
- ✅ Screenshots (if enabled)
- ✅ Idle time

### What's NOT Tracked

- ❌ Actual keystrokes (no keylogging)
- ❌ Passwords
- ❌ Personal data
- ❌ Browser history
- ❌ File contents

### Data Privacy

- All data stored locally by default
- No cloud upload unless configured
- User has full control over data
- Can be deleted by removing the folder

---

## 🚨 Antivirus Warnings

Some antivirus software may flag the app because:
- It monitors keyboard/mouse
- It captures screenshots
- It's unsigned

**Solutions:**
1. Add to antivirus exceptions
2. Get a code signing certificate (for professional distribution)
3. Explain to users this is expected behavior

---

## 📋 Distribution Checklist

Before sharing the ZIP:

- [ ] Build completed successfully
- [ ] Tested on a clean Windows machine
- [ ] All features work
- [ ] No missing DLL errors
- [ ] README.txt included
- [ ] File size is reasonable (~15-25 MB)
- [ ] Virus scan completed (optional but recommended)

---

## 📤 How to Share

### Method 1: Email
- Attach the ZIP file
- Include installation instructions
- Mention SmartScreen warning

### Method 2: Cloud Storage
- Upload to Google Drive, Dropbox, OneDrive
- Share the link
- Set appropriate permissions

### Method 3: Network Share
- Copy to company network share
- Users download from there

### Method 4: USB Drive
- Copy ZIP to USB
- Distribute physically

### Method 5: Company Portal
- Upload to internal software portal
- Users download via company intranet

---

## 🆘 Troubleshooting

### "VCRUNTIME140.dll is missing"

**Solution:** User needs to install Visual C++ Redistributable
- Download: https://aka.ms/vs/17/release/vc_redist.x64.exe

### App doesn't start

**Solutions:**
- Run as Administrator
- Check Windows Event Viewer
- Ensure Windows 10 or later (64-bit)

### Screenshots not saving

**Solutions:**
- Check folder permissions
- Ensure enough disk space
- Run as Administrator

### Antivirus blocks the app

**Solutions:**
- Add to antivirus exceptions
- Whitelist the executable
- Contact IT department

---

## 🎓 User Training

Provide users with:

1. **Quick Start Guide:**
   - Extract ZIP
   - Run EXE
   - Configure settings
   - Start monitoring

2. **Feature Overview:**
   - What's tracked
   - How to configure
   - How to view data

3. **Privacy Information:**
   - What data is collected
   - Where it's stored
   - How to delete it

4. **Support Contact:**
   - Who to contact for help
   - Troubleshooting resources

---

## 📈 Next Steps

### For Basic Distribution

1. Build the ZIP (using GitHub Actions or Windows)
2. Test on a clean Windows machine
3. Share with users
4. Provide support as needed

### For Professional Distribution

1. Get a code signing certificate
2. Sign the executable
3. Create an installer (optional)
4. Set up auto-update mechanism
5. Create user documentation
6. Provide IT support

### For Enterprise Deployment

1. Package as MSI installer
2. Deploy via Group Policy or SCCM
3. Configure centrally
4. Monitor deployment
5. Provide helpdesk support

---

## 📞 Support

### For Developers

- See: `WINDOWS_BUILD_GUIDE.md`
- See: `BUILD_ON_WINDOWS.md`
- See: `DEPLOYMENT.md`

### For End Users

- See: `README.txt` (included in ZIP)
- Contact your IT administrator
- Check company support portal

---

## ✅ Summary

**To create a shareable Windows app:**

1. **Easiest:** Use GitHub Actions (no Windows needed)
2. **Alternative:** Build on Windows machine
3. **Result:** `ActivityTracker_Windows_Portable.zip`
4. **Share:** Via email, cloud, USB, or network
5. **Users:** Extract and run - no installation!

**That's it!** You now have a complete, portable Windows application ready to share.

---

## 🎉 You're Done!

The project is fully set up for Windows portable distribution. Choose your build method and create the ZIP file. Users will love how easy it is to use!

**Questions?** Check the detailed guides:
- `WINDOWS_BUILD_GUIDE.md` - Detailed build instructions
- `BUILD_ON_WINDOWS.md` - Building from Mac
- `DEPLOYMENT.md` - Enterprise deployment
- `README.md` - Project overview
