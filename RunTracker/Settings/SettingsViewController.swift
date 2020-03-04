//
//  SettingsViewController.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 26/02/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import UIKit
import QuickTableViewController

class SettingsViewController : QuickTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableContents = [
            
            Section(title: "Notificaciones", rows: [
                NavigationRow(text: "Cadencia", detailText: .none, icon: .image(UIImage(systemName: "metronome")!), action: { _ in
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "CadenceSettingsViewController") as! CadenceSettingsViewController
                    self.navigationController!.pushViewController(viewController, animated: true)
                }),
                NavigationRow(text: "Intervalos", detailText: .none, icon: .image(UIImage(systemName: "stopwatch")!), action: { _ in
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "IntervalSettingsViewController") as! IntervalSettingsViewController
                    self.navigationController!.pushViewController(viewController, animated: true)
                })
            ]),
            
            Section(title: "Entreno", rows: [
                NavigationRow(text: "Precisión GPS", detailText: .none, icon: .image(UIImage(systemName: "location")!), action: { _ in
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "GpsSettingsViewController") as! GpsSettingsViewController
                    self.navigationController!.pushViewController(viewController, animated: true)
                }),
                SwitchRow(text: "Autopause", switchValue: Settings.getAutoPause(), icon: .image(UIImage(systemName: "pause")!), action: { row in
                    Settings.setAutoPause(value: (row as! SwitchRow).switchValue)
                })
            ])
        ]
    }
    
    
    
}
