//
//  IntervalSettingsViewController.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 26/02/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import UIKit
import QuickTableViewController

class IntervalSettingsViewController : QuickTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timeImage = UIImage(systemName: "clock")
        let distanceImage = UIImage(systemName: "mappin.and.ellipse")
        
        tableContents = [
            RadioSection(title: "Selecciona intervalo de notificación", options: [
                OptionRow(text: "1 minuto", isSelected: false, icon: .image(timeImage!), action: didToggleSelection()),
                OptionRow(text: "5 minutos", isSelected: false, icon: .image(timeImage!), action: didToggleSelection()),
                OptionRow(text: "10 minutos", isSelected: false, icon: .image(timeImage!), action: didToggleSelection()),
                OptionRow(text: "15 minutos", isSelected: false, icon: .image(timeImage!), action: didToggleSelection()),
                OptionRow(text: "30 minutos", isSelected: false, icon: .image(timeImage!), action: didToggleSelection()),
                OptionRow(text: "45 minutos", isSelected: false, icon: .image(timeImage!), action: didToggleSelection()),
                OptionRow(text: "60 minutos", isSelected: false, icon: .image(timeImage!), action: didToggleSelection()),
                OptionRow(text: "100 metros", isSelected: false, icon: .image(distanceImage!), action: didToggleSelection()),
                OptionRow(text: "250 metros", isSelected: false, icon: .image(distanceImage!), action: didToggleSelection()),
                OptionRow(text: "500 metros", isSelected: false, icon: .image(distanceImage!), action: didToggleSelection()),
                OptionRow(text: "1 km", isSelected: false, icon: .image(distanceImage!), action: didToggleSelection()),
                OptionRow(text: "2 km", isSelected: false, icon: .image(distanceImage!), action: didToggleSelection()),
                OptionRow(text: "5 km", isSelected: false, icon: .image(distanceImage!), action: didToggleSelection()),
                OptionRow(text: "10 km", isSelected: false, icon: .image(distanceImage!), action: didToggleSelection()),
            ])
        ]
    }
    
    private func didToggleSelection() -> (Row) -> Void {
        return { [weak self] row in
            // ...
        }
    }
    
}
