//
//  CommentViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 06/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

final class CommentViewModel {
    
    let feedId: String
    var commentCount: Int
    let isOwner: Bool
    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    
    var comments = [Comment]()
    var replies: [String: [Comment]] = [:]
    var expandedComments: [String] = []
    var commentIDToPreload: String?
    
    var reload: (() -> ())?
    
    init(feedId: String, commentCount: Int, isOwner: Bool) {
        self.feedId = feedId
        self.commentCount = commentCount
        self.isOwner = isOwner
        getComments()
    }
    
    func getComments() {
        APIController.makeRequest(request: .getComments(feed: feedId, count: 0, limit: 1000)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let e):
                    print(e.localizedDescription)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["comments"] as? [JSONDictionary] else { return }
                    let comments = data.compactMap{ Comment.init(json: $0) }
                    self.comments = comments
                    if let commentIDToPreload = self.commentIDToPreload, let comment = comments.first(where: {$0.id == commentIDToPreload}) {
                        self.getReplies(of: comment, force: true)
                    }
                    self.reload?()
                }
            }
        }
    }
    
    func getReplies(of comment: Comment, force: Bool = false) {
        let commentId = comment.parentComment ?? comment.id
        
        func addReplies(comments: [Comment]) {
            replies[commentId] = comments
            if let index = self.comments.firstIndex(where: {$0.id == commentId}) {
                self.comments.insert(contentsOf: comments, at: index + 1)
            }
            expandedComments.append(commentId)
        }
        
        func removeReplies() {
            self.comments = self.comments.filter({
                $0.parentComment != commentId
            })
            self.expandedComments = self.expandedComments.filter({$0 != commentId})
        }
        
        if !force {
            if expandedComments.contains(commentId) {
                removeReplies()
                reload?()
                return
            }
            
            if let replies = replies[commentId] {
                addReplies(comments: replies)
                reload?()
                return
            }
        }
        
        APIController.makeRequest(request: .getReply(commentId: commentId, count: 0, limit: 1000)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let e):
                    print(e.localizedDescription)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["reply"] as? [JSONDictionary] else { return }
                    let comments = data.compactMap{ Comment.init(json: $0) }
                    comments.forEach({$0.parentComment = comment.id})
                    removeReplies()
                    addReplies(comments: comments)
                    self.commentIDToPreload = nil
                    self.reload?()
                }
            }
        }
    }
    
    func like(comment: Comment) {
        guard let user = appDelegate?.user else {
            return
        }
        let param: JSONDictionary = [
            "entity_id": comment.id,
            "user_id": user.id,
            "user_image": user.profileImage,
            "user_name": user.username,
            "value": comment.likeStatus
        ]
        APIController.makeRequest(request: .likeComment(param: param)) { (_) in
            
        }
    }
    
    func delete(comment: Comment, completion: @escaping (String?)->()) {
        APIController.makeRequest(request: .deleteComment(commentId:comment.id, isReply: comment.parentComment != nil)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let e):
                    completion(e.localizedDescription)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary else { return }
                    if let status = meta["status"] as? String,
                        status == "200" {
                        
                        if let parentCommentId = comment.parentComment {
                            var replies = self.replies[parentCommentId]
                            if let index = replies?.firstIndex(where: {$0.id == comment.id}) {
                                replies?.remove(at: index)
                                self.replies[parentCommentId] = replies
                            }
                            let comment = self.comments.first(where: {$0.id == parentCommentId})
                            comment?.replyCount = "\((Int(comment?.replyCount ?? "0") ?? 0) - 1)"
                        }else {
                            self.commentCount -= 1
                        }
                        if let index = self.comments.firstIndex(where: {$0.id == comment.id}) {
                            self.comments.remove(at: index)
                            if let replies = self.replies[comment.id]?.map({$0.id}) {
                                self.comments = self.comments.filter({!replies.contains($0.id)})
                            }
                        }
                        
                        completion(nil)
                    } else {
                        completion(kDefaultError)
                    }
                }
            }
            
        }
    }
    
    func comment(text: String, taggedUsers: String, hashTags: String, comment: Comment? = nil, completion: @escaping (String?) -> ()) {
        if let comment = comment {
            return reply(text: text, taggedUsers: taggedUsers, hashTags: hashTags, on: comment, completion: completion)
        }
        
        let timestamp = Date().timeIntervalSince1970
        let c : String! = String(format:"%.0f", timestamp)
        
        let param: JSONDictionary = [
            "component": text,
            "createdon": c,
            "entity_id": feedId,
            "taged_user": taggedUsers,
            "hash_tag": hashTags,
            "user_id": Helpers.userId
        ]
        
        APIController.makeRequest(request: .saveComment(param: param)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    completion("Failed to post comment. Try again.")
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let status = meta["status"] as? String, status == "200" else { return completion(kDefaultError) }
                    self.commentCount += 1
                    self.getComments()
                    completion(nil)
                }
            }
            
        }
    }
    
    private func reply(text: String, taggedUsers: String, hashTags: String, on comment: Comment, completion: @escaping (String?) -> ()) {
        let timestamp = Date().timeIntervalSince1970
        let c : String! = String(format:"%.0f", timestamp)

        var param: JSONDictionary = [
            "component": text,
            "createdon": c,
            "entity_id": comment.parentComment ?? comment.id,
            "taged_user": taggedUsers,
            "hash_tag": hashTags,
            "user_id": Helpers.userId
        ]
        
        if comment.parentComment != nil {
            let userId = comment.userId
            if !taggedUsers.contains(userId) && comment.userId != Helpers.userId {
                param["taged_user"] = taggedUsers.isEmpty ? userId : (taggedUsers + ",\(userId)")
                param["component"] = "\(comment.username) " + text
            }
        }
        
        APIController.makeRequest(request: .saveReply(param: param)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    completion("Failed to reply. Try again.")
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let status = meta["status"] as? String,
                        status == "200" else { return completion(kDefaultError)}
                    comment.replyCount = "\((Int(comment.replyCount) ?? 0) + 1)"
                    self.getReplies(of: comment, force: true)
                    completion(nil)
                }
            }
        }
    }
    
}
