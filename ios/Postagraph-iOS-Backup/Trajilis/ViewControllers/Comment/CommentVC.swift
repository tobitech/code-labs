//
//  CommentVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 08/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import Hakawai
import IQKeyboardManagerSwift

final class CommentVC: BaseVC {

    var viewModel: CommentViewModel!
    var onDone: (() -> ())?
    private var replyingToComment: Comment?
    private var plugin: HKWMentionsPlugin?
    private var textViewPlaceholderLabel : UILabel!
    
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textView: HKWTextView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var textViewContainerView: UIView!
    @IBOutlet var replyContainerView: UIView!
    @IBOutlet weak var replyUsernameLabel: UILabel!
    @IBOutlet weak var replyCommentLabel: UILabel!
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setCommentCount()
        commentsCountLabel.superview?.set(cornerRadius: 8)
        tableView.tableFooterView = UIView()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewModel.reload = { [weak self] in
            guard let self = self else {return}
            self.setCommentCount()
            self.tableView.reloadData()
        }
        setupTextView()
        textViewPlaceHolder()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func setCommentCount() {
        switch viewModel.commentCount {
        case 0: commentsCountLabel.text = "Comments"
        case 1: commentsCountLabel.text = "1 Comment"
        default:
           commentsCountLabel.text = "\(self.viewModel.commentCount) comments"
        }
    }

    private func textViewPlaceHolder() {
        textViewPlaceholderLabel = UILabel()
        textViewPlaceholderLabel.text = "What do you think?"
        textView.externalDelegate = self
        textViewPlaceholderLabel.font =  textView.font
        textViewPlaceholderLabel.sizeToFit()
        textView.addSubview(textViewPlaceholderLabel)
        textViewPlaceholderLabel.frame.origin = CGPoint(x: 10, y: (textView.font?.pointSize)! / 2)
        textViewPlaceholderLabel.textColor = textView.textColor?.withAlphaComponent(0.5)
        textViewPlaceholderLabel.isHidden = !textView.text.isEmpty
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
        tableView.register(UINib.init(nibName: CommentTableViewCell.name, bundle: nil), forCellReuseIdentifier: CommentTableViewCell.name)
        tableView.reloadData()
        viewModel.getComments()
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint.constant = endFrame?.size.height ?? 0.0
            }
            
            tableView.scrollRectToVisible(CGRect(x: 0.0, y: tableView.contentSize.height - 1.0, width: 1.0,  height: 1.0), animated: false)
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

    private func setupTextView() {
        let mode = HKWMentionsChooserPositionMode.customLockTopNoArrow
        let controlCharacters = CharacterSet(charactersIn: "@#")
        let mentionsPlugin = HKWMentionsPlugin(chooserMode: mode, controlCharacters: controlCharacters, searchLength: -1)

        mentionsPlugin?.chooserViewClass = CustomChooserView.self
        mentionsPlugin?.resumeMentionsCreationEnabled = true
        mentionsPlugin?.chooserViewEdgeInsets = UIEdgeInsets(top: 2, left: 0.5, bottom: 0.5, right: 0.5)
        plugin = mentionsPlugin
        plugin?.chooserViewBackgroundColor = .lightGray
        mentionsPlugin?.delegate = MentionsManager.shared
        textView.controlFlowPlugin = mentionsPlugin
        plugin?.setChooserTopLevel(view, attachmentBlock: { (chooserView) in
            chooserView!.bottomAnchor.constraint(equalTo: self.textViewContainerView.topAnchor, constant: 0).isActive = true
            chooserView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            chooserView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            chooserView!.heightAnchor.constraint(equalToConstant: 200).isActive = true
        })
    }

    fileprivate func like(comment: Comment) {
        guard var count = Int(comment.likeCount) else { return }
        if comment.likeStatus == false {
            comment.likeStatus = true
            count += 1
        } else {
            comment.likeStatus = false
            count -= 1
        }
        comment.likeCount = "\(count)"
        tableView.reloadData()
        viewModel.like(comment: comment)
    }

    @IBAction func sendTapped(_ sender: Any) {
        guard !textView.text.isEmpty else { return }
        viewModel.comment(text: textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), taggedUsers: getTaggedUsers(), hashTags: getTags(), comment: replyingToComment) { [weak self] (error) in
            if let error = error {
                self?.showAlert(message: error)
            }else {
                self?.textView.text = ""
                self?.textView.resignFirstResponder()
                self?.closeReply(nil)
            }
        }
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
        let ids = tags.compactMap{ $0.entityName() }.joined(separator: ",")
        return ids
    }
    
    private func options(comment: Comment) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let copy = UIAlertAction(title: "Copy", style: .default) { (_) in
            UIPasteboard.general.string = comment.component
        }
        let reply = UIAlertAction(title: "Reply", style: .default) { (_) in
            self.reply(comment: comment)
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.delete(comment: comment)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(copy)
        alert.addAction(reply)
        
        if self.viewModel.isOwner || comment.userId == Helpers.userId {
            alert.addAction(delete)
        }
        
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    private func delete(comment: Comment) {
        spinner(with: "Deleting...", blockInteraction: true)
        viewModel.delete(comment: comment) { [weak self] (error) in
            self?.hideSpinner()
            if let error = error {
                self?.showAlert(message: error)
            }else {
                self?.commentsCountLabel.text = "\(self?.viewModel.commentCount ?? 0) comments"
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBAction func closeReply(_ sender: Any?) {
        replyContainerView.isHidden = true
        replyingToComment = nil
    }
    
    private func reply(comment: Comment) {
        textView.becomeFirstResponder()
        replyingToComment = comment
        replyContainerView.isHidden = false
        replyUsernameLabel.text = "@" + comment.username
        replyCommentLabel.text = comment.component
    }
    
    
    @IBAction func close(_ sender: Any) {
        onDone?()
        dismiss(animated: true, completion: nil)
    }
    
}

extension CommentVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.name) as! CommentTableViewCell
        let comment = viewModel.comments[indexPath.row]
        cell.configure(comment: comment)
        cell.likeBlock = {
            self.like(comment: comment)
        }
        
        cell.optionBlock = {
            self.options(comment: comment)
        }
        
//        if (self.isOwner || comment.userId == Helpers.userId) {
//            cell.btnDelete.isHidden = false
//        }
        
//        cell.btnDelete.addTarget(self, action: #selector(btnDeleteCommentTapped(sender:)), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = viewModel.comments[indexPath.row]
        if comment.parentComment == nil {
            viewModel.getReplies(of: comment)
        }
    }
    
}

extension CommentVC: HKWTextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let isNotEmpty = !textView.text.isEmpty
        textViewPlaceholderLabel.isHidden = isNotEmpty
        sendButton.isEnabled = isNotEmpty
        sendButton.tintColor = isNotEmpty ? UIColor(hexString: "#D63D41") : UIColor(hexString: "#3F3F3F")
    }
    
    func textView(_ textView: HKWTextView, willBeginEditing editing: Bool) {
        textViewPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: HKWTextView, willEndEditing editing: Bool) {
        textViewPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
    
}
