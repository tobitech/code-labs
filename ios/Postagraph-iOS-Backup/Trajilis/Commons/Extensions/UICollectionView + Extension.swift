//
//  UICollectionView + Extension.swift
//  Trajilis
//
//  Created by Perfect Aduh on 11/07/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type, reuseIdentifier: String? = nil) {
        let reuseId = reuseIdentifier ?? "\(T.self)"
        self.register(UINib(nibName: reuseId, bundle: Bundle.main), forCellWithReuseIdentifier: reuseId)
    }
    
    func register<T: UICollectionReusableView>(_: T.Type, reuseIdentifier: String? = nil, forSupplementaryViewOfKind: String? = nil) {
        let reuseId = reuseIdentifier ?? "\(T.self)"
        let kind = forSupplementaryViewOfKind ?? UICollectionView.elementKindSectionFooter
        
        self.register(UINib(nibName: reuseId, bundle: Bundle.main), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseId)
    }
    
    func dequeue<T: UICollectionViewCell>(_: T.Type, for indexPath: IndexPath) -> T {
        
        guard
            let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self),
                                           for: indexPath) as? T
            else { fatalError("Could not dequeue cell with type \(T.self)") }
        
        return cell
    }
    
    func dequeue<T: UICollectionReusableView>(_: T.Type, for indexPath: IndexPath, forSupplementaryViewOfKind: String? = nil) -> T {
        let kind = forSupplementaryViewOfKind ?? UICollectionView.elementKindSectionFooter
        
        guard
            let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: T.self), for: indexPath) as? T
            else { fatalError("Could not dequeue cell with type \(T.self)") }
        
        return cell
    }
    
}
