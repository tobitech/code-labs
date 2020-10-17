//
//  ReusableView.swift
//  Cloudy
//
//  Created by Bart Jacobs on 08/05/2018.
//  Copyright © 2018 Cocoacasts. All rights reserved.
//

import UIKit

protocol ReusableView {
    
    static var reuseIdentifier: String { get }
    
}

extension ReusableView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}

extension UITableViewCell: ReusableView {}
