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
    case UNDEFINED = 0
    case TIME = 1
    case DISTANCE = 2
}

public enum Gender : Int {
    case UNDEFINED = 0
    case FEMALE = 1
    case MALE = 2
}

public class Settings {
    private static let KEY_CADENCE = "Cadence"
    private static let KEY_GPS_ACCURACY = "GpsAccuracy"
    private static let KEY_INTERVAL_VALUE = "IntervalValue"
    private static let KEY_INTERVAL_TYPE = "IntervalType"
    private static let KEY_AUTOPAUSE = "AutoPause"
    
    private static let KEY_PROFILE_NAME = "Profile_Name"
    private static let KEY_PROFILE_GENDER = "Profile_Gender"
    private static let KEY_PROFILE_AGE = "Profile_Age"
    private static let KEY_PROFILE_WEIGHT = "Profile_Weight"
    private static let KEY_PROFILE_HEIGHT = "Profile_Height"
    
    private static let KEY_RUN_DATA_ORDER = "RunDataOrder"
    
    public static func getCadence() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_CADENCE)
    }
    
    public static func getGpsAccuracty() -> GpsAccuracy {
        let intValue = UserDefaults.standard.integer(forKey: KEY_GPS_ACCURACY)
        return GpsAccuracy(rawValue: intValue)!
    }
    
    public static func getIntervalValue() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_INTERVAL_VALUE)
    }
    
    public static func getIntervalType() -> IntervalType {
        let intValue = UserDefaults.standard.integer(forKey: KEY_INTERVAL_TYPE)
        return IntervalType(rawValue: intValue)!
    }
    
    public static func getAutoPause() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_AUTOPAUSE)
    }
    
    public static func setCadence(value: Int) {
        UserDefaults.standard.set(value, forKey: KEY_CADENCE)
    }
    
    public static func setGpsAccuracy(value: GpsAccuracy) {
        UserDefaults.standard.set(value.rawValue, forKey: KEY_GPS_ACCURACY)
    }
    
    public static func setIntervalValue(value: Int) {
        UserDefaults.standard.set(value, forKey: KEY_INTERVAL_VALUE)
    }
    
    public static func setIntervalType(value: IntervalType) {
        UserDefaults.standard.set(value.rawValue, forKey: KEY_INTERVAL_TYPE)
    }
    
    public static func setAutoPause(value: Bool) {
        UserDefaults.standard.set(value, forKey: KEY_AUTOPAUSE)
    }
    
    public static func getProfileName() -> String {
        return UserDefaults.standard.string(forKey: KEY_PROFILE_NAME) ?? ""
    }
    
    public static func getProfileShortName() -> String {
        let name = getProfileName()
        if !name.contains(" ") {
            return name
        }
        
        return name.components(separatedBy: " ").first!
    }
    
    public static func setProfileName(_ name: String) {
        UserDefaults.standard.set(name, forKey: KEY_PROFILE_NAME)
    }
    
    public static func getProfileGender() -> Gender {
        let intValue = UserDefaults.standard.integer(forKey: KEY_PROFILE_GENDER)
        return Gender(rawValue: intValue)!
    }
    
    public static func setProfileGender(_ gender: Gender) {
        UserDefaults.standard.set(gender.rawValue, forKey: KEY_PROFILE_GENDER)
    }
    
    public static func getProfileAge() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_PROFILE_AGE)
    }
    
    public static func setProfileAge(value: Int) {
        UserDefaults.standard.set(value, forKey: KEY_PROFILE_AGE)
    }
    
    public static func getProfileWeight() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_PROFILE_WEIGHT)
    }
    
    public static func setProfileWeight(value: Int) {
        UserDefaults.standard.set(value, forKey: KEY_PROFILE_WEIGHT)
    }
    
    public static func getProfileHeight() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_PROFILE_HEIGHT)
    }
    
    public static func setProfileHeight(value: Int) {
        UserDefaults.standard.set(value, forKey: KEY_PROFILE_HEIGHT)
    }
    
    public static func setRunDataOrder(index: Int, key: String) {
        UserDefaults.standard.set(key, forKey: KEY_RUN_DATA_ORDER + String(index))
    }
    
    public static func getRunDataOrder(index: Int) -> String? {
        let strValue = UserDefaults.standard.string(forKey: KEY_RUN_DATA_ORDER + String(index))
        return strValue == "" ? nil : strValue
    }
}
