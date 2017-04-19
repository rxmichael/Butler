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
    
    let managedObjectContext = ((UIApplication.shared.delegate) as! AppDelegate).managedObjectContext
    
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
        button.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
//            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin
        view.addSubview(button)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        
        // set highlited image
        let highlightedImage  = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
//        print("button will selected: \(atIndex)")
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
//        print("button did selected: \(atIndex)")
        self.performSegue(withIdentifier: "addItem", sender: self)
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
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        //Q: how to "rerange"
        let dateSort  = NSSortDescriptor(key: "dueDate", ascending: true)
        fetch.sortDescriptors = [dateSort]
        do {
            let fetchResults = try managedObjectContext.fetch(fetch) as! [Item]
            listItems = fetchResults
            tableView.reloadData()
        } catch let error as NSError  {
            fatalError("Failed to fetch category information: \(error)")
        }
    }
    
    func deleteFromCoreData(_ indexPath: IndexPath) {

        let oldItem = listItems[indexPath.row]
        managedObjectContext.delete(oldItem)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let uiAlert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            uiAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.deleteFromCoreData(indexPath)
                self.listItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .none)
            }))
            uiAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(uiAlert, animated: true, completion: nil)   
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! ItemTableViewCell
        let item = listItems[indexPath.row]
        cell.titleLabel!.text = item.title
        cell.dateLabel!.text = DateFormatter.localizedString(from: item.dueDate! as Date, dateStyle: .short, timeStyle: .none)
        
        if (item.dueDate! as NSDate).timeIntervalSince(NSDate() as Date).sign == .minus {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Here's your agenda"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // get header as a view
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        // set background color and text color
        header.contentView.backgroundColor = UIColor(hex: 0xF3F2F1)//UIColor(hex: 0x0099E8)
        header.textLabel!.textColor = UIColor(hex: 0x0099E8)//UIColor.whiteColor()//(hex: 0xFF9912)
        header.textLabel!.textAlignment = .center
    }
    
    // helper function to display a UI alert controller
    func showAlertWithOk(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertDismissAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertDismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailItem" {
            let detailVC = segue.destination as! AddItemTableViewController
            let item = listItems[(tableView.indexPathForSelectedRow?.row)!]
//            print("Selected item is \(item)")
            detailVC.item = item
        }
    }

}
