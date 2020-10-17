//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGHotelAmenitiItemView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var view1:UIView!
    @IBOutlet weak var imgView1:UIImageView!
    @IBOutlet weak var lblItem1:UILabel!
    @IBOutlet weak var lblCenter1:UILabel!
    
    @IBOutlet weak var view2:UIView!
    @IBOutlet weak var imgView2:UIImageView!
    @IBOutlet weak var lblItem2:UILabel!
    @IBOutlet weak var lblCenter2:UILabel!
    
    
    @IBOutlet weak var view3:UIView!
    @IBOutlet weak var imgView3:UIImageView!
    @IBOutlet weak var lblItem3:UILabel!
    @IBOutlet weak var lblCenter3:UILabel!
    
    
    class func getView() -> PGHotelAmenitiItemView {
        let view  = Bundle.main.loadNibNamed("PGHotelAmenitiItemView", owner: self, options: nil)!.first as! PGHotelAmenitiItemView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.view1.isHidden = false
        view.view2.isHidden = false
        view.view3.isHidden = false

        view.setView(index: 0, hidden: true)
        view.setView(index: 1, hidden: true)
        view.setView(index: 2, hidden: true)
        view.lblItem1.numberOfLines = 2
        view.lblCenter1.numberOfLines = 1
        view.lblItem2.numberOfLines = 2
        view.lblCenter2.numberOfLines = 1
        view.lblItem3.numberOfLines = 2
        view.lblCenter3.numberOfLines = 1
        return view
    }
    func setView(index:Int,hidden:Bool) {
        switch index {
        case 0:
            self.imgView1.isHidden = hidden
            self.lblItem1.isHidden = hidden
            self.lblCenter1.isHidden = hidden
            
        case 1:
            self.imgView2.isHidden = hidden
            self.lblItem2.isHidden = hidden
            self.lblCenter2.isHidden = hidden
            
        case 2:
            self.imgView3.isHidden = hidden
            self.lblItem3.isHidden = hidden
            self.lblCenter3.isHidden = hidden
        default:
            break
        }
        
    }
}
