//
//  HotelCheckInOutView.swift
//  Trajilis
//
//  Created by bharats802 on 16/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class HotelCheckInOutView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var lblCheckInDate:UILabel!
    @IBOutlet weak var lblCheckInDay:UILabel!
    @IBOutlet weak var lblCheckInMonth:UILabel!
    
    @IBOutlet weak var afterLbl:UILabel!
    @IBOutlet weak var beforeLbl:UILabel!
    
    @IBOutlet weak var lblCheckOutDate:UILabel!
    @IBOutlet weak var lblCheckOutDay:UILabel!
    @IBOutlet weak var lblCheckOutMonth:UILabel!
    
    @IBOutlet weak var lblRooms:UILabel!
    @IBOutlet weak var lblRoomsTitle:UILabel!
    @IBOutlet weak var btnRoomsAdd:TrajilisButton!
    @IBOutlet weak var btnRoomsMinus:TrajilisButton!
    
    @IBOutlet weak var viewCheckIn:UIView!
    @IBOutlet weak var viewCheckOut:UIView!
    @IBOutlet weak var viewRooms:UIView!
    @IBOutlet weak var btnCheckIn:UIButton!
    @IBOutlet weak var btnCheckOut:UIButton!
    
    @IBOutlet weak var checkInLbl1: UILabel!
    @IBOutlet weak var checkInLbl2: UILabel!
    @IBOutlet weak var checkOutLbl1: UILabel!
    @IBOutlet weak var checkOutLbl2: UILabel!
    
    @IBOutlet weak var checkOutStackView: UIStackView!
    @IBOutlet weak var checkInStackView: UIStackView!
    
    @IBOutlet weak var checkInImgView: UIImageView!
    @IBOutlet weak var checkOutImgView: UIImageView!
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM"
        return formatter
    }()

    
    class func getView() -> HotelCheckInOutView {
        let view  = Bundle.main.loadNibNamed("HotelCheckInOutView", owner: self, options: nil)!.first as! HotelCheckInOutView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setupControls()
        return view
    }
    func setupControls() {
        self.lblRooms.text = "1"
        
        self.lblCheckInDay.text = "--"
        self.lblCheckInDate.text = "--"
        self.lblCheckInMonth.text = "--"
        self.lblCheckOutDay.text = "--"
        self.lblCheckOutDate.text = "--"
        self.lblCheckOutMonth.text = "--"
        
        
        self.lblCheckInDate.textColor = .appRed
        self.lblCheckOutDate.textColor = .appRed
        self.lblRooms.textColor = .appRed
        
        self.btnRoomsAdd.backgroundColor = .appRed
        self.btnRoomsMinus.backgroundColor = .appRed
        self.btnRoomsMinus.setGradient = true
        self.btnRoomsAdd.setGradient = true

    }
    func setDate(isCheckIn:Bool,date:Date?) {
        if let date = date {
            let dateString = formatter.string(from: date)
            //"dd MMM"
            let arrDate = dateString.components(separatedBy: " ")
            if arrDate.count == 3 {
                if isCheckIn {
                    self.lblCheckInDay.text = "\(arrDate.first ?? ""),"
                    self.lblCheckInDate.text = arrDate[1]
                    self.lblCheckInMonth.text = arrDate.last
                    
                } else {
                    self.lblCheckOutDay.text = "\(arrDate.first ?? ""),"
                    self.lblCheckOutDate.text = arrDate[1]
                    self.lblCheckOutMonth.text = arrDate.last
                }
            }
        }
    }
}
