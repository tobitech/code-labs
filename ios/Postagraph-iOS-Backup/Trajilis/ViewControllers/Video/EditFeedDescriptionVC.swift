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


final class EditFeedDescriptionVC: BaseVC {

    @IBOutlet var descTextView: HKWTextView!
    var textViewPlaceholderLabel : UILabel!
    var selectedFeed:Feed?
    private var plugin: HKWMentionsPlugin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        self.descTextView.backgroundColor = .appRed
        navigationItem.title = "Edit Description"
        let continueBarButton = UIBarButtonItem(image: UIImage.init(named: "whiteshare"), style: .plain, target: self, action: #selector(post(_:)))
        navigationItem.rightBarButtonItem = continueBarButton
        self.setupTextView()
        if let feed = self.selectedFeed {
            self.resolveMenstions(feed:feed)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = false
        MentionsManager.shared.shouldAddMention = { entity in
            let containsMention = self.plugin?.mentions()?.contains(where: {
                if let mention = $0 as? HKWMentionsAttribute {
                   return mention.entityIdentifier == entity.entityId()
                }else if let mention = $0 as? HKWMentionsEntityProtocol {
                    return mention.entityId() == entity.entityId()
                }
                return false
            }) ?? false
            
            return !containsMention
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MentionsManager.shared.shouldAddMention = nil
    }
    
    private func resolveMenstions(feed:Feed) {
        let components = feed.component.components(separatedBy: " ")
        var mensions = [HKWMentionsAttribute]()
        for text in components {
            if text.hasPrefix("@") {
                let txt = text.replacingOccurrences(of: "@", with: "")
                if !txt.isEmpty {
                    if let entityId = feed.getIDForUser(userName: txt) {
                        if let mention1 =  HKWMentionsAttribute.mention(withText: txt,  identifier: entityId) {
                            mention1.range = NSRange(location: self.descTextView.text.count, length: mention1.mentionText.count)
                            self.descTextView.insertText(mention1.mentionText)
                            mensions.append(mention1)
                        }
                    }
                }
            } else if text.hasPrefix("#") {
                let txt = text//.replacingOccurrences(of: "#", with: "")
                if !txt.isEmpty {
                    if let mention1 =  HKWMentionsAttribute.mention(withText: txt,  identifier: txt) {
                        mention1.range = NSRange(location: self.descTextView.text.count, length: mention1.mentionText.count)
                        self.descTextView.insertText(mention1.mentionText)
                        mensions.append(mention1)
                    }
                }
            } else {
                self.descTextView.insertText(text)
            }
            self.descTextView.insertText(" ")
        }
        self.plugin?.addMentions(mensions)
    }

    private func setupTextView() {
        let mode = HKWMentionsChooserPositionMode.enclosedTop
        // In this demo, the user may explicitly begin a mention with either the '@' or '+' characters
        let controlCharacters = CharacterSet(charactersIn: "@#")
        // The user may also begin a mention by typing three characters (set searchLength to 0 to disable)
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

        if let selFeed = self.selectedFeed {
            
            let parameters: JSONDictionary = [
                "content": original(text: descTextView.text),
                "user_id": UserDefaults.standard.string(forKey: USERID)!,
                "feed_id":selFeed.id,
                "taged_user": getTaggedUsers(),
                "hash_tag": getTags(),
                "feed_visibility":selFeed.feed_visibility
            ]
            self.spinner(with: "Updating...", blockInteraction: true)
            APIController.makeRequest(request: .editFeed(param: parameters)) { (response) in
                DispatchQueue.main.async {
                    self.hideSpinner()
                    switch response {
                    case .success(_):
                        NotificationCenter.default.post(name: Constants.NotificationName.Reload, object: nil)
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        self.showAlert(message: error.desc)
                    }
                }
            }
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

    
}
extension EditFeedDescriptionVC : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        
        return true
    }
    
}
struct PGMentions {
    var mention:MentionsEntity?
    var range:NSRange?
    init(men:MentionsEntity,rng:NSRange) {
        mention = men
        range = rng
    }
}

