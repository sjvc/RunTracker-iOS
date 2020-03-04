//
//  Settings.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 04/03/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import Foundation

public enum GpsAccuracy : Int {
    case HIGH = 0
    case MEDIUM = 1
    case LOW = 2
}

public enum IntervalType : Int {
    case NONE = 0
    case TIME = 1
    case DISTANCE = 2
}

public class Settings {
    private static let KEY_CADENCE = "Cadence"
    private static let KEY_GPS_ACCURACY = "GpsAccuracy"
    private static let KEY_INTERVAL_VALUE = "IntervalValue"
    private static let KEY_INTERVAL_TYPE = "IntervalType"
    private static let KEY_AUTOPAUSE = "AutoPause"
    
    public static func getCadence() -> Int {
        return UserDefaults.standard.integer(forKey: Settings.KEY_CADENCE)
    }
    
    public static func getGpsAccuracty() -> GpsAccuracy {
        let intValue = UserDefaults.standard.integer(forKey: Settings.KEY_GPS_ACCURACY)
        return GpsAccuracy(rawValue: intValue)!
    }
    
    public static func getIntervalValue() -> Int {
        return UserDefaults.standard.integer(forKey: Settings.KEY_INTERVAL_VALUE)
    }
    
    public static func getIntervalType() -> IntervalType {
        let intValue = UserDefaults.standard.integer(forKey: Settings.KEY_INTERVAL_TYPE)
        return IntervalType(rawValue: intValue)!
    }
    
    public static func getAutoPause() -> Bool {
        return UserDefaults.standard.bool(forKey: Settings.KEY_AUTOPAUSE)
    }
    
    public static func setCadence(value: Int) {
        UserDefaults.standard.set(value, forKey: Settings.KEY_CADENCE)
    }
    
    public static func setGpsAccuracy(value: GpsAccuracy) {
        UserDefaults.standard.set(value.rawValue, forKey: Settings.KEY_GPS_ACCURACY)
    }
    
    public static func setIntervalValue(value: Int) {
        UserDefaults.standard.set(value, forKey: Settings.KEY_INTERVAL_VALUE)
    }
    
    public static func setIntervalType(value: IntervalType) {
        UserDefaults.standard.set(value.rawValue, forKey: Settings.KEY_INTERVAL_TYPE)
    }
    
    public static func setAutoPause(value: Bool) {
        UserDefaults.standard.set(value, forKey: Settings.KEY_AUTOPAUSE)
    }
}
