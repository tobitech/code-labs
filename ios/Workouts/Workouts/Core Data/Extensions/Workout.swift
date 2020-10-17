//
//  Workout.swift
//  Workouts
//
//  Created by Bart Jacobs on 05/02/2018.
//  Copyright © 2018 Cocoacasts. All rights reserved.
//

import CoreData

extension Workout {

    class func findAll(in managedObjectContext: NSManagedObjectContext) throws -> [Workout] {
        // Helpers
        var workouts: [Workout] = []
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        // Perform Fetch Request
        workouts = try managedObjectContext.fetch(fetchRequest)
        
        return workouts
    }
    
    /*
    class func findAll(in managedObjectContext: NSManagedObjectContext) -> [Workout] {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        return (try? managedObjectContext.fetch(fetchRequest)) ?? []
    }
    */
    
}
