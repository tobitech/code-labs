//
//  AppStoryboard.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

struct Router {
    
    static func get<T: UIViewController>() -> T {
        // view controller storyboard name is expected to be the class name of view controller
        let storyboardID    = "\(T.self)"
        // view controller name is expected to be in format <StoryBoard name>ViewController
        let storyboardName  = storyboardID.replacingOccurrences(of: "ViewController", with: "")
        let storyboard      = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: storyboardID) as! T
    }

}

enum AppStoryboard: String {
    case main
    case auth
    case initial
    case home
    case profile
    case onboarding
    case favorite
    case message
    case trips
    case comment
    case likes
    case terminal
    case notification
    case video
    case feed
    case places
    case search
    case nearby
    case tripster
    case flight
    case follow
    case invite
    case trending
    case hotels
    case settings
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue.capitalized, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type,
                                             function: String = #function, line: Int = #line,
                                             file: String = #file) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID)," +
                "not found in \(self.rawValue) Storyboard.\nFile : \(file)"
                + "\nLine Number : \(line) \nFunction : \(function)")
        }
        return scene
    }
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}
