//
//  ChatCell.swift
//  Trajilis
//
//  Created by bharats802 on 20/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class ChatCell: ChatBaseCell {
    static let identifier = "ChatCell"
    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet weak var leadingLblMessage:NSLayoutConstraint!
    @IBOutlet weak var trailingLblMessage:NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.centerControl = self.lblMessage
        self.lblMessage.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override func set(isCurrentSender:Bool) {
        self.lblMessage.textColor =  isCurrentSender ? .white : .black
        self.lblMessage.font = UIFont(name: "PTSans-Regular", size: 17)!
        super.set(isCurrentSender: isCurrentSender)
        self.leadingLblMessage.constant = isCurrentSender ? 50 : 15
        self.trailingLblMessage.constant = isCurrentSender ? 15 : 50
    }
}



class ChatBaseCell: UITableViewCell {
    
    @IBOutlet weak var imgViewSelect:UIImageView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var viewBG:UIView!
    
    @IBOutlet weak var cnstrntImgLeading:NSLayoutConstraint!
    @IBOutlet weak var cnstrntImgTrailing:NSLayoutConstraint!
    
    @IBOutlet weak var lblLeft:UILabel!
    @IBOutlet weak var lblRight:UILabel!
    
    
    @IBOutlet weak var cnstrntImgHeight:NSLayoutConstraint!
    @IBOutlet weak var cnstrntImgWidth:NSLayoutConstraint!
    
    @IBOutlet var progressView: CircularLoaderView!
    @IBOutlet weak var activity:UIActivityIndicatorView?
    
    @IBOutlet weak var tailSendImageView: UIImageView!
    @IBOutlet weak var tailReceiveImageView: UIImageView!
    
    var cnstrntLabel:NSLayoutConstraint?
    var centerControl:UIView?
    weak var delegate: ChatCellDelegate?
    
    
    
    @IBOutlet weak var viewReply:UIView!
    @IBOutlet weak var viewForward:UIView!
    @IBOutlet weak var viewReplyForwardSeparator:UIView!
    
    @IBOutlet weak var lblReplyText:UILabel!
    @IBOutlet weak var lblReplyBtm:UILabel!
    @IBOutlet weak var imgViewReply:UIImageView!
    @IBOutlet weak var imgViewForward:UIImageView!
    @IBOutlet weak var lblForward:UILabel!
    @IBOutlet weak var cnstrntReplyLabelBtm:NSLayoutConstraint!
    @IBOutlet weak var imgViewReplySeparator:UIImageView!
    @IBOutlet weak var imgViewReplyQuote:UIImageView!
    @IBOutlet weak var viewReplyForwardBack:MessageReplyForwardView!

    var isCurrentSender: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.cnstrntImgHeight.constant = 35
        self.cnstrntImgWidth.constant = cnstrntImgHeight.constant
        self.imgViewSelect.isHidden = false
        // Initialization code
        self.imgView.layer.borderColor = UIColor.red.cgColor
        self.imgView.layer.cornerRadius = self.cnstrntImgWidth.constant/2
        self.imgView.layer.borderWidth = 1
        self.imgView.layer.masksToBounds = true
        
//        self.viewBG.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.viewBG.layer.cornerRadius = 17
//        self.viewBG.layer.borderWidth = 0.1
        
        self.lblRight.textColor = UIColor(hexString: "#7B7B81")
        self.lblLeft.textColor = UIColor(hexString: "#7B7B81")
        
        self.lblRight.textAlignment = .right
        self.lblLeft.textAlignment = .left
        
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(longPressed))
        self.addGestureRecognizer(longPressRecognizer)
        
    }
    
    @IBAction func longPressed(sender: UILongPressGestureRecognizer)
    {
        if sender.state == .began {
            
            self.delegate?.showMessageOptionsTapped(self)
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setBottomLabels(msg:Message,isCurrentSender:Bool) {
        if isCurrentSender {
            self.lblRight.text = msg.sender.displayName
            let dateString = msg.sentDate.toString(dateFormat: "HH:mm", dateStyle: .medium)
            self.lblLeft.text = dateString
        } else {
            self.lblLeft.text = msg.sender.displayName
            let dateString = msg.sentDate.toString(dateFormat: "HH:mm", dateStyle: .medium)
            self.lblRight.text = dateString
        }
    }
    func setForReplied() {
        self.viewReply.isHidden = false
        self.viewReplyForwardSeparator.isHidden = false
    }
    func setForForwared(){
        self.viewForward.isHidden = false
        self.viewReplyForwardSeparator.isHidden = false
    }
    func set(isCurrentSender: Bool) {
        tailSendImageView.isHidden = !isCurrentSender
        tailReceiveImageView.isHidden = isCurrentSender
        tailReceiveImageView.tintColor = UIColor(hexString: "#DADADA")
        tailSendImageView.tintColor = UIColor(hexString: "#D63D41")
        tailReceiveImageView.image = UIImage(named: "tailReceived")
        tailSendImageView.image = UIImage(named: "tailSend")
        
        self.isCurrentSender = isCurrentSender
        self.cnstrntLabel?.isActive = false
        let pading:CGFloat = 10
        guard let container = self.centerControl else {
            return
        }
        self.viewBG.backgroundColor = isCurrentSender ? UIColor(hexString: "#D63D41") : UIColor(hexString: "#DADADA")
        self.lblLeft.text = nil
        self.lblRight.text = nil
        
        self.viewReply.backgroundColor = UIColor.clear
        self.viewForward.isHidden = true
        self.viewReply.isHidden = true
        self.viewReplyForwardSeparator.isHidden = true
        
        self.viewReplyForwardSeparator.backgroundColor =  UIColor.clear
        
        self.lblLeft.font = UIFont(name: "PTSans-Regular", size: 11)!
        self.lblRight.font = UIFont(name: "PTSans-Regular", size: 11)!
        self.lblForward.font = UIFont(name: "PTSans-Regular", size: 11)!
        self.lblReplyBtm.font = UIFont(name: "PTSans-Regular", size: 11)!
        self.lblReplyText.font = UIFont(name: "PTSans-Regular", size: 11)!
        self.lblForward.textColor = isCurrentSender ? .white : .black
        self.lblReplyBtm.textColor = isCurrentSender ? .white : .black
        self.lblReplyText.textColor = isCurrentSender ? .white : .black
        self.imgViewForward.image = UIImage(named:"foward_msg_white")?.withRenderingMode(.alwaysTemplate)
        self.imgViewForward.tintColor = isCurrentSender ? .white : .black
        self.imgViewReplyQuote.tintColor = isCurrentSender ? .white : .black
        self.imgViewReplySeparator.image = UIImage(named:"dashlineWhite")?.withRenderingMode(.alwaysTemplate)
        self.imgViewReplySeparator.tintColor = isCurrentSender ? .white : .black
        
        if isCurrentSender {
            cnstrntImgLeading.priority = .defaultLow
            cnstrntImgTrailing.priority = .defaultHigh
            
            let cnstrnt = NSLayoutConstraint(item: container, attribute: .trailing, relatedBy: .equal, toItem: self.imgView, attribute: .centerX, multiplier: 1, constant: -pading)
            self.addConstraint(cnstrnt)
            self.cnstrntLabel = cnstrnt
            self.activity?.style = .gray
//            self.lblReplyText.textColor = UIColor.darkGray
//            self.imgViewReplySeparator.image = UIImage(named:"dashlineBlack")
//            self.imgViewReplyQuote.tintColor = UIColor.white
//            self.imgViewForward.tintColor = UIColor.white
//            self.lblForward.textColor = UIColor.darkGray
//            self.imgViewForward.image = UIImage(named:"forward_msg")
        } else {
            cnstrntImgLeading.priority = .defaultHigh
            cnstrntImgTrailing.priority = .defaultLow
            let cnstrnt = NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .equal, toItem: self.imgView, attribute: .centerX, multiplier: 1, constant: pading)
            self.addConstraint(cnstrnt)
            self.cnstrntLabel = cnstrnt
            
//            self.lblReplyText.textColor = UIColor.white
            self.activity?.style = .whiteLarge
            self.lblRight.textAlignment = .right
            self.lblLeft.textAlignment = .left
//            self.imgViewReplySeparator.image = UIImage(named:"dashlineWhite")
//            self.imgViewReplyQuote.tintColor = UIColor.white
//            self.imgViewForward.tintColor = UIColor.white
//            self.lblForward.textColor = UIColor.white
//            self.imgViewForward.image = UIImage(named:"foward_msg_white")
            
        }
        self.activity?.startAnimating()
    }
    func updateDisplay(progress: Float, totalSize : String) {
        progressView.isHidden = false
        progressView.progress = Double(progress)
    }
    func setupDownloadStatus(download:Download?) {
        var showDownloadControls = false
        if let download = download {
            showDownloadControls = true
            if !download.isDownloading {
                showDownloadControls = false
            }
        }
        progressView.isHidden = !showDownloadControls
    }
    func setupUploadStatus(upload:MessageUpload?) {
        var showDownloadControls = false
        if let upload = upload {
            showDownloadControls = true
            if !upload.isUploading {
                showDownloadControls = false
            }
        }
        progressView.isHidden = !showDownloadControls
    }
}

protocol ChatCellDelegate:class {
    
//    func pauseTapped(_ cell: ChatBaseCell)
//    func resumeTapped(_ cell: ChatBaseCell)
//    func cancelTapped(_ cell: ChatBaseCell)
//    func downloadTapped(_ cell: ChatBaseCell)
    func showMessageOptionsTapped(_ cell: ChatBaseCell)
}
class MessageReplyForwardView:UIView {
    var indexPath:IndexPath?
}
