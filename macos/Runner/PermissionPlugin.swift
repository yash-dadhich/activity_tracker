import Cocoa
import FlutterMacOS
import CoreGraphics
import ApplicationServices

class PermissionPlugin: NSObject, FlutterPlugin {
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.activitytracker/permissions",
            binaryMessenger: registrar.messenger
        )
        let instance = PermissionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkScreenRecording":
            result(checkScreenRecordingPermission())
            
        case "checkAccessibility":
            result(checkAccessibilityPermission())
            
        case "requestScreenRecording":
            requestScreenRecordingPermission()
            result(nil)
            
        case "requestAccessibility":
            requestAccessibilityPermission()
            result(nil)
            
        case "openSystemPreferences":
            openSystemPreferences()
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Screen Recording Permission
    
    func checkScreenRecordingPermission() -> Bool {
        if #available(macOS 10.15, *) {
            // Try to capture a small screenshot to test permission
            let displayID = CGMainDisplayID()
            let image = CGDisplayCreateImage(displayID, rect: CGRect(x: 0, y: 0, width: 1, height: 1))
            return image != nil
        }
        return true
    }
    
    func requestScreenRecordingPermission() {
        if #available(macOS 10.15, *) {
            // Trigger permission dialog by attempting to capture screen
            let displayID = CGMainDisplayID()
            _ = CGDisplayCreateImage(displayID)
        }
    }
    
    // MARK: - Accessibility Permission
    
    func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options)
    }
    
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options)
    }
    
    // MARK: - System Preferences
    
    func openSystemPreferences() {
        // Try multiple methods to open System Preferences/Settings
        
        // Method 1: Try opening Privacy & Security directly (macOS 13+)
        if #available(macOS 13.0, *) {
            if let url = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension") {
                if NSWorkspace.shared.open(url) {
                    print("Opened Settings app successfully")
                    return
                }
            }
        }
        
        // Method 2: Try opening Security & Privacy pane (macOS 10.15-12)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
            if NSWorkspace.shared.open(url) {
                print("Opened System Preferences successfully")
                return
            }
        }
        
        // Method 3: Try opening just the Security pane
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security") {
            if NSWorkspace.shared.open(url) {
                print("Opened Security pane successfully")
                return
            }
        }
        
        // Method 4: Open the preference pane file directly
        let prefPanePath = "/System/Library/PreferencePanes/Security.prefPane"
        if FileManager.default.fileExists(atPath: prefPanePath) {
            let url = URL(fileURLWithPath: prefPanePath)
            if NSWorkspace.shared.open(url) {
                print("Opened Security prefPane successfully")
                return
            }
        }
        
        // Method 5: Last resort - open System Preferences/Settings app
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Preferences.app"))
        }
        
        print("Opened System Preferences/Settings app")
    }
}
