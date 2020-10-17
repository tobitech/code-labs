//
//  TripInvitationVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 22/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class TripInvitationVC: BaseVC {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var noInviteView: UIView!

    var trips = [Trip]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchTrips()
        tableView.register(SearchExplorerTableViewCell.Nib, forCellReuseIdentifier: SearchExplorerTableViewCell.identifier)

        title = "Trip Invite"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }

    private func fetchTrips() {
        spinner(with: "One Moment...")
        APIController.makeRequest(request: .getTripList(userId: Helpers.userId, invitationStatus: "INVITED", count: 0, limit: 1000)) { [weak self] (response) in
            self?.hideSpinner()
            switch response {
            case .failure(_):
                self?.showNoInviteView()
            case .success(let value):
                guard let sSelf = self else {
                    return
                }
                guard let json = try? value.mapJSON()  as? JSONDictionary, let tripData = json?["data"] as? [JSONDictionary] else {
                    sSelf.showNoInviteView()
                    return
                }

                let tripList = tripData.map{Trip.init(json: $0)}
                sSelf.trips = tripList
                sSelf.tableView.reloadData()
                sSelf.showNoInviteView()
            }
        }
    }

    func showNoInviteView() {
        if trips.isEmpty {
            tableView.isHidden = true
            noInviteView.isHidden = false
        }
    }

    func acceptOrRejectInvite(param: JSONDictionary) {
        self.spinner(with: "Updating...", blockInteraction: true)
        APIController.makeRequest(request: .acceptOrRejectTripInvite(param: param)) { [weak self] (_) in
            self?.hideSpinner()
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

extension TripInvitationVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return trips.count
        } else {
            return trips.first?.members.count ?? 00
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TripInviteTableViewCell.identifier) as! TripInviteTableViewCell
            let trip = trips[indexPath.row]
            cell.configure(trip: trip)
            cell.acceptBlock = {
                let param = [
                    "is_accept": "true",
                    "trip_id": trip.tripId,
                    "user_id": Helpers.userId
                ]
                self.acceptOrRejectInvite(param: param)
            }
            
            cell.rejectBlock = {
                let param = [
                    "is_accept": "false",
                    "trip_id": trip.tripId,
                    "user_id": Helpers.userId
                ]
                self.acceptOrRejectInvite(param: param)
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchExplorerTableViewCell.identifier, for: indexPath) as! SearchExplorerTableViewCell
            if let member = trips.first?.members[indexPath.row] {
                cell.configure(member: member)
                cell.addExplorerButton.isHidden = true
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 60
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "Trip Members"
        }
    }
}
