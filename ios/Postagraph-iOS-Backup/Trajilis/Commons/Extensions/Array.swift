//
//  Array.swift
//  Trajilis
//
//  Created by Moses on 24/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

extension Array {
    
    static func search(by name: String, objects: [Any]) -> [Searchable] {
        guard let objects = objects as? [Searchable] else { return [] }
        return objects.filter({ $0.value.lowercased().contains(name.lowercased()) })
    }
    
    func item(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
