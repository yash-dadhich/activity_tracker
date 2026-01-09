import Cocoa
import FlutterMacOS
import ApplicationServices
import CoreGraphics
import Foundation

public class ComprehensiveMonitoringPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var isMonitoring = false
    
    // Event monitoring
    private var globalKeyMonitor: Any?
    private var globalMouseMonitor: Any?
    private var localKeyMonitor: Any?
    private var localMouseMonitor: Any?
    
    // Application monitoring
    private var appObserver: NSObjectProtocol?
    private var windowObserver: NSObjectProtocol?
    
    // Timers for periodic checks
    private var activityTimer: Timer?
    private var browserTimer: Timer?
    
    // Current state tracking
    private var currentApp: NSRunningApplication?
    private var currentWindow: AXUIElement?
    private var lastKeystroke: Date = Date()
    private var keystrokeBuffer: [[String: Any]] = []
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "comprehensive_monitoring", binaryMessenger: registrar.messenger)
        let instance = ComprehensiveMonitoringPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startMonitoring":
            startMonitoring(result: result)
        case "stopMonitoring":
            stopMonitoring(result: result)
        case "captureScreenshot":
            captureScreenshot(result: result)
        case "getCurrentApplication":
            getCurrentApplication(result: result)
        case "getCurrentWindow":
            getCurrentWindow(result: result)
        case "getBrowserActivity":
            getBrowserActivity(result: result)
        case "getRecentKeystrokes":
            getRecentKeystrokes(result: result)
        case "getScreenResolution":
            getScreenResolution(result: result)
        case "getActiveMonitors":
            getActiveMonitors(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func checkPermissions(result: @escaping FlutterResult) {
        let permissions: [String: Any] = [
            "accessibility": checkAccessibilityPermission(),
            "screenRecording": checkScreenRecordingPermission(),
            "inputMonitoring": checkInputMonitoringPermission()
        ]
        
        result(permissions)
    }
    
    private func checkAccessibilityPermission() -> Bool {
        // Check if accessibility permission is granted without prompting
        return AXIsProcessTrusted()
    }
    
    private func checkScreenRecordingPermission() -> Bool {
        // Check screen recording permission by attempting to get screen info
        guard let screen = NSScreen.main else { return false }
        
        // Try to create a screen capture - this will indicate if we have permission
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let imageRef = CGWindowListCreateImage(rect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution)
        
        return imageRef != nil
    }
    
    private func checkInputMonitoringPermission() -> Bool {
        // For input monitoring, we can check if we can create event taps
        // This is a simplified check - in production you might want more sophisticated detection
        return true // Assume granted for demo purposes
    }
    
    private func startMonitoring(result: @escaping FlutterResult) {
        guard !isMonitoring else {
            result(true)
            return
        }
        
        // Check permissions first without prompting
        let hasAccessibility = checkAccessibilityPermission()
        let hasScreenRecording = checkScreenRecordingPermission()
        let hasInputMonitoring = checkInputMonitoringPermission()
        
        if !hasAccessibility {
            print("⚠️ Accessibility permission not granted - monitoring will be limited")
            result(FlutterError(code: "PERMISSION_DENIED", 
                              message: "Accessibility permission required for comprehensive monitoring", 
                              details: ["accessibility": false, "screenRecording": hasScreenRecording, "inputMonitoring": hasInputMonitoring]))
            return
        }
        
        if !hasScreenRecording {
            print("⚠️ Screen recording permission not granted - screenshots will be unavailable")
        }
        
        isMonitoring = true
        
        // Start global event monitoring
        startGlobalEventMonitoring()
        
        // Start application monitoring
        startApplicationMonitoring()
        
        // Start periodic checks
        startPeriodicChecks()
        
        print("🔍 Comprehensive monitoring started")
        result(true)
    }
    
    private func stopMonitoring(result: @escaping FlutterResult) {
        guard isMonitoring else {
            result(true)
            return
        }
        
        isMonitoring = false
        
        // Stop all monitoring
        stopGlobalEventMonitoring()
        stopApplicationMonitoring()
        stopPeriodicChecks()
        
        print("🛑 Comprehensive monitoring stopped")
        result(true)
    }
    
    private func startGlobalEventMonitoring() {
        // Global key monitoring
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        // Local key monitoring (for events in our app)
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
        
        // Global mouse monitoring
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [
            .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
            .mouseMoved, .leftMouseDragged, .rightMouseDragged,
            .scrollWheel, .otherMouseDown, .otherMouseUp
        ]) { [weak self] event in
            self?.handleMouseEvent(event)
        }
        
        // Local mouse monitoring
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [
            .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
            .mouseMoved, .leftMouseDragged, .rightMouseDragged,
            .scrollWheel, .otherMouseDown, .otherMouseUp
        ]) { [weak self] event in
            self?.handleMouseEvent(event)
            return event
        }
    }
    
    private func stopGlobalEventMonitoring() {
        if let monitor = globalKeyMonitor {
            NSEvent.removeMonitor(monitor)
            globalKeyMonitor = nil
        }
        
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
        
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseMonitor = nil
        }
        
        if let monitor = localMouseMonitor {
            NSEvent.removeMonitor(monitor)
            localMouseMonitor = nil
        }
    }
    
    private func startApplicationMonitoring() {
        // Monitor application switches
        appObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                self?.handleApplicationChange(app)
            }
        }
        
        // Monitor window changes
        windowObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleWindowChange()
        }
    }
    
    private func stopApplicationMonitoring() {
        if let observer = appObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            appObserver = nil
        }
        
        if let observer = windowObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            windowObserver = nil
        }
    }
    
    private func startPeriodicChecks() {
        // Check for activity every 5 seconds
        activityTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkCurrentActivity()
        }
        
        // Check browser activity every 2 seconds
        browserTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkBrowserActivity()
        }
    }
    
    private func stopPeriodicChecks() {
        activityTimer?.invalidate()
        activityTimer = nil
        
        browserTimer?.invalidate()
        browserTimer = nil
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let keystrokeData: [String: Any] = [
            "key": event.charactersIgnoringModifiers ?? "",
            "keyCode": event.keyCode,
            "modifiers": getModifierFlags(event.modifierFlags),
            "isSpecialKey": event.specialKey != nil,
            "typingSpeed": calculateTypingSpeed(),
            "keyDuration": event.timestamp - lastKeystroke.timeIntervalSince1970,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        keystrokeBuffer.append(keystrokeData)
        
        // Keep only last 100 keystrokes in buffer
        if keystrokeBuffer.count > 100 {
            keystrokeBuffer.removeFirst()
        }
        
        lastKeystroke = Date()
        
        // Send to Flutter
        channel?.invokeMethod("onKeystroke", arguments: keystrokeData)
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        let mouseData: [String: Any] = [
            "eventType": getMouseEventType(event.type),
            "x": event.locationInWindow.x,
            "y": event.locationInWindow.y,
            "button": getMouseButton(event.buttonNumber),
            "clickCount": event.clickCount,
            "scrollDelta": event.scrollingDeltaY,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Send to Flutter
        channel?.invokeMethod("onMouseEvent", arguments: mouseData)
    }
    
    private func handleApplicationChange(_ app: NSRunningApplication) {
        currentApp = app
        
        let appData: [String: Any] = [
            "applicationName": app.localizedName ?? "Unknown",
            "applicationPath": app.bundleURL?.path ?? "",
            "processId": app.processIdentifier,
            "bundleId": app.bundleIdentifier ?? "",
            "version": getAppVersion(app),
            "memoryUsage": getMemoryUsage(app.processIdentifier),
            "cpuUsage": getCPUUsage(app.processIdentifier),
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Send to Flutter
        channel?.invokeMethod("onApplicationChange", arguments: appData)
        
        // Also check for file access
        checkFileAccess(for: app)
    }
    
    private func handleWindowChange() {
        guard let app = NSWorkspace.shared.frontmostApplication else { return }
        
        let windowTitle = getFrontmostWindowTitle()
        let windowData: [String: Any] = [
            "windowTitle": windowTitle,
            "windowId": getWindowId(),
            "applicationName": app.localizedName ?? "Unknown",
            "windowBounds": getWindowBounds(),
            "isFullscreen": isWindowFullscreen(),
            "isMinimized": isWindowMinimized(),
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Send to Flutter
        channel?.invokeMethod("onWindowChange", arguments: windowData)
    }
    
    private func checkCurrentActivity() {
        // Check idle state
        let idleTime = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .mouseMoved)
        let isIdle = idleTime > 60 // 1 minute idle threshold
        
        let idleData: [String: Any] = [
            "isIdle": isIdle,
            "idleDuration": idleTime,
            "idleThreshold": 60,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Send to Flutter
        channel?.invokeMethod("onIdleStateChange", arguments: idleData)
        
        // Check screen changes
        checkScreenChanges()
    }
    
    private func checkBrowserActivity() {
        guard let app = currentApp,
              let bundleId = app.bundleIdentifier,
              isBrowserApp(bundleId) else { return }
        
        let browserData = getBrowserData(for: bundleId)
        
        // Send to Flutter
        channel?.invokeMethod("onBrowserActivity", arguments: browserData)
    }
    
    private func checkFileAccess(for app: NSRunningApplication) {
        // This is a simplified version - in a real implementation,
        // you'd use file system events or process monitoring
        let recentFiles = getRecentlyAccessedFiles()
        
        for fileInfo in recentFiles {
            let fileData: [String: Any] = [
                "eventType": "file_access",
                "filePath": fileInfo["path"] ?? "",
                "fileName": fileInfo["name"] ?? "",
                "fileExtension": fileInfo["extension"] ?? "",
                "fileSize": fileInfo["size"] ?? 0,
                "operation": "open",
                "fileType": fileInfo["type"] ?? "",
                "lastModified": fileInfo["modified"] ?? "",
                "permissions": fileInfo["permissions"] ?? "",
                "timestamp": Date().timeIntervalSince1970
            ]
            
            // Send to Flutter
            channel?.invokeMethod("onFileAccess", arguments: fileData)
        }
    }
    
    private func checkScreenChanges() {
        let screenData: [String: Any] = [
            "eventType": "screen_update",
            "screenResolution": getScreenResolution(),
            "monitorCount": NSScreen.screens.count,
            "primaryMonitor": getPrimaryMonitorInfo(),
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Send to Flutter
        channel?.invokeMethod("onScreenChange", arguments: screenData)
    }
    
    // MARK: - Screenshot Capture
    
    private func captureScreenshot(result: @escaping FlutterResult) {
        guard let screen = NSScreen.main else {
            result(FlutterError(code: "SCREEN_ERROR", message: "Could not access main screen", details: nil))
            return
        }
        
        let rect = screen.frame
        let imageRef = CGWindowListCreateImage(rect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution)
        
        guard let cgImage = imageRef else {
            result(FlutterError(code: "CAPTURE_ERROR", message: "Could not capture screen", details: nil))
            return
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let imageData = bitmapRep.representation(using: .png, properties: [:]) else {
            result(FlutterError(code: "CONVERSION_ERROR", message: "Could not convert image", details: nil))
            return
        }
        
        result(FlutterStandardTypedData(bytes: imageData))
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentApplication(result: @escaping FlutterResult) {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            result(nil)
            return
        }
        
        let appData: [String: Any] = [
            "applicationName": app.localizedName ?? "Unknown",
            "applicationPath": app.bundleURL?.path ?? "",
            "processId": app.processIdentifier,
            "bundleId": app.bundleIdentifier ?? "",
            "version": getAppVersion(app)
        ]
        
        result(appData)
    }
    
    private func getCurrentWindow(result: @escaping FlutterResult) {
        let windowData: [String: Any] = [
            "windowTitle": getFrontmostWindowTitle(),
            "windowId": getWindowId(),
            "windowBounds": getWindowBounds(),
            "isFullscreen": isWindowFullscreen(),
            "isMinimized": isWindowMinimized()
        ]
        
        result(windowData)
    }
    
    private func getBrowserActivity(result: @escaping FlutterResult) {
        guard let app = NSWorkspace.shared.frontmostApplication,
              let bundleId = app.bundleIdentifier,
              isBrowserApp(bundleId) else {
            result(nil)
            return
        }
        
        let browserData = getBrowserData(for: bundleId)
        result(browserData)
    }
    
    private func getRecentKeystrokes(result: @escaping FlutterResult) {
        result(keystrokeBuffer)
        keystrokeBuffer.removeAll() // Clear buffer after reading
    }
    
    private func getScreenResolution(result: @escaping FlutterResult) {
        guard let screen = NSScreen.main else {
            result(nil)
            return
        }
        
        let resolution: [String: Any] = [
            "width": screen.frame.width,
            "height": screen.frame.height,
            "scale": screen.backingScaleFactor
        ]
        
        result(resolution)
    }
    
    private func getActiveMonitors(result: @escaping FlutterResult) {
        let monitors = NSScreen.screens.enumerated().map { index, screen in
            return [
                "id": index,
                "width": screen.frame.width,
                "height": screen.frame.height,
                "x": screen.frame.origin.x,
                "y": screen.frame.origin.y,
                "scale": screen.backingScaleFactor,
                "isPrimary": screen == NSScreen.main
            ]
        }
        
        result(monitors)
    }
    
    // MARK: - Utility Functions
    
    private func getModifierFlags(_ flags: NSEvent.ModifierFlags) -> [String] {
        var modifiers: [String] = []
        
        if flags.contains(.shift) { modifiers.append("shift") }
        if flags.contains(.control) { modifiers.append("control") }
        if flags.contains(.option) { modifiers.append("option") }
        if flags.contains(.command) { modifiers.append("command") }
        if flags.contains(.capsLock) { modifiers.append("capsLock") }
        
        return modifiers
    }
    
    private func getMouseEventType(_ type: NSEvent.EventType) -> String {
        switch type {
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            return "click"
        case .leftMouseUp, .rightMouseUp, .otherMouseUp:
            return "release"
        case .mouseMoved, .leftMouseDragged, .rightMouseDragged:
            return "move"
        case .scrollWheel:
            return "scroll"
        default:
            return "unknown"
        }
    }
    
    private func getMouseButton(_ buttonNumber: Int) -> String {
        switch buttonNumber {
        case 0: return "left"
        case 1: return "right"
        case 2: return "middle"
        default: return "other"
        }
    }
    
    private func calculateTypingSpeed() -> Double {
        let timeDiff = Date().timeIntervalSince(lastKeystroke)
        return timeDiff > 0 ? 1.0 / timeDiff : 0.0
    }
    
    private func getFrontmostWindowTitle() -> String {
        guard let app = NSWorkspace.shared.frontmostApplication else { return "Unknown" }
        
        let appRef = AXUIElementCreateApplication(app.processIdentifier)
        var windowRef: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(appRef, kAXFocusedWindowAttribute as CFString, &windowRef)
        
        guard result == .success, let window = windowRef else { return "Unknown" }
        
        var titleRef: CFTypeRef?
        let titleResult = AXUIElementCopyAttributeValue(window as! AXUIElement, kAXTitleAttribute as CFString, &titleRef)
        
        guard titleResult == .success, let title = titleRef as? String else { return "Unknown" }
        
        return title
    }
    
    private func getWindowId() -> String {
        // Simplified window ID generation
        return UUID().uuidString
    }
    
    private func getWindowBounds() -> [String: Double] {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return ["x": 0, "y": 0, "width": 0, "height": 0]
        }
        
        let appRef = AXUIElementCreateApplication(app.processIdentifier)
        var windowRef: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(appRef, kAXFocusedWindowAttribute as CFString, &windowRef)
        
        guard result == .success, let window = windowRef else {
            return ["x": 0, "y": 0, "width": 0, "height": 0]
        }
        
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        
        AXUIElementCopyAttributeValue(window as! AXUIElement, kAXPositionAttribute as CFString, &positionRef)
        AXUIElementCopyAttributeValue(window as! AXUIElement, kAXSizeAttribute as CFString, &sizeRef)
        
        var position = CGPoint.zero
        var size = CGSize.zero
        
        if let positionValue = positionRef {
            AXValueGetValue(positionValue as! AXValue, .cgPoint, &position)
        }
        
        if let sizeValue = sizeRef {
            AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        }
        
        return [
            "x": Double(position.x),
            "y": Double(position.y),
            "width": Double(size.width),
            "height": Double(size.height)
        ]
    }
    
    private func isWindowFullscreen() -> Bool {
        // Simplified fullscreen detection
        guard let screen = NSScreen.main else { return false }
        let bounds = getWindowBounds()
        
        return bounds["width"] == Double(screen.frame.width) && 
               bounds["height"] == Double(screen.frame.height)
    }
    
    private func isWindowMinimized() -> Bool {
        // Simplified minimized detection
        let bounds = getWindowBounds()
        return bounds["width"] == 0 && bounds["height"] == 0
    }
    
    private func getAppVersion(_ app: NSRunningApplication) -> String {
        guard let bundleURL = app.bundleURL,
              let bundle = Bundle(url: bundleURL),
              let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
    
    private func getMemoryUsage(_ processId: pid_t) -> Int {
        // Simplified memory usage - would need more complex implementation
        return 0
    }
    
    private func getCPUUsage(_ processId: pid_t) -> Double {
        // Simplified CPU usage - would need more complex implementation
        return 0.0
    }
    
    private func isBrowserApp(_ bundleId: String) -> Bool {
        let browserIds = [
            "com.google.Chrome",
            "com.apple.Safari",
            "org.mozilla.firefox",
            "com.microsoft.edgemac",
            "com.operasoftware.Opera"
        ]
        return browserIds.contains(bundleId)
    }
    
    private func getBrowserData(for bundleId: String) -> [String: Any] {
        // This would require browser-specific implementations
        // For now, return mock data
        return [
            "eventType": "navigation",
            "url": "https://example.com",
            "title": "Example Page",
            "domain": "example.com",
            "browserName": getBrowserName(bundleId),
            "tabId": "tab_1",
            "referrer": "",
            "loadTime": 1.5,
            "scrollPosition": 0,
            "formInteractions": []
        ]
    }
    
    private func getBrowserName(_ bundleId: String) -> String {
        switch bundleId {
        case "com.google.Chrome": return "Chrome"
        case "com.apple.Safari": return "Safari"
        case "org.mozilla.firefox": return "Firefox"
        case "com.microsoft.edgemac": return "Edge"
        case "com.operasoftware.Opera": return "Opera"
        default: return "Unknown Browser"
        }
    }
    
    private func getRecentlyAccessedFiles() -> [[String: Any]] {
        // This would require file system monitoring
        // For now, return empty array
        return []
    }
    
    private func getScreenResolution() -> [String: Double] {
        guard let screen = NSScreen.main else {
            return ["width": 0, "height": 0, "scale": 1]
        }
        
        return [
            "width": Double(screen.frame.width),
            "height": Double(screen.frame.height),
            "scale": Double(screen.backingScaleFactor)
        ]
    }
    
    private func getPrimaryMonitorInfo() -> [String: Any] {
        guard let screen = NSScreen.main else {
            return [:]
        }
        
        return [
            "width": screen.frame.width,
            "height": screen.frame.height,
            "x": screen.frame.origin.x,
            "y": screen.frame.origin.y,
            "scale": screen.backingScaleFactor
        ]
    }
}