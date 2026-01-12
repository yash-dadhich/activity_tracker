#include "monitoring_plugin.h"
#include "silent_screenshot.h"
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter_windows.h>
#include <windows.h>
#include <psapi.h>
#include <gdiplus.h>
#include <sstream>
#include <iomanip>
#include <chrono>

#pragma comment(lib, "gdiplus.lib")

using namespace Gdiplus;

MonitoringPlugin* MonitoringPlugin::instance_ = nullptr;

void MonitoringPlugin::RegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar_ref) {
  
  // Create C++ wrapper for the registrar
  static flutter::PluginRegistrar registrar(registrar_ref);
  
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar.messenger(), 
      "com.activitytracker/monitoring",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<MonitoringPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  // Keep plugin and channel alive - store in static variables
  static std::unique_ptr<MonitoringPlugin> static_plugin = std::move(plugin);
  static std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> static_channel = std::move(channel);
}

MonitoringPlugin::MonitoringPlugin() {
  instance_ = this;
  GdiplusStartupInput gdiplusStartupInput;
  ULONG_PTR gdiplusToken;
  GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);
}

MonitoringPlugin::~MonitoringPlugin() {
  StopMonitoring();
}

void MonitoringPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
  if (method_call.method_name() == "startMonitoring") {
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
      StartMonitoring(*arguments);
      result->Success(flutter::EncodableValue(true));
    } else {
      result->Error("INVALID_ARGUMENT", "Expected map argument");
    }
  } else if (method_call.method_name() == "stopMonitoring") {
    StopMonitoring();
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name() == "captureScreenshot") {
    std::string path = CaptureScreenshot();
    if (!path.empty()) {
      result->Success(flutter::EncodableValue(path));
    } else {
      result->Error("SCREENSHOT_FAILED", "Failed to capture screenshot");
    }
  } else if (method_call.method_name() == "getActiveWindow") {
    result->Success(flutter::EncodableValue(GetActiveWindow()));
  } else if (method_call.method_name() == "getInputActivity") {
    result->Success(flutter::EncodableValue(GetInputActivity()));
  } else if (method_call.method_name() == "isSystemIdle") {
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
      auto threshold_it = arguments->find(flutter::EncodableValue("threshold"));
      if (threshold_it != arguments->end()) {
        int threshold = std::get<int>(threshold_it->second);
        result->Success(flutter::EncodableValue(IsSystemIdle(threshold)));
        return;
      }
    }
    result->Error("INVALID_ARGUMENT", "Expected threshold argument");
  } else {
    result->NotImplemented();
  }
}

std::string MonitoringPlugin::CaptureScreenshot() {
  // Use completely silent screenshot capture
  // This uses Desktop Duplication API which is invisible to the user
  const char* result = CaptureSilentScreenshot();
  
  if (result && strlen(result) > 0) {
    return std::string(result);
  }
  
  // Fallback to GDI with CAPTUREBLT if Desktop Duplication fails
  HDC hScreenDC = GetDC(NULL);
  HDC hMemoryDC = CreateCompatibleDC(hScreenDC);

  int width = GetSystemMetrics(SM_CXSCREEN);
  int height = GetSystemMetrics(SM_CYSCREEN);

  HBITMAP hBitmap = CreateCompatibleBitmap(hScreenDC, width, height);
  HBITMAP hOldBitmap = (HBITMAP)SelectObject(hMemoryDC, hBitmap);

  // Use CAPTUREBLT flag to capture layered windows without flashing
  BitBlt(hMemoryDC, 0, 0, width, height, hScreenDC, 0, 0, SRCCOPY | CAPTUREBLT);
  
  hBitmap = (HBITMAP)SelectObject(hMemoryDC, hOldBitmap);

  std::string filepath = SaveBitmapToFile(hBitmap, width, height);

  DeleteDC(hMemoryDC);
  ReleaseDC(NULL, hScreenDC);
  DeleteObject(hBitmap);

  return filepath;
}

std::string MonitoringPlugin::SaveBitmapToFile(HBITMAP hBitmap, int width, int height) {
  // Generate filename with timestamp
  auto now = std::chrono::system_clock::now();
  auto time = std::chrono::system_clock::to_time_t(now);
  
  // Use localtime_s for thread safety
  struct tm timeinfo;
  localtime_s(&timeinfo, &time);
  
  std::stringstream ss;
  ss << "screenshot_" << std::put_time(&timeinfo, "%Y%m%d_%H%M%S") << ".png";
  
  std::string filename = ss.str();
  std::wstring wfilename(filename.begin(), filename.end());

  Bitmap bitmap(hBitmap, NULL);
  CLSID pngClsid;
  
  // Get PNG encoder CLSID
  UINT num = 0;
  UINT size = 0;
  GetImageEncodersSize(&num, &size);
  ImageCodecInfo* pImageCodecInfo = (ImageCodecInfo*)(malloc(size));
  GetImageEncoders(num, size, pImageCodecInfo);
  
  for (UINT i = 0; i < num; ++i) {
    if (wcscmp(pImageCodecInfo[i].MimeType, L"image/png") == 0) {
      pngClsid = pImageCodecInfo[i].Clsid;
      break;
    }
  }
  free(pImageCodecInfo);

  bitmap.Save(wfilename.c_str(), &pngClsid, NULL);
  
  return filename;
}

flutter::EncodableMap MonitoringPlugin::GetActiveWindow() {
  flutter::EncodableMap result;
  
  HWND hwnd = GetForegroundWindow();
  if (hwnd) {
    std::string title = GetWindowTitle(hwnd);
    std::string processName = GetProcessName(hwnd);
    
    result[flutter::EncodableValue("title")] = flutter::EncodableValue(title);
    result[flutter::EncodableValue("application")] = flutter::EncodableValue(processName);
  } else {
    result[flutter::EncodableValue("title")] = flutter::EncodableValue("Unknown");
    result[flutter::EncodableValue("application")] = flutter::EncodableValue("Unknown");
  }
  
  return result;
}

std::string MonitoringPlugin::GetWindowTitle(HWND hwnd) {
  char title[256];
  GetWindowTextA(hwnd, title, sizeof(title));
  return std::string(title);
}

std::string MonitoringPlugin::GetProcessName(HWND hwnd) {
  DWORD processId;
  GetWindowThreadProcessId(hwnd, &processId);
  
  HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processId);
  if (hProcess) {
    char processName[MAX_PATH];
    if (GetModuleBaseNameA(hProcess, NULL, processName, sizeof(processName))) {
      CloseHandle(hProcess);
      return std::string(processName);
    }
    CloseHandle(hProcess);
  }
  
  return "Unknown";
}

flutter::EncodableMap MonitoringPlugin::GetInputActivity() {
  flutter::EncodableMap result;
  result[flutter::EncodableValue("keystrokes")] = flutter::EncodableValue(keystroke_count_);
  result[flutter::EncodableValue("mouseClicks")] = flutter::EncodableValue(mouse_click_count_);
  
  // Reset counters after reading
  keystroke_count_ = 0;
  mouse_click_count_ = 0;
  
  return result;
}

bool MonitoringPlugin::IsSystemIdle(int thresholdSeconds) {
  LASTINPUTINFO lii;
  lii.cbSize = sizeof(LASTINPUTINFO);
  
  if (GetLastInputInfo(&lii)) {
    DWORD currentTime = GetTickCount();
    DWORD idleTime = (currentTime - lii.dwTime) / 1000; // Convert to seconds
    return idleTime >= static_cast<DWORD>(thresholdSeconds);
  }
  
  return false;
}

LRESULT CALLBACK MonitoringPlugin::KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
  if (nCode >= 0 && instance_) {
    if (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) {
      instance_->keystroke_count_++;
    }
  }
  return CallNextHookEx(NULL, nCode, wParam, lParam);
}

LRESULT CALLBACK MonitoringPlugin::MouseProc(int nCode, WPARAM wParam, LPARAM lParam) {
  if (nCode >= 0 && instance_) {
    if (wParam == WM_LBUTTONDOWN || wParam == WM_RBUTTONDOWN) {
      instance_->mouse_click_count_++;
    }
  }
  return CallNextHookEx(NULL, nCode, wParam, lParam);
}

void MonitoringPlugin::StartMonitoring(const flutter::EncodableMap& config) {
  if (is_monitoring_) return;
  
  // Install keyboard hook
  keyboard_hook_ = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, NULL, 0);
  
  // Install mouse hook
  mouse_hook_ = SetWindowsHookEx(WH_MOUSE_LL, MouseProc, NULL, 0);
  
  is_monitoring_ = true;
}

void MonitoringPlugin::StopMonitoring() {
  if (!is_monitoring_) return;
  
  if (keyboard_hook_) {
    UnhookWindowsHookEx(keyboard_hook_);
    keyboard_hook_ = nullptr;
  }
  
  if (mouse_hook_) {
    UnhookWindowsHookEx(mouse_hook_);
    mouse_hook_ = nullptr;
  }
  
  is_monitoring_ = false;
}
