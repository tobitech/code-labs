//
//  PageVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

final class PageVC: UIViewController {
    
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    var index: Int! = 0
     let headers = [
        "Live Experiences ",
        "Search and Book",
        "Never Miss a Moment",
        "Find Places Nearby"
    ]
    
    let descriptions = [
    "Capture the best and worst of everywhere. Anywhere. Be there. In the moment.",
    "Your trip. At your fingertip.",
    "One’s destination is never a place but a new way of seeing things. Every moment. Every experience. One shared memory book.",
    "Something to do? Somewhere to eat? Discover local places. "
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImageView.image = UIImage(named: "onboarding\(String(index))")
        headerLabel.text = headers[index]
        descLabel.text = descriptions[index]
    }
    
}
