//
//  PGHotelSummaryViewController.swift
//  Trajilis
//
//  Created by bharats802 on 22/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PGHotelSummaryViewController: BaseVC {

    var hotelBooking:PGHotelBooking?
    
    let paymentView = PGHotelPaymentSummaryView.getView()
    @IBOutlet weak var btnBookNow:TrajilisButton!
    @IBOutlet weak var stackView:UIStackView!
    
    let viewCheckInOut:HotelCheckInOutView! = HotelCheckInOutView.getView()
    weak var roomDescriptionView: PGRoomDescription?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Booking Summary"
        // Do any additional setup after loading the view.
        
        self.fillHotelDetails()
    }
    
    func fillHotelDetails() {
        self.stackView.removeAllViews()
        if let hotel = self.hotelBooking?.selectedHotel {
            
            let plceInfo = PlaceInfoView.getView()
            plceInfo.imgViewWidthCnstrnt.constant = 80
            plceInfo.stackView.isHidden = true
            plceInfo.fillWithHotel(hotel: hotel)
            if let image = hotel.hotelImage,!image.isEmpty,let url = URL(string:image) {
                plceInfo.imgView.sd_setImage(with: url, completed: nil)
            } else {
                plceInfo.imgView.image = UIImage(named:"mapsmall")
            }
            
            self.stackView.addArrangedSubview(plceInfo)
            plceInfo.btnEMail.addTarget(self, action: #selector(btnWebsiteTapped(sender:)), for: .touchUpInside)
            plceInfo.btnContact.addTarget(self, action: #selector(btnPhoneTapped(sender:)), for: .touchUpInside)
            plceInfo.btnDirection.addTarget(self, action: #selector(btnDirectionlTapped(sender:)), for: .touchUpInside)

            self.viewCheckInOut.btnRoomsAdd.isHidden = true
            self.viewCheckInOut.btnRoomsMinus.isHidden = true
            self.viewCheckInOut.viewRooms.isHidden = true
            self.viewCheckInOut.checkInLbl1.isHidden = false
            self.viewCheckInOut.checkOutLbl1.isHidden = false
            self.viewCheckInOut.afterLbl.isHidden = false
            self.viewCheckInOut.beforeLbl.isHidden = false
            
            self.viewCheckInOut.checkOutLbl2.textColor = UIColor.appRed
            self.viewCheckInOut.checkOutImgView.image = UIImage(named: "hotel-icon-selected")
            
            self.viewCheckInOut.setDate(isCheckIn: true, date: self.hotelBooking?.checkInDate)
            self.viewCheckInOut.setDate(isCheckIn: false, date: self.hotelBooking?.checkOutDate)
            
            self.viewCheckInOut.lblRoomsTitle.text = "Rooms"
            self.viewCheckInOut.lblRooms.text = "\(self.hotelBooking?.numOfRooms ?? 1)"
            
            
            self.stackView.addArrangedSubview(self.viewCheckInOut)
            let height = NSLayoutConstraint(item: self.viewCheckInOut, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80)
            self.viewCheckInOut.addConstraint(height)
            
            
            if let room = self.hotelBooking?.selectedRoom {
                let roomDescription = PGRoomDescription.getView()
                self.stackView.addArrangedSubview(roomDescription)
                roomDescription.fillValue(room: room)
                //roomDescription.btnChange.addTarget(self, action: #selector(btnChangeTapped(sender:)), for: .touchUpInside)
                //self.roomDescriptionView = roomDescription
            }
            
            if let amnt = self.hotelBooking?.selectedAmount {
                
                paymentView.btnApplePay.addTarget(self, action: #selector(btnApplePayTapped(sender:)), for: .touchUpInside)
                paymentView.btnCreditCard.addTarget(self, action: #selector(btnCreditCardTapped(sender:)), for: .touchUpInside)
                self.stackView.addArrangedSubview(paymentView)
                paymentView.fillValue(amount: amnt)
                
                if let info = amnt.priceInfo,!info.isEmpty {
                    paymentView.lblPriceInfo.text = info
                }
                
                
                if let sdate = self.hotelBooking?.checkInDate,let edate = self.hotelBooking?.checkOutDate {
                    let days = Helpers.daysBetween(start: sdate, end: edate)
                    let numofRooms = self.hotelBooking?.numOfRooms ?? 1
                    if numofRooms == 1 {
                        if days > 1 {
                            paymentView.lblRoomTitle.text = "One room(\(days) nights)"
                        } else {
                            paymentView.lblRoomTitle.text = "One room(\(days) night)"
                        }
                    } else {
                        if days > 1 {
                            paymentView.lblRoomTitle.text = "\(numofRooms) rooms(\(days) nights)"
                        } else {
                            paymentView.lblRoomTitle.text = "\(numofRooms) rooms(\(days) night)"
                        }
                    }
                    print(days)
                }
            } else {
                
            }
        }
        
    }
    
    
    @IBAction func btnWebsiteTapped(sender:UIButton) {
        if let website = self.hotelBooking?.selectedHotel?.hotelDescription?.website,!website.isEmpty {
            guard let url = URL.init(string: website) else {
                return
            }
            let vc = OnboardingWebVC.instantiate(fromAppStoryboard: .onboarding)
            vc.url = url
            vc.title = self.hotelBooking?.selectedHotel?.hotelName ?? "Website"
            navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showAlert(message: "website not available.")
        }
    }
    @IBAction func btnPhoneTapped(sender:UIButton) {
        if let phone = self.hotelBooking?.selectedHotel?.hotelDescription?.phoneNumber
            ,!phone.isEmpty {
            let formatedNumber = phone.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
            if let url = URL(string: "TEL://\(formatedNumber)"),UIApplication.shared.canOpenURL(url)  {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.showAlert(message: "phone number not available.")
            }
        } else {
            self.showAlert(message: "phone number not available.")
        }
    }
    @IBAction func btnDirectionlTapped(sender:UIButton) {
        if let location = self.hotelBooking?.selectedHotel?.hotelAddress {
            let strURL = "comgooglemaps://?saddr=&daddr=\(location.replacingOccurrences(of: " ", with: "+"))&zoom=10"
            if let plcURL = URL(string:strURL) {
                UIApplication.shared.open(plcURL, options: [:], completionHandler: nil)
            } else {
                self.showAlert(message: "Unable to get direction to the location.")
            }
        } else {
            self.showAlert(message: "Unable to get place's location.")
        }
    }
    
    @IBAction func btnCreditCardTapped(sender:TrajilisButton) {
        self.paymentView.setPayment(isCreditCard: true)
    }
    @IBAction func btnApplePayTapped(sender:TrajilisButton) {
        self.paymentView.setPayment(isCreditCard: false)
    }
   
    @IBAction func btnBookNowTapped(sender:UIButton) {
        
        self.view.endEditing(true)
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        
        if let booking = self.hotelBooking {
            let controller = TravelerInformationVC.instantiate(fromAppStoryboard: .flight)
            controller.isFlightBooking = false
            controller.selectedApplePay = !self.paymentView.btnCreditCard.isSelected
            // controller.travelersData?.adults = booking.occupent
            controller.hotelBooking = booking
            navigationController?.pushViewController(controller, animated: true)
        }
    }

}


class PGHotelBooking:NSObject {
    var selectedHotel:PGHotel?
    var selectedRoom:PGHotelRoom?
    var selectedAmount:PGHotelAmount?
    var checkInDate:Date?
    var checkOutDate:Date?
    var occupent:Int = 1
    var numOfRooms:Int = 1
    var selectedLocation:String = ""
}
