//
//  TRBaseVCProtocol.swift
//  Trajilis
//
//  Created by bharats802 on 16/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

public protocol TRBaseVCProtocol {
    
}

public extension TRBaseVCProtocol where Self: UIViewController {
    public func setBackgroundImage() {
        let imageView = UIImageView(image: UIImage(named: "trajilis_newlogo"))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.centerToSuperview()
        view.sendSubviewToBack(imageView)
    }
    
}
