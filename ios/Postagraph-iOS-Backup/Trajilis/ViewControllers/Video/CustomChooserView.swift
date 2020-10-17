//
//  CustomChooserView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

import Hakawai

class CustomChooserView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var tableView: UITableView!

    weak var delegate: HKWCustomChooserViewDelegate?
    var borderMode: HKWChooserBorderMode = .top

    // Protocol factory method
    @objc(chooserViewWithFrame:delegate:)
    class func chooserView(withFrame frame: CGRect, delegate: HKWCustomChooserViewDelegate) -> Any {

        let item = CustomChooserView.init(frame: frame)
        item.delegate = delegate
        item.frame = frame
        item.setNeedsLayout()
        return item
    }

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        tableView.dataSource = self
//        tableView.register(UINib.init(nibName: "CustomeChooseTableViewCell", bundle: nil), forCellReuseIdentifier: CustomeChooseTableViewCell.kIdentifier)
//        tableView.delegate = self
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("CustomChooserView", owner: self, options: nil)
        addSubview(contentView)
        self.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib.init(nibName: "CustomeChooseTableViewCell", bundle: nil), forCellReuseIdentifier: CustomeChooseTableViewCell.kIdentifier)
        contentView.fill()
    }
}

// MARK: - HKWChooserViewProtocol
extension CustomChooserView: HKWChooserViewProtocol {
    func becomeVisible() {
        isHidden = false
        setNeedsLayout()
    }

    func resetScrollPositionAndHide() {
        // Don't do anything
        isHidden = true
    }

    func reloadData() {
        tableView.reloadData()
    }

}

extension CustomChooserView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(delegate?.numberOfModelObjects() ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = delegate?.modelObject(for: UInt(indexPath.row)) as! HKWMentionsEntityProtocol
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomeChooseTableViewCell.kIdentifier) as! CustomeChooseTableViewCell
        let meta = model.entityMetadata()!
        let type = meta["type"] as! String
        let image = meta["image"] as? String ?? ""
        if type == "user" {
            if let url = URL.init(string: image) {
                cell.imageV.sd_setImage(with: url, completed: nil)
            }
        } else {
            cell.imageV.image = UIImage(named: "hash.png")
        }
        cell.nameLabel.text = model.entityName()?.replacingOccurrences(of: "#", with: "")
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension CustomChooserView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.modelObjectSelected(at: UInt(indexPath.row))
    }
}

