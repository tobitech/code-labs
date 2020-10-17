//
//  PGHotelFilterViewController.swift
//  Trajilis
//
//  Created by bharats802 on 03/05/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PGHotelFilterViewController: BaseVC {

    var sortFilter:PGHotelSortFilter?

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var lblPriceLowToHight:UILabel!
    @IBOutlet weak var lblStarLevel:UILabel!
    @IBOutlet weak var lblDistanceFromYou:UILabel!
    @IBOutlet weak var btnPriceLowToHight:UIButton!
    @IBOutlet weak var btnStarLevel:UIButton!
    @IBOutlet weak var btnDistanceFromYou:UIButton!
    
    @IBOutlet weak var btnStar1:UIButton!
    @IBOutlet weak var btnStar2:UIButton!
    @IBOutlet weak var btnStar3:UIButton!
    @IBOutlet weak var btnStar4:UIButton!
    @IBOutlet weak var btnStar5:UIButton!
    
    @IBOutlet var imgStar1:[UIImageView]!
    @IBOutlet var imgStar2:[UIImageView]!
    @IBOutlet var imgStar3:[UIImageView]!
    @IBOutlet var imgStar4:[UIImageView]!
    @IBOutlet var imgStar5:[UIImageView]!
    
    @IBOutlet weak var sliderPrice:UISlider!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var lblPriceLeading:NSLayoutConstraint!
    var maxVal :Float = 1000000
    var didFilter:((PGHotelSortFilter?) -> Void)?
    let currency = CurrencyManager.shared.getUserCurrencyCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sort & Filter"
        self.sliderPrice.tintColor = .red
        self.sliderPrice.maximumValue = maxVal
        self.sliderPrice.value = self.sliderPrice.maximumValue
        self.sliderPrice.minimumValue = 0
        self.lblPrice.text = nil
        if let sfilter = self.sortFilter {
            if let sortB = sfilter.sortBy {
                switch sortB {
                case .DistanceFromYou:
                        self.btnDistanceFromYou.isSelected = true
                case .PriceLowToHight:
                    self.btnPriceLowToHight.isSelected = true
                case .StarLevel:
                    self.btnStarLevel.isSelected = true
                }
            }
            if let ratin = sfilter.filterByStar {
                switch ratin {
                case 1:
                    self.btnStarTapped(sender: self.btnStar1)
                case 2:
                    self.btnStarTapped(sender: self.btnStar2)
                case 3:
                    self.btnStarTapped(sender: self.btnStar3)
                case 4:
                    self.btnStarTapped(sender: self.btnStar4)
                case 5:
                    self.btnStarTapped(sender: self.btnStar5)
                default:
                    break
                }
            }
            
            self.sliderPrice.value = Float(sfilter.pricePerNight).rounded()
            self.searchBar.text = sfilter.name
            
            scrollView.isScrollEnabled = false
            if (UIDevice.current.screenType == .iPhones_4_4S || UIDevice.current.screenType != .iPhones_5_5s_5c_SE) {
               scrollView.isScrollEnabled = true
            }
        }
        
        self.lblPrice.text = "\(CurrencyManager.shared.getSymbol(forCurrency: currency))\(sliderPrice.value.rounded())"
        self.lblPriceLeading.constant = sliderPrice.thumbCenterX - 120
//        if self.sliderPrice.value == self.sliderPrice.minimumValue || self.sliderPrice.value <= self.sliderPrice.minimumValue || self.sliderPrice.value <= (self.sliderPrice.maximumValue / 4)  {
//            self.lblPriceLeading.constant = self.sliderPrice.thumbCenterX + 20
//        }else {
//
//        }
        // Do any additional setup after loading the view.
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnSortByTapped(sender:UIButton) {
        switch sender.tag {
        case 1:
            sender.isSelected = !sender.isSelected
            self.btnStarLevel.isSelected = false
            self.btnDistanceFromYou.isSelected = false
        case 2:
            sender.isSelected = !sender.isSelected
            self.btnPriceLowToHight.isSelected = false
            self.btnDistanceFromYou.isSelected = false
        case 3:
            sender.isSelected = !sender.isSelected
            self.btnPriceLowToHight.isSelected = false
            self.btnStarLevel.isSelected = false
        default:
            break
        }
    }
    
    @IBAction func btnStarTapped(sender:UIButton) {
        
        self.selectStar(stars: self.imgStar1)
        self.selectStar(stars: self.imgStar2)
        self.selectStar(stars: self.imgStar3)
        self.selectStar(stars: self.imgStar4)
        self.selectStar(stars: self.imgStar5)
        
        
        
        self.btnStar1.superview?.backgroundColor = .white
        self.btnStar2.superview?.backgroundColor = .white
        self.btnStar3.superview?.backgroundColor = .white
        self.btnStar4.superview?.backgroundColor = .white
        self.btnStar5.superview?.backgroundColor = .white
        self.btnStar1.isSelected = false
        self.btnStar2.isSelected = false
        self.btnStar3.isSelected = false
        self.btnStar4.isSelected = false
        self.btnStar5.isSelected = false
        
        
        switch sender {
        case self.btnStar1:
           self.selectStar(stars: self.imgStar1,isSelected: true)
           self.selectStarBtn(starBtn: self.btnStar1)
            //fallthrough
        case self.btnStar2:
            self.selectStar(stars: self.imgStar2,isSelected: true)
            self.selectStarBtn(starBtn: self.btnStar2)
           // fallthrough
        case self.btnStar3:
            self.selectStar(stars: self.imgStar3,isSelected: true)
            self.selectStarBtn(starBtn: self.btnStar3)
           // fallthrough
        case self.btnStar4:
            self.selectStar(stars: self.imgStar4,isSelected: true)
            self.selectStarBtn(starBtn: self.btnStar4)
           // fallthrough
        case self.btnStar5:
            self.selectStar(stars: self.imgStar5,isSelected: true)
            self.selectStarBtn(starBtn: self.btnStar5)
        default:
            break
        }
        
    }
    func selectStarBtn(starBtn:UIButton) {
        starBtn.superview?.backgroundColor = .appRed
        starBtn.isSelected = true
    }
    func selectStar(stars:[UIImageView],isSelected:Bool = false) {
        for star in stars {
            if isSelected {
                star.image = UIImage(named:"str")
            } else {
                star.image = UIImage(named:"strGrey")
            }
        }
        
    }
    
    @IBAction func sliderValueChanged(sender:UISlider) {

        let maxValue = sender.maximumValue
        let quaterValue = maxValue/4
        if sender.value < quaterValue {
            self.lblPriceLeading.constant = sliderPrice.thumbCenterX + 10
        }else {
             self.lblPriceLeading.constant = sliderPrice.thumbCenterX - 60
        }
        self.lblPrice.text = "\(CurrencyManager.shared.getSymbol(forCurrency: currency))\(sliderPrice.value.rounded())"
        
    }
    @IBAction func btnApplyTapped(sender:UIButton) {
        var sfilter:PGHotelSortFilter!
        if let sortF = self.sortFilter {
            sfilter = sortF
        } else {
            sfilter = PGHotelSortFilter()
        }
        
        if self.btnPriceLowToHight.isSelected {
            sfilter.sortBy = .PriceLowToHight
        } else if self.btnStarLevel.isSelected {
            sfilter.sortBy = .StarLevel
        } else if self.btnDistanceFromYou.isSelected {
            sfilter.sortBy = .DistanceFromYou
        } else {
            sfilter.sortBy = nil
        }
        
        if self.btnStar1.isSelected {
            sfilter.filterByStar = 1
        } else if self.btnStar2.isSelected {
            sfilter.filterByStar = 2
        } else if self.btnStar3.isSelected {
            sfilter.filterByStar = 3
        } else if self.btnStar4.isSelected {
            sfilter.filterByStar = 4
        } else if self.btnStar5.isSelected {
            sfilter.filterByStar = 5
        } else {
            sfilter.filterByStar = nil
        }
        
        sfilter.pricePerNight = CGFloat(self.sliderPrice.value)
        sfilter.name = self.searchBar.text
        
        
        self.didFilter?(sfilter)
        self.navigationController?.popViewController(animated: true)
    }
}

extension UISlider {
    
    //this version will return the x coordinate in relation to the UISlider frame
    var thumbCenterX: CGFloat {
        return thumbRect(forBounds: frame, trackRect: trackRect(forBounds: bounds), value: value).midX
    }
    
    //this version will return the x coordinate in relation to the UISlider's containing view
//    var thumbCenterX: CGFloat {
//        return thumbRect(forBounds: frame, trackRect: trackRect(forBounds: frame), value: value).midX
//    }
    
}
struct PGHotelSortFilter {
    
    var sortBy: kSortBy?
    var filterByStar:Int?
    var pricePerNight:CGFloat = 5000
    var name:String?
}

enum kSortBy : Int {
    case PriceLowToHight = 0
    case StarLevel = 1
    case DistanceFromYou = 2
}
