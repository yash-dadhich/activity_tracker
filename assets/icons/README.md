# Icons Directory

Place your application icons here:

- `app_icon.png` - Main application icon (512x512)
- `tray_icon.png` - System tray icon (32x32)
- `tray_icon_active.png` - Active state tray icon (32x32)

## Icon Requirements

### Windows
- ICO format for executable icon
- PNG for system tray (16x16, 32x32, 48x48)

### macOS
- ICNS format for application icon
- PNG for menu bar (16x16@1x, 32x32@2x)

## Generating Icons

You can use online tools or command-line utilities:

### Using ImageMagick
```bash
# Convert PNG to ICO (Windows)
convert app_icon.png -define icon:auto-resize=256,128,64,48,32,16 app_icon.ico

# Create ICNS (macOS)
mkdir app_icon.iconset
sips -z 16 16 app_icon.png --out app_icon.iconset/icon_16x16.png
sips -z 32 32 app_icon.png --out app_icon.iconset/icon_16x16@2x.png
# ... (repeat for all sizes)
iconutil -c icns app_icon.iconset
```

### Using Online Tools
- https://www.icoconverter.com/
- https://cloudconvert.com/
- https://iconverticons.com/
