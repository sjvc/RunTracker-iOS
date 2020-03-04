//
//  RunHistoryTableViewController.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 04/03/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import UIKit
import CoreData

class RunHistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var frc : NSFetchedResultsController<Run>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let miDelegate = UIApplication.shared.delegate! as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let consulta = NSFetchRequest<Run>(entityName: "Run")
        let sortDescriptors = [NSSortDescriptor(key:"date", ascending:false)]
        consulta.sortDescriptors = sortDescriptors
        self.frc = NSFetchedResultsController<Run>(fetchRequest: consulta, managedObjectContext: miContexto, sectionNameKeyPath: nil, cacheName: nil)
        
        self.frc.delegate = self;
        
        //ejecutamos el fetch
        try! self.frc.performFetch()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.frc.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frc.sections![section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiCelda", for: indexPath)
        
        let run = self.frc.object(at: indexPath)
        cell.textLabel?.text = DateFormatter.localizedString(from: run.date!, dateStyle: .short, timeStyle: .medium)
        cell.detailTextLabel?.text = FormatDisplay.distance(meters: run.distance) + " km."
        
        return cell
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with:.automatic )
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            self.tableView.insertRows(at: [newIndexPath!], with:.automatic )
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case .insert:
            self.tableView.insertSections(IndexSet(integer:sectionIndex), with: .automatic)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
        default: break
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let miDelegate = UIApplication.shared.delegate as! AppDelegate
                let miContexto = miDelegate.persistentContainer.viewContext

                let run = self.frc.object(at: indexPath)
                miContexto.delete(run)
                
                try! miContexto.save()
            }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
