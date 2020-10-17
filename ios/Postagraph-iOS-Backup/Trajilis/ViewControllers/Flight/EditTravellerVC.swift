//
//  EditTravellerVC.swift
//  Trajilis
//
//  Created by user on 27/08/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

protocol EditTravellerDelegate {
    func didFinishPickingTravellers(data: TravelersData)
}

struct TravelersData {
    var adults: [TravelerInfo]
    var children: [TravelerInfo]
    var infantOwnSeat: [TravelerInfo]
    var infantOnLap: [TravelerInfo]
    
    func total() -> Int {
        return adults.count + children.count + infantOwnSeat.count + infantOnLap.count
    }
    
    func allTravelers() -> [TravelerInfo] {
        return adults + children + infantOwnSeat + infantOnLap
    }
    
    func totalSeats() -> Int {
        return adults.count + children.count + infantOwnSeat.count
    }
    
    func totalInfants() -> Int {
        return infantOnLap.count + infantOwnSeat.count
    }
    
    static func newAdult() -> TravelerInfo {
        return TravelerInfo(travelerType: .adult, withInfant: false, email: nil, bio: TravelerBioInfo(firstname: "", lastname: "", dateOfBirth: ""), phone: nil, gender: "", infant: nil)
    }
    
    static func newChild() -> TravelerInfo {
        return TravelerInfo(travelerType: .child, withInfant: false, email: nil, bio: TravelerBioInfo(firstname: "", lastname: "", dateOfBirth: ""), phone: nil, gender: "", infant: nil)
    }
    
    static func newInfantOwnSeat() -> TravelerInfo {
        return TravelerInfo(travelerType: .infantWithSeat, withInfant: false, email: nil, bio: TravelerBioInfo(firstname: "", lastname: "", dateOfBirth: ""), phone: nil, gender: "", infant: nil)
    }
    
    static func newInfantOnLap() -> TravelerInfo {
        return TravelerInfo(travelerType: .infant, withInfant: false, email: nil, bio: TravelerBioInfo(firstname: "", lastname: "", dateOfBirth: ""), phone: nil, gender: "", infant: nil)
    }
    
}

class EditTravellerVC: UIViewController {

    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet var infantOwnSeatCountLabel: UILabel!
    @IBOutlet var infantOnLapCountLabel: UILabel!
    @IBOutlet var childCountLabel: UILabel!
    @IBOutlet var adultCountLabel: UILabel!
    
    var editTravlerDelegate: EditTravellerDelegate?
    var travelersData: TravelersData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureViews()
    }
    
    fileprivate func configureViews() {
        closeBtn.addTarget(self, action: #selector(handleCloseBtn), for: .touchUpInside)
        
        applyButton.layer.cornerRadius = 4
        applyButton.layer.masksToBounds = true
        applyButton.addTarget(self, action: #selector(handleApplyTapped), for: .touchUpInside)
        
        adultCountLabel.text = "\(travelersData?.adults.count ?? 0)"
        childCountLabel.text = "\(travelersData?.children.count ?? 0)"
        infantOwnSeatCountLabel.text = "\(travelersData?.infantOwnSeat.count ?? 0)"
        infantOnLapCountLabel.text = "\(travelersData?.infantOnLap.count ?? 0)"
    }

    @objc func handleCloseBtn() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleApplyTapped() {
        guard let travelersData = self.travelersData else { return }
        
        let infants = travelersData.infantOnLap + travelersData.infantOwnSeat
        
        for infant in infants {
            for var adult in travelersData.adults {
                if adult.infant == nil {
                    adult.infant = TravelerBioInfo(firstname: infant.bio.firstname, lastname: infant.bio.lastname, dateOfBirth: infant.bio.dateOfBirth)
                    break
                }
            }
        }
        
        editTravlerDelegate?.didFinishPickingTravellers(data: travelersData)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func incrementCountTapped(_ sender: UIButton) {
        guard let travelersData = travelersData else { return }
        
        switch sender.tag {
        case 0:
            guard let adultCount = adultCountLabel.text, var count = Int(adultCount) else { return }
            count += 1
            adultCountLabel.text = String(count)
            
            self.travelersData?.adults.removeAll()
            
            guard count > 0 else { return }
            for _ in 1...count {
                self.travelersData?.adults.append(TravelersData.newAdult())
            }
        case 1:
            guard let childCount = childCountLabel.text, var count = Int(childCount) else { return }
            count += 1
            childCountLabel.text = String(count)
            
            self.travelersData?.children.removeAll()
            guard count > 0 else { return }
            for _ in 1...count {
                self.travelersData?.children.append(TravelersData.newChild())
            }
        case 2:
            guard let infantCount = infantOwnSeatCountLabel.text, var count = Int(infantCount) else { return }
            count += 1
            
            let totalInfants = travelersData.infantOnLap.count + count
            if totalInfants > travelersData.adults.count {
                self.showAlert(message: "Number of infants is more than adults")
                count -= 1
            }
            
            infantOwnSeatCountLabel.text = String(count)
            
            self.travelersData?.infantOwnSeat.removeAll()
            guard count > 0 else { return }
            for _ in 1...count {
                self.travelersData?.infantOwnSeat.append(TravelersData.newInfantOwnSeat())
            }
        case 3:
            guard let infantCount = infantOnLapCountLabel.text, var count = Int(infantCount) else { return }
            count += 1
            
            let totalInfants = travelersData.infantOwnSeat.count + count
            if totalInfants > travelersData.adults.count {
                self.showAlert(message: "Number of infants is more than adults")
                count -= 1
            }
            
            infantOnLapCountLabel.text = String(count)
            
            self.travelersData?.infantOnLap.removeAll()
            guard count > 0 else { return }
            for _ in 1...count {
                self.travelersData?.infantOnLap.append(TravelersData.newInfantOnLap())
            }
        default:
            break
        }
    }
    
    @IBAction func decrementCountTapped(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            guard let adultCount = adultCountLabel.text, var count = Int(adultCount), count > 0 else { return }
            count -= 1
            adultCountLabel.text = String(count)

            self.travelersData?.adults.removeAll()
            guard count > 0 else { return }
            for _ in 1...count {
                self.travelersData?.adults.append(TravelersData.newAdult())
            }
        case 1:
            guard let childCount = childCountLabel.text, var count = Int(childCount), count > 0 else { return }
            count -= 1
            childCountLabel.text = String(count)
            
            self.travelersData?.children.removeAll()
            guard count > 0 else { return }
            for _ in 1...count {
                self.travelersData?.children.append(TravelersData.newChild())
            }
        case 2:
            guard let infantCount = infantOwnSeatCountLabel.text, var count = Int(infantCount), count > 0 else { return }
            count -= 1
            infantOwnSeatCountLabel.text = String(count)
            
            self.travelersData?.infantOwnSeat.removeAll()
            guard count > 0 else { return }
            for _ in 1...count {
                self.travelersData?.infantOwnSeat.append(TravelersData.newInfantOwnSeat())
            }
        case 3:
            guard let infantCount = infantOnLapCountLabel.text, var count = Int(infantCount), count > 0 else { return }
            count -= 1
            infantOnLapCountLabel.text = String(count)
            
            self.travelersData?.infantOnLap.removeAll()
            guard count > 0 else { return }
            for _ in 1...count {
                self.travelersData?.infantOnLap.append(TravelersData.newInfantOnLap())
            }
        default:
            break
        }
    }
}
