//
//  DistanceUinitViewController.swift
//  Trajilis
//
//  Created by Moses on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

enum DistantUnit: Int {
    case miles
    case kilometers
}

class DistanceUinitViewController: UIViewController {

    var unit : DistantUnit!
    
    @IBOutlet weak var  mileSwitch : UISwitch!
    @IBOutlet weak var  kmSwitch : UISwitch!
    
    var selected : ((String) -> Void)?
    
    init() {
        super.init(nibName: "DistanceUinitViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.isUserInteractionEnabled = true
        view.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(dismissView))]
        update()
    }

    @IBAction func toggle(_ event: UISwitch) {
        self.unit = DistantUnit.init(rawValue: event.tag)
        update()
    }
    
    private func update() {
        if unit == nil { return }
        
        if unit == DistantUnit.miles {
            mileSwitch.setOn(true, animated: true)
            kmSwitch.setOn(false, animated: true)
        } else {
            mileSwitch.setOn(false, animated: true)
            kmSwitch.setOn(true, animated: true)
        }
    }
    
    @IBAction fileprivate func dismissView() {
        if unit != nil {
            if unit == DistantUnit.miles {
                selected?("Miles")
            } else {
                selected?("KiloMeters")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

}
