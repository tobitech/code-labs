//
//  TrendingTVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 13/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TrendingTVC: BaseTVC {

    var viewModel: TrendingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trending"
        tableView.register(UINib.init(nibName: TrendingTableViewCell.name, bundle: nil), forCellReuseIdentifier: TrendingTableViewCell.reuseIdentifier)
        checkLocation()

        viewModel.reload = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.didAnimate {
                strongSelf.tableView.reloadData()
            } else {
                strongSelf.animateTable()
            }
        }
        navigationController?.navigationBar.barTintColor = UIColor.appRed
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }

    private func checkLocation() {
        Locator.shared.authorize()
        Locator.shared.locate { (result) in
            switch result {
            case .success(let location):
                if let loc = location.location {
                    self.viewModel.lat = "\(loc.coordinate.latitude)"
                    self.viewModel.lng = "\(loc.coordinate.longitude)"
                    self.viewModel.load()
                }
                Locator.shared.reset()
            case .failure(_):
                let alertController = UIAlertController(title: "Error", message: "Enable Location permissions in settings", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }
                alertController.addAction(settingsAction)
                // If user cancels, do nothing, next time Pick Video is called, they will be asked again to give permission
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                // Run GUI stuff on main thread
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

}


extension TrendingTVC {
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrendingTableViewCell.reuseIdentifier) as! TrendingTableViewCell
        let place = viewModel.places[indexPath.row]
        cell.configure(place: place)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = viewModel.places[indexPath.row]
        let controller = PlacesVC.instantiate(fromAppStoryboard: .places)
        controller.location = place.name
        controller.address = nil
        controller.rating = place.rating
        controller.viewModel = FeedViewModel(type: .places(id: place.id))
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
