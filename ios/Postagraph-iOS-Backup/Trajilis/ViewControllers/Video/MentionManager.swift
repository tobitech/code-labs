//
//  MentionManager.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

import Hakawai

class MentionsManager: NSObject {

    static let shared = MentionsManager()
    var shouldAddMention: ((MentionsEntity) -> (Bool))?

    private let mentionsCellId = "mentionsCell"
    private let mentionsCellHeight: CGFloat = 60.0
    private var fakeData = [MentionsEntity]()

    private var currentPage = 0
    private var limit = 1000

    fileprivate func fetchUsers(text: String, completion: @escaping (([MentionsEntity]) -> ())) {
        APIController.makeRequest(request: .searchUserForTag(searchParam: text, count: currentPage, limit: limit)) { [weak self] (response) in
            DispatchQueue.main.async {
                switch response {
                case .success(let value):
                    guard let json = try? value.mapJSON() as? JSONDictionary, let data = json?["data"] as? [JSONDictionary] else { return }
                    var entities = [MentionsEntity]()
                    for dict in data {
                        let name = dict["user_name"] as? String ?? ""
                        let userId = dict["user_id"] as? String ?? ""
                        let userImage = dict["profile_image"] as? String ?? ""
                        let entity = MentionsEntity(name: "@\(name)", id: userId, image: userImage, type: .user)
                        if let shouldAddMention = self?.shouldAddMention {
                            if shouldAddMention(entity) {
                                entities.append(entity)
                            }
                        }else {
                            entities.append(entity)
                        }
                    }
                    completion(entities)
                case .failure(_):
                    completion([])
                }
            }

        }
    }

    private func fetchHash(text: String, completion: @escaping (([MentionsEntity]) -> Void)) {
        APIController.makeRequest(request: .searchHashTag(searchParam: text, count: currentPage, limit: limit)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    completion([])
                case .success(let value):
                     var entities = [MentionsEntity]()
                    guard let json = try? value.mapJSON() as? JSONDictionary, let data = json?["data"] as? [JSONDictionary] else { return }
                    for (index, value) in data.enumerated() {
                        let name = value["hash_tag"] as? String ?? ""
                        let entity = MentionsEntity.init(name: "#\(name)", id: "\(index)", image: "", type: .hashTag)
                        entities.append(entity)
                    }
                    completion(entities)
                }
            }
        }
    }
}

//MARK: - HKWMentionsDelegate
extension MentionsManager: HKWMentionsDelegate {
    func cell(forMentionsEntity entity: HKWMentionsEntityProtocol!, withMatch matchString: String!, tableView: UITableView!, at indexPath: IndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCell(withIdentifier: mentionsCellId)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: mentionsCellId)
            cell?.backgroundColor = .lightGray
        }
        
        cell?.textLabel?.text = entity.entityName()
        cell?.detailTextLabel?.text = entity.entityId()
        return cell
    }


    // In this method, the plug-in gives us a search string and some metadata, as well as a block. Our responsibility is to
    //  perform whatever work is necessary to get the entities for that search string (network call, database query, etc),
    //  and then to call the completion block with an array of entity objects corresponding to the search string. See the
    //  documentation for the method for more details.
    func asyncRetrieveEntities(forKeyString keyString: String!, searchType type: HKWMentionsSearchType, controlCharacter character: unichar,
                               completion completionBlock: (([Any]?, Bool, Bool) -> Void)!) {
        guard completionBlock != nil else {
            return
        }

        if keyString.count == 0 {
            return
        }
        if character == 64 {
            fetchUsers(text: keyString) { (entities) in
                completionBlock(entities, false, true)
            }
        } else if character == 35 {
            fetchHash(text: keyString) { (entities) in
                completionBlock(entities, false, true)
            }
        }
    }

    // In this method, the plug-in gives us a mentions entity (one we previously returned in response to a query), and asks
    //  us to provide a table view cell corresponding to that entity to be presented to the user.

    func heightForCell(forMentionsEntity entity: HKWMentionsEntityProtocol!, tableView: UITableView!) -> CGFloat {
        return mentionsCellHeight
    }

}
