//
//  SearchFlightVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 05/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class FlightBookingConfirmationVC: UIViewController {

    var flightBooking: PGFlightBookingDetail?
    var isFromPayments: Bool = false
    
    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var scrollView:UIScrollView!
    
    @IBOutlet weak var viewBookingButton: UIButton!
    
    var viewDetails = PGFlightBookingDetailView.getView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.layer.masksToBounds = false
        self.showNavigationBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isFromPayments {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

}
