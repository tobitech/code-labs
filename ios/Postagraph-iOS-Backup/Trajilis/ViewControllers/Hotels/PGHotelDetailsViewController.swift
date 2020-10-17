//
//  PlaceDetailsViewController.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Alamofire
class PGHotelDetailsViewController: BaseVC {
    
    @IBOutlet weak var btnContinue:TrajilisButton!
    @IBOutlet weak var backBtn:UIButton!
    @IBOutlet weak var stackView:UIStackView!
    weak var roomDescriptionView:PGRoomDescription?
    
    var hotelBooking:PGHotelBooking?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Helpers.setupBackButton(button: backBtn)
        // Do any additional setup after loading the view.
        self.stackView.removeAllViews()
        self.hotelBooking?.selectedRoom = self.hotelBooking?.selectedHotel?.getMinimumPriceHotelRoom()
        self.btnContinue.setGradient = true
        self.btnContinue.bgColor = .appRed
        self.getHotelDetails()
        self.setContinueBtn()
    }
    func setContinueBtn() {
        if let room = self.hotelBooking?.selectedRoom {
            let currency = CurrencyManager.shared.getSymbol(forCurrency: room.currencyCode)
            self.btnContinue.setTitle("Continue | \(currency)\(room.totalFare.rounded(toPlaces: 2))", for: .normal)
        }
    }
    func fillHotelDetails() {
        self.stackView.removeAllViews()
        if let hotel = self.hotelBooking?.selectedHotel {
            if let image = hotel.hotelImage,!image.isEmpty {
                let imagesView = PlaceImagesView.getView()
                self.stackView.addArrangedSubview(imagesView)
                imagesView.setImages(images: [image])
            } else {
                let imagesView = PlaceImagesView.getView()
                self.stackView.addArrangedSubview(imagesView)
                imagesView.setDummyImage()
            }
            let plceInfo = PlaceInfoView.getView()
            plceInfo.fillWithHotel(hotel: hotel)
            self.stackView.addArrangedSubview(plceInfo)
            plceInfo.btnEMail.addTarget(self, action: #selector(btnWebsiteTapped(sender:)), for: .touchUpInside)
            plceInfo.btnContact.addTarget(self, action: #selector(btnPhoneTapped(sender:)), for: .touchUpInside)
            plceInfo.btnDirection.addTarget(self, action: #selector(btnDirectionlTapped(sender:)), for: .touchUpInside)
            
            // amenties
            
            if let services = self.hotelBooking?.selectedHotel?.hotelDescription?.services,services.count > 0 {
                let servicesView = PGHotelAmenitiesView.getView()
                servicesView.fillValue(services:services)
                self.stackView.addArrangedSubview(servicesView)
            }

            if let descs = hotel.hotelDescription?.texts,descs.count > 0 {
                let hotelDescriptionView = PGHotelDescriptionView.getView()
                hotelDescriptionView.fillValue(hotel: hotel)
                hotelDescriptionView.btnViewAll.addTarget(self, action: #selector(btnViewAllDescTapped(sender:)), for: .touchUpInside)
                self.stackView.addArrangedSubview(hotelDescriptionView)
            }
            
            if let room = self.hotelBooking?.selectedRoom {
                let roomDescription = PGRoomDescription.getView()
                self.stackView.addArrangedSubview(roomDescription)
                roomDescription.fillValue(room: room)
                roomDescription.btnChange.addTarget(self, action: #selector(btnChangeTapped(sender:)), for: .touchUpInside)
                self.roomDescriptionView = roomDescription
            }
            
            if let policy = self.hotelBooking?.selectedHotel?.hotelDescription?.policyInfo {
                let servicesView = PGHotelAmenitiesView.fromNib()
                servicesView.fillPolicy(policy:policy)
                self.stackView.addArrangedSubview(servicesView)
            }
        }
        let btmView = UIView()
        self.stackView.addArrangedSubview(btmView)
        btmView.translatesAutoresizingMaskIntoConstraints = false
        //center image
        let heightConstraint = NSLayoutConstraint(item: btmView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120)
        btmView.addConstraints([heightConstraint])
        
    }
    @IBAction func btnViewAllDescTapped(sender:UIButton) {
        if let texts = self.hotelBooking?.selectedHotel?.hotelDescription?.texts,texts.count > 0 {
            var desc = ""
            for text in texts {
                desc.append(text)
                desc.append("\n")
            }
            let cc = PGDescriptionViewController.instantiate(fromAppStoryboard: .hotels)
            cc.text = desc
            let navVC = UINavigationController(rootViewController: cc)
            navVC.configure()
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        
    }
    @IBAction func btnChangeTapped(sender:UIButton) {
        
        let vc = PGSelectRoomViewController.instantiate(fromAppStoryboard: .hotels)
        vc.selectedHotel = self.hotelBooking?.selectedHotel
        vc.selectedRoom = self.hotelBooking?.selectedRoom
        vc.didSelectRoom = { [weak self](room) in
            self?.hotelBooking?.selectedRoom = room
            self?.roomDescriptionView?.fillValue(room: room)
            self?.setContinueBtn()
        }
        let navVC = UINavigationController(rootViewController: vc)
        navVC.configure()
        self.present(navVC, animated: true, completion: nil)
        
    }
    func getHotelDetails() {
//        self.fillHotelDetails()
//        return;
        guard let hotelCode = self.hotelBooking?.selectedHotel?.hotelCode else {
            return
        }
        self.spinner(with: "Getting Details...", blockInteraction: true)
        
        let param: JSONDictionary = [
            "hotelCode": [hotelCode]
        ]
        
        APIController.makeRequest(request: .hotelDetails(param: param)) { [weak self](response) in
            
            DispatchQueue.main.async {
                if let strngSelf = self {
                    strngSelf.hideSpinner()
                    switch response {
                    case .failure(let error):
                        strngSelf.showAlert(message: error.desc)
                        strngSelf.navigationController?.popViewController(animated: true)
                    case .success(let result):
                        do {
                            guard let json = try result.mapJSON() as? JSONDictionary, let data = json["data"] as? JSONDictionary else { return }
                            if let hotels = data["hotels"] as? [JSONDictionary] {
                                if let hotel = hotels.first {
                                    self?.hotelBooking?.selectedHotel?.updateHotel(json:hotel)
                                    self?.fillHotelDetails()
                                } else {
                                    strngSelf.showAlert(message: "No hotels found.")
                                }
                            }
                        } catch {
                            print(error)
                        }
                        
                    }
                }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func backBtnTapped(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnContinueTapped(sender:UIButton) {
        self.getHotelPricing()
        return;
       
    }
    func showSummaryVC(amount:PGHotelAmount) {
        let vc = PGHotelSummaryViewController.instantiate(fromAppStoryboard: .hotels)
        self.hotelBooking?.selectedAmount = amount
        vc.hotelBooking = self.hotelBooking
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func getHotelPricing() {
        
        guard let hotelCode = self.hotelBooking?.selectedHotel?.hotelCode,let roomCode = self.hotelBooking?.selectedRoom?.bookingCode  else {
            return
        }
        let dateFormat = "yyyy-MM-dd"
        var checkInDate = ""
        var checkOutDate = ""
        if let checkIn = self.hotelBooking?.checkInDate {
            checkInDate = checkIn.getStringInformat(dateFormat: dateFormat)
        } else {
            self.showAlert(message: "Please select check in date.")
            return
        }
        if let checkOut = self.hotelBooking?.checkOutDate {
            checkOutDate = checkOut.getStringInformat(dateFormat: dateFormat)
        } else {
            self.showAlert(message: "Please select check out date.")
            return
        }
        var location = self.hotelBooking!.selectedLocation
        if location.isEmpty, let city = self.hotelBooking?.selectedHotel?.hotelCity {
            location = city
        }
        self.spinner(with: "Getting Pricing...", blockInteraction: true)
        
        let currency = CurrencyManager.shared.getUserCurrencyCode()
        let param: JSONDictionary = [
            "hotelCode": hotelCode,
            "bookingCode": roomCode,
            "totalOccupants": self.hotelBooking!.occupent,
            "quantity": self.hotelBooking!.numOfRooms,
            "startDate": checkInDate,
            "endDate": checkOutDate,
            "currency": currency
        ]
        
        APIController.makeRequest(request: .hotelPricing(param: param)) { [weak self](response) in
            
            DispatchQueue.main.async {
                if let strngSelf = self {
                    strngSelf.hideSpinner()
                    switch response {
                    case .failure(let error):
                        strngSelf.showAlert(message: error.desc)
                        strngSelf.navigationController?.popViewController(animated: true)
                    case .success(let result):
                        do {
                            guard let json = try result.mapJSON() as? JSONDictionary, let data = json["data"] as? JSONDictionary else { return }
                            if let hotels = data["hotels"] as? [JSONDictionary] {
                                if let hotel = hotels.first {
                                    if let amount = hotel["LocalAmount"] as? JSONDictionary {
                                        var amountObj = PGHotelAmount(json: amount)
                                    
                                        if let payment = hotel["Payment"] as? JSONDictionary {
                                            if let policy = payment["paymentPolicy"] as? String {
                                                if(policy == "Deposit") {
                                                    amountObj.priceInfo = "Credit card will be debited immediately."
                                                } else if(policy == "GuaranteeRequired") {
                                                    amountObj.priceInfo = "Credit card is ONLY for the purpose of guaranteeing the room. No payment will occur at this time."
                                                }
                                            }
                                        }
                                        self?.showSummaryVC(amount: amountObj)
                                        return
                                    }
                                }
                            }else {
                                strngSelf.showAlert(message: "App is unable to process the request at this time. Please try again later.")
                            }
                        } catch {
                            print(error)
                            strngSelf.showAlert(message: "App is unable to process the request at this time. Please try again later.")
                        }
                    }
                }
            }
        }
    }
}
