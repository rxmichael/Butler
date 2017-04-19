//
//  DateTableViewCell.swift
//  Butler
//
//  Created by blackbriar on 9/6/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate: class {
    func datePickerTableViewCellDidUpdateDate(_ cell: DateTableViewCell)
}

class DateTableViewCell: UITableViewCell {


    fileprivate var datePickerExpandedHeight: CGFloat = 0
    weak var delegate: DatePickerTableViewCellDelegate?
    
    var date: Date {
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
        self.layoutMargins = UIEdgeInsets.zero
        self.selectionStyle = .none
        setSelected(true, animated: false)
        dateChanged(datePicker)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected && datePicker.isEnabled {
            let closed = datePicker.isHidden
            
            datePicker.isHidden = !closed
            datePickerHeightConstraint.constant = closed ? datePickerExpandedHeight : 0
        }
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        
        delegate?.datePickerTableViewCellDidUpdateDate(self)
    }

}
