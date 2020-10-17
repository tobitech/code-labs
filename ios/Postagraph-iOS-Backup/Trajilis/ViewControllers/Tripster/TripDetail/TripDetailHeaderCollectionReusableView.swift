//
//  TripDetailHeaderCollectionReusableView.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/16/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SDWebImage

class TripDetailHeaderCollectionReusableView: UICollectionReusableView {
    
    var trip: Trip? {
        didSet {
            setup()
        }
    }
    
    var selectedMode: kTripDetailTab = .AllMemories {
        didSet {
            setupTab()
        }
    }
    
    var onTabChanged: ((kTripDetailTab)->())?
    var onMemberSelected: ((TripMember)->())?
    var onUsersTapped: (()->())?
    var onAddMemoryTapped: (()->())?
    var onBookFlightsTapped: (()->())?
    
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDateLabel: UILabel!
    @IBOutlet weak var tripPrivatePublicLabel: UILabel!
    @IBOutlet weak var tripUserCountLabel: UILabel!
    @IBOutlet weak var tripMemoriesCountLabel: UILabel!
    @IBOutlet weak var tripPinsCountLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var addAMemoryView: UIView!
    @IBOutlet weak var bookFlightsView: UIView!
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var memoriesButton: UIButton!
    @IBOutlet weak var pinsButton: UIButton!
    @IBOutlet weak var calendarImageView: UIImageView!
    @IBOutlet weak var usersStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        calendarImageView.tintColor = UIColor(hexString: "#D63D41")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnUser))
        usersStackView.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.addAMemory))
        addAMemoryView.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnUser(_:)))
        membersCollectionView.addGestureRecognizer(tapGesture3)
        
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(self.bookFlights))
        bookFlightsView.addGestureRecognizer(tapGesture4)
    }
    
    @IBAction func memories(_ sender: Any) {
        onTabChanged?(.AllMemories)
        selectedMode = .AllMemories
    }
    
    @IBAction func pins(_ sender: Any) {
        onTabChanged?(.Pins)
        selectedMode = .Pins
    }
    
    private func setup() {
        guard let trip = trip else {return}
        tripNameLabel.text = trip.tripName
        tripDateLabel.text = String(format:"%@ - %@",formatDate(timestamp: trip.startDate), formatDate(timestamp: trip.endDate))
        tripPrivatePublicLabel.text = trip.feed_visibility.lowercased().capitalized
        tripUserCountLabel.text = trip.memberCount
        tripMemoriesCountLabel.text = trip.memoryCount
        tripPinsCountLabel.text = "0"
        locationLabel.text = trip.location
        notesLabel.text = trip.desc
        membersCollectionView.reloadData()
    }
    
    private func formatDate(timestamp: String) -> String {
        guard let double = Double(timestamp) else { return "" }
        let date = Date(timeIntervalSince1970: double)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "EEE,MMM d"
        return dateFormate.string(from: date)
    }
    
    private func setupTab() {
        if selectedMode == .AllMemories {
            memoriesButton.tintColor = UIColor(hexString: "#D63D41")
            pinsButton.tintColor = UIColor(hexString: "#3F3F3F", alpha: 0.5)
        }else {
            memoriesButton.tintColor = UIColor(hexString: "#3F3F3F", alpha: 0.5)
            pinsButton.tintColor = UIColor(hexString: "#D63D41")
        }
    }
    
    @objc private func tappedOnUser(_ gesture: UITapGestureRecognizer) {
//        let location = gesture.location(in: membersCollectionView)
//        if let indexPath = membersCollectionView.indexPathForItem(at: location) {
//            onMemberSelected?(trip!.members[indexPath.row])
//            return
//        }
        onUsersTapped?()
    }
    
    @objc private func addAMemory() {
        onAddMemoryTapped?()
    }
    
    @objc private func bookFlights() {
        onBookFlightsTapped?()
    }

}

extension TripDetailHeaderCollectionReusableView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trip?.members.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(TripListGrapherCollectionViewCell.self, for: indexPath)
        let placeHolderImage = UIImage(named: "userAvatar")
        cell.imageView.image = placeHolderImage
        let member = trip?.members[indexPath.row]
        cell.imageView.alpha = member?.inviteStatus == "INVITED" ? 0.6 : 1
        if let urlString = member?.userImage,
        let url = URL(string: urlString) {
            cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
        return cell
    }

}
