//
//  TrendingTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 13/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class MyHotelsBookingsCell: UITableViewCell {

    
    @IBOutlet weak var imgViewHotel:UIImageView!
    @IBOutlet weak var lblHotelName:UILabel!    
    @IBOutlet weak var lblLocation:UILabel!
    @IBOutlet weak var lblCheckInDate:UILabel!
    @IBOutlet weak var lblCheckOutDate:UILabel!
    @IBOutlet weak var lblRoom:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    
    @IBOutlet weak var lblCheckInDateTitle:UILabel!
    @IBOutlet weak var lblCheckOutDateTitle:UILabel!
    @IBOutlet weak var lblRoomTitle:UILabel!

    @IBOutlet weak var btnViewDetails:UIButton!
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var name: String {
        return reuseIdentifier
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnViewDetails.setTitleColor(.appRed, for: .normal)
        self.lblCheckInDate.textColor = .appRed
        self.lblCheckOutDate.textColor = .appRed
        self.lblRoom.textColor = .appRed
        self.imgViewHotel.layer.cornerRadius = 3
        self.imgViewHotel.layer.masksToBounds = true
        self.imgViewHotel.layer.borderWidth = 1
        self.imgViewHotel.layer.borderColor = UIColor.appRed.cgColor
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    func resetCell() {
        self.imgViewHotel.image = UIImage(named:"mapsmall")
        self.lblHotelName.text = "NA"
        self.lblLocation.text = nil
        self.lblCheckInDate.text = nil
        self.lblCheckOutDate.text = nil
        self.lblRoom.text = nil
        self.lblPrice.text = nil
        self.btnViewDetails.isUserInteractionEnabled = false
        self.lblCheckInDateTitle.text = "CHECK IN"
        self.lblCheckOutDateTitle.text = "CHECK OUT"
        self.lblRoomTitle.text = "Rooms:"
        
    }
    func fillData(booking:PGHotelBookingDetail) {
        self.lblHotelName.text = booking.hotel_name ?? "NA"
        self.lblLocation.text = booking.hotel_city ?? "NA"
        self.lblRoom.text = "\(booking.numOfRooms)"
        let currency = CurrencyManager.shared.getSymbol(forCurrency: booking.currency)
        self.lblPrice.text = "\(currency)\(booking.feeAmount  ?? "NA")"
        self.lblCheckInDate.text = booking.start_date ?? "NA"
        self.lblCheckOutDate.text = booking.end_date ?? "NA"
        if let img = booking.hotel?.hotelImage,!img.isEmpty,let url = URL(string:img) {
            
            self.imgViewHotel.sd_setImage(with: url, placeholderImage: UIImage(named: "mapsmall"))
        }
    }
    
}
