//
//  CardListVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class CardListVC: BaseVC {
    
    @IBOutlet var tableView: UITableView!
    
    var cards = [PaymentCard]()
    var didSelect: ((PaymentCard) -> Void)?
    var didDismiss:(() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCards()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didDismiss?()
    }

    private func setupCards() {
        cards.append(PaymentCard.init(name: "Master Card", imageName: "master", code: "CA"))
        cards.append(PaymentCard.init(name: "Discover", imageName: "discover", code: "DS"))
        cards.append(PaymentCard.init(name: "American Express", imageName: "ae", code: "AX"))
        cards.append(PaymentCard.init(name: "Visa", imageName: "visa", code: "VI"))
        cards.append(PaymentCard.init(name: "Diner Club", imageName: "diner", code: "DS"))
    }
}

extension CardListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell")
        cell?.textLabel?.text = cards[indexPath.row].name
        cell?.imageView?.image = UIImage(named: cards[indexPath.row].imageName)
        cell?.imageView?.contentMode = .scaleAspectFill
        cell?.imageView?.clipsToBounds = true
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.didSelect?(self.cards[indexPath.row])
            })
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}


struct PaymentCard {
    let name: String
    let imageName: String
    let code: String
}
