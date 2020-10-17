//
//  PGHotelsViewController.swift
//  Trajilis
//
//  Created by bharats802 on 16/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PGHotelsViewController: BaseVC {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var viewHeader:UIView!
    @IBOutlet var lblHeader:UILabel!
    @IBOutlet var lblHotelText:UILabel!
    var searchParams:JSONDictionary?
    var curntLocParams:JSONDictionary?
    var arrHotels = [PGHotel]()
    var arrFilteredHotels:[PGHotel]?
    
    var hotelBooking:PGHotelBooking?

    var sortFilter:PGHotelSortFilter!  = PGHotelSortFilter()
    
    var maxVal:Float = 1000000
    
    var city: String = ""
    var departDate: String = ""
    var returnDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNavigationBar()
        self.title = "\(departDate) - \(returnDate)"
        navigationController?.navigationBar.prefersLargeTitles = false        
        self.tblView.backgroundColor = .clear
        self.tblView.tableFooterView = UIView(frame:CGRect.zero)
        self.tblView.separatorStyle = .none
        self.tblView.register(PGHotelListCell.classForCoder(), forCellReuseIdentifier: PGHotelListCell.identifier)
        self.tblView.register(UINib(nibName: PGHotelListCell.identifier, bundle: nil), forCellReuseIdentifier: PGHotelListCell.identifier)
        self.getHotels()
        let filterIcon = UIBarButtonItem(image: UIImage(named: "hotelfilter"), style: .plain, target: self, action: #selector(filterTapped(_:)))
        navigationItem.rightBarButtonItem = filterIcon

       
        // Do any additional setup after loading the view.
    }
    @IBAction func filterTapped(_ sender: UIButton) {
        let vc = PGHotelFilterViewController.instantiate(fromAppStoryboard: .hotels)
        vc.sortFilter = self.sortFilter
        vc.maxVal = self.maxVal
        vc.didFilter = { [weak self](sfiler) in
            if let strngSelf = self {
                strngSelf.sortFilter = sfiler
                strngSelf.loadFiltered()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func loadFiltered() {
        
        if self.arrHotels.count > 0 {
            
           self.arrFilteredHotels = self.arrHotels
            
            if let name = self.sortFilter.name,name.count > 0 {
                let nameFiltered = self.arrFilteredHotels?.filter({ (hotel) -> Bool in
                    if hotel.hotelName.lowercased().contains(name.lowercased()) {
                        return true
                    }
                    return false
                })
                self.arrFilteredHotels = nameFiltered
            }
            
            if let starRating = self.sortFilter.filterByStar {
                let starFiltered = self.arrFilteredHotels?.filter { (hotel) -> Bool in
                    if let rating = hotel.hotelDescription?.ratings_value,Int(rating) >= starRating {
                        return true
                    } else {
                        return false
                    }
                }
                self.arrFilteredHotels = starFiltered
            }
            

            let priceFiltered = self.arrFilteredHotels?.filter({ (hotel) -> Bool in
                if hotel.getMinimumPriceValue() < Double(self.sortFilter.pricePerNight) {
                    return true
                } else {
                    return false
                }
            })
            self.arrFilteredHotels = priceFiltered
            
            if let sortBy = self.sortFilter.sortBy {
                switch  sortBy {
                case kSortBy.PriceLowToHight :
                    
                    let priceSorted = self.arrFilteredHotels?.sorted(by: { (h1, h2) -> Bool in
                        if h1.getMinimumPriceValue() < h2.getMinimumPriceValue() {
                            return true
                        }
                        return false
                    })
                    
                    self.arrFilteredHotels = priceSorted
                    
                case kSortBy.StarLevel :
                    
                    let priceSorted = self.arrFilteredHotels?.sorted(by: { (h1, h2) -> Bool in
                        if let rt1 = h1.hotelDescription?.ratings_value, let rt2 = h2.hotelDescription?.ratings_value,rt1  > rt2 {
                            return true
                        }
                        return false
                    })
                    
                    self.arrFilteredHotels = priceSorted
                    
                default:
                    break
                }
                
            }
            
        }
        if let filtered = self.arrFilteredHotels {
            self.tblView.reloadData()
            self.lblHeader.text = "\(filtered.count) Hotels found in \(self.city)"
            self.lblHeader.isHidden = false
            self.lblHotelText.isHidden = false
        } else {
            self.showAlert(message: "No hotels found.")
        }
        
    }
    func getCurrentLocationHotels() {
        guard let param = self.curntLocParams else {
            return
        }
        self.lblHeader.text = nil
        self.lblHeader.text = "0"
        self.lblHeader.isHidden = true
        self.lblHotelText.isHidden = true
        self.spinner(with: "Getting Hotels...", blockInteraction: true)
        APIController.makeRequest(request: .hotelNearby(param: param)) { [weak self](response) in
            
            DispatchQueue.main.async {
                
                if let strngSelf = self {
                    strngSelf.hideSpinner()
                    switch response {
                    case .failure(let error):
                        strngSelf.showAlert(message: error.desc)
                        strngSelf.navigationController?.popViewController(animated: true)
                    case .success(let result):
                        do {
                            guard let json = try result.mapJSON() as? JSONDictionary, let data = json["data"] as? JSONDictionary else {
                                strngSelf.showAlert(message: "No hotels found.")
                                return
                            }
                            if let hotels = data["hotels"] as? [JSONDictionary]{
                                let hotelsArr  = hotels.compactMap{ PGHotel.init(json: $0) }
                                if hotelsArr.count > 0 {
                                    strngSelf.arrHotels.append(contentsOf: hotelsArr)
                                    strngSelf.arrFilteredHotels = strngSelf.arrHotels
                                    strngSelf.tblView.reloadData()
                                    strngSelf.lblHeader.text = "\(strngSelf.arrHotels.count)  Hotels found in \(strngSelf.city)"
                                    strngSelf.lblHeader.isHidden = false
                                    strngSelf.lblHotelText.isHidden = false
                                    
                                    
                                    let priceFiltered = strngSelf.arrHotels.sorted(by: { (h1, h2) -> Bool in
                                        if h1.getMinimumPriceValue() > h2.getMinimumPriceValue() {
                                            return true
                                        }
                                        return false
                                    })
                                    let maxPrice = priceFiltered.first
                                    if let mprice = maxPrice?.getMinimumPriceValue() {
                                        strngSelf.maxVal = Float(mprice)
                                    }
                                    
                                    
                                } else {
                                    strngSelf.showAlert(message: "No hotels found.")
                                }
                            }
                            
                        } catch {
                            print(error)
                        }
                        
                    }
                }
            }
        }
    }
    
    func getHotels() {
        guard let param = self.searchParams else {
            self.getCurrentLocationHotels()
            return
        }
        self.lblHeader.text = nil
        self.lblHeader.text = "0"
        self.lblHeader.isHidden = true
        self.lblHotelText.isHidden = true
        self.spinner(with: "Getting Hotels...", blockInteraction: true)
        APIController.makeRequest(request: .hotelSearch(param: param)) { [weak self](response) in
            
            DispatchQueue.main.async {
                if let strngSelf = self {
                    strngSelf.hideSpinner()
                    switch response {
                    case .failure(let error):
                        strngSelf.showAlert(message: error.desc)
                        strngSelf.navigationController?.popViewController(animated: true)
                    case .success(let result):
                        do {
                            guard let json = try result.mapJSON() as? JSONDictionary, let data = json["data"] as? JSONDictionary else {
                                
                                DispatchQueue.main.async {
                                    strngSelf.showAlert(message: "No hotels found.")
                                }                                
                                strngSelf.navigationController?.popViewController(animated: true)
                                return
                            }
                            if let hotels = data["hotels"] as? [JSONDictionary]{
                                let hotelsArr  = hotels.compactMap{ PGHotel.init(json: $0) }
                                if hotelsArr.count > 0 {
                                    strngSelf.arrHotels.append(contentsOf: hotelsArr)
                                    strngSelf.arrFilteredHotels = strngSelf.arrHotels
                                    strngSelf.tblView.reloadData()
                                    strngSelf.lblHeader.text = "\(strngSelf.arrHotels.count)  Hotels found in \(strngSelf.city)"
                                    strngSelf.lblHeader.isHidden = false
                                    strngSelf.lblHotelText.isHidden = false
                                    
                                    let priceFiltered = strngSelf.arrHotels.sorted(by: { (h1, h2) -> Bool in
                                        if h1.getMinimumPriceValue() > h2.getMinimumPriceValue() {
                                            return true
                                        }
                                        return false
                                    })
                                    
                                    let maxPrice = priceFiltered.first
                                    if let mprice = maxPrice?.getMinimumPriceValue() {
                                        strngSelf.maxVal = Float(mprice)
                                    }
                                    
                                } else {
                                    strngSelf.showAlert(message: "No hotels found.")
                                    strngSelf.navigationController?.popViewController(animated: true)
                                }
                            }
                            
                        } catch {
                            print(error)
                        }
                        
                    }
                }
            }
            
            
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PGHotelsViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrFilteredHotels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PGHotelListCell.identifier, for: indexPath) as! PGHotelListCell
        if let fitlerd =  self.arrFilteredHotels,fitlerd.count > indexPath.row {
            let hotel = fitlerd[indexPath.row]
            cell.fillHotel(hotel:hotel)
        }
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let fitlerd =  self.arrFilteredHotels,fitlerd.count > indexPath.row {
            let hotel = fitlerd[indexPath.row]
            let vc = PGHotelDetailsViewController.instantiate(fromAppStoryboard: .hotels)
            self.hotelBooking?.selectedHotel = hotel
            vc.hotelBooking = self.hotelBooking
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
   
}
