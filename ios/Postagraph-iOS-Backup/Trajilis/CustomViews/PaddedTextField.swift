//
//  PaddedTextField.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PaddedTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
}
