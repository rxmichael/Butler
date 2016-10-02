//
//  AddItemTableViewController.swift
//  Butler
//
//  Created by blackbriar on 9/5/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit
import CoreData

class AddItemTableViewController: UITableViewController, DatePickerTableViewCellDelegate, SetLocationDelegate {

    var managedObjectContext : NSManagedObjectContext?
    var item: Item?
    
    private var date = NSDate()
    let titleSection = 0
    let locationSection = 1
    let rowInSection = 0
    var longitude: Double = 0
    var latitude: Double = 0
    var selectedRowIndex  = 0
    var cellTapped = false
    
    var titleCell : TitleTableViewCell!
    var locationCell : LocationTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        tableView.tableFooterView = UIView()
        setupCells()
        self.navigationController!.navigationBar.tintColor = UIColor(hex: 0x0099E8)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor(hex: 0x0099E8)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Table view data source
     */

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func setupCells() {
        titleCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: titleSection)) as! TitleTableViewCell
        locationCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: locationSection)) as! LocationTableViewCell
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as! TitleTableViewCell
            if let item = item {
                cell.titleTextField.text = item.title
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as!LocationTableViewCell
            if let item = item {
//                print("ITEM location is \(item.location)")
                cell.locationLabel.text = item.location
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("dateCell", forIndexPath: indexPath) as!DateTableViewCell
            if let item = item {
                cell.date = item.dueDate!
            }
            else {
                cell.date = date
            }
            cell.datePicker.enabled = true
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("radiusCell", forIndexPath: indexPath) as!RadiusTableViewCell
            if let item = item {
                cell.setRadius(Double(item.radius!))
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("activeCell", forIndexPath: indexPath) as!ActiveTableViewCell
            if let item = item {
                let active = item.active as! Bool
                cell.activeSwitch.setOn(active, animated: true)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func datePickerTableViewCellDidUpdateDate(cell: DateTableViewCell) {
        date = cell.date
    }
    
    // dynamically resize the height of the date cell

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 2 && self.selectedRowIndex == 2 && cellTapped {
            return 244
        }
        
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedRowIndex != indexPath.section {
            self.selectedRowIndex = indexPath.section
            self.cellTapped = true
        }
        else {
            self.cellTapped = false
            self.selectedRowIndex = -1
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        if titleCell.titleTextField.text!.isEmpty {
            showAlert("Error", message: "Name cannot be empty", buttonPrompt: "Ok")
            return
        }
        if locationCell.locationLabel.text == "show map" {
            showAlert("Error", message: "You have to set the location", buttonPrompt: "Ok")
            return
        }
        if item == nil {
//            print("Creating new enetity")
            item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: managedObjectContext!) as! Item
        }
        let sections = numberOfSectionsInTableView(self.tableView)
        for section in 0 ..< sections {
            switch section {
            case 0:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: section)) as! TitleTableViewCell
                if item!.title != cell.titleTextField.text {
                    item!.title = cell.titleTextField.text
                }
                break
            case 1:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: section)) as! LocationTableViewCell
                if item!.location != cell.locationLabel.text {
                    item!.location = cell.locationLabel.text
                }
                break
            case 2:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: section)) as! DateTableViewCell
                if item!.dueDate != cell.date {
                    item!.dueDate = cell.date
                }
                break
            case 3:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: section)) as! RadiusTableViewCell
                if item!.radius != cell.getDescription() {
                    item!.radius = cell.getDescription()
                }
                break
            case 4:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: section)) as! ActiveTableViewCell
                if item!.active != cell.activeSwitch.on {
                    item!.active = cell.activeSwitch.on
                }
//                print("SETTING ITEM to \(cell.activeSwitch.on)")
                break
//            case 4:
//                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: section)) as! ToggleTableViewCell
//                if(cell.switchNotify.on){
//                    categoryToAdd?.toogle=true
//                }else{
//                    categoryToAdd?.toogle=false
//                }
//                break
//            default:
//                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: section)) as! SegementTableViewCell
//                
//                if(cell.whenSegment.selectedSegmentIndex == 0){// arrive
//                    categoryToAdd?.notifyByArriveOrLeave = 0
//                }else{// leave
//                    categoryToAdd?.notifyByArriveOrLeave = 1
//                }
//                break
//            }
//        }
            default:
                break
            }
        }
        if self.latitude != 0 && self.longitude != 0 {
            item!.latitude = self.latitude
            item!.longitude = self.longitude
        }
        do {
            try managedObjectContext!.save()
//            print("SAVED")
            showAlertSuccess("Success", message: "Item successfully updated", buttonPrompt: "Ok")
        }
        catch let error as NSError {
            fatalError("Failed to save: \(error)")
        }
        
    }
    
    func showAlert(title:String, message:String, buttonPrompt: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertDismissAction = UIAlertAction(title: buttonPrompt, style: .Default, handler: nil)
        alertController.addAction(alertDismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func showAlertSuccess(title:String, message:String, buttonPrompt: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertDismissAction = UIAlertAction(title: buttonPrompt, style: .Default) {(action: UIAlertAction) in
            // have to make a dispatch call not to get kernel error from Xcode at runtime
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        alertController.addAction(alertDismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* 
    // MARK: - SetLocationDelegate
     */
    
    func setLocation(lastLocation: Location) {
//        print("set location called")
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowInSection, inSection: locationSection)) as! LocationTableViewCell
        cell.locationLabel.text = lastLocation.name
//        print("longitude is \(lastLocation.latitude)")
        self.latitude = lastLocation.latitude
        self.longitude = lastLocation.longitude

    }
    
    /*
     // MARK: - Navigation
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            let destination = segue.destinationViewController as! MapViewController
            if item != nil {
                destination.lastLocation = Location(name: (item!.location)!, longitude: Double(item!.longitude!), latitude: Double(item!.latitude!))
            }
            destination.setLocationDelegate = self
        }
    }

}
