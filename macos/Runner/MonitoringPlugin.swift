import Cocoa
import FlutterMacOS
import CoreGraphics
import ApplicationServices
import AppKit

class MonitoringPlugin: NSObject, FlutterPlugin {
    private var isMonitoring = false
    private var keystrokeCount = 0
    private var mouseClickCount = 0
    private var eventTap: CFMachPort?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.activitytracker/monitoring",
            binaryMessenger: registrar.messenger
        )
        let instance = MonitoringPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startMonitoring":
            if let args = call.arguments as? [String: Any] {
                startMonitoring(config: args)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected map argument", details: nil))
            }
            
        case "stopMonitoring":
            stopMonitoring()
            result(true)
            
        case "captureScreenshot":
            if let path = captureScreenshot() {
                result(path)
            } else {
                result(FlutterError(code: "SCREENSHOT_FAILED", message: "Failed to capture screenshot", details: nil))
            }
            
        case "getActiveWindow":
            result(getActiveWindow())
            
        case "getInputActivity":
            result(getInputActivity())
            
        case "isSystemIdle":
            if let args = call.arguments as? [String: Any],
               let threshold = args["threshold"] as? Int {
                result(isSystemIdle(thresholdSeconds: threshold))
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected threshold argument", details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Screenshot Capture
    
    func captureScreenshot() -> String? {
        guard let displayID = CGMainDisplayID() as CGDirectDisplayID? else {
            return nil
        }
        
        guard let image = CGDisplayCreateImage(displayID) else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "screenshot_\(timestamp).png"
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypePNG, 1, nil) else {
            return nil
        }
        
        CGImageDestinationAddImage(destination, image, nil)
        
        if CGImageDestinationFinalize(destination) {
            return fileURL.path
        }
        
        return nil
    }
    
    // MARK: - Active Window Tracking
    
    func getActiveWindow() -> [String: String] {
        var result: [String: String] = [
            "title": "Unknown",
            "application": "Unknown"
        ]
        
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return result
        }
        
        result["application"] = frontmostApp.localizedName ?? "Unknown"
        
        // Get window title using Accessibility API
        let options = CGWindowListOption(arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements)
        let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]]
        
        if let windows = windowList {
            for window in windows {
                if let ownerPID = window[kCGWindowOwnerPID as String] as? Int32,
                   ownerPID == frontmostApp.processIdentifier,
                   let windowTitle = window[kCGWindowName as String] as? String,
                   !windowTitle.isEmpty {
                    result["title"] = windowTitle
                    break
                }
            }
        }
        
        return result
    }
    
    // MARK: - Input Activity Tracking
    
    func getInputActivity() -> [String: Int] {
        let result = [
            "keystrokes": keystrokeCount,
            "mouseClicks": mouseClickCount
        ]
        
        // Reset counters
        keystrokeCount = 0
        mouseClickCount = 0
        
        return result
    }
    
    // MARK: - Idle Detection
    
    func isSystemIdle(thresholdSeconds: Int) -> Bool {
        let idleTime = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState,
            eventType: .mouseMoved
        )
        return idleTime >= Double(thresholdSeconds)
    }
    
    // MARK: - Monitoring Control
    
    func startMonitoring(config: [String: Any]) {
        guard !isMonitoring else { return }
        
        // Create event tap for keyboard and mouse monitoring
        let eventMask = (1 << CGEventType.keyDown.rawValue) |
                       (1 << CGEventType.leftMouseDown.rawValue) |
                       (1 << CGEventType.rightMouseDown.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                let plugin = Unmanaged<MonitoringPlugin>.fromOpaque(refcon!).takeUnretainedValue()
                
                switch type {
                case .keyDown:
                    plugin.keystrokeCount += 1
                case .leftMouseDown, .rightMouseDown:
                    plugin.mouseClickCount += 1
                default:
                    break
                }
                
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Failed to create event tap")
            return
        }
        
        self.eventTap = eventTap
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        
        isMonitoring = true
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
        
        isMonitoring = false
    }
}
