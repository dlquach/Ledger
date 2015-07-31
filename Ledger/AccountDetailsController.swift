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
        self.name = account.valueForKey("name") as NSString
        self.nameLabel.text = name
        
        // Set up table view stuff
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // TODO: pull this into its own method since its being copied so much
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
                totalDue += amount
            }
        }
        
        self.amountLabel.text = "$ " + NSString(format: "%.2f", totalDue)
        
        // There's probably a way better way to handle plurality
        if (self.transactions.count > 1) {
            self.numTransactionsLabel.text = NSString(format: "%d Transactions", self.transactions.count)
        }
        else {
            self.numTransactionsLabel.text = NSString(format: "%d Transaction", self.transactions.count)
        }
        
        // Change the header view color based on whether or not this account is in the red or black
        if self.totalDue >= 0 {
            headerView.backgroundColor = ColorStyles.green
            self.navigationController?.navigationBar.barTintColor = ColorStyles.green
        }
        else {
            headerView.backgroundColor = ColorStyles.red
            self.navigationController?.navigationBar.barTintColor = ColorStyles.red
        }
        self.navigationController?.navigationBar.tintColor = ColorStyles.white
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        // Create add button
        let addButton: UIBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: "createNewTransactionWithName")
        self.navigationItem.rightBarButtonItem = addButton
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(self.transactions.count)
        return self.transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        let transaction = self.transactions[indexPath.row]
        
        cell.textLabel?.text = transaction.0 + " : " + NSString(format: "%.2f", transaction.1)
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }
    
}
