//
//  ios_getting_startedApp.swift
//  ios-getting-started
//
//  Created by Oluwatobi Omotayo on 21/03/2021.
//

import SwiftUI

@main
struct ios_getting_startedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    public init() {
        // initialize amplify
        let _ = Backend.initialize()
    }
}
