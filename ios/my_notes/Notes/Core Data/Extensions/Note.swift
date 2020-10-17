//
//  Note.swift
//  Notes
//
//  Created by Bart Jacobs on 06/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import Foundation

extension Note {

    // MARK: - Dates

    var updatedAtAsDate: Date {
        return updatedAt ?? Date()
    }

    var createdAtAsDate: Date {
        return createdAt ?? Date()
    }

    // MARK: - Tags

    var alphabetizedTags: [Tag]? {
        guard let tags = tags as? Set<Tag> else {
            return nil
        }

        return tags.sorted(by: {
            guard let tag0 = $0.name else { return true }
            guard let tag1 = $1.name else { return true }
            return tag0 < tag1
        })
    }

    var alphabetizedTagsAsString: String? {
        guard let tags = alphabetizedTags, tags.count > 0 else {
            return nil
        }

        let names = tags.compactMap { $0.name }
        return names.joined(separator: ", ")
    }

}
