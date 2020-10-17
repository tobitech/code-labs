//
//  PGSelectRoomViewController.swift
//  Trajilis
//
//  Created by bharats802 on 22/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PGSelectRoomViewController: BaseVC {

    @IBOutlet weak var tblView:UITableView!
    var selectedRoom:PGHotelRoom?
    
    var selectedHotel:PGHotel?
    var idenifier = "PGSelectRoomCell"
    
    var didSelectRoom:((PGHotelRoom) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Room"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PGSelectRoomViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rooms = self.selectedHotel?.rooms {
            return rooms.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.idenifier, for: indexPath) as! PGSelectRoomCell
        
        if let rooms = self.selectedHotel?.rooms,rooms.count > indexPath.row {
            let room = rooms[indexPath.row]
            cell.lblDesc.text =  room.roomDescription
            let currency = CurrencyManager.shared.getSymbol(forCurrency: room.currencyCode)
            cell.lblPrice.text =  "\(currency)\(room.totalFare.rounded(toPlaces: 2))"
            if let selRoom = self.selectedRoom,selRoom.bookingCode == room.bookingCode {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let rooms = self.selectedHotel?.rooms,rooms.count > indexPath.row {
            let room = rooms[indexPath.row]
            self.didSelectRoom?(room)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
class PGSelectRoomCell:UITableViewCell {
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblPrice.textColor = .appRed
        self.tintColor = .appRed
    }
}

