//
//  FlightOptionsTVCell.swift
//  Trajilis
//
//  Created by Perfect Aduh on 12/07/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightOptionsTVCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var data: [FareFamilyServices]! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var price: FareFamilyPrice! {
        didSet {
            priceLbl.text = kUserCurrencySymbol + "\(Int(price.totalAmount.rounded()))"
        }
    }
    
    var moreLessComplete: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(FlightOptionsCVCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc fileprivate func handleMoreLess() {
        moreLessComplete?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        checkImageView.image = selected ? #imageLiteral(resourceName: "check_icon") : #imageLiteral(resourceName: "unselected")
    }
}


extension FlightOptionsTVCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = data {
            return data.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(FlightOptionsCVCell.self, for: indexPath)
        cell.fareFamilyServices = self.data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (frame.width / 2) - 32
        return .init(width: width, height: 28)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        moreLessComplete?()
    }
}
