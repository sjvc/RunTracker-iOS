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
        
        tableContents = [
            RadioSection(title: "Selecciona la precisión del GPS", options: [
                OptionRow(text: "Alta", isSelected: false, action: didToggleSelection()),
                OptionRow(text: "Media", isSelected: false, action: didToggleSelection()),
                OptionRow(text: "Baja", isSelected: false, action: didToggleSelection())
            ])
        ]
    }
    
    private func didToggleSelection() -> (Row) -> Void {
        return { [weak self] row in
            // ...
        }
    }
    
}
