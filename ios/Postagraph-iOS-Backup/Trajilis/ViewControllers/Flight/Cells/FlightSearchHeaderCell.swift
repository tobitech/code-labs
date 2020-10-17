//
//  FlightSearchHeaderCell.swift
//  Trajilis
//
//  Created by user on 03/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

protocol FlightSearchHeaderCellDelegate: class {
    func handleStopsToggleChanged(_ cell: FlightSearchHeaderCell, isOn: Bool)
    func handlesortingControlChanged(_ cell: FlightSearchHeaderCell, selectedIndex: Int)
}

class FlightSearchHeaderCell: UITableViewCell {
    
    weak var delegate: FlightSearchHeaderCellDelegate?

    @IBOutlet weak var flightDatesLabel: UILabel!
    @IBOutlet weak var sortSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var flightCountLbl: UILabel!
    @IBOutlet weak var stopToggleSwitch: UISwitch!
    @IBOutlet weak var cityNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func sortSegmentedChanged(_ sender: CustomSegmentedControl) {
        self.delegate?.handlesortingControlChanged(self, selectedIndex: sender.selectedSegmentIndex)
    }
    
    @IBAction func stopsToggleChanged(_ sender: UISwitch) {
        self.delegate?.handleStopsToggleChanged(self, isOn: sender.isOn)
    }
}
