//
//  DateTableViewCell.swift
//  Butler
//
//  Created by blackbriar on 9/6/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate: class {
    func datePickerTableViewCellDidUpdateDate(cell: DateTableViewCell)
}

class DateTableViewCell: UITableViewCell {


    private var datePickerExpandedHeight: CGFloat = 0
    weak var delegate: DatePickerTableViewCellDelegate?
    
    var date: NSDate {
        get {
            return datePicker.date
        }
        set {
            datePicker.date = newValue
            dateChanged(datePicker)
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        datePickerExpanded = datePickerHeightConstraint.constant
//        print("datepicker expanded height \(datePickerExpandedHeight)")
        self.layoutMargins = UIEdgeInsetsZero
        self.selectionStyle = .None
        setSelected(true, animated: false)
        dateChanged(datePicker)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected && datePicker.enabled {
            let closed = datePicker.hidden
            
            datePicker.hidden = !closed
            datePickerHeightConstraint.constant = closed ? datePickerExpandedHeight : 0
        }
    }
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        dateLabel.text = NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        
        delegate?.datePickerTableViewCellDidUpdateDate(self)
    }

}
