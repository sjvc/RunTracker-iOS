//
//  MapRunAnnotation.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 12/03/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import Foundation
import MapKit

class MapRunAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var imageName: String?
    
    init(coordinate: CLLocationCoordinate2D, imageName: String) {
        self.coordinate = coordinate
        self.imageName = imageName
    }
}
