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

    var accounts = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Balances"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext  = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            accounts = results
            for account in accounts {
                println(account.valueForKey("name"))
                println(account.valueForKey("amount"))
                tableView.reloadData()
            }
        }
        else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            println(accounts.count)
            return accounts.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
                as UITableViewCell
            
            cell.textLabel.text =
                (accounts[indexPath.row].valueForKey("name") as NSString) + " : " +
                NSString(format: "%.2f", (accounts[indexPath.row].valueForKey("amount")) as Float)
            
            return cell
    }

}

