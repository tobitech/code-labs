//
//  searchFriendTopView.swift
//  Trajilis
//
//  Created by Perfect Aduh on 22/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class SearchFriendTopView: UIView {
    
    //Outlets
    @IBOutlet weak var suggestedBtn: UIButton!
    @IBOutlet weak var searchView: SearchView!
    @IBOutlet weak var headerView: HeaderWithLineView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    private func setupView() {
        headerView.headerText = "Search Friend"
        headerView.headerFontSize = 40
    }
    
}
