//
//  AirlineFilterVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 21/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class AirlineFilterVC: BaseVC {

    @IBOutlet var tableView: UITableView!
    var airlines = [Company]()
    var selectedAirlines = [Company]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Airlines"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

}

extension AirlineFilterVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airlines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AirlineFilterTableViewCell") as! AirlineFilterTableViewCell
        let airline = airlines[indexPath.row]
        cell.configure(company: airline, isOn: selectedAirlines.contains(where: { $0._id == airline._id }))
        cell.switchDidChange = { value in
            if value {
                self.selectedAirlines.append(airline)
            } else {
                if let index = self.selectedAirlines.firstIndex(where: { $0._id == airline._id }) {
                    self.selectedAirlines.remove(at: index)
                }
            }
            tableView.reloadData()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


