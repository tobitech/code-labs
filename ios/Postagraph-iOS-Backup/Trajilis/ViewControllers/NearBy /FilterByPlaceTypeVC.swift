//
//  FilterByPlaceTypeVC.swift
//  Trajilis
//
//  Created by Perfect Aduh on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit


protocol FilterByPlaceDelegate {
    
    func passPlaceAPI(value: String)
}

class FilterByPlaceTypeVC: BaseVC {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Mark: Properties
//    let viewModel: NearbyViewModel!

    var delegate: FilterByPlaceDelegate?
    var placeTypeAPIArray: [String] = [String]()
    var placeTypeTitleArray: [String] = [String]()
    var placeTypeIconArray: [String] = [String]()
    var selectedIndex: IndexPath?
    var didSelectPlace:((String)->Void)?
    var selectedPlaceType:String! =  ""
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        self.title = "Filter"
        placeTypeAPIArray = ["restaurant","art_gallery","atm","bar","bus_station","cafe","gas_station","locksmith","lodging","movie_theater","museum","night_club","parking","shopping_mall","subway_station","zoo"]
        placeTypeTitleArray = ["Restaurant","Art Gallery","ATM","Bar","Bus Station","Cafe","Gas Station","Locksmith","Lodging","Movie Theater","Museum","Night Club","Parking","Shopping Mall","Subway Station","Zoo"]
        placeTypeIconArray = ["restaurant","art_gallery","atm","bar","bus-stop","cafe.","gas-station","locksmith","lodging","movie_theater","museum","night_club","parking","shopping","train","zoo"]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "All Places", style: .plain, target: self, action: #selector(btnAllTapped(sender:)))
        if !selectedPlaceType.isEmpty {
            if let index = placeTypeAPIArray.firstIndex(of: selectedPlaceType) {
                self.selectedIndex = IndexPath(row: index, section: 0)
            }
        }
    }
    @IBAction func btnAllTapped(sender:UIBarButtonItem) {
        self.didSelectPlace?("")
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTableView() {
        self.tableView.backgroundColor = .clear
        tableView.rowHeight = 70
        tableView.estimatedRowHeight = 70
        tableView.register(UINib.init(nibName: "PlaceTypeFIlterTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaceTypeFIlterTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    
    @IBAction func backBtnPressed( _ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyBtnPressed( _ sender: UIButton) {
        if let indexPath = self.selectedIndex {
            self.delegate?.passPlaceAPI(value: self.placeTypeAPIArray[indexPath.row])
        }
        self.navigationController?.popViewController(animated: true)
    }
}


extension FilterByPlaceTypeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return placeTypeTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceTypeFIlterTableViewCell", for: indexPath) as! PlaceTypeFIlterTableViewCell
        cell.backgroundColor = .clear
        cell.isPlaceSelected = (self.selectedIndex == indexPath)
        cell.configureCell(title: self.placeTypeTitleArray[indexPath.row], placeImgName: self.placeTypeIconArray[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.placeTypeAPIArray[indexPath.row]
        self.didSelectPlace?(place)
        self.navigationController?.popViewController(animated: true)
    }
    
}
