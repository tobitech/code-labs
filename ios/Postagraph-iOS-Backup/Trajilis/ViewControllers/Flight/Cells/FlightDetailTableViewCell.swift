//
//  FlightDetailTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 27/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightDetailTableViewCell: UITableViewCell {

    static let identifier = "FlightDetailTableViewCell"

//    @IBOutlet var operatingAirlineLabel: UILabel!
//    @IBOutlet var durationLabel: UILabel!
//    @IBOutlet var arrDateLabel: UILabel!
//    @IBOutlet var depDateLabel: UILabel!
//    @IBOutlet var arrivalAirportNameLabel: UILabel!
//    @IBOutlet var arrivalCityNameLabel: UILabel!
//    @IBOutlet var depAirportNameLabel: UILabel!
//    @IBOutlet var depCityLabel: UILabel!
    @IBOutlet var flightNumberLabel: UILabel!
    @IBOutlet var airlineNameLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var containerStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var lblFareRule: UILabel!
    @IBOutlet var viewFareRule: UIView!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.register(FareRulesCell.self)
            collectionView.register((FareRulesHeaderView.self), reuseIdentifier: "FareRulesHeaderView", forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        }
    }
    var fareRules: [String]? {
        didSet {
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.isUserInteractionEnabled = false
        collectionView.isHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func fillData(result: FlightSearchResult?,cabinClass:FlightClass) {
        if let results = result {
            self.configure(flights: results.flights,cabinCode:cabinClass, duration: results.duration)
            self.setFareRules(result: results)
        }
    }
    func setFareRules(result: FlightSearchResult) {
        
        var rules: Set<String> = []
        for detail in result.details {
            if let pen = detail.fareRule?.PEN {
                rules.insert(pen)
            }
        }
        let array = Array(rules)
        let string = array.joined(separator: "\n")
//        self.lblFareRule.isHidden = true
        
        if(!string.isEmpty) {
//            self.lblFareRule.isHidden = false
//            self.lblFareRule.text = "Fare Rules\n\(string)"
        }
        //viewFareRule.isHidden = self.lblFareRule.isHidden
    }
    func configure(flights: [Flight],cabinCode:FlightClass,duration:String) {
        guard let first = flights.first else { return }
        titleLabel.text = "Departing flight - \(Helpers.formattedDateFromString(dateString: first.dateOfDeparture, withFormat: "EEE. MMM dd, yyyy"))"
        let layoverText = flights.count > 1 ? "- Includes \(flights.count-1) stop layover" : ""
        
        let durationStr = duration.replacingOccurrences(of: ":", with: "h ").appending("m")
        subtitleLabel.text = "Total trip time: \(durationStr) \(layoverText)"
        
//        subtitleLabel.text = "Total trip time: \(addTime(flights: flights)) \(layoverText)"
        
        if let markCompany = first.marketingCompany, let marketingName = first.marketingCompany?.full_name,!marketingName.isEmpty {
            airlineNameLabel.text = marketingName
            if let logo = markCompany.logo, let url = URL(string: logo) {
                logoImageView.sd_setImage(with: url, completed: nil)
            }
        } else {
            
            airlineNameLabel.text = first.operatingCompany?.full_name ?? ""
            if let logo = first.operatingCompany?.logo, let url = URL(string: logo) {
                logoImageView.sd_setImage(with: url, completed: nil)
            }
        }
        
        flightNumberLabel.text = "Flight No: \(first.flightNumber)"
        

        containerStackView.removeAllArrangedSubviews()
        for (index, flight) in flights.enumerated() {
            let noLayover = index == flights.count - 1
            let height: CGFloat = noLayover ? 208 : 295

            let flightView = FlightView(frame: .init(x: 0, y: 0, width: containerStackView.bounds.width, height: height))
            containerStackView.addArrangedSubview(flightView)
            if !noLayover {
                let nextFlight = flights[index+1]
                let layoverDuration = Helpers.durationBetween(latestDate: nextFlight.departureDate, previousDate: flight.arrivalDate)
                flightView.layoverDurationLabel.text = layoverDuration
            }
            flightView.configure(with: flight, noLayover: noLayover)
            flightView.flightClassLabel.text = nil
            
            flightView.flightClassLabel.text = cabinCode.rawValue
            
        }

    }


    func formattedDateFromString(dateString: String, withFormat format: String) -> String {

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = inputFormatter.date(from: dateString) {

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format

            return outputFormatter.string(from: date)
        }

        return ""
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

extension UIStackView {
    @discardableResult
    func removeAllArrangedSubviews() -> [UIView] {
        let removedSubviews = arrangedSubviews.reduce([]) { (removedSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            NSLayoutConstraint.deactivate(subview.constraints)
            subview.removeFromSuperview()
            return removedSubviews + [subview]
        }
        return removedSubviews
    }
}

extension FlightDetailTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fareRules = fareRules {
            collectionViewHeight.constant = 90
            return fareRules.count
        }else {
            collectionViewHeight.constant = 0
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(FareRulesCell.self, for: indexPath)
        if let fareRules = self.fareRules {
            cell.fareRuleLbl.text = fareRules[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return .init(width: self.frame.width, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FareRulesHeaderView", for: indexPath) as! FareRulesHeaderView
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return .init(width: self.frame.width, height: 30)
    }
}
