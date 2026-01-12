#ifndef MONITORING_PLUGIN_H_
#define MONITORING_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <string>
#include <memory>

class MonitoringPlugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  MonitoringPlugin();
  virtual ~MonitoringPlugin();

  // Disallow copy and assign.
  MonitoringPlugin(const MonitoringPlugin&) = delete;
  MonitoringPlugin& operator=(const MonitoringPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // Screenshot capture
  std::string CaptureScreenshot();
  
  // Active window tracking
  flutter::EncodableMap GetActiveWindow();
  
  // Input activity tracking
  flutter::EncodableMap GetInputActivity();
  
  // Idle detection
  bool IsSystemIdle(int thresholdSeconds);
  
  // Monitoring control
  void StartMonitoring(const flutter::EncodableMap& config);
  void StopMonitoring();

  // Helper functions
  std::string GetWindowTitle(HWND hwnd);
  std::string GetProcessName(HWND hwnd);
  std::string SaveBitmapToFile(HBITMAP hBitmap, int width, int height);

  // State
  bool is_monitoring_ = false;
  int keystroke_count_ = 0;
  int mouse_click_count_ = 0;
  HHOOK keyboard_hook_ = nullptr;
  HHOOK mouse_hook_ = nullptr;

  static LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);
  static LRESULT CALLBACK MouseProc(int nCode, WPARAM wParam, LPARAM lParam);
  static MonitoringPlugin* instance_;
};

#endif  // MONITORING_PLUGIN_H_
