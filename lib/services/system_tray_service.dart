import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class SystemTrayService with TrayListener {
  static final SystemTrayService _instance = SystemTrayService._internal();
  factory SystemTrayService() => _instance;
  SystemTrayService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to set icon, but don't fail if it doesn't exist
      try {
        await trayManager.setIcon(
          'assets/icons/app_icon.png',
          isTemplate: true,
        );
      } catch (e) {
        debugPrint('Could not set tray icon: $e');
        // Continue without icon
      }

      Menu menu = Menu(
        items: [
          MenuItem(
            key: 'show_window',
            label: 'Show Window',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'about',
            label: 'About',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit',
            label: 'Exit (Requires Admin Password)',
          ),
        ],
      );

      await trayManager.setContextMenu(menu);
      await trayManager.setToolTip('Employee Monitoring - Running');
      
      trayManager.addListener(this);
      _isInitialized = true;
      
      debugPrint('System tray initialized');
    } catch (e) {
      debugPrint('Failed to initialize system tray: $e');
      // Don't throw - app can work without tray
    }
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        windowManager.show();
        windowManager.focus();
        break;
      case 'about':
        // Show about dialog
        break;
      case 'exit':
        // This will trigger the window close handler which requires password
        windowManager.close();
        break;
    }
  }

  Future<void> updateTooltip(String message) async {
    if (_isInitialized) {
      await trayManager.setToolTip(message);
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      trayManager.removeListener(this);
      await trayManager.destroy();
      _isInitialized = false;
    }
  }
}
