//
//  UITableView + Extension.swift
//  Trajilis
//
//  Created by Perfect Aduh on 12/07/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation


extension UITableView {
    func register<T: UITableViewCell>(_: T.Type, reuseIdentifier: String? = nil) {
        let reuseId = reuseIdentifier ?? "\(T.self)"
        self.register(UINib(nibName: reuseId, bundle: Bundle.main), forCellReuseIdentifier: reuseId)
    }
    
    func dequeue<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath? = nil) -> T {
        
        
        if let indexPath = indexPath {
            guard
                let cell = dequeueReusableCell(withIdentifier: String(describing: T.self),
                                               for: indexPath) as? T
                else { fatalError("Could not dequeue cell with type \(T.self)") }
            return cell
            
        }
        
        /// In case we're dealing with section Headers. They don't need a special headerClass cell...
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self)) as? T
            else { fatalError("Could not dequeue header cell with type \(T.self)") }
        return cell
    }
    
}
