//
//  AddNewTransaction.swift
//  Ledger
//
//  Created by Derek Quach on 1/28/15.
//  Copyright (c) 2015 Derek Quach. All rights reserved.
//

import UIKit
import CoreData

class AddNewTransactionController: UIViewController, UITextViewDelegate, UIBarPositioningDelegate {
    
    var defaultName: String?
    
    @IBOutlet weak var nameField: UITextView!
    @IBOutlet weak var amountField: UITextView!
    @IBOutlet weak var reasonField: UITextView!
    @IBOutlet weak var chargeButton: UIButton!
    @IBOutlet weak var toPayButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var interactor:Interactor? = nil
    
    @IBAction func dismissGesture(sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translationInView(view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .Began:
            interactor.hasStarted = true
            dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.updateInteractiveTransition(progress)
        case .Cancelled:
            interactor.hasStarted = false
            interactor.cancelInteractiveTransition()
        case .Ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finishInteractiveTransition()
                : interactor.cancelInteractiveTransition()
        default:
            break
        }
    }
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func acceptButtonPressed(sender: AnyObject) {
        if validateFieldsAndPopup() {
            return
        }
        
        let name = nameField.text.capitalizedString
        var amount = (amountField.text.stringByReplacingOccurrencesOfString("$", withString: "") as NSString).floatValue
        let reason = reasonField.text.capitalizedString
        
        // Charge or To Pay
        if sender as! NSObject == chargeButton {
            amount = abs(amount)
        }
        else {
            amount = abs(amount) * -1
        }
        
        // See if the person already exists or not. 
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext // The '!' means you are assuring mangagedObjectContext is not nil

        let fetchRequest = NSFetchRequest(entityName: "Person")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do {
            let fetchResults =
                try managedContext.executeFetchRequest(fetchRequest)
            let people = fetchResults as! [NSManagedObject]
            
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
            transaction.setValue(NSDate(), forKey: "date")
            
            // Save the amounts to CoreData
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let titleString = "New Transcation"
        
        self.setupTextViews()
        
        // See if this page is for a specific person
        if (defaultName != nil) {
            self.nameField.text = defaultName
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
        
        self.chargeButton.backgroundColor = ColorStyles.green
        self.toPayButton.backgroundColor = ColorStyles.red
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
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
        if textView == amountField {
            textView.text = textView.text.stringByReplacingOccurrencesOfString("$", withString: "")
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == nameField {
            formatNameField(textView)
        }
        else if textView == amountField {
            formatAmountField(textView)
        }
        else if textView == reasonField {
            formatReasonField(textView)
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
        return textView.text.characters.count + (text.characters.count - range.length) <= maxChars
        
    }
    
    // Other functions
    func generateTextBorder(textView: UITextView) -> CALayer {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: textView.frame.size.height - width, width: textView.frame.size.width, height: textView.frame.size.height)
        border.borderWidth = width
        
        return border
    }
    
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
        
        nameField.layer.borderWidth = 0.0
        amountField.layer.borderWidth = 0.0
        
        let nameBorder = generateTextBorder(nameField)
        let amountBorder = generateTextBorder(amountField)
        
        nameField.layer.addSublayer(nameBorder)
        nameField.layer.masksToBounds = true
        amountField.layer.addSublayer(amountBorder)
        amountField.layer.masksToBounds = true
        
        
        reasonField.layer.borderColor = UIColor.darkGrayColor().CGColor
        reasonField.layer.borderWidth = 1
    }
    
    func validateFieldsAndPopup() -> Bool {
        var alertController: UIAlertController?
        if nameField.textColor == UIColor.lightGrayColor() || nameField.text.isEmpty {
            alertController = UIAlertController(title: "Incomplete Form", message:
                "Please fill out a name", preferredStyle: UIAlertControllerStyle.Alert)
            alertController!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        }
        else if amountField.textColor == UIColor.lightGrayColor() || amountField.text.isEmpty {
            alertController = UIAlertController(title: "Incomplete Form", message:
                "Please fill out an amount", preferredStyle: UIAlertControllerStyle.Alert)
            alertController!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        }
        else if reasonField.textColor == UIColor.lightGrayColor() || reasonField.text.isEmpty {
            alertController = UIAlertController(title: "Incomplete Form", message:
                "Please fill out a reason", preferredStyle: UIAlertControllerStyle.Alert)
            alertController!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        }
        if alertController != nil {
            self.presentViewController(alertController!, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    func formatNameField(textView: UITextView) {
        if textView == nameField {
            if textView.text.isEmpty {
                textView.text = "Name"
                textView.textColor = UIColor.lightGrayColor()
            }
            else {
                textView.text = textView.text.capitalizedString
            }
        }
    }
    
    func formatAmountField(textView: UITextView) {
        if textView == amountField {
            if textView.text.isEmpty {
                textView.text = "Amount"
                textView.textColor = UIColor.lightGrayColor()
            }
            else {
                let amount = (textView.text.stringByReplacingOccurrencesOfString("$", withString: "") as NSString).floatValue
                textView.text = "$" + (NSString(format: "%.2f", abs(amount)) as String)
            }
        }
    }
    
    func formatReasonField(textView: UITextView) {
        if textView == reasonField {
            if textView.text.isEmpty {
                textView.text = "Reason"
                textView.textColor = UIColor.lightGrayColor()
            }
        }
    }
}

