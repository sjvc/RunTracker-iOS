//
//  LocationManager.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 17/02/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import CoreLocation

class LocationManager {
    static let shared = CLLocationManager()
    
    private init() { }
    
    public static func hasPermission() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }
}
