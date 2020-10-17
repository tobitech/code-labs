//
//  PaymentVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

let MERCHANT = "1A"
import Flurry_iOS_SDK
import SkyFloatingLabelTextField

final class PaymentVC: BaseVC {
    
    // MARK: - IB Outlets
    @IBOutlet var nameOnCardTextField: SkyFloatingLabelTextField!
    @IBOutlet var cardNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet var cvvTextField: SkyFloatingLabelTextField!
    @IBOutlet var expiryDateTextField: SkyFloatingLabelTextField!
    @IBOutlet var streetTextField: SkyFloatingLabelTextField!
    @IBOutlet var zipcodeTextField: SkyFloatingLabelTextField!
    @IBOutlet var cityTextField: SkyFloatingLabelTextField!
    @IBOutlet var countryTextField: SkyFloatingLabelTextField!
    @IBOutlet var stateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var completeBookingButton: UIButton!
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var selectedCardImage: UIImageView!
    
    // MARK: Properties
    
    var fareRules = [PGFareRule]()
    
    var travelerData: TravelersData?
    
    var outboundFlight: FlightDetails?
    var inboundFlight: FlightDetails?

    var bookingItinerary = [JSONDictionary]()
    var passengerArray = [JSONDictionary]()

    var departureDate: Date?

    var returnDate: Date?
    var destination: Airport?
    var origin: Airport?

    var kountSessionId:String?
    var selectedCountry: Country?
    var selectedState: State?
    var bestPricing: BestPricing?
    var loaderImageView: UIImageView!
    var tripType = FlightTrip.roundTrip
    
    var isFlightBooking: Bool = true
    
    // for hotel booking
    var hotelBooking: PGHotelBooking?
    
    var fareFamilyName = "BASIC"
    var contact: JSONDictionary?
    
    var card: PaymentCard? {
        didSet {
            guard let card = card else { return }
            self.selectedCardImage.image = UIImage(named: card.imageName)
            self.cardNumberTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "check-mark"))
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showNavigationBar()
        let fairRulesButton = UIBarButtonItem(title: "Fare Rules", style: .plain, target: self, action: #selector(showFairRules))
        fairRulesButton.tintColor = UIColor.appRed
        navigationItem.rightBarButtonItem = fairRulesButton
        
        title = "Payment Info"
        
        setupLoaderView()
        
        configureForm()
        
        stateTextField.setLeftPaddingPoints(5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentTime = getCurrentMillis()
        let len = 31 - "\(currentTime)".count
        let randomStr = String.randomStr(length: len)
        // GET SessioinID
        let sID = "\(randomStr)-\(currentTime)"
        KDataCollector.shared().collect(forSession: sID, completion: nil)
        self.kountSessionId = sID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showNavigationBar()
    }
    
    // MARK: - Helpers
    
    @objc func showFairRules() {
        let controller = FareRuleVC.instantiate(fromAppStoryboard: .flight)
        controller.fareRules = self.fareRules
        
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
    
    fileprivate func setupLoaderView() {
        loaderImageView = UIImageView(frame: CGRect(x: view.frame.size.width/2, y: view.frame.size.height/2, width: 100, height: 100))
        loaderImageView.center = view.center
        //let image = UIImage.gifImageWithName(name: "act1")
        loaderImageView.loadGif(name: "act1")
        view.addSubview(loaderImageView)
        loaderImageView.isHidden = true
    }
    
    fileprivate func configureForm() {
        cardNumberTextField.titleFormatter = { $0 }
        nameOnCardTextField.titleFormatter = { $0 }
        expiryDateTextField.titleFormatter = { $0 }
        cvvTextField.titleFormatter = { $0 }
        streetTextField.titleFormatter = { $0 }
        cityTextField.titleFormatter = { $0 }
        // cityTextField.isEnabled = false
        stateTextField.titleFormatter = { $0 }
        // stateTextField.isEnabled = false
        countryTextField.titleFormatter = { $0 }
        // countryTextField.isEnabled = false
        zipcodeTextField.titleFormatter = { $0 }
        
        cardContainerView.makeCornerRadius(cornerRadius: 4.0)
        cardContainerView.set(borderWidth: 1.0, of: UIColor(hexString: "EFEFEF"))
        cardContainerView.layer.masksToBounds = false
        cardContainerView.layer.shadowColor = UIColor(white: 0, alpha: 0.1).cgColor
        cardContainerView.layer.shadowOpacity = 1
        cardContainerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        cardContainerView.layer.shadowRadius = 10
        cardContainerView.layer.rasterizationScale = UIScreen.main.scale
        
        cvvTextField.delegate = self
        zipcodeTextField.delegate = self
        expiryDateTextField.delegate = self
        cardNumberTextField.delegate = self
        
        cardNumberTextField.addTarget(self, action: #selector(handleInputTextChanged(textField:)), for: .editingChanged)
        cardNumberTextField.addTarget(self, action: #selector(handleInputTextEnded(textField:)), for: .editingDidEnd)
        expiryDateTextField.addTarget(self, action: #selector(handleInputTextChanged(textField:)), for: .editingChanged)
        
        let stateTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStateTapped))
        stateTextField.addGestureRecognizer(stateTapGesture)
        
        // let cityTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCityTapped))
        // cityTextField.addGestureRecognizer(cityTapGesture)
        
        let countryTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCountryTapped))
        countryTextField.addGestureRecognizer(countryTapGesture)
        
        completeBookingButton.layer.cornerRadius = 4.0
        completeBookingButton.layer.masksToBounds = true
    }
    
    @objc func handleCityTapped() {
        guard let id = selectedCountry?.id else { return }
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.countryId = id
        controller.type = .city
        controller.didSelectCity = { [weak self] city in
            self?.cityTextField.text = city.name
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleStateTapped() {
        guard let countryId = selectedCountry?.id else {
            self.showAlert(message: "Please select a country first.")
            return }
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.countryId = countryId
        controller.type = .state
        controller.didSelectState = { [weak self] state in
            self?.cityTextField.text = ""
            self?.stateTextField.text = state.name
            self?.selectedState = state
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleCountryTapped() {
        self.view.endEditing(true)
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.type = .country
        controller.didSelectCountry = { [weak self] country in
            self?.selectedCountry = country
            self?.countryTextField.text = country.name
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func getCurrentMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    fileprivate func checkBookability(completion: @escaping ((Bool, String?) -> Void)) {
        
        let param: JSONDictionary = [
            "itinerary": self.bookingItinerary,
            "passenger": self.passengerArray
        ]
        
        APIController.makeRequest(request: .bookability(param: param)) { (response) in
            switch response {
            case .failure(let error):
                Flurry.logError("bookability_api", message: error.desc, exception: nil);
                completion(false, "This itinerary can not be booked at the moment")
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let success = json?["status"] as? Bool else {
                        completion(false, "This itinerary can not be booked at the moment")
                        return
                }
                let msg: String? = success ? nil : json?["data"] as? String
                completion(success, msg)
            }
        }
    }
    
    func makeHotelBooking(param: JSONDictionary) {
        
        spinner(with: "Booking...", blockInteraction: true)
        APIController.makeRequest(request: .bookHotel(param: param)) { [weak self](response) in
            if let strngSelf = self {
                strngSelf.hideSpinner()
                switch response {
                case .failure(let error):
                    Flurry.logError("bookHotel_api", message: error.desc, exception: nil);
                    strngSelf.showAlert(message: "This hotel can not be booked at the moment")
                    
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? JSONDictionary, let statusCode = json?["statusCode"] as? Int else {
                            strngSelf.showAlert(message: "This hotel can not be booked at the moment")
                            return
                    }
                    if statusCode == 200 {
                        strngSelf.hotelBookingConfimed(data:data)
                        
                    } else {
                        strngSelf.showAlert(message: "Unable to book flight")
                    }
                }
            }
            
        }
    }
    
    func flightBookingConfirmed(data:JSONDictionary) {
        let bookingDetails = PGFlightBookingDetail(json: data)
        let vc = FlightBookingConfirmationVC.instantiate(fromAppStoryboard: .flight)
        vc.isFromPayments = true
        vc.hideNavigationBar()
        vc.flightBooking = bookingDetails
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func hotelBookingConfimed(data:JSONDictionary) {
        let bookingDetails = PGHotelBookingDetail(json: data)
        let vc = PGHotelBookingConfirmationViewController.instantiate(fromAppStoryboard: .hotels)
        vc.hideNavigationBar()
        vc.hotelBookingDetails = bookingDetails
        vc.selectedHotel = self.hotelBooking?.selectedHotel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func completeBookingTapped(_ sender: Any) {
        guard let card = self.card else {
            showAlert(message: "We could not recognize that card ")
            return
        }
        
        if cardNumberTextField.text == nil ||  cardNumberTextField.text!.isEmpty || cardNumberTextField.text?.count ?? 0 < 8 || cardNumberTextField.text?.count ?? 0 > 19 {
            showAlert(message: "Enter valid card number.")
            return
        }
        
        if nameOnCardTextField.text == nil || nameOnCardTextField.text!.isEmpty {
            showAlert(message: "Name on card is required.")
            return
        }
        
        if cvvTextField.text == nil ||  cvvTextField.text!.isEmpty || cvvTextField.text == "000" || cvvTextField.text?.count ?? 0 < 3 {
            showAlert(message: "Valid CVV is required.")
            return
        }
    
        if expiryDateTextField.text == nil || expiryDateTextField.text!.isEmpty {
            showAlert(message: "expiry month is required.")
            return
        }
        
        if streetTextField.text == nil || streetTextField.text!.isEmpty {
            showAlert(message: "Billing address is required.")
            return
        }
        
        if cityTextField.text == nil ||  cityTextField.text!.isEmpty {
            showAlert(message: "City is required.")
            return
        }
        
        if zipcodeTextField.text == nil || zipcodeTextField.text!.isEmpty {
            showAlert(message: "Zipcode is required.")
            return
        }
        
        guard let cardNumber = cardNumberTextField.text,
            let name = nameOnCardTextField.text,
            let cvv = cvvTextField.text,
            let expiryDate = expiryDateTextField.text,
            let street = streetTextField.text,
            let city = cityTextField.text,
            let cvvAsNumber = Int(cvv),
            let state = stateTextField.text,
            let country = selectedCountry,
            let zipcode = zipcodeTextField.text else { return }
        
        let cardNum = cardNumber.replacingOccurrences(of: "-", with: "")
        let expDate = expiryDate.replacingOccurrences(of: " ", with: "")
        let expMonth = expDate.substring(fromIndex: 0, count: 2)
        let expYear = expDate.substring(fromIndex: 3, count: 2)

        let creditCardInfo: JSONDictionary = [
            "vendorCode": card.code,
            "cardNumber": cardNum,
            "expiryDate": "\(expMonth)\(expYear)",
            "securityId": cvvAsNumber,
            "name": name
        ]

        let addressArray = [street]

        let billingAddressInfo: JSONDictionary = [
            "addressLines": addressArray,
            "city": city,
            "zipCode": zipcode,
            "countryCode": country.sortName
        ]

        let kountSId = kountSessionId ?? ""
        
        if self.isFlightBooking {
            let price = "\(Int(Double(inboundFlight?.amount ?? "") ?? 0))"
            let parameters: JSONDictionary = [
                "itinerary": bookingItinerary,
                "passenger": passengerArray,
                "contact": self.contact,
                "fareAmount": price,
                "creditCardInfo": creditCardInfo,
                "billingAddress": billingAddressInfo,
                "merchant": MERCHANT,
                "kount_session_id": kountSId,
                "currency": CurrencyManager.shared.getUserCurrencyCode(),
                "tripType": self.tripType == .roundTrip ? 2 : 1,
                "familyName": fareFamilyName,
            ]
            
            checkAvialability(param: parameters)
        } else {
            if let htlBooking = self.hotelBooking {
                
                var feeAmount = ""
                if let amount = htlBooking.selectedAmount?.amountAfterTax {
                    feeAmount =  "\(amount)"
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
                
               
                let address: JSONDictionary = [
                    "name" : name,
                    "addressLine": "",
                    "city": city,
                    "zipCode": zipcode,
                    "countryCode": country.sortName
                ]
                
                let parameters: JSONDictionary = [
                    "location": htlBooking.selectedLocation,
                    "bookingCode": htlBooking.selectedRoom?.bookingCode ?? "",
                    "hotelCode": htlBooking.selectedHotel?.hotelCode ?? "",
                    "hotelName":htlBooking.selectedHotel?.hotelName ?? "",
                    "hotelCity":htlBooking.selectedHotel?.hotelCity ?? "",
                    "totalOccupants": htlBooking.occupent,
                    "startDate": checkInDate,
                    "endDate": checkOutDate,
                    "feeAmount": feeAmount,
                    "fareAmount": feeAmount,
                    "passenger": passengerArray,
                    "contact": contact,
                    "creditCardInfo": creditCardInfo,
                    "billingAddress": billingAddressInfo,
                    "address":address,
                    "merchant": MERCHANT,
                    "kount_session_id": kountSId,
                    "currency": CurrencyManager.shared.getUserCurrencyCode()
                ]
                
                makeHotelBooking(param: parameters)
            }
        }
    }
    
    func checkAvialability(param: JSONDictionary) {
        
        guard !passengerArray.isEmpty else {
            showAlert(message: "Please provide passenger detail")
            return
        }
        
        spinner(with: "Check bookability...")
        checkBookability { (success, msg) in
            DispatchQueue.main.async {
                self.hideSpinner()
                if !success {
                    self.showAlert(message: msg ?? "Unable to book flight")
                } else {
                    print(success)
                    self.bookFlight(param: param)
                }
            }
        }
    }
    
    private func bookFlight(param: JSONDictionary) {
        
        loaderImageView.isHidden = false
        APIController.makeRequest(request: .bookFlight(param: param)) { (response) in
            self.loaderImageView.isHidden = true
            DispatchQueue.main.async {
                switch response {
                case .failure(let e):
                    Flurry.logError("bookFlight_api", message: e.desc, exception: nil);
                    self.showAlert(message: e.desc)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? JSONDictionary, let statusCode = json?["statusCode"] as? Int else {
                            self.showAlert(message: "This flight can not be booked at the moment")
                            return
                    }
                    if statusCode == 200 {
                        //self.bookingSuccess()
                        self.flightBookingConfirmed(data:data)
                    } else {
                        self.showAlert(message: "Unable to book flight")
                    }
                }
            }
        }
    }

    private func bookingSuccess() {
        let alertController = UIAlertController(title: "Success", message: "Your flight tickets have been booked successfully. Your ticket details will be sent to you through e-mail and SMS. ", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NotificationCenter.default.post(name: NSNotification.Name.init("ResetBooking"), object: nil)
            self.navigationController?.popToRootViewController(animated: true)

        }

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }


}

// MARK: - UITextField Delegate

extension PaymentVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if textField == cvvTextField {
            return newLength <= 3 && string.rangeOfCharacter(from: CharacterSet.letters) == nil
        } else if textField == cardNumberTextField {
            return string.rangeOfCharacter(from: CharacterSet.letters) == nil
        } else if textField == zipcodeTextField || textField == streetTextField {
            return string.hasSpecialCharacters()
        } else if textField == expiryDateTextField {
            return newLength <= 5
        }
        
        return true
    }
}

extension PaymentVC {
    @objc func handleInputTextChanged(textField: UITextField) {
        guard let text = textField.text else { return }
        if textField == cardNumberTextField {
            textField.text = modifyCreditCardString(creditCardString: text)
            
            return
        }
        
        if textField == expiryDateTextField {
            textField.text = modifyExpireDateString(expireDateString: text)
            return
        }
    }
    
    @objc func handleInputTextEnded(textField: UITextField) {
        guard let text = textField.text else { return }
        setCardType(number: text)
    }
    
    fileprivate func setCardType(number: String) {
        let text = number.replacingOccurrences(of: "-", with: "")
        guard let type = CreditCardType.cardTypeForCreditCardNumber(cardNumber: text) else {
            self.cardNumberTextField.rightView = nil
            return
        }
        switch type {
        case .Amex:
            card = PaymentCard.init(name: "American Express", imageName: "ae", code: "AX")
        case .Master:
            card = PaymentCard.init(name: "Master Card", imageName: "master", code: "CA")
        case .Discover:
            card = PaymentCard.init(name: "Discover", imageName: "discover", code: "DS")
        case .Visa:
            card = PaymentCard.init(name: "Visa", imageName: "visa", code: "VI")
        case .DinerClub:
            card = PaymentCard.init(name: "Diner Club", imageName: "diner", code: "DS")
        }
    }
    
    func modifyCreditCardString(creditCardString : String) -> String {
        let trimmedString = creditCardString.components(separatedBy: "-").joined()
        
        let arrOfCharacters = Array(trimmedString)
        
        var modifiedCreditCardString = ""
        
        if arrOfCharacters.count > 0 {
            for i in 0...arrOfCharacters.count-1 {
                modifiedCreditCardString.append(arrOfCharacters[i])
                
                if((i+1) % 4 == 0 && i+1 != arrOfCharacters.count) {
                    
                    modifiedCreditCardString.append("-")
                }
            }
        }
        
        return modifiedCreditCardString
    }
    
    func modifyExpireDateString(expireDateString : String) -> String {
        return expireDateString.applyPatternOnNumbers(pattern: "**/**", replacementCharacter: "*")
    }
}
