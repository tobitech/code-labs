//
//  NoTripVC.swift
//  Trajilis
//
//  Created by bharats802 on 13/03/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class NoTripViewController: BaseVC {

    @IBOutlet private weak var createTripBtn:UIButton!
    @IBOutlet private weak var lblMessage:UILabel!
    @IBOutlet private weak var lblSubMessage:UILabel!
    
    var viewModel: NoTripViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.largeTitleDisplayMode = .never
        showNavigationBar()
        if viewModel == nil {return}
        lblMessage.text = viewModel.message
        
        let isNotCurrentUser = !viewModel.isCurrentUser
        
        lblSubMessage.isHidden = isNotCurrentUser
        createTripBtn.isHidden = isNotCurrentUser
        
//        createTripBtn.set(cornerRadius: 4)
//        createTripBtn.set(borderWidth: 2, of: .red)//UIColor(hexString: "#E5E5E5"))
//        createTripBtn.backgroundColor = .blue
    }
    
    @IBAction func createTripBtnPressed(sender: UIButton) {
        let controller: NewTripViewController = Router.get()
        let model = NewTripViewModel.init()
        controller.viewModel = model
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
