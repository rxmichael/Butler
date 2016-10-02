//
//  ActiveTableViewCell.swift
//  Butler
//
//  Created by blackbriar on 9/12/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit

class ActiveTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutMargins = UIEdgeInsetsZero
        self.selectionStyle = .None
    }

    @IBOutlet weak var activeSwitch: UISwitch!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
