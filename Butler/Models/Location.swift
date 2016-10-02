//
//  Location.swift
//  Butler
//
//  Created by blackbriar on 9/26/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import Foundation

class Location {
    var name: String!
    var longitude: Double!
    var latitude: Double!
    
    init(name: String, longitude: Double, latitude: Double) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
    }
    
    
}