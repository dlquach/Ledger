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
    var account: NSManagedObject!
    var tableView: UITableView = UITableView()
    var transactions = [(NSString, Float)]()
    var name: NSString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name = account.valueForKey("name") as NSString
        self.title = name
        
        self.tableView.frame = UIScreen.mainScreen().bounds
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.tableView)

        // Get all the reasons and values
        // TODO: pull this into its own method since its being copied so much
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext  = appDelegate.managedObjectContext!

        let fetchRequest = NSFetchRequest(entityName: "Transactions")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        var error: NSError?

        let entities = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]!
        if entities.count != 0 {
            for entity in entities {
                let reason: NSString = entity.valueForKey("reason") as NSString
                let amount: Float = entity.valueForKey("amount") as Float
                transactions.append((reason, amount))
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        let transaction = self.transactions[indexPath.row]
        
        cell.textLabel?.text = transaction.0 + " : " + NSString(format: "%.2f", transaction.1)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }
}
