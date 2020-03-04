//
//  CadenceSettingsViewController.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 26/02/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import UIKit
import QuickTableViewController

class CadenceSettingsViewController : QuickTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentCadence = Settings.getCadence()
        
        var optionRows = [OptionRow<UITableViewCell>]()
        optionRows.append(OptionRow(text: "Ninguna", isSelected: currentCadence == 0, action: didToggleSelection(0)))
        
        let minCadence = 90
        let maxCadence = 180
        let cadenceInterval = 5
        
        var cadence = minCadence
        repeat {
            optionRows.append(OptionRow(text: String(cadence), isSelected: currentCadence == cadence, action: didToggleSelection(cadence)))
            cadence += cadenceInterval
        } while(cadence <= maxCadence)
        
        tableContents = [
            RadioSection(title: "Selecciona cadencia mínima", options: optionRows)
        ]
    }
    
    private func didToggleSelection(_ value : Int) -> (Row) -> Void {
        return { [weak self] row in
            Settings.setCadence(value: value)
        }
    }
    
}
