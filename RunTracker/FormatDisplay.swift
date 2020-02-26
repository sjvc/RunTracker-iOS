//
//  FormatDisplay.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 26/02/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import Foundation

public class FormatDisplay {
    // Devuelve el tiempo en formato MM:SS si es menor de una hora, y en HH:MM si es mayor a una hora
    public static func time(seconds: Int) -> String {
        if seconds < 3600 {
            return String(format: "%02d:%02d", seconds / 60, seconds % 60)
        } else {
            return String(format: "%02d:%02d", seconds / 3600, (seconds % 3600) / 60)
        }
    }
    
    // Devuelve la distancia en kilómetros
    public static func distance(meters: Double) -> String {
        return String(format: "%05.2f", meters / 1000.0)
    }
    
    // Devuelve el ritmo en minutos por kilómetro
    public static func pace(secondsPerMeter : NSNumber?) -> String {
        return String(format: "%05.2f", Double(truncating: secondsPerMeter ?? 0) / (60.0 * 1000.0))
    }
    
    // Devuelve la cadencia en pasos por minuto
    public static func cadence(stepsPerSeconds : NSNumber?) -> String {
        return String(format: "%05.2f", Double(truncating: stepsPerSeconds ?? 0) / 60.0)
    }
}
