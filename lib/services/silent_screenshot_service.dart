import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Silent screenshot service using Windows GDI+ API
/// Captures screenshots completely invisibly - no UI, no notifications
class SilentScreenshotService {
  /// Captures screenshot using Windows GDI+ API
  /// Returns the file path if successful, null otherwise
  Future<String?> captureScreenshot() async {
    if (!Platform.isWindows) {
      print('Silent screenshot only supported on Windows');
      return null;
    }

    try {
      // Get screen dimensions
      final screenWidth = GetSystemMetrics(SM_CXSCREEN);
      final screenHeight = GetSystemMetrics(SM_CYSCREEN);

      if (screenWidth == 0 || screenHeight == 0) {
        print('Failed to get screen dimensions');
        return null;
      }

      // Get device context for the entire screen
      final hdcScreen = GetDC(NULL);
      if (hdcScreen == 0) {
        print('Failed to get screen DC');
        return null;
      }

      // Create compatible DC
      final hdcMemory = CreateCompatibleDC(hdcScreen);
      if (hdcMemory == 0) {
        ReleaseDC(NULL, hdcScreen);
        print('Failed to create compatible DC');
        return null;
      }

      // Create compatible bitmap
      final hBitmap = CreateCompatibleBitmap(hdcScreen, screenWidth, screenHeight);
      if (hBitmap == 0) {
        DeleteDC(hdcMemory);
        ReleaseDC(NULL, hdcScreen);
        print('Failed to create bitmap');
        return null;
      }

      // Select bitmap into memory DC
      final hOldBitmap = SelectObject(hdcMemory, hBitmap);

      // Copy screen to bitmap using BitBlt with CAPTUREBLT for silent capture
      final result = BitBlt(
        hdcMemory,
        0,
        0,
        screenWidth,
        screenHeight,
        hdcScreen,
        0,
        0,
        SRCCOPY | CAPTUREBLT,
      );

      if (result == 0) {
        SelectObject(hdcMemory, hOldBitmap);
        DeleteObject(hBitmap);
        DeleteDC(hdcMemory);
        ReleaseDC(NULL, hdcScreen);
        print('BitBlt failed');
        return null;
      }

      // Save bitmap to file
      final filePath = await _saveBitmapToFile(
        hBitmap,
        screenWidth,
        screenHeight,
      );

      // Cleanup
      SelectObject(hdcMemory, hOldBitmap);
      DeleteObject(hBitmap);
      DeleteDC(hdcMemory);
      ReleaseDC(NULL, hdcScreen);

      return filePath;
    } catch (e) {
      print('Screenshot error: $e');
      return null;
    }
  }

  /// Save bitmap to PNG file using GDI+
  Future<String?> _saveBitmapToFile(
    int hBitmap,
    int width,
    int height,
  ) async {
    try {
      // Load GDI+ library
      final gdiplus = DynamicLibrary.open('gdiplus.dll');

      // Get function pointers
      final gdiplusStartup = gdiplus.lookupFunction<
          Int32 Function(Pointer<IntPtr>, Pointer<GdiplusStartupInput>, Pointer),
          int Function(Pointer<IntPtr>, Pointer<GdiplusStartupInput>, Pointer)>(
        'GdiplusStartup',
      );

      final gdiplusShutdown = gdiplus.lookupFunction<
          Void Function(IntPtr),
          void Function(int)>(
        'GdiplusShutdown',
      );

      final gdipCreateBitmapFromHBITMAP = gdiplus.lookupFunction<
          Int32 Function(IntPtr, IntPtr, Pointer<IntPtr>),
          int Function(int, int, Pointer<IntPtr>)>(
        'GdipCreateBitmapFromHBITMAP',
      );

      final gdipSaveImageToFile = gdiplus.lookupFunction<
          Int32 Function(IntPtr, Pointer<Utf16>, Pointer<GUID>, Pointer),
          int Function(int, Pointer<Utf16>, Pointer<GUID>, Pointer)>(
        'GdipSaveImageToFile',
      );

      final gdipDisposeImage = gdiplus.lookupFunction<
          Int32 Function(IntPtr),
          int Function(int)>(
        'GdipDisposeImage',
      );

      // Initialize GDI+
      final startupInput = calloc<GdiplusStartupInput>();
      startupInput.ref.GdiplusVersion = 1;
      startupInput.ref.DebugEventCallback = 0;
      startupInput.ref.SuppressBackgroundThread = 0;
      startupInput.ref.SuppressExternalCodecs = 0;

      final token = calloc<IntPtr>();
      
      var status = gdiplusStartup(token, startupInput, nullptr);
      if (status != 0) {
        calloc.free(startupInput);
        calloc.free(token);
        print('GdiplusStartup failed: $status');
        return null;
      }

      // Create GDI+ bitmap from HBITMAP
      final gpBitmap = calloc<IntPtr>();
      status = gdipCreateBitmapFromHBITMAP(hBitmap, 0, gpBitmap);
      if (status != 0) {
        gdiplusShutdown(token.value);
        calloc.free(startupInput);
        calloc.free(token);
        calloc.free(gpBitmap);
        print('GdipCreateBitmapFromHBITMAP failed: $status');
        return null;
      }

      // Generate filename
      final timestamp = DateTime.now();
      final filename = 'screenshot_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}_${timestamp.second.toString().padLeft(2, '0')}.png';
      
      // Get save directory
      final appDir = await getApplicationDocumentsDirectory();
      final screenshotsDir = Directory(path.join(appDir.path, 'screenshots', 'activity_tracker'));
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }
      
      final filePath = path.join(screenshotsDir.path, filename);

      // Get PNG encoder CLSID
      final encoderClsid = _getPngEncoderClsid();

      // Save to file
      final filePathPtr = filePath.toNativeUtf16();
      status = gdipSaveImageToFile(
        gpBitmap.value,
        filePathPtr,
        encoderClsid,
        nullptr,
      );

      // Cleanup
      calloc.free(filePathPtr);
      calloc.free(encoderClsid);
      gdipDisposeImage(gpBitmap.value);
      gdiplusShutdown(token.value);
      calloc.free(startupInput);
      calloc.free(token);
      calloc.free(gpBitmap);

      if (status == 0) {
        print('✅ Screenshot saved: $filePath');
        return filePath;
      } else {
        print('GdipSaveImageToFile failed: $status');
        return null;
      }
    } catch (e) {
      print('Save bitmap error: $e');
      return null;
    }
  }

  /// Get PNG encoder CLSID
  Pointer<GUID> _getPngEncoderClsid() {
    // PNG encoder CLSID: {557CF406-1A04-11D3-9A73-0000F81EF32E}
    final clsid = calloc<GUID>();
    clsid.ref.setGUID('{557CF406-1A04-11D3-9A73-0000F81EF32E}');
    return clsid;
  }
}

// GDI+ Constants
const int SRCCOPY = 0x00CC0020;
const int CAPTUREBLT = 0x40000000;
const int SM_CXSCREEN = 0;
const int SM_CYSCREEN = 1;

// GDI+ Structures
final class GdiplusStartupInput extends Struct {
  @Uint32()
  external int GdiplusVersion;

  @IntPtr()
  external int DebugEventCallback;

  @Int32()
  external int SuppressBackgroundThread;

  @Int32()
  external int SuppressExternalCodecs;
}
