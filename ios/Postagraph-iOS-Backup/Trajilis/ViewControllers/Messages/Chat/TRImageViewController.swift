//
//  TRImageViewController
//
//  Created by bharats802 on 25/08/18.
//  Copyright © 2018 Solwares. All rights reserved.
//

import UIKit
import SDWebImage

class TRImageViewController: BaseVC,UIScrollViewDelegate {

    @IBOutlet var backButton: UIButton!
    var imgURL:URL?
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var scrollView:UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.title = "Image"
//        self.backButton.isHidden = true
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10.0
        if let url = imgURL {
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            //self.imgView.sd_setImage(with: url, completed: nil)
            self.imgView.contentMode = .scaleAspectFit
            self.imgView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), progress: nil) { (img, error, type, url) in
                if let image = img {
                    var scaleFactor:CGFloat = 0.0
                    if image.size.width >= image.size.height {
                        let aspectRatio = image.size.width/image.size.height
                        let screenWidth = UIScreen.main.bounds.width
                        let toBeHeight = screenWidth/aspectRatio
                        scaleFactor = UIScreen.main.bounds.height/toBeHeight
                    } else {
                        let aspectRatio = image.size.height/image.size.width
                        let screenHeight = UIScreen.main.bounds.height
                        let toBeWidth = screenHeight/aspectRatio
                        scaleFactor = UIScreen.main.bounds.width/toBeWidth
                        
                    }
//                    if scaleFactor > 1 {
//                        self.scrollView.zoomScale = scaleFactor
//                    } else {
//                        self.scrollView.zoomScale = 1
//                    }
                }
                
                
            }
            
        } else {
            self.showAlert(message: "Unable to display selected picture. Please try again later.")
        }
        
//        Helpers.setupBackButton(button: backButton)
        self.backButton.addTarget(self, action: #selector(btnCancelTapped(sender:)), for: .touchUpInside)
        
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(btnCancelTapped(sender:)))
        self.navigationItem.leftBarButtonItem  = cancelBtn
        // Do any additional setup after loading the view.
    }
    @IBAction func btnCancelTapped(sender:UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.zoomScale < 1 {
            UIView.animate(withDuration: 0.3) {
                scrollView.zoomScale = 1
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func getVC(imgURL:URL?)->TRImageViewController{
        let mainStory = UIStoryboard(name: "ImageViewer", bundle: nil)
        let vc = mainStory.instantiateViewController(withIdentifier: "TRImageViewController") as! TRImageViewController
        vc.imgURL = imgURL
        return vc
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
