//
//  MentionsEntity.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation
import Hakawai

class MentionsEntity: NSObject {

    enum EntityType: String {
        case user = "user"
        case hashTag = "hash"
    }

    private var name: String
    private var id: String!
    private var image: String?
    private var type: EntityType!

    init(name: String, id: String, image: String, type: EntityType) {
        self.name = name
        self.id = id
        self.image = image
        self.type = type
    }
}

extension MentionsEntity: HKWMentionsEntityProtocol {

    func entityId() -> String! {
        return id
    }

    func entityName() -> String! {
        return name
    }

    func entityMetadata() -> [AnyHashable : Any]! {
        return [id: name, "type": type.rawValue, "image": image ?? ""]
    }
}
