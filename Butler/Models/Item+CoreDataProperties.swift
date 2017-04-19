//
//  Item+CoreDataProperties.swift
//  Butler
//
//  Created by blackbriar on 9/12/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var active: NSNumber?
    @NSManaged var dueDate: Date?
    @NSManaged var latitude: NSNumber?
    @NSManaged var location: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var title: String?
    @NSManaged var radius: NSNumber?

}
