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
    
    @IBAction func acceptButtonPressed(sender: AnyObject) {
        println(nameField.text)
        println(amountField.text)
        println(reasonField.text)
        
        // See if the person already exists or not. If so, add the amounts instead of creating a new entity
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext! // The '!' means you are assuring mangagedObjectContext is not nil
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let predicate = NSPredicate(format: "name == %@", nameField.text)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        var error: NSError?
        let entity = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]!
        
        if entity.count != 0 {
            println("Object already exists")
            
            let person = entity[0]
            person.setValue(person.valueForKey("amount")!.floatValue + (amountField.text as NSString).floatValue, forKey: "amount")
        }
        else {
            println("Object does not exist")
            
            // Create a new entity to store
            let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
            
            let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            person.setValue(nameField.text, forKey: "name")
            person.setValue((amountField.text as NSString).floatValue, forKey: "amount")
            
            
        }
        
        // Save the amounts to CoreData
        if !managedContext.save(&error) {
            println("Could not save, \(error), \(error?.userInfo)")
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.	
    }
    
    
}

