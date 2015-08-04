//
//  AddNewTransaction.swift
//  Ledger
//
//  Created by Derek Quach on 1/28/15.
//  Copyright (c) 2015 Derek Quach. All rights reserved.
//

import UIKit
import CoreData

class AddNewTransactionController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameField: UITextView!
    @IBOutlet weak var amountField: UITextView!
    @IBOutlet weak var reasonField: UITextView!
    
    var defaultName: String?
    
    @IBAction func acceptButtonPressed(sender: AnyObject) {
        let name = nameField.text.capitalizedString
        let amount = (amountField.text as NSString).floatValue
        let reason = reasonField.text.capitalizedString
        var error: NSError?
        
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
            self.nameField.editable = false
        }
        self.title = titleString
        
        self.setupTextViews()
        
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
    
    // Text view control stuff
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            if textView == nameField {
                textView.text = "Name"
            }
            else if textView == amountField {
                textView.text = "Amount"
            }
            else if textView == reasonField {
                textView.text = "Reason"
            }
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    // Other functions
    func setupTextViews() {
        // Set delegates for the text views
        nameField.delegate = self
        amountField.delegate = self
        reasonField.delegate = self
        
        nameField.text = "Name"
        nameField.textColor = UIColor.lightGrayColor()
        amountField.text = "Amount"
        amountField.textColor = UIColor.lightGrayColor()
        reasonField.text = "Reason"
        reasonField.textColor = UIColor.lightGrayColor()
        
        nameField.layer.borderColor = ColorStyles.black.CGColor
        nameField.layer.borderWidth = 1
        amountField.layer.borderColor = ColorStyles.black.CGColor
        amountField.layer.borderWidth = 1
        reasonField.layer.borderColor = ColorStyles.black.CGColor
        reasonField.layer.borderWidth = 1
    }
}

