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
        
        let type = Settings.getIntervalType()
        let value = Settings.getIntervalValue()
        
        tableContents = [
            RadioSection(title: "Selecciona intervalo de notificación", options: [
                OptionRow(text: "Ninguno", isSelected: type == IntervalType.UNDEFINED, action: didToggleSelection(IntervalType.UNDEFINED, 0)),
                OptionRow(text: "1 minuto", isSelected: type == IntervalType.TIME && value == 1, icon: .image(timeImage!), action: didToggleSelection(IntervalType.TIME, 1)),
                OptionRow(text: "5 minutos", isSelected: type == IntervalType.TIME && value == 5, icon: .image(timeImage!), action: didToggleSelection(IntervalType.TIME, 5)),
                OptionRow(text: "10 minutos", isSelected: type == IntervalType.TIME && value == 10, icon: .image(timeImage!), action: didToggleSelection(IntervalType.TIME, 10)),
                OptionRow(text: "15 minutos", isSelected: type == IntervalType.TIME && value == 15, icon: .image(timeImage!), action: didToggleSelection(IntervalType.TIME, 15)),
                OptionRow(text: "30 minutos", isSelected: type == IntervalType.TIME && value == 30, icon: .image(timeImage!), action: didToggleSelection(IntervalType.TIME, 30)),
                OptionRow(text: "45 minutos", isSelected: type == IntervalType.TIME && value == 45, icon: .image(timeImage!), action: didToggleSelection(IntervalType.TIME, 45)),
                OptionRow(text: "60 minutos", isSelected: type == IntervalType.TIME && value == 60, icon: .image(timeImage!), action: didToggleSelection(IntervalType.TIME, 60)),
                OptionRow(text: "100 metros", isSelected: type == IntervalType.DISTANCE && value == 100, icon: .image(distanceImage!), action: didToggleSelection(IntervalType.DISTANCE, 100)),
                OptionRow(text: "250 metros", isSelected: type == IntervalType.DISTANCE && value == 250, icon: .image(distanceImage!), action: didToggleSelection(IntervalType.DISTANCE, 250)),
                OptionRow(text: "500 metros", isSelected: type == IntervalType.DISTANCE && value == 500, icon: .image(distanceImage!), action: didToggleSelection(IntervalType.DISTANCE, 500)),
                OptionRow(text: "1 km", isSelected: type == IntervalType.DISTANCE && value == 1000, icon: .image(distanceImage!), action: didToggleSelection(IntervalType.DISTANCE, 1000)),
                OptionRow(text: "2 km", isSelected: type == IntervalType.DISTANCE && value == 2000, icon: .image(distanceImage!), action: didToggleSelection(IntervalType.DISTANCE, 2000)),
                OptionRow(text: "5 km", isSelected: type == IntervalType.DISTANCE && value == 5000, icon: .image(distanceImage!), action: didToggleSelection(IntervalType.DISTANCE, 5000)),
                OptionRow(text: "10 km", isSelected: type == IntervalType.DISTANCE && value == 10000, icon: .image(distanceImage!), action: didToggleSelection(IntervalType.DISTANCE, 10000)),
            ])
        ]
    }
    
    private func didToggleSelection(_ type: IntervalType, _ value: Int) -> (Row) -> Void {
        return { [weak self] row in
            Settings.setIntervalType(value: type)
            Settings.setIntervalValue(value: value)
        }
    }
    
}
