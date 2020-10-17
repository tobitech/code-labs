//
//  TimeFilterVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 21/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class TimeFilterVC: BaseVC {

    @IBOutlet var outboundView: UIView!

    @IBOutlet var buttons: [TrajilisButton]!
    @IBOutlet var sixthButton: TrajilisButton!
    @IBOutlet var fifthButton: TrajilisButton!
    @IBOutlet var fourthButton: TrajilisButton!
    @IBOutlet var thirdButton: TrajilisButton!
    @IBOutlet var secondButton: TrajilisButton!
    @IBOutlet var firstButton: TrajilisButton!


    var timeDiffernce: Int = 4
    var time = "00:00"
    var isReturnFlight = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Times"
        for button in buttons {
            button.addTarget(self, action: #selector(buttonSelected(sender:)), for: .touchUpInside)
        }
    }

    @objc func buttonSelected(sender: TrajilisButton) {
        for button in buttons {
            select(button: button, isSelected: button == sender)
        }
        if sender.tag == 0 {
            time = "00:00"
        }
        if sender.tag == 1 {
            time = "04:00"
        }
        if sender.tag == 2 {
            time = "08:00"
        }
        if sender.tag == 3 {
            time = "12:00"
        }
        if sender.tag == 4 {
            time = "16:00"
        }
        if sender.tag == 5 {
            time = "20:00"
        }
    }

    private func select(button: TrajilisButton, isSelected: Bool) {
        button.setGradient = isSelected
        button.setTitleColor(isSelected ? UIColor.white : UIColor.appBlack, for: .normal)
    }

}
