//
//  ConfirmItineraryVC.swift
//  Trajilis
//
//  Created by Perfect Aduh on 05/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SDWebImage

class ConfirmItineraryVC: UIViewController {

    @IBOutlet weak var outboundDateLabel: UILabel!
    @IBOutlet weak var inboundFlightInfoLabel: UILabel!
    @IBOutlet weak var outboundCity1Lbl: UILabel!
    @IBOutlet weak var inboundCity1Lbl: UILabel!
    @IBOutlet weak var departureDate1Lbl: UILabel!
    @IBOutlet weak var airlineName1Lbl: UILabel!
    @IBOutlet weak var duration1Lbl: UILabel!
    @IBOutlet weak var departureTime1Lbl: UILabel!
    @IBOutlet weak var airLogoImgV1: UIImageView!
    @IBOutlet weak var outboundCity2Lbl: UILabel!
    @IBOutlet weak var inboundCity2Lbl: UILabel!
    @IBOutlet weak var departureDate2Lbl: UILabel!
    @IBOutlet weak var airlineName2Lbl: UILabel!
    @IBOutlet weak var duration2Lbl: UILabel!
    @IBOutlet weak var departureTime2Lbl: UILabel!
    @IBOutlet weak var airLogoImgV2: UIImageView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var passengerCountLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!

    var param: JSONDictionary!
    var departureDate: Date?
    var cabinClass: FlightClass = FlightClass.economy
    var returnDate: Date?
    var destination: Airport?
    var origin: Airport?
    
    var inboundFlight: FlightDetails?
    var outboundFlight: FlightDetails?
    
    var travelersData: TravelersData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Confirm Itinerary"
        
        self.travelersData = (self.navigationController as? BookingNavigationController)?.travelersData
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        outboundCity1Lbl.text = origin?.city ?? ""
        outboundCity2Lbl.text = destination?.city ?? ""
        
        outboundDateLabel.text = Helpers.formattedDateFromString(dateString: outboundFlight?.flightInfo?[0].dateOfDeparture ?? "", withFormat: "EEE, MMM d") //
        
        inboundCity1Lbl.text  = destination?.city ?? ""
        inboundCity2Lbl.text  = origin?.city ?? ""
        
        departureDate1Lbl.text = Helpers.formattedDateFromString(dateString: outboundFlight?.flightInfo?[0].dateOfDeparture ?? "", withFormat: "EEE, MMM d") //
        airlineName1Lbl.text = outboundFlight?.flightInfo?[0].operatingDetails.fullName
        duration1Lbl.text = "\(outboundFlight?.duration ?? "")h"
        departureTime1Lbl.text = outboundFlight?.flightInfo?[0].timeOfDeparture
        
        if let url = URL(string: outboundFlight?.flightInfo?[0].marketingDetails.logoSmall ?? "") {
            airLogoImgV1.sd_setImage(with: url)
        }
        
        inboundFlightInfoLabel.text = Helpers.formattedDateFromString(dateString: inboundFlight?.flightInfo?[0].dateOfDeparture ?? "", withFormat: "EEE, MMM d") //
        departureDate2Lbl.text = Helpers.formattedDateFromString(dateString: inboundFlight?.flightInfo?[0].dateOfDeparture ?? "", withFormat: "EEE, MMM d") //
        airlineName2Lbl.text = inboundFlight?.flightInfo?[0].operatingDetails.fullName
        duration2Lbl.text = "\(inboundFlight?.duration ?? "")h"
        departureTime2Lbl.text = inboundFlight?.flightInfo?[0].timeOfDeparture
        if let url = URL(string: inboundFlight?.flightInfo?[0].marketingDetails.logoSmall ?? "") {
            airLogoImgV2.sd_setImage(with: url)
        }
        
        let currency = CurrencyManager.shared.getUserCurrencyCode()
        amountLbl.text = "\(currency) \(Int(Double(outboundFlight?.amount ?? "") ?? 0))"
        passengerCountLbl.text = "\(travelersData?.adults.count ?? 0) Adult"
        
        continueBtn.makeCornerRadius(cornerRadius: 4.0)
        continueBtn.addTarget(self, action: #selector(handleContinueBtn), for: .touchUpInside)
    }
    
    @objc func handleContinueBtn() {
        let controller =  FlightDetailsVC.instantiate(fromAppStoryboard: .flight)
        controller.inboundFlight = self.inboundFlight
        controller.outboundFlight = self.outboundFlight
        controller.origin = self.origin
        controller.destination = self.destination
        controller.departureDate = self.departureDate
        controller.returnDate = self.returnDate
        controller.param = self.param
        self.navigationController?.pushViewController(controller, animated: true)
    }
   
}
