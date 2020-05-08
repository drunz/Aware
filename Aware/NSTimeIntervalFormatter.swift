//
//  NSTimeIntervalFormatter.swift
//  Aware
//
//  Created by Joshua Peek on 12/18/15.
//  Copyright © 2015 Joshua Peek. All rights reserved.
//

import Foundation

class NSTimeIntervalFormatter {
    /**
        Formats time interval as a human readable duration string.

        - Parameters:
            - interval: The time interval in seconds.

        - Returns: A `String`.
     */
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = NSInteger(interval) / 60
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
    }
    
    /**
        Formats time interval as a fully extended human readable duration string.

        - Parameters:
            - interval: The time interval in seconds.

        - Returns: A `String`.
     */
    func stringFromTimeIntervalExtended(_ interval: TimeInterval) -> String {
        let minutes = NSInteger(interval) / 60
        let minuteValue = minutes % 60
        let minuteString = minuteValue > 1 ? "minutes" : "minute"
        if minutes < 60 {
            return "\(minuteValue) \(minuteString)"
        } else {
            let hourValue = minutes / 60
            let hourString = hourValue > 1 ? "hours" : "hour"
            return "\(hourValue) \(hourString) and \(minuteValue) \(minuteString)"
        }
    }
}
