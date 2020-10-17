//
//  ReadyToPostVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 14/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos
import MapKit
import Hakawai
import Alamofire
import AWSS3
import SkyFloatingLabelTextField

final class ReadyToPostVC: BaseVC {
    
    let kIdentifier = "ReadyToPostTableViewCell"
    var isFromRecordings:Bool = false
    var savedRecord:SavedRecording?
    @IBOutlet var shareBtn: UIButton!
    @IBOutlet var descTextView: HKWTextView!
    @IBOutlet var locationTxtLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var textViewPlaceHolderLabel: UILabel!
    @IBOutlet weak var postTypeSegmentedControl: CustomSegmentedControl!
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var charactersCountLabel: UILabel!
    
    var coordinates: CLLocationCoordinate2D?
    
    private var plugin: HKWMentionsPlugin?
    
    var videoURLs: [URL] = []
    var coverImages: [UIImage]?
    var postType = "PUBLIC"
    
    let videoViewModel = VideoViewModel()
    
    var selectedVenue: Venue? {
        didSet {
            if let v = selectedVenue {
                self.locationTxtLabel.text = v.name
                self.locationTxtLabel.font = UIFont(name: "PTSans-Bold", size: 16.0)
                self.locationTxtLabel.textColor = UIColor.defaultText
                self.textFieldChanged()
            }
        }
    }
    
    var trip: Trip? {
        didSet {
            if let t = trip {
                shareBtn.setTitle(t.tripName, for: .normal)
                
                if(t.feed_visibility == kTripVisibility.PRIVATE.rawValue) {
                    self.postTypeSegmentedControl.selectedSegmentIndex = 2
                    self.postTypeSegmentedControl.setEnabled(false, forSegmentAt: 0)
                    self.postTypeSegmentedControl.setEnabled(false, forSegmentAt: 1)
                    self.postTypeSegmentedControl.setEnabled(false, forSegmentAt: 2)
                } else {
                    self.postTypeSegmentedControl.setEnabled(true, forSegmentAt: 0)
                    self.postTypeSegmentedControl.setEnabled(true, forSegmentAt: 1)
                    self.postTypeSegmentedControl.setEnabled(true, forSegmentAt: 2)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Ready to post"
        
        setup()
        if let savedReoc = self.savedRecord {
            self.coordinates = CLLocationCoordinate2D(latitude: savedReoc.lat, longitude: savedReoc.lng)
            //self.getPlace()
        } else {
            Locator.shared.locate { (location) in
                switch location {
                case .success(let loc):
                    self.coordinates = loc.location?.coordinate
                    
                case .failure(_):
                    break
                }
            }
            checkLocation()
        }
        setupTextView()
        textViewPlaceHolder()
        descTextView.addDoneOnKeyboardWithTarget(self, action: #selector(self.done))
    }
    
    @objc private func done() {
        descTextView.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //showNavigationBar()
        navigationController?.navigationBar.tintColor = .red
    }
    
    private func textViewPlaceHolder() {
        descTextView.externalDelegate = self
        textViewPlaceHolderLabel.isHidden = !descTextView.text.isEmpty
    }
    
    private func setup() {
//        descTextView.delegate = self
//        descTxtFeild.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        ratingView.rating = 0
        ratingView.settings.emptyBorderWidth = 2
        
        let continueBarButton = UIBarButtonItem(image: UIImage.init(named: "whiteshare"), style: .plain, target: self, action: #selector(post(_:)))
        navigationItem.rightBarButtonItem = continueBarButton
        
        // configure share button
        shareBtn.layer.cornerRadius = 4
        shareBtn.layer.masksToBounds = true
    }
    
    @objc fileprivate func textFieldChanged() {
        guard let desc = descTextView.text,
            let location = locationTxtLabel.text else { return }
        if !desc.isEmpty && !location.isEmpty {
            shareBtn.isEnabled = true
            shareBtn.backgroundColor = UIColor.appRed
        } else {
            shareBtn.isEnabled = false
            shareBtn.backgroundColor = UIColor.appRed.withAlphaComponent(0.3)
        }
    }
    
    private func checkLocation() {
        Locator.shared.authorize()
        Locator.shared.locate { (result) in
            switch result {
            case .success(let location):
                if let loc = location.location {
                    UserDefaults.standard.set(loc.coordinate.latitude, forKey: "latitude")
                    UserDefaults.standard.set(loc.coordinate.longitude, forKey: "longitude")
                    //self.getPlace()
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
    
    private func setupTextView() {
        let mode = HKWMentionsChooserPositionMode.customLockBottomNoArrow
        let controlCharacters = CharacterSet(charactersIn: "@#")
        let mentionsPlugin = HKWMentionsPlugin(chooserMode: mode, controlCharacters: controlCharacters, searchLength: -1)
        mentionsPlugin?.chooserViewClass = CustomChooserView.self
        mentionsPlugin?.resumeMentionsCreationEnabled = true
        mentionsPlugin?.chooserViewEdgeInsets = UIEdgeInsets(top: 2, left: 0.5, bottom: 0.5, right: 0.5)
        plugin = mentionsPlugin
        plugin?.chooserViewBackgroundColor = .lightGray
        mentionsPlugin?.delegate = MentionsManager.shared
        descTextView.controlFlowPlugin = mentionsPlugin
        plugin?.setChooserTopLevel(view, attachmentBlock: { (chooserView) in
            chooserView!.topAnchor.constraint(equalTo: self.descTextView.bottomAnchor, constant: 0).isActive = true
            chooserView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            chooserView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            chooserView!.heightAnchor.constraint(equalToConstant: 200).isActive = true
        })
    }
    
    @objc private func post(_ sender: UIBarButtonItem) {
        if descTextView.text.isEmpty || descTextView.text.count > 200 {
            showAlert(message: "Please write a description. Maximum of 200 characters.")
            return
        }
        
        guard let venue = selectedVenue else {
            showAlert(message: "Select venue")
            return
        }
        
//        videoViewModel.coordinates = self.coordinates
//        videoViewModel.coverImages = self.coverImages
//        videoViewModel.postType = self.postType
//        videoViewModel.rating = Int(ratingView.rating)
//        videoViewModel.taggedUsers = self.getTaggedUsers()
//        videoViewModel.tags = self.getTags()
//        videoViewModel.videoURLs = self.videoURLs
//        videoViewModel.trip = self.trip
//        videoViewModel.plugin = self.plugin
//        videoViewModel.selectedVenue = self.selectedVenue
//        videoViewModel.description = descTextView.text
        
        let postDict: [String: Any] = [
            "coordinates": self.coordinates,
            "coverImages": self.coverImages,
            "postType": self.postType,
            "rating": Int(ratingView.rating),
            "taggedUsers": self.getTaggedUsers(),
            "tags": self.getTags(),
            "videoURLs": self.videoURLs,
            "trip": self.trip,
            "plugin": self.plugin,
            "description": descTextView.text,
            "selectedVenue": self.selectedVenue
        ]
        
        NotificationCenter.default.post(name: NSNotification.Name.postContent, object: nil, userInfo: postDict)
        if self.navigationController?.viewControllers.first?.isKind(of: CameraVC.self) == false {
            self.navigationController?.popToRootViewController(animated: true)
        }else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func original(text: String) -> String {
        guard let mentions = plugin?.mentions() as? [HKWMentionsAttribute] else { return text }
        var components = text.components(separatedBy: " ")
        for mention in mentions {
            guard let count = mention.entityId()?.count else {
                continue
            }
            if count > 10 {
                if let index = components.firstIndex(of: mention.entityName()) {
                    components[index] = "@" + components[index]
                }
            } else {
                if let index = components.firstIndex(of: mention.entityName()) {
                    //components[index] = "#" + components[index]
                    components[index] = components[index]
                }
            }
        }
        return components.joined(separator: " ")
    }
    
    private func getTaggedUsers() -> String {
        guard let mentions = plugin?.mentions() as? [HKWMentionsAttribute] else { return "" }
        var users = [HKWMentionsAttribute]()
        for mention in mentions {
            guard let count = mention.entityId()?.count, count > 10 else {
                continue
            }
            users.append(mention)
        }
        let ids = users.compactMap{ $0.entityId() }.joined(separator: ",")
        return ids
    }
    
    private func getTags() -> String {
        guard let mentions = plugin?.mentions() as? [HKWMentionsAttribute] else { return "" }
        var tags = [HKWMentionsAttribute]()
        for mention in mentions {
            guard let count = mention.entityId()?.count, count < 10 else {
                continue
            }
            tags.append(mention)
        }
        var ids = tags.compactMap{ $0.entityName() }.joined(separator: ",")
        
        let newHashes = self.getNewHastags(addedHash: ids)
        if !newHashes.isEmpty {
            if !ids.isEmpty {
                ids.append(",")
            }
            ids.append(newHashes)
        }
        return ids.replacingOccurrences(of: "#", with: "")
    }
    
    
    private func getNewHastags(addedHash:String) -> String {
        let content = original(text: descTextView.text)
        let components = content.components(separatedBy: " ")
        var newHashes = [String]()
        for text in components {
            if text.hasPrefix("#") {
                let txt = text.replacingOccurrences(of: "#", with: "")
                if !txt.isEmpty {
                    if !addedHash.contains(txt) {
                        newHashes.append(txt)
                    }
                }
            }
        }
        return newHashes.joined(separator: ",")
    }
    
    private func getPlace() {
        
        var lng = "\(UserDefaults.standard.double(forKey: "longitude"))"
        var lat = "\(UserDefaults.standard.double(forKey: "latitude"))"
        
        if self.savedRecord != nil, let ln = self.coordinates?.longitude,let lt = self.coordinates?.latitude {
            lng = "\(ln)"
            lat = "\(lt)"
        }
        
        let urlString = String(format: "https://api.foursquare.com/v2/venues/search?ll=%@,%@&client_id=3P1KGZPYB5XETWEGOAS235WEZTGFTHOF11CB3AXM2YDVRI3N&client_secret=AB5UEOONXC1TGOGZPS5LDOFGUVF4ZAU21SF5BGQELQXMRBHF&categoryId=4d4b7105d754a06375d81259,4e67e38e036454776db1fb3a,4d4b7105d754a06378d81259,4d4b7105d754a06377d81259,4d4b7104d754a06370d81259,4d4b7105d754a06372d81259,4d4b7105d754a06373d81259,4d4b7105d754a06374d81259,4d4b7105d754a06376d81259,4d4b7105d754a06379d81259&v=20161304&radius=\(kLocationRadius)&limit=100",lat,lng)
        let escapedString = urlString.replacingOccurrences(of: "|", with: ",")
        Alamofire.request(escapedString).validate().responseJSON { (response) in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let value):
                    guard let json = (value as! JSONDictionary)["response"] as? JSONDictionary,
                        let data = json["venues"] as? [JSONDictionary] else { return }
                    let venues = data.compactMap{ Venue.init(json: $0) }
                    self.selectedVenue = venues.first
                case .failure(let e):
                    self.showAlert(message: e.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func shareOnTripsterTapped(_ sender: Any) {
        let controller = TripsterListViewController.instantiate(fromAppStoryboard: .tripster)
        let viewModel = TripListViewModel()
        viewModel.viewMode = .CurrentTrips
        viewModel.userId = UserDefaults.standard.string(forKey: USERID)!
        controller.selected = { [weak self] trip in
            self?.trip = trip
            self?.shareBtn.setTitle("Shared trip to \(trip.tripName)", for: .normal)
//            self?.navigationItem.rightBarButtonItem?.tintColor = UIColor.appRed
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        viewModel.isOnMainTab = false
        controller.viewModel = viewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func locationTapped(_ sender: Any) {
        let controller = PlaceSearchVC.instantiate(fromAppStoryboard: .video)
        controller.selected = { [weak self] venue in
            self?.selectedVenue = venue
        }
        if self.savedRecord != nil {
            controller.coordinates = self.coordinates
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func postTypedChanged(_ sender: CustomSegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            postType = "PUBLIC"
        } else if sender.selectedSegmentIndex == 1 {
            postType = "FOLLOWER"
        } else if sender.selectedSegmentIndex == 2 {
            postType = "PRIVATE"
        }
    }
}

extension ReadyToPostVC: HKWTextViewDelegate {
    
//    func textView(_ textView: HKWTextView, didChangeAttributedTextTo newText: NSAttributedString, originalText: NSAttributedString, originalRange: NSRange) {
//        textViewPlaceHolderLabel.isHidden = !textView.text.isEmpty
//    }
    
    func textViewDidChange(_ textView: UITextView) {
        let isNotEmpty = !textView.text.isEmpty
        textViewPlaceHolderLabel.isHidden = isNotEmpty
        
        let count = textView.text.count
        charactersCountLabel.text = "\(count)"
        
        let textHeight = (textView.text as NSString).boundingRect(with: CGSize(width: textView.frame.width, height: 150), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: textView.font!], context: nil).height + (textView.text.isEmpty ? 0 : 14)
           textViewHeightConstraint?.constant = max(min(textHeight, 100), 40)
    }
    
    func textView(_ textView: HKWTextView, willBeginEditing editing: Bool) {
        textViewPlaceHolderLabel.isHidden = true
    }
    
    func textView(_ textView: HKWTextView, willEndEditing editing: Bool) {
            textViewPlaceHolderLabel.isHidden = !textView.text.isEmpty
    }
    
}

//extension ReadyToPostVC: UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//        return text.count <= 200
//    }
//
//}
