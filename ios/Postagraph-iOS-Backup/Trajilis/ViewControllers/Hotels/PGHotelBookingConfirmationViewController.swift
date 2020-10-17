//
//  PGHotelSummaryViewController.swift
//  Trajilis
//
//  Created by bharats802 on 22/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PGHotelBookingConfirmationViewController: BaseVC {
    
    var selectedHotel:PGHotel?
    var hotelBookingDetails:PGHotelBookingDetail?
    
    let paymentView = PGHotelPaymentSummaryView.getView()
    @IBOutlet weak var btnBookNow:TrajilisButton!
    @IBOutlet weak var stackView:UIStackView!
    let viewCheckInOut:HotelCheckInOutView! = HotelCheckInOutView.getView()
    var isFromMyBookings:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideNavigationBar()
        // Do any additional setup after loading the view.
        self.fillHotelDetails()
    }
    
    func fillHotelDetails() {
        
        self.stackView.removeAllViews()
        let bookingView = PGHotelBookingConfirmationView.getView()
        self.stackView.addArrangedSubview(bookingView)
        
       
        
        if let bookingDetails = self.hotelBookingDetails {
            
            
            if let bid = self.hotelBookingDetails?.control_number {
                bookingView.lblBookingID.text = bid
            }
            if let bid = self.hotelBookingDetails?.order_number {
                bookingView.lblOrderNumber.text = bid
            }
            
            if let hotel = self.selectedHotel {
                let plceInfo = PlaceInfoView.getView()
                plceInfo.imgViewWidthCnstrnt.constant = 80
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
            } 
            
            
            self.viewCheckInOut.btnRoomsAdd.isHidden = true
            self.viewCheckInOut.btnRoomsMinus.isHidden = true
            
            self.viewCheckInOut.lblRoomsTitle.text = "Rooms"
            self.viewCheckInOut.lblRooms.text = "\(bookingDetails.numOfRooms)"
            
            
            self.viewCheckInOut.setDate(isCheckIn: true, date: Helpers.dateFromString(dateString: bookingDetails.start_date))
            self.viewCheckInOut.setDate(isCheckIn: false, date:  Helpers.dateFromString(dateString: bookingDetails.end_date))
            
            self.stackView.addArrangedSubview(self.viewCheckInOut)
            let height = NSLayoutConstraint(item: self.viewCheckInOut, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80)
            self.viewCheckInOut.addConstraint(height)
            
        }        
        self.stackView.addArrangedSubview(PGContactUsView.getView())
    }
    
    
    @IBAction func btnWebsiteTapped(sender:UIButton) {
        if let website = self.selectedHotel?.hotelDescription?.website,!website.isEmpty {
            guard let url = URL.init(string: website) else {
                return
            }
            let vc = OnboardingWebVC.instantiate(fromAppStoryboard: .onboarding)
            vc.url = url
            vc.title = self.selectedHotel?.hotelName ?? "Website"
            navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showAlert(message: "website not available.")
        }
    }
    @IBAction func btnPhoneTapped(sender:UIButton) {
        if let phone = self.selectedHotel?.hotelDescription?.phoneNumber
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
        if let location = self.selectedHotel?.hotelAddress {
            let strURL = "comgooglemaps://?saddr=&daddr=\(location.replacingOccurrences(of: " ", with: "+"))&zoom=10"
            if let plcURL = URL(string:strURL) {
                UIApplication.shared.open(plcURL, options: [:], completionHandler: nil)
            } else {
                self.showAlert(message: "Unable to get direction to the location.")
            }
        } else if let name = self.hotelBookingDetails?.hotel_name, let cityName = self.hotelBookingDetails?.hotel_city {
            let location = "\(name),\(cityName)"
            
            let strURL = "comgooglemaps://?saddr=&daddr=\(location.replacingOccurrences(of: " ", with: "+"))&zoom=10"
            if let plcURL = URL(string:strURL) {
                UIApplication.shared.open(plcURL, options: [:], completionHandler: nil)
            } else {
                self.showAlert(message: "Unable to get direction to the location.")
            }
        }        
        else {
            self.showAlert(message: "Unable to get place's location.")
        }
    }
   
    @IBAction func btnBookNowTapped(sender:UIButton) {
        if self.isFromMyBookings {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
