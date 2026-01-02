import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WindowsActivityTracker {
  int _keystrokeCount = 0;
  int _mouseClickCount = 0;
  DateTime _lastActivityTime = DateTime.now();
  Timer? _pollTimer;
  
  // Store previous mouse position to detect movement
  int _lastMouseX = 0;
  int _lastMouseY = 0;
  
  void startTracking() {
    if (!Platform.isWindows) return;
    
    print('🪟 Starting Windows activity tracking...');
    
    // Poll for activity every 100ms
    _pollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _checkActivity();
    });
  }
  
  void stopTracking() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
  
  void _checkActivity() {
    try {
      // Check for keyboard activity
      _checkKeyboardActivity();
      
      // Check for mouse activity
      _checkMouseActivity();
    } catch (e) {
      // Silently handle errors
    }
  }
  
  void _checkKeyboardActivity() {
    // Check if any key is currently pressed
    // Common keys to check (A-Z, 0-9, Space, Enter, etc.)
    final keysToCheck = [
      // Letters A-Z
      ...List.generate(26, (i) => 0x41 + i),
      // Numbers 0-9
      ...List.generate(10, (i) => 0x30 + i),
      // Special keys
      VK_SPACE, VK_RETURN, VK_BACK, VK_TAB,
      VK_SHIFT, VK_CONTROL, VK_MENU, // Shift, Ctrl, Alt
    ];
    
    for (final vkCode in keysToCheck) {
      final state = GetAsyncKeyState(vkCode);
      // Check if key was pressed since last check (high bit set)
      if (state & 0x8000 != 0) {
        _keystrokeCount++;
        _lastActivityTime = DateTime.now();
        break; // Only count once per poll
      }
    }
  }
  
  void _checkMouseActivity() {
    final point = calloc<POINT>();
    try {
      if (GetCursorPos(point) != 0) {
        final x = point.ref.x;
        final y = point.ref.y;
        
        // Check if mouse moved
        if (x != _lastMouseX || y != _lastMouseY) {
          _lastActivityTime = DateTime.now();
          _lastMouseX = x;
          _lastMouseY = y;
        }
        
        // Check for mouse button clicks
        if (GetAsyncKeyState(VK_LBUTTON) & 0x8000 != 0 ||
            GetAsyncKeyState(VK_RBUTTON) & 0x8000 != 0) {
          _mouseClickCount++;
          _lastActivityTime = DateTime.now();
        }
      }
    } finally {
      free(point);
    }
  }
  
  Map<String, int> getAndResetCounts() {
    final result = {
      'keystrokes': _keystrokeCount,
      'mouseClicks': _mouseClickCount,
    };
    _keystrokeCount = 0;
    _mouseClickCount = 0;
    return result;
  }
  
  bool isIdle(int thresholdSeconds) {
    final idleTime = DateTime.now().difference(_lastActivityTime).inSeconds;
    return idleTime >= thresholdSeconds;
  }
  
  String getActiveWindowTitle() {
    try {
      final hwnd = GetForegroundWindow();
      if (hwnd == 0) return 'Unknown';
      
      final length = GetWindowTextLength(hwnd);
      if (length == 0) return 'Unknown';
      
      final buffer = wsalloc(length + 1);
      try {
        GetWindowText(hwnd, buffer, length + 1);
        return buffer.toDartString();
      } finally {
        free(buffer);
      }
    } catch (e) {
      return 'Unknown';
    }
  }
  
  String getActiveProcessName() {
    try {
      final hwnd = GetForegroundWindow();
      if (hwnd == 0) return 'Unknown';
      
      final processId = calloc<DWORD>();
      try {
        GetWindowThreadProcessId(hwnd, processId);
        
        final hProcess = OpenProcess(
          PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
          0,
          processId.value,
        );
        
        if (hProcess == 0) return 'Unknown';
        
        try {
          final buffer = wsalloc(MAX_PATH);
          try {
            final size = GetModuleBaseName(hProcess, 0, buffer, MAX_PATH);
            if (size > 0) {
              return buffer.toDartString();
            }
          } finally {
            free(buffer);
          }
        } finally {
          CloseHandle(hProcess);
        }
      } finally {
        free(processId);
      }
    } catch (e) {
      return 'Unknown';
    }
    return 'Unknown';
  }
}
