//
//  RadiusTableViewCell.swift
//  Butler
//
//  Created by blackbriar on 9/9/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit

class RadiusTableViewCell: UITableViewCell {


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutMargins = UIEdgeInsetsZero
        self.selectionStyle = .None
    }

    @IBOutlet weak var radiusSegment: UISegmentedControl!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func getDescription() -> Double {
        switch radiusSegment.selectedSegmentIndex {
        case 0:
            return 50.0
        case 1:
            return 250.0
        case 2:
            return 1000.0
        default:
            return 1000.0
        }
    }
    func setRadius(radius: Double) {
        switch radius {
        case 50.0:
            self.radiusSegment.selectedSegmentIndex = 0
        case 250.0:
            self.radiusSegment.selectedSegmentIndex = 1
        case 1000.0:
            self.radiusSegment.selectedSegmentIndex = 2
        default:
            self.radiusSegment.selectedSegmentIndex = 2
        }
    }
    
    
    
    

}
