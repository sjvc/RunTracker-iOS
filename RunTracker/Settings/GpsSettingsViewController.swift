//
//  GpsSettingsViewController.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 26/02/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import UIKit
import QuickTableViewController

class GpsSettingsViewController : QuickTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gpsAccuracy = Settings.getGpsAccuracty()
        
        tableContents = [
            RadioSection(title: "Selecciona la precisión del GPS", options: [
                OptionRow(text: "Óptima", isSelected: gpsAccuracy == GpsAccuracy.HIGH, action: didToggleSelection(GpsAccuracy.HIGH))//,
                //OptionRow(text: "Media", isSelected: gpsAccuracy == GpsAccuracy.MEDIUM, action: didToggleSelection(GpsAccuracy.MEDIUM)),
                //OptionRow(text: "Baja", isSelected: gpsAccuracy == GpsAccuracy.LOW, action: didToggleSelection(GpsAccuracy.LOW))
            ])
        ]
    }
    
    private func didToggleSelection(_ value : GpsAccuracy) -> (Row) -> Void {
        return { [weak self] row in
            Settings.setGpsAccuracy(value: value)
        }
    }
    
}
