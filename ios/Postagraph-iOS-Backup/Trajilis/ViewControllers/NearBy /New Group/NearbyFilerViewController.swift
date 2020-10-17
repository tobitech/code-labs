//
//  NearbyFilerViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/27/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class NearbyFilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var setDistanceButton: UIButton!
    
    var onDistanceSet: ((CGFloat)->())?
    var ondSelectPlace: ((String) -> ())?
    var selectedDistance: CGFloat = 1
    var selectedPlaceType: String = ""
    
    private let placeTypeAPIArray = ["restaurant","art_gallery","atm","bar","bus_station","cafe","gas_station","locksmith","lodging","movie_theater","museum","night_club","parking","shopping_mall","subway_station","zoo"]
    private let placeTypeTitleArray = ["Restaurant","Art Gallery","ATM","Bar","Bus Station","Cafe","Gas Station","Locksmith","Lodging","Movie Theater","Museum","Night Club","Parking","Shopping Mall","Subway Station","Zoo"]
   private let placeTypeIconArray = ["restaurant","art_gallery","atm","bar","bus-stop","cafe.","gas-station","locksmith","lodging","movie_theater","museum","night_club","parking","shopping","train","zoo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        setDistanceButton.set(cornerRadius: 4)
        setDistanceButton.set(borderWidth: 2, of: UIColor(hexString: "#E5E5E5"))
        distanceSlider.setValue(Float(selectedDistance), animated: false)
        sliderValueChanged(nil)
    }
    
    @IBAction func setDistanceTapped(_ sender: Any) {
        onDistanceSet?(CGFloat(distanceSlider.value))
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectAllTapped(_ sender: Any) {
        ondSelectPlace?("")
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sliderValueChanged(_ sender: Any?) {
        let sliderValue = distanceSlider.value
        self.distanceLabel.text = "\((sliderValue * 100).rounded() / 100) Miles"
    }
    
}

extension NearbyFilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeTypeAPIArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(NearbyFilterPlaceTableViewCell.self, for: indexPath)
        cell.placeNameLabel.text = placeTypeTitleArray[indexPath.row]
        cell.placeImageView.image = UIImage(named: placeTypeIconArray[indexPath.row])
        cell.placeIsSelected = placeTypeAPIArray[indexPath.row] == selectedPlaceType
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let place = placeTypeAPIArray[indexPath.row]
        ondSelectPlace?(place)
        navigationController?.popViewController(animated: true)
    }
    
}
