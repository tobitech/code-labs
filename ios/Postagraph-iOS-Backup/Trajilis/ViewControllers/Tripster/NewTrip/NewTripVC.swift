//
//  NewTripVC.swift
//  Trajilis
//
//  Created by Perfect Aduh on 30/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import DropDown
import Alamofire

class NewTripViewController: BaseVC {
    //Outlets
    @IBOutlet weak var tripNameTextField: FloatingLabelTextField!
    @IBOutlet weak var startDateTextField: FloatingLabelTextField!
    @IBOutlet weak var endDateTextField: FloatingLabelTextField!
    @IBOutlet weak var locationTextField: FloatingLabelTextField!
    @IBOutlet weak var notesTextView: FloatingLabelTextView!
    @IBOutlet weak var privatePublicSwitch: UISwitch!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var notesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Properties
    var didAddTrip:(()->Void)?
    var onTripDelete: (()->())?
    
    let kDateFormat = "MM/dd/yyyy"
    var tripType = kTripVisibility.PUBLIC.rawValue
    var viewModel: NewTripViewModel!
    //    var isSearching = false
    var addressResult = [String]()
    var places = [CondensedPlace]()
    
    var startDateAndTime: Date?
    var endDateAndTime: Date?
    
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create New Trip"
        
        notesTextView.delegate = self
        [tripNameTextField, startDateTextField, endDateTextField, locationTextField].forEach {
            $0.delegate = self
        }
        startDateTextField.tag = 1001
        
        let mode = FloatingLabelTextField.Mode(
            textColor: UIColor(hexString: "#D63D41"),
            placeHolderColor: UIColor(hexString: "#3F3F3F", alpha: 0.5),
            floatingTitleColor: UIColor(hexString: "#3F3F3F", alpha: 0.5),
            lineColor: UIColor(hexString: "#505050"),
            iconTintColor: UIColor(hexString: "#D63D41"),
            errorColor: UIColor(hexString: "#D63D41"),
            font: UIFont(name: "PTSans-Bold", size: 16)!)
        startDateTextField.selectedMode = mode
        endDateTextField.selectedMode = mode
        
        setupView()
        setupCompletionHandler()
        setupDropDown()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    private func setupView() {
        guard let trip = viewModel?.trip, viewModel.isEdit else { return }
        title = "Edit Trip Details"
        tripNameTextField.text = trip.tripName
        notesTextView.text = trip.desc
        let isPrivate = trip.feed_visibility == kTripVisibility.PRIVATE.rawValue
        privatePublicSwitch.setOn(isPrivate, animated: false)
        
        locationTextField.text = trip.location
        let start = Date(timeIntervalSince1970: Double(trip.startDate) ?? 0)
        startDateAndTime = start
        startDateTextField.text = start.toString(dateFormat: "MM/dd/yyyy")
        
        let end = Date(timeIntervalSince1970: Double(trip.endDate) ?? 0)
        endDateAndTime = end
        endDateTextField.text = end.toString(dateFormat: "MM/dd/yyyy")
        
        continueButton.setTitle("Save Changes", for: .normal)
        
        addressResult = [trip.location]
        
        let deleteBarButtonItem = UIBarButtonItem(image: UIImage(named: "trash"), style: .plain, target: self, action: #selector(self.deleteTrip))
        navigationItem.rightBarButtonItem = deleteBarButtonItem
        
    }
    
    @objc private func deleteTrip() {
        let controller = UIAlertController(title: nil, message: "Are you sure, you want to delete this trip?", preferredStyle: Helpers.actionSheetStyle())
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.spinner(with: "Deleting Trip...", blockInteraction: true)
            self.viewModel.deleteTrip(success: { [weak self] in
                self?.hideSpinner()
                self?.onTripDelete?()
            }) { [weak self] (error) in
                self?.hideSpinner()
                self?.showAlert(message: error)
            }
        }
        
        controller.addAction(cancel)
        controller.addAction(delete)
        
        present(controller, animated: true, completion: nil)
    }
    
    private func setupDropDown() {
        dropDown.anchorView = notesTextView
        dropDown.dismissMode = .onTap
        dropDown.dataSource = addressResult
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.locationTextField.text = item
        }
        dropDown.width = Helpers.isPad() ? 400 : locationTextField.bounds.width
        dropDown.direction = .bottom
        dropDown.selectRow(0)
    }
    
    private func setupCompletionHandler() {
        viewModel?.saveNewTripComplete = { [weak self] message in
            self?.hideSpinner()
            if let msg = message {
                self?.showAlert(message: msg)
            }else {
                self?.didAddTrip?()
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        tripType = sender.isOn ? kTripVisibility.PRIVATE.rawValue : kTripVisibility.PUBLIC.rawValue
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        let lat = UserDefaults.standard.string(forKey: "latitude") ?? "0"
        let long = UserDefaults.standard.string(forKey: "longitude") ?? "0"
        let tripName = tripNameTextField.text
        let startDate = startDateTextField.text
        let endDate = endDateTextField.text
        
        guard !tripName.isEmpty else {
            showAlert(message: "Trip name required")
            return
        }
        guard !startDate.isEmpty else {
            showAlert(message: "Start date required")
            return
        }
        guard !endDate.isEmpty else {
            showAlert(message: "End date required")
            return
        }
        
        guard let selectedItem = dropDown.selectedItem, selectedItem == locationTextField.text else {
            showAlert(message: locationTextField.text.isEmpty ? "Location required" : "Invalid Location")
            return
        }
        
        func done() {
            let start_Date = startDate
            let end_Date = endDate
            let datefrmter = DateFormatter()
            datefrmter.dateFormat = self.kDateFormat
            let date = datefrmter.date(from: start_Date)
            
            //start date
            let timestamp = (date! as NSDate).timeIntervalSince1970
            let startDateTimeStamp:String = String(format:"%.0f", timestamp)
            //end date
            let timestampend = datefrmter.date(from: end_Date)!.timeIntervalSince1970 + (24*60*60) - 1
            let endDateTimeStamp:String = String(format:"%.0f", timestampend)
            
            let invitedUsers = self.viewModel.selectedUsers.map{$0.userId}
            let strInvitedUsers = invitedUsers.joined(separator: ",")
            self.spinner(with: "One moment...", blockInteraction: true)
            self.viewModel.saveNewTrip(tripName: tripName, startDate: startDateTimeStamp, endDate: endDateTimeStamp, location: selectedItem, description: self.notesTextView.text, invitedUser: strInvitedUsers, lat: "\(lat)", long: "\(long)",visibility: self.tripType)
        }
        
        if viewModel.isEdit {
            done()
        }else {
            let vc: AddMemberToTripViewController = Router.get()
            let viewModel = AddMemberToTripViewModel()
            viewModel.noMemberTitle = "Add users to your trip."
            viewModel.noMemberSubtitle = "Tap the search bar to find members."
            vc.viewModel = viewModel
            viewModel.allowEmpty = true
            vc.title = tripName
            vc.onDone = { [weak self] in
                self?.viewModel.selectedUsers = viewModel.selectedUsers
                done()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //    private func setupTableView() {
    //        tableView.rowHeight = 70
    //        tableView.register(SearchExplorerTableViewCell.Nib, forCellReuseIdentifier: SearchExplorerTableViewCell.identifier)
    //        tableView.dataSource = self
    //        tableView.delegate = self
    //    }
    
    //    private func setupSearchBar() {
    //        let searchbarView = SearchView.init(frame: searchContainerView.frame)
    //        searchbarView.searchBar.delegate = self
    //        searchbarView.searchBar.returnKeyType = .default
    //        searchContainerView.addSubview(searchbarView)
    //        searchbarView.translatesAutoresizingMaskIntoConstraints = false
    //        searchbarView.fill()
    //        searchbarView.searchBar.placeholder = "search for friends to add to trip"
    //        self.searchView = searchbarView
    //    }
    
    //    private func textViewPlaceHolder() {
    //        textViewPlaceholderLabel = UILabel()
    //        if let text = viewModel.trip?.desc  {
    //            if text.isEmpty {
    //                textViewPlaceholderLabel.text = "Enter notes."
    //            }
    //        } else {
    //            textViewPlaceholderLabel.text = "Enter notes."
    //        }
    //        notesTextView.delegate = self
    //        textViewPlaceholderLabel.font =  notesTextView.font
    //        textViewPlaceholderLabel.sizeToFit()
    //        notesTextView.addSubview(textViewPlaceholderLabel)
    //        textViewPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (notesTextView.font?.pointSize)! / 2)
    //        textViewPlaceholderLabel.textColor = UIColor.lightGray
    //        textViewPlaceholderLabel.isHidden = !notesTextView.text.isEmpty
    //    }
    
    func getPlaces(text:String?) {
        if let searchTxt = text,!searchTxt.isEmpty {
            var urlString = "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?"
            let encoded = searchTxt.encoded()
            urlString += "&input=\(encoded)"
            self.places.removeAll()
            urlString.append("&key=\(Constants.GOOGLEAPIKEY)")
            if let url = URL(string:urlString) {
                print("search -- \(urlString)")
                let request = URLRequest(url: url)
                Alamofire.request(request).responseJSON {[weak self] (response) in
                    DispatchQueue.main.async {
                        if let val = response.result.value as AnyObject? {
                            if let results = val["predictions"] as? [AnyObject] {
                                let places = results.compactMap{ CondensedPlace.init(data: $0) }
                                if places.count > 0 {
                                    self?.places.append(contentsOf: places)
                                    self?.dropDown.dataSource = places.compactMap{ $0.name }
                                    if self?.dropDown.show().canBeDisplayed == false {
                                        self?.scrollView.contentOffset.y += 50
                                        self?.dropDown.show()
                                    }
                                    self?.dropDown.reloadAllComponents()
                                } else {
                                    self?.dropDown.hide()
                                }
                            }
                        }else {
                            self?.dropDown.hide()
                        }
                    }
                    
                }
            }
        } else {
            self.dropDown.hide()
        }
    }
    
    //    fileprivate func search(text: String) {
    //        viewModel.searchUserForTrip(searchParam: text, tripId: "")
    //    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

//extension NewTripViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return isSearching ? viewModel.searchUserForTripResponse.count : viewModel.selectedUsers.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: SearchExplorerTableViewCell.identifier, for: indexPath) as! SearchExplorerTableViewCell
//        let user = isSearching ? viewModel.searchUserForTripResponse[indexPath.row] : viewModel.selectedUsers[indexPath.row]
//        cell.configureCell(userData: user, isSelected: viewModel.isSelected(user: user))
//        cell.addExplorer = {
//            self.viewModel.add(user: user)
//            tableView.reloadData()
//        }
//        return cell
//    }
//}


//extension NewTripViewController: UISearchBarDelegate {
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        //searchBar.resignFirstResponder()
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        isSearching = !searchText.isEmpty
//        search(text: searchText)
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.resignFirstResponder()
//        isSearching = false
//    }
//    @IBAction func publicTapped(_ sender: Any) {
//        tripType = "PUBLIC"
//        select(button: privateButton, isSelected: false)
//        select(button: publicButton, isSelected: true)
//    }
//    @IBAction func privateTapped(_ sender: Any) {
//        tripType = "PRIVATE"
//        select(button: privateButton, isSelected: true)
//        select(button: publicButton, isSelected: false)
//    }
//    private func select(button: TrajilisButton, isSelected: Bool) {
//        button.setGradient = isSelected
//        button.setTitleColor(isSelected ? UIColor.white : UIColor.appBlack, for: .normal)
//    }
//}

//extension NewTripViewController: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        if textView == notesTextView {
//            textViewPlaceholderLabel.isHidden = !notesTextView.text.isEmpty
//        }
//    }
//}

extension NewTripViewController: FloatingLabelTextViewDelegate {
    
    func floatingLabelTextViewDidChange(_ FloatingLabelTextView: FloatingLabelTextView) {
        
    }
    
    func floatingLabelTextViewShouldChangeHeight(_ FloatingLabelTextView: FloatingLabelTextView, toHeight height: CGFloat) {
        notesHeightConstraint.constant = max(40, height)
    }
    
}

extension NewTripViewController: FloatingLabelTextFieldDelegate {
    
    func floatingLabelTextFieldDidChange(_ floatingLabelTextField: FloatingLabelTextField) {
        if floatingLabelTextField == locationTextField {
            getPlaces(text: locationTextField.text)
        }
    }
    
    func floatingLabelTextFieldDidBeginEditing(_ floatingLabelTextField: FloatingLabelTextField) {
        if floatingLabelTextField == startDateTextField || floatingLabelTextField == endDateTextField {
            let datePickerView: UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePicker.Mode.date
            datePickerView.minimumDate = Date()
            if floatingLabelTextField == startDateTextField {
                datePickerView.date = startDateAndTime ?? Date()
                //            if let date = endDateAndTime {
                //                datePickerView.maximumDate = date
                //            }
            } else {
                datePickerView.date = endDateAndTime ?? Date()
                if let date = startDateAndTime {
                    datePickerView.minimumDate = date
                }
            }
            floatingLabelTextField.textField.inputView = datePickerView
            datePickerView.tag = floatingLabelTextField.tag
            datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
            self.datePickerValueChanged(datePickerView)
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateFormat
        if sender.tag == 1001 {
            startDateTextField.text = dateFormatter.string(from: sender.date)
            self.startDateAndTime = sender.date
            if let endDate = endDateAndTime {
                if endDate.timeIntervalSince(startDateAndTime!) < 0 {
                    endDateAndTime = startDateAndTime
                    endDateTextField.text = dateFormatter.string(from: sender.date)
                }
            }
        } else {
            endDateTextField.text = dateFormatter.string(from: sender.date)
            self.endDateAndTime = sender.date
        }
    }
    
}
