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
    @IBOutlet weak var acceptButton: UIButton!
    
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
        
        self.setupTextViews()
        
        // See if this page is for a specific person
        if (defaultName != nil) {
            self.nameField.text = defaultName
            titleString += " with " + defaultName!
            self.nameField.editable = false
            self.nameField.textColor = UIColor.darkGrayColor()
        }
        
        self.title = titleString
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = ColorStyles.white
        self.navigationController?.navigationBar.tintColor = ColorStyles.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName :ColorStyles.black]
        self.navigationController?.hideShadow = false
        
        self.acceptButton.backgroundColor = ColorStyles.green
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var maxChars:Int
        
        if textView == reasonField {
            maxChars = 35
        }
        else {
            maxChars = 20
        }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        //If the text is larger than the maxtext, the return is false
        return countElements(textView.text) + (countElements(text) - range.length) <= maxChars
        
    }
    
    // Other functions
    func setupTextViews() {
        // Set delegates for the text views
        nameField.delegate = self
        amountField.delegate = self
        reasonField.delegate = self
        
        nameField.textContainer.maximumNumberOfLines = 1;
        
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

