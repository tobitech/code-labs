//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGFlightBookingDetailView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var stackView:UIStackView!
    
    class func getView() -> PGFlightBookingDetailView {
        let view  = Bundle.main.loadNibNamed("PGFlightBookingDetailView", owner: self, options: nil)!.first as! PGFlightBookingDetailView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    func addItinaries(itinaries:[PGFlightItinary]) {
        
        for iti in itinaries {
            let viewItinary = PGFlightItineraryView.getView()
            viewItinary.lblTitle.text = iti.segments.first?.marketingCompany
            if let strUrl = iti.segments.first?.marketingCompanyLogo,let url = URL(string:strUrl) {
                viewItinary.imgView.sd_setImage(with: url, completed: nil)
            }
            self.stackView.addArrangedSubview(viewItinary)
            for segments in iti.segments {
                let segView = PGFlightSegmentView.getView()
                viewItinary.stackView.addArrangedSubview(segView)
                segView.fillSegment(segment: segments)
            }
            
            
        }
        
    }
    
    
}
