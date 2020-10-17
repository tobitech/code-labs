//
//  TripsterListTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/16/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SDWebImage

class TripsterListTableViewCell: UITableViewCell {

    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDates:UILabel!
    @IBOutlet weak var lblMemories:UILabel!
    @IBOutlet weak var lblGraphers:UILabel!
    @IBOutlet weak var lblLocation:UILabel!
    @IBOutlet weak var memoriesCollectionView:UICollectionView!
    @IBOutlet weak var graphersCollectionView:UICollectionView!
    @IBOutlet weak var lblBeFirstToAdd:UILabel!
    @IBOutlet weak var beFirstToAdd:UIStackView!
    @IBOutlet weak var addToTrip:UIView!
    @IBOutlet weak var addMemoryView:UIView!
    @IBOutlet weak var chatDeleteStackView: UIStackView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var trip: Trip!
    var onAddMemoriesTapped: (()->())?
    var onChatTapped: (()->())?
    var onDeleteTapped: (()->())?
    var onAddToTripTapped: (()->())?
    var onCellTapped: (() -> ())?
    var onUserTapped: ((TripMember)->())?
    var onMemoryTapped: ((Feed) -> ())?
    
    var tripSelectMode: Bool = false {
        didSet {
            addToTrip.isHidden = !tripSelectMode
            if tripSelectMode {
                chatDeleteStackView.isHidden = true
                beFirstToAdd.isHidden = true
            }
        }
    }
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        memoriesCollectionView.register(TripsterCollectionViewCell.self, reuseIdentifier: TripsterCollectionViewCell.identifier)
        memoriesCollectionView.delegate = self
        memoriesCollectionView.dataSource = self
        graphersCollectionView.delegate = self
        graphersCollectionView.dataSource = self
        
        [addToTrip, addMemoryView].forEach({
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addMemories(_:)))
            $0?.addGestureRecognizer(tapGesture)
            $0?.set(borderWidth: 2, of: UIColor(hexString: "#e5e5e5"))
            $0?.set(cornerRadius: 4)
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped(_:)))
        self.contentView.addGestureRecognizer(tapGesture)
    }
    
    func configure(trip:Trip, isPublic: Bool = false) {
        self.lblTitle.text = trip.tripName
        self.lblDates.text = String(format:"%@ - %@",formatDate(timestamp: trip.startDate), formatDate(timestamp: trip.endDate))
        self.lblLocation.text = trip.location
        let memberCount = trip.memberCount
        let memoryCount = trip.memoryCount
        
        lblGraphers.text = ""
        lblMemories.text = ""
        
        if memberCount != "0" {
            lblGraphers.text = "\(memberCount) Users going on this trip"
        }else {
            lblGraphers.text = "0 Users going on this trip"
        }
        
        if memoryCount != "0" {
            beFirstToAdd.isHidden = true
            memoriesCollectionView.isHidden = false
            lblMemories.text = "\(memoryCount) Memories Shared"
        }else {
            beFirstToAdd.isHidden = false
            memoriesCollectionView.isHidden = true
            lblMemories.text = "0 Memories Shared"
        }
        lblBeFirstToAdd.text = isPublic ? "Be first to a add memory": ""
        self.trip = trip
        trip.onMemoriesAdded = { [weak self] in
            self?.memoriesCollectionView.reloadData()
        }
        memoriesCollectionView.reloadData()
        graphersCollectionView.reloadData()
        
        deleteButton.tintColor = trip.adminUser?.userId == Helpers.userId ? UIColor(hexString: "#D63D41") : UIColor(hexString: "#E5E5E5")
        deleteButton.isUserInteractionEnabled = trip.adminUser?.userId == Helpers.userId
        chatButton.isHidden = !trip.shouldShowChat()
        chatDeleteStackView.isHidden = deleteButton.isHidden && chatButton.isHidden
    }
    
    private func formatDate(timestamp: String) -> String {
        guard let double = Double(timestamp) else { return "" }
        let date = Date(timeIntervalSince1970: double)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "EEE,MMM d"
        return dateFormate.string(from: date)
    }
    
    @objc private func addMemories(_ sender: UITapGestureRecognizer) {
        if sender.view == addToTrip {
           onAddToTripTapped?()
        }else {
            onAddMemoriesTapped?()
        }
    }
    
    @objc private func cellTapped(_ gesture: UITapGestureRecognizer) {
//        var location = gesture.location(in: graphersCollectionView)
//        if let indexPath = graphersCollectionView.indexPathForItem(at: location) {
//            let member = trip.members[indexPath.row]
//            onUserTapped?(member)
//            return
//        }
//        location = gesture.location(in: memoriesCollectionView)
//        if let indexPath = memoriesCollectionView.indexPathForItem(at: location) {
//            let memory = trip.memories[indexPath.row]
//            onMemoryTapped?(memory)
//            return
//        }
        onCellTapped?()
        print("cell tapped")
    }
    
    @IBAction private func chatTapped(_ sender: Any) {
        onChatTapped?()
    }
    
    @IBAction private func deleteTapped(_ sender: Any) {
        onDeleteTapped?()
    }
    
}

extension TripsterListTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == memoriesCollectionView {
            return trip?.memories.count ?? 0
        }
        return trip?.members.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == memoriesCollectionView {
            let cell = collectionView.dequeue(TripListMemoryCollectionViewCell.self, for: indexPath)
            
            let memory = trip.memories[indexPath.row]
            cell.imageView.image = nil
            cell.viewCountLabel.text = "\(memory.viewcount)"
            if let url = URL(string: memory.imageURL) {
                cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imageView.sd_setImage(with: url, completed: nil)
            }
            return cell
        }else {
            let cell = collectionView.dequeue(TripListGrapherCollectionViewCell.self, for: indexPath)
            let member = trip.members[indexPath.row]
            cell.imageView.alpha = member.inviteStatus == "INVITED" ? 0.6 : 1
            let placeHolderImage = UIImage(named: "userAvatar")
            cell.imageView.image = placeHolderImage
            if let url = URL(string: member.userImage) {
                cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
            }
            return cell
        }
    }
    
}
