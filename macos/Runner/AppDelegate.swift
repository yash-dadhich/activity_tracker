import Cocoa
import FlutterMacOS
//import MonitorPlugin
//import PermissionPlugin

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    
    // Register custom plugins
    MonitoringPlugin.register(with: controller.registrar(forPlugin: "MonitoringPlugin"))
    PermissionPlugin.register(with: controller.registrar(forPlugin: "PermissionPlugin"))
  }
}
