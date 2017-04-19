//
//  ItemAnnotation.swift
//  Butler
//
//  Created by blackbriar on 9/12/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import Foundation
import MapKit

// Custom annotation to include an Item, for easier retrieval when an annotation is tapped
class ItemAnnotation: NSObject, MKAnnotation {
    
    fileprivate var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    var pinColor: UIColor?
    
    var title: String?
    var subtitle: String?
    var item: Item?
    
    func setCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
    
    // Build annotation from the item information
    func buildFromItem(_ item: Item) {
        
        self.setCoordinate(CLLocationCoordinate2D(latitude: Double(item.latitude!), longitude: Double(item.longitude!)))
        self.title = item.title
        self.item = item
        let active =  item.active as! Bool
//        print("\(item.title) IS ACTIVE \(active)")
        if active {
            self.pinColor = UIColor.red
        }
        else {
            self.pinColor = UIColor(hex: 0xA244D1)
        }
    }
}
