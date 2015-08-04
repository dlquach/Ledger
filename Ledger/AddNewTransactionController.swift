//
//  AddNewTransaction.swift
//  Ledger
//
//  Created by Derek Quach on 1/28/15.
//  Copyright (c) 2015 Derek Quach. All rights reserved.
//

import UIKit
import CoreData

class AddNewTransactionController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var reasonField: UITextField!
    
    var defaultName: String?
    
    @IBAction func acceptButtonPressed(sender: AnyObject) {
        let name = nameField.text.capitalizedString
        let amount = (amountField.text as NSString).floatValue
        let reason = reasonField.text.capitalizedString
        var error: NSError?
        
        println(amountField.text)
        println(reason)
        
        // See if the person already exists or not. 
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext! // The '!' means you are assuring mangagedObjectContext is not nil

        let fetchRequest = NSFetchRequest(entityName: "Person")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        let people = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]!
        
        // This person doesn't exist in CoreData, create an entry for them.
        if people.count == 0 {
            let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
            let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            person.setValue(name, forKey: "name")
        }
        
        // Create a new transactions entity to store
        let entity = NSEntityDescription.entityForName("Transactions", inManagedObjectContext: managedContext)
        
        let transaction = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        transaction.setValue(name, forKey: "name")
        transaction.setValue(amount, forKey: "amount")
        transaction.setValue(reason, forKey: "reason")
        
        // Save the amounts to CoreData
        if !managedContext.save(&error) {
            println("Could not save, \(error), \(error?.userInfo)")
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var titleString = "New Transcation"

        // See if this page is for a specific person
        if (defaultName != nil) {
            self.nameField.text = defaultName
            titleString += " with " + defaultName!
            self.nameField.enabled = false
            self.nameField.borderStyle = UITextBorderStyle.None
        }
        self.title = titleString
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = ColorStyles.white
        self.navigationController?.navigationBar.tintColor = ColorStyles.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName :ColorStyles.black]
        self.navigationController?.hideShadow = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.	
    }
    
    
}

