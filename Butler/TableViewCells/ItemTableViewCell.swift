//
//  ItemTableViewCell.swift
//  Butler
//
//  Created by blackbriar on 9/28/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutMargins = UIEdgeInsetsZero
        self.selectionStyle = .None
        self.activeImage.layer.cornerRadius = 5
    }
    
    @IBOutlet weak var activeImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
