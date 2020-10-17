//
//  FilterByDistanceVC.swift
//  Trajilis
//
//  Created by Perfect Aduh on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit


class FilterByDistanceVC: BaseVC {
    
    //Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMin: UILabel!
    @IBOutlet weak var lblMax: UILabel!
    
    @IBOutlet weak var selectedDistanceLbl: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var applyBtn: UIButton!
    
    var didSelectDistance:((CGFloat)->Void)?
    
    var selectedRadius:CGFloat = 0 // in miles
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Distance"
        
        selectedDistanceLbl.makeCornerRadius(cornerRadius: 20, shadowColour: nil, shadowRadius: nil, shadowOpacity: nil, shadowOffset: nil)
        self.lblTitle.textColor = .appRed
        self.distanceSlider.value = Float(self.selectedRadius)
        self.sliderValueChanged(self.distanceSlider)
    }
    
    @IBAction func backBtnPressed( _ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnRefreshTapped( _ sender: UIButton) {
        self.distanceSlider.value = Float(Helpers.meterToMile(mtr: kDefaultNearbySearchRadius))
        self.sliderValueChanged(self.distanceSlider)
    }
    @IBAction func applyBtnPressed( _ sender: UIButton) {
        let value = self.distanceSlider.value
        self.didSelectDistance?(CGFloat(value))
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sliderValueChanged( _ sender: UISlider) {
        let sliderValue = distanceSlider.value
        self.selectedDistanceLbl.text = "\((sliderValue * 100).rounded() / 100) Miles"
    }
}
