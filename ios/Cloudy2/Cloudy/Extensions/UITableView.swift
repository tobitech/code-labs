//
//  UITableView.swift
//  Cloudy
//
//  Created by Bart Jacobs on 08/05/2018.
//  Copyright © 2018 Cocoacasts. All rights reserved.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        
        return cell
    }
    
}
