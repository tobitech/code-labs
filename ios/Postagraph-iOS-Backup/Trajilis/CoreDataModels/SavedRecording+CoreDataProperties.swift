//
//  SavedRecording+CoreDataProperties.swift
//  Trajilis
//
//  Created by bharats802 on 23/05/19.
//  Copyright © 2019 Johnson. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedRecording {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedRecording> {
        return NSFetchRequest<SavedRecording>(entityName: "SavedRecording")
    }

    @NSManaged public var filepath: String?
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var recordedOn: Double
    
}
