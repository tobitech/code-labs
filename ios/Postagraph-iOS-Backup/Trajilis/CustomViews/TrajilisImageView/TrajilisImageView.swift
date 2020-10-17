//
//  TrajilisImageView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 13/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TrajilisImageView: UIView {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var contentView: UIView!

    @IBInspectable var cornerRadius: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageContainerView.layer.cornerRadius = cornerRadius
        imageContainerView.layer.masksToBounds = true
        imageContainerView.layer.shadowOpacity = Float(1.0)
        imageContainerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        imageContainerView.layer.shadowColor = UIColor.appRed.cgColor

        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
    }

    func setImage(url: URL) {
        imageView.sd_setImage(with: url, completed: nil)
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("TrajilisImageView", owner: self, options: nil)
        addSubview(contentView)
        contentView.fill()
    }

}
