//
//  AccountDetailsController.swift
//  Ledger
//
//  Created by Derek Quach on 7/30/15.
//  Copyright (c) 2015 Derek Quach. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AccountDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var numTransactionsLabel: UILabel!
    
    
    var account: NSManagedObject!
    var transactions = [(NSString, Float)]()
    var name: NSString!
    var totalDue: Float = 0.0
    
    func createNewTransactionWithName() {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("NewTransaction") as AddNewTransactionController
        vc.defaultName = name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.navigationController?.hideShadow = true
        
        self.name = account.valueForKey("name") as NSString
        self.nameLabel.text = name
        
        // Set up table view stuff
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Setup the header view
        self.updateHeaderView()
        
        // Create add button
        let addButton: UIBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: "createNewTransactionWithName")
        self.navigationItem.rightBarButtonItem = addButton
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateHeaderView()
    }
    
    func updateHeaderView() {
        self.totalDue = self.grabTransactionsAndComputeBalance()
        
        self.amountLabel.text = "$ " + NSString(format: "%.2f", totalDue)
        if (totalDue == 0) {
            self.amountLabel.text = "Nothing"
        }
        println("HEY")
        println(self.transactions.count)
        // There's probably a way better way to handle plurality
        if (self.transactions.count == 1) {
            self.numTransactionsLabel.text = NSString(format: "%d Transaction", self.transactions.count)
        }
        else {
            self.numTransactionsLabel.text = NSString(format: "%d Transactions", self.transactions.count)
        }
        
        // Change the header view color based on whether or not this account is in the red or black
        if self.totalDue >= 0 {
            headerView.backgroundColor = ColorStyles.teal
            self.navigationController?.navigationBar.barTintColor = ColorStyles.teal
        }
        else {
            headerView.backgroundColor = ColorStyles.red
            self.navigationController?.navigationBar.barTintColor = ColorStyles.red
        }
        self.navigationController?.navigationBar.tintColor = ColorStyles.white
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    }
    
    func grabTransactionsAndComputeBalance() -> Float {
        // Wipe the most likely outdated transactions array
        self.transactions = [(NSString, Float)]()
        var total: Float = 0.0
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext  = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Transactions")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        var error: NSError?
        
        // Get all the transactions
        let entities = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]!
        if entities.count != 0 {
            for entity in entities {
                let reason: NSString = entity.valueForKey("reason") as NSString
                let amount: Float = entity.valueForKey("amount") as Float
                transactions.append((reason, amount))
                total += amount
            }
        }
        return total
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(self.transactions.count)
        return self.transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:TransactionCell = tableView.dequeueReusableCellWithIdentifier("transactionCell") as TransactionCell
        let transaction = self.transactions[indexPath.row]
        
        let amount = transaction.1
        
        cell.reasonLabel.text = transaction.0
        cell.amountLabel.text = NSString(format: "$%.2f", amount)
        
        if amount >= 0 {
            cell.amountLabel.textColor = ColorStyles.teal
        }
        else {
            cell.amountLabel.textColor = ColorStyles.red
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext  = appDelegate.managedObjectContext!
            
            // Delete all the transcations associated with this person
            let fetchRequest = NSFetchRequest(entityName: "Transactions")
            let predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.predicate = predicate
            var error: NSError?
            
            let entities = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]!
            
            
            managedContext.deleteObject(entities[indexPath.row])
            
            if !managedContext.save(&error) {
                println("Could not save the delete!")
            }
            self.transactions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.updateHeaderView()
        }
        
    }
    
}
