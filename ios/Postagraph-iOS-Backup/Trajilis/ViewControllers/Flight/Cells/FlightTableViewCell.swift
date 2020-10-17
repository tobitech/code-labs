//
//  FlightTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 12/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightTableViewCell: UITableViewCell {

    static let identifier = "FlightTableViewCell"

//    @IBOutlet var returnStackView: UIStackView!
//    @IBOutlet var returnTimeLabel: UILabel!
//    @IBOutlet var returnDestinationLabel: UILabel!
//    @IBOutlet var returnExtLabel: UILabel!
//    @IBOutlet var returnStopsLabel: UILabel!
//    @IBOutlet var returnDurationLabel: UILabel!
//    @IBOutlet var departtureExtLabel: UILabel!
//    @IBOutlet var departureStopsLabel: UILabel!
//    @IBOutlet var departureDurationLabel: UILabel!
//    @IBOutlet var destinationTimeLabel: UILabel!
////    @IBOutlet var destinationLabel: UILabel!
//    @IBOutlet var returnDepartureOriginTimeLabel: UILabel!
//    @IBOutlet var returnDepartureOriginLabel: UILabel!
//    @IBOutlet var departureOriginTimeLabel: UILabel!
//    @IBOutlet var departureOriginLabel: UILabel!
    @IBOutlet var fareLabel: UILabel!
    @IBOutlet var airlineNameLabel: UILabel!
    @IBOutlet var airlineLogoImageView: UIImageView!
    @IBOutlet var cardView: CardView!

    @IBOutlet var secondLayoverArrowImageView: UIImageView!
    @IBOutlet var firstLayoverArrowImagView: UIImageView!
    @IBOutlet var secondLayoverLabel: UILabel!
    @IBOutlet var firstLayoverLabel: UILabel!
    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var originLabel: UILabel!
    @IBOutlet var timeOfArrivalLabel: UILabel!
    @IBOutlet var timeOfDepartureLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var numberOfStopLabel: UILabel!
    
    @IBOutlet var roundTripLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
//        self.originLabel.textColor = .appRed
//        self.firstLayoverLabel.textColor = .appRed
//        self.secondLayoverLabel.textColor = .appRed
//        self.destinationLabel.textColor = .appRed
        
    }

    func configure(outgoing: FlightSearchResult, index: Int, isRoundTrip: Bool) {
        roundTripLabel.isHidden = !isRoundTrip
        fareLabel.text = "\(kUserCurrencySymbol)\(outgoing.totalAggAmount.rounded(toPlaces: 2))"
        guard let firstFlight = outgoing.flights.first else { return }
        airlineNameLabel.text = firstFlight.operatingCompany?.full_name ?? ""
        if let logo = firstFlight.operatingCompany?.logo,  let url = URL(string: logo) {
            airlineLogoImageView.sd_setImage(with: url, completed: nil)
        }

        durationLabel.text = addTime(flights: outgoing.flights)
        timeOfDepartureLabel.text = firstFlight.timeOfDeparture
        timeOfArrivalLabel.text = firstFlight.timeOfArrival

        if outgoing.flights.count > 1 {
            let count = outgoing.flights.count-1
            let stop = count > 1 ? "stops" : "stop"
            numberOfStopLabel.text = "\(outgoing.flights.count - 1) \(stop)"
            destinationLabel.text = outgoing.flights.last?.arrivalLocation
        } else {
            numberOfStopLabel.text = "Non-Stop"
        }

        originLabel.text = firstFlight.departureLocation
        timeOfDepartureLabel.text = firstFlight.timeOfDeparture
        if outgoing.flights.count > 1 {
            let lastFlight = outgoing.flights.last!
            timeOfArrivalLabel.text = lastFlight.timeOfArrival
            destinationLabel.text = lastFlight.arrivalLocation

            firstLayoverLabel.isHidden = true
            firstLayoverArrowImagView.isHidden = true
            secondLayoverLabel.isHidden = true
            secondLayoverArrowImageView.isHidden = true

            if outgoing.flights.count == 2 {
                firstLayoverArrowImagView.isHidden = false
                firstLayoverLabel.isHidden = false
                firstLayoverLabel.text = lastFlight.departureLocation
            }

            if outgoing.flights.count == 3 {
                let thirdFlight = outgoing.flights[1]
                firstLayoverArrowImagView.isHidden = false
                firstLayoverLabel.isHidden = false
                firstLayoverLabel.text = thirdFlight.departureLocation
                secondLayoverArrowImageView.isHidden = false
                secondLayoverLabel.isHidden = false
                secondLayoverLabel.text = lastFlight.departureLocation
            }
        } else {
            timeOfArrivalLabel.text = firstFlight.timeOfArrival
            destinationLabel.text = firstFlight.arrivalLocation
            firstLayoverLabel.isHidden = true
            firstLayoverArrowImagView.isHidden = true
            secondLayoverLabel.isHidden = true
            secondLayoverArrowImageView.isHidden = true
        }

//        returnStackView.isHidden = true
//        guard let incoming = incoming, let incomingFlight = incoming.flights.first else {
//
//            return
//        }


//        returnStackView.isHidden = false
//
//        returnDepartureOriginLabel.text = outgoingFlight.arrivalLocation
//        returnDestinationLabel.text = departureOriginLabel.text
//        returnDurationLabel.text = addTime(flights: incoming.flights)
//        returnDepartureOriginTimeLabel.text = incomingFlight.timeOfDeparture + " DEP"
//        returnTimeLabel.text = incomingFlight.timeOfArrival + " ARR"
//
//        if incoming.flights.count > 1 {
//            returnStopsLabel.text = "\(incoming.flights.count-1) STOP"
//            returnExtLabel.text = "\(outgoingFlight.arrivalLocation) +\(outgoing.flights.count-2)"
//        } else {
//            returnStopsLabel.text = "NON STOP"
//            returnExtLabel.text = "- -"
//        }

    }

    private func addTime(flights: [Flight]) -> String {
        var sum = 0
        for flight in flights {
            let components = flight.flightDuration.components(separatedBy: ".")
            let hour = components.first!
            let minute = components.last!
            if let hourToInt = Int(hour) {
                sum += (hourToInt * 60)
            }
            if let minutesToInt = Int(minute) {
                sum += minutesToInt
            }
        }
        let hour: Int = sum/60
        let minute: Int = sum%60
        return "\(hour)h \(minute)m"
    }

}

extension Collection {
    func get(at index: Index) -> Iterator.Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
