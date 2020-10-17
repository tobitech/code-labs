//
//  ViewController.swift
//  Workouts
//
//  Created by Bart Jacobs on 05/02/2018.
//  Copyright © 2018 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // MARK: - Properties
    
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // Fetch Workouts
            let workouts = try Workout.findAll(in: managedObjectContext)
            
            print(workouts)
        } catch {
            print("Unable to Fetch Workouts, (\(error))")
        }
        
        /*
        // Fetch Workouts
        if let workouts = try? Workout.findAll(in: managedObjectContext) {
            print(workouts)
        } else {
            print("Unable to Fetch Workouts")
        }
        */
    }

}
