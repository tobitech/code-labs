//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGHotelAmenitiesView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var stackView:UIStackView!
    let topServices = kAmenities.allValues()
    class func getView() -> PGHotelAmenitiesView {
        let view  = Bundle.main.loadNibNamed("PGHotelAmenitiesView", owner: self, options: nil)!.first as! PGHotelAmenitiesView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func getImageForService(service: String) -> UIImage? {        
        for serv in topServices {
            if service.lowercased().contains(serv.lowercased()) {
                if let img = UIImage(named:serv) {
                    return img
                }
            }
        }
        return UIImage(named:"checkIcon")
    }
    func fillValue(services:[PGHotelServices]) {
        var amentiView:PGHotelAmenitiItemView?
        var index = 0
        var count = 0
        for service in services {
            if count == 9 { // show only 10 amenties
                break
            }
            if index == 0 {
                let view1 = PGHotelAmenitiItemView.getView()
                self.stackView.addArrangedSubview(view1)
                amentiView = view1
            }
            if let amntView = amentiView {
                switch index {
                case 0:
                    amntView.lblItem1.isHidden = false
                    amntView.lblItem1.text = service.value
                    amntView.imgView1.isHidden = false
                    amntView.imgView1.image = self.getImageForService(service: service.value)
                    
                case 1:
                    
                    amntView.lblItem2.isHidden = false
                    amntView.lblItem2.text = service.value
                    amntView.imgView2.isHidden = false
                    amntView.imgView2.image = self.getImageForService(service: service.value)
                case 2:
                    amntView.lblItem3.isHidden = false
                    amntView.lblItem3.text = service.value
                    amntView.imgView3.isHidden = false
                    amntView.imgView3.image = self.getImageForService(service: service.value)
                default:
                    break
                }
            }
            index = index + 1
            if index >= 3 {
                index = 0
            }
            count = count + 1
        }
        
        
    }
    func fillPolicy(policy:PGHotelPolicyInfo) {
        self.stackView.axis = .horizontal
        self.stackView.spacing = 0
        self.lblTitle.text = "Things to know"
        if !policy.checkInTime.isEmpty {
            let vc = PGHotelNeedToKnowItem.getView()
            vc.lblItem1.text = "Check in time is \(policy.checkInTime)"
            self.stackView.addArrangedSubview(vc)
        }
        if !policy.checkOutTime.isEmpty {
            let vc = PGHotelNeedToKnowItem.getView()
            vc.lblItem1.text = "Check out time is \(policy.checkInTime)"
            self.stackView.addArrangedSubview(vc)
        }
        for txt in  policy.texts {
            let vc = PGHotelNeedToKnowItem.getView()
            vc.lblItem1.text = txt
            self.stackView.addArrangedSubview(vc)
        }
        
    }
    
}
