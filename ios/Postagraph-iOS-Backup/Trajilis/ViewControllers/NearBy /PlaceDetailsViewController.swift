//
//  PlaceDetailsViewController.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Alamofire


class PlaceDetailsViewController: BaseVC {

    @IBOutlet weak var backBtn:UIButton!
    @IBOutlet weak var stackView:UIStackView!
    var placeId:String?
    var googlePlace:GooglePlace?
    override func viewDidLoad() {
        super.viewDidLoad()
        Helpers.setupBackButton(button: backBtn)
        // Do any additional setup after loading the view.
        self.stackView.removeAllViews()
        self.getDetails()
    }
    func getDetails() {
        if let plcId = self.placeId {
                let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(plcId)&key=\(Constants.GOOGLEAPIKEY)"
                if let url = URL(string:urlString) {
                    
                    let request = URLRequest(url: url)
                    self.spinner(with: "Loading...", blockInteraction: true)
                    Alamofire.request(request).responseJSON { [weak self](response) in
                        if let strngSelf = self {
                            DispatchQueue.main.async {
                                strngSelf.hideSpinner()
                                if let val = response.result.value as AnyObject? {
                                    print(val)
                                    if let status = val["status"] as? String,status == "OK", let result = val["result"] as AnyObject? {
                                        strngSelf.googlePlace = GooglePlace(data: result)
                                        
                                        strngSelf.addViews()
                                        
                                        
                                    } else {
                                        
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func addViews() {
        self.stackView.removeAllViews()
        if let gplace = self.googlePlace {
            if gplace.photos.count > 0 {
                let imagesView = PlaceImagesView.getView()
                self.stackView.addArrangedSubview(imagesView)
                imagesView.setImages(images: gplace.photos)
            }
            
            
            let plceInfo = PlaceInfoView.getView()
            plceInfo.fillWithPlace(gplace: gplace)
            self.stackView.addArrangedSubview(plceInfo)
            plceInfo.btnEMail.addTarget(self, action: #selector(btnWebsiteTapped(sender:)), for: .touchUpInside)
            plceInfo.btnContact.addTarget(self, action: #selector(btnPhoneTapped(sender:)), for: .touchUpInside)
            plceInfo.btnDirection.addTarget(self, action: #selector(btnDirectionlTapped(sender:)), for: .touchUpInside)
            
            if let timings = gplace.weekday_text,timings.count > 0 {
                let timingsView = PlaceTimingsView.getView()
                timingsView.setTiming(timings: timings)
                self.stackView.addArrangedSubview(timingsView)
            }
            
            if gplace.reviews.count > 0 {
                let reviewsView = PlaceReviewsView.getView()
                reviewsView.setReviews(reviews: gplace.reviews)
                self.stackView.addArrangedSubview(reviewsView)
            }
            
            
        }
        
    }
    @IBAction func btnWebsiteTapped(sender:UIButton) {
        if let website = self.googlePlace?.website,!website.isEmpty {
            guard let url = URL.init(string: website) else {
                return
            }
            let vc = OnboardingWebVC.instantiate(fromAppStoryboard: .onboarding)
            vc.url = url
            vc.title = self.googlePlace?.name
            navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showAlert(message: "website not available.")
        }
    }
    @IBAction func btnPhoneTapped(sender:UIButton) {
        if let phone = self.googlePlace?.phone
,!phone.isEmpty {
            let formatedNumber = phone.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
            if let url = URL(string: "TEL://\(formatedNumber)"),UIApplication.shared.canOpenURL(url)  {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.showAlert(message: "phone number not available.")
            }
        } else {
            self.showAlert(message: "phone number not available.")
        }
    }
    @IBAction func btnDirectionlTapped(sender:UIButton) {
        if let location = self.googlePlace?.address {
            let strURL = "comgooglemaps://?saddr=&daddr=\(location.replacingOccurrences(of: " ", with: "+"))&zoom=10"
            if let plcURL = URL(string:strURL) {
                UIApplication.shared.open(plcURL, options: [:], completionHandler: nil)
            } else {
                self.showAlert(message: "Unable to get direction to the location.")
            }
        } else {
            self.showAlert(message: "Unable to get place's location.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backBtnTapped(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
