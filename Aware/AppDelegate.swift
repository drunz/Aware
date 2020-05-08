//
//  AppDelegate.swift
//  Aware
//
//  Created by Joshua Peek on 12/06/15.
//  Copyright © 2015 Joshua Peek. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    var timerStart: Date = Date()

    // Redraw button every minute
    let buttonRefreshRate: TimeInterval = 60

    // Reference to installed global mouse event monitor
    var mouseEventMonitor: Any?

    // Default value to initialize userIdleSeconds to
    static let defaultUserIdleSeconds: TimeInterval = 2 * 60
    
    // User configurable idle time in seconds (defaults to 2 minutes)
    var userIdleSeconds: TimeInterval = defaultUserIdleSeconds

    // Default value to initialize sessionLimitSeconds to
    static let defaultSessionLimitSeconds: TimeInterval = 30 * 60
    
    // Seconds after which a break reminder is shown
    var sessionLimitSeconds: TimeInterval = defaultSessionLimitSeconds
    
    // Default value to initialize snoozeDurationSeconds to
    static let defaultSnoozeDurationSeconds: TimeInterval = 5 * 60
    
    // Seconds to snooze a break reminder for
    var snoozeDurationSeconds: TimeInterval = defaultSnoozeDurationSeconds
    
    // Last time a notification has been shown to the user
    var notificationShownLast: Date = Date.distantPast

    func readUserIdleSeconds() -> TimeInterval {
        let defaultsValue = UserDefaults.standard.object(forKey: "UserIdleSeconds") as? TimeInterval
        return defaultsValue ?? type(of: self).defaultUserIdleSeconds
    }
    
    func readSessionLimitSeconds() -> TimeInterval {
        let defaultsValue = UserDefaults.standard.object(forKey: "SessionLimitSeconds") as? TimeInterval
        return defaultsValue ?? type(of: self).defaultSessionLimitSeconds
    }
    
    func readSnoozeDurationSeconds() -> TimeInterval {
        let defaultsValue = UserDefaults.standard.object(forKey: "SnoozeDurationSeconds") as? TimeInterval
        return defaultsValue ?? type(of: self).defaultSnoozeDurationSeconds
    }

    // kCGAnyInputEventType isn't part of CGEventType enum
    // defined in <CoreGraphics/CGEventTypes.h>
    let AnyInputEventType = CGEventType(rawValue: UInt32.max)!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    @IBOutlet weak var menu: NSMenu! {
        didSet {
            statusItem.menu = menu
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.userIdleSeconds = self.readUserIdleSeconds()
        self.sessionLimitSeconds = self.readSessionLimitSeconds()
        self.snoozeDurationSeconds = self.readSnoozeDurationSeconds()

        updateButton()
        let _ = Timer.scheduledTimer(buttonRefreshRate, userInfo: nil, repeats: true) { _ in self.updateButton() }

        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil) { _ in self.resetTimer() }
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { _ in self.resetTimer() }
        
        NSUserNotificationCenter.default.delegate = self
    }

    func resetTimer() {
        timerStart = Date()
        updateButton()
    }

    func onMouseEvent(_ event: NSEvent) {
        if let eventMonitor = mouseEventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            mouseEventMonitor = nil
        }
        updateButton()
    }

    func updateButton() {
        var idle: Bool

        if (self.sinceUserActivity() > userIdleSeconds) {
            timerStart = Date()
            idle = true
        } else if (CGDisplayIsAsleep(CGMainDisplayID()) == 1) {
            timerStart = Date()
            idle = true
        } else {
            idle = false
        }

        let duration = Date().timeIntervalSince(timerStart)
        let title = NSTimeIntervalFormatter().stringFromTimeInterval(duration)
        statusItem.button!.title = title

        if (idle) {
            statusItem.button!.attributedTitle = updateAttributedString(statusItem.button!.attributedTitle, [
                NSAttributedString.Key.foregroundColor: NSColor.controlTextColor.withAlphaComponent(0.1)
            ])

            // On next mouse event, immediately update button
            if mouseEventMonitor == nil {
                mouseEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [
                    NSEvent.EventTypeMask.mouseMoved,
                    NSEvent.EventTypeMask.leftMouseDown
                ], handler: onMouseEvent)
            }
            
            enableNotifications()
        } else if (sessionLimitReached(duration) && snoozeExpired()) {
            showNotification(duration)
        }
    }

    let userActivityEventTypes: [CGEventType] = [
        .leftMouseDown,
        .rightMouseDown,
        .mouseMoved,
        .keyDown,
        .scrollWheel
    ]

    func sinceUserActivity() -> CFTimeInterval {
        return userActivityEventTypes.map { CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: $0) }.min()!
    }

    func updateAttributedString(_ attributedString: NSAttributedString, _ attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let str = NSMutableAttributedString(attributedString: attributedString)
        str.addAttributes(attributes, range: NSMakeRange(0, str.length))
        return str
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) {
        case .actionButtonClicked:
            disableNotifications()
        default:
            break;
        }
    }
    
    func sessionLimitReached(_ sessionDuration: TimeInterval) -> Bool {
        return sessionDuration >= sessionLimitSeconds
    }
    
    func snoozeExpired() -> Bool {
        return Date().timeIntervalSince(notificationShownLast) >= snoozeDurationSeconds
    }
    
    func enableNotifications() -> Void {
        notificationShownLast = Date.distantPast
    }
    
    func disableNotifications() -> Void {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        notificationShownLast = Date.distantFuture
    }
    
    func showNotification(_ sessionDuration: TimeInterval) -> Void {
        let durationString = NSTimeIntervalFormatter().stringFromTimeIntervalExtended(sessionDuration)
        let notification = NSUserNotification()
        notification.title = "Take a break"
        notification.subtitle = "You've been active for over \(durationString)."
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = true
        notification.otherButtonTitle = "Snooze"
        notification.actionButtonTitle = "Dismiss"
        
        NSUserNotificationCenter.default.deliver(notification)
        notificationShownLast = Date()
    }
}
