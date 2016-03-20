//
//  OverviewController.swift
//  Ledger
//
//  Created by Derek Quach on 1/23/15.
//  Copyright (c) 2015 Derek Quach. All rights reserved.
//

import UIKit
import CoreData

class OverviewController: UIViewController, UITableViewDataSource {

    var people = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelectionDuringEditing = false
        
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = ColorStyles.white
        self.navigationController?.navigationBar.tintColor = ColorStyles.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName :ColorStyles.black]
        self.navigationController?.hideShadow = false
      
        // Re-enable the status bar
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext  = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        do {
            let fetchedResults =
                try managedContext.executeFetchRequest(fetchRequest)
            people = fetchedResults as! [NSManagedObject]
            
            for _ in people {
                tableView.reloadData() // Is this really efficient? No.
            }
        
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView,
        didSelectRowAtIndexPath
        indexPath: NSIndexPath) {
            //let vc = AccountDetailsController()
            let vc = storyboard?.instantiateViewControllerWithIdentifier("AccountDetails") as! AccountDetailsController
            vc.account = people[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return people.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            let cell =
            tableView.dequeueReusableCellWithIdentifier("accountCell")
                as! AccountCell
   
            let name = people[indexPath.row].valueForKey("name") as! NSString
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext  = appDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName: "Transactions")
            let predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.predicate = predicate
            
            do {
                let fetchResults =
                    try managedContext.executeFetchRequest(fetchRequest)
                let entities = fetchResults as! [NSManagedObject]
                
                var amount: Float = 0.0
                if entities.count != 0 {
                    for entity in entities {
                        amount += entity.valueForKey("amount") as! Float
                    }
                }
                
                if amount >= 0 {
                    cell.amountLabel.textColor = ColorStyles.teal
                }
                else {
                    cell.amountLabel.textColor = ColorStyles.red
                }
                
                cell.nameLabel.text = name as String
                cell.amountLabel.text = (NSString(format: "$%.2f", abs(amount))) as String
                if entities.count == 1 {
                    cell.transactionLabel.text = (NSString(format: "%d Transaction", entities.count)) as String
                }
                else {
                    cell.transactionLabel.text = (NSString(format: "%d Transactions", entities.count)) as String
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }

            
            
            return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext  = appDelegate.managedObjectContext
            
            // Delete all the transcations associated with this person
            let fetchRequest = NSFetchRequest(entityName: "Transactions")
            let predicate = NSPredicate(format: "name == %@", people[indexPath.row].valueForKey("name") as! NSString)
            fetchRequest.predicate = predicate
            
            do {
                let fetchResults =
                    try managedContext.executeFetchRequest(fetchRequest)
                let entities = fetchResults as! [NSManagedObject]
                

            
                if entities.count != 0 {
                    for entity in entities {
                        managedContext.deleteObject(entity)
                    }
                }
            
                managedContext.deleteObject(people[indexPath.row])

                people.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }

    }
    
  
}

