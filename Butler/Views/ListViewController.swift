//
//  ListViewController.swift
//  Butler
//
//  Created by blackbriar on 9/4/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit
import CircleMenu
import CoreData

class ListViewController: UIViewController, CircleMenuDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let managedObjectContext = ((UIApplication.sharedApplication().delegate) as! AppDelegate).managedObjectContext
    
    var listItems = [Item]()
    
    let items: [(icon: String, color: UIColor)] = [
        ("appointment", UIColor(hex: 0x0099E8)),
        ("pin", UIColor(red:0.22, green:0.74, blue:0, alpha:1)),
        ("geo_fence", UIColor(hex: 0xFFC125)), //(red:0.96, green:0.23, blue:0.21, alpha:1)),
        ("ingredients", UIColor(hex: 0xA244D1)),
        //red:0.51, green:0.15, blue:1, alpha:1)),
        ("settings", UIColor(red:1, green:0.39, blue:0, alpha:1)),
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        let xCenter: CGFloat = (view.frame.size.width - 50)/2
        let yCenter: CGFloat = ((view.frame.size.height - 30)/2 + (tableView.frame.size.height)/3 )
        let button = CircleMenu(
            frame: CGRect(x: xCenter, y: yCenter, width: 50, height: 50),
            normalIcon:"plus",
            selectedIcon:"cancel",
            buttonsCount: 4,
            duration: 2,
            distance: 120)
        button.delegate = self
        button.layer.cornerRadius = button.frame.size.width / 2.0
        view.addSubview(button)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - CircleMenu Delegate
     */
    
    func circleMenu(circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        button.setImage(UIImage(imageLiteral: items[atIndex].icon), forState: .Normal)
        
        // set highlited image
        let highlightedImage  = UIImage(imageLiteral: items[atIndex].icon).imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(highlightedImage, forState: .Highlighted)
        button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
//        print("button will selected: \(atIndex)")
    }
    
    func circleMenu(circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
//        print("button did selected: \(atIndex)")
        self.performSegueWithIdentifier("addItem", sender: self)
        // not used for now
//        switch atIndex {
//        case 0:
//            break
//            
//        default:
//            break
//        }
    }
    
    // core data operations methods
    
    func fetchData() {
        let fetch = NSFetchRequest(entityName: "Item")
        //Q: how to "rerange"
        let dateSort  = NSSortDescriptor(key: "dueDate", ascending: true)
        fetch.sortDescriptors = [dateSort]
        do {
            let fetchResults = try managedObjectContext.executeFetchRequest(fetch) as! [Item]
            listItems = fetchResults
            tableView.reloadData()
        } catch let error as NSError  {
            fatalError("Failed to fetch category information: \(error)")
        }
    }
    
    func deleteFromCoreData(indexPath: NSIndexPath) {

        let oldItem = listItems[indexPath.row]
        managedObjectContext.deleteObject(oldItem)
        do {
            try managedObjectContext.save()
            showAlertWithOk("Successfully deleted", message: "Item successfuly deleted from storage")
        } catch let error as NSError {
            fatalError("Failed to delete run: \(error)")
        }
//        print("SUCCESSFULLY DELETED")
        
    }
    
    /* 
    // MARK: Tableview methods
     */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listItems.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let uiAlert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .Alert)
            uiAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
                self.deleteFromCoreData(indexPath)
                self.listItems.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }))
            uiAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(uiAlert, animated: true, completion: nil)   
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as! ItemTableViewCell
        let item = listItems[indexPath.row]
        cell.titleLabel!.text = item.title
        cell.dateLabel!.text = NSDateFormatter.localizedStringFromDate(item.dueDate!, dateStyle: .ShortStyle, timeStyle: .NoStyle)
        
        if item.dueDate!.timeIntervalSinceDate(NSDate()).isSignMinus {
            // due date has passed
            cell.dateLabel.textColor = UIColor(hex: 0xFF8C00)//FF7F00)//FF9500)
        } else {
            //due date has not passed
            cell.dateLabel.textColor = UIColor(hex: 0xF3F2F1)//A244D1)//F3F2F1)
        }
        if Bool(item.active!) {
//            print("ITEM  ACTIVE")
            cell.activeImage.image = UIImage(named: "locationon1")
        } else {
//            print("ITEM  INACTIVE")
            cell.activeImage.image = UIImage(named: "locationoff2")
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Here's your agenda"
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // get header as a view
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        // set background color and text color
        header.contentView.backgroundColor = UIColor(hex: 0xF3F2F1)//UIColor(hex: 0x0099E8)
        header.textLabel!.textColor = UIColor(hex: 0x0099E8)//UIColor.whiteColor()//(hex: 0xFF9912)
        header.textLabel!.textAlignment = .Center
    }
    
    // helper function to display a UI alert controller
    func showAlertWithOk(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertDismissAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(alertDismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailItem" {
            let detailVC = segue.destinationViewController as! AddItemTableViewController
            let item = listItems[(tableView.indexPathForSelectedRow?.row)!]
//            print("Selected item is \(item)")
            detailVC.item = item
        }
    }

}
