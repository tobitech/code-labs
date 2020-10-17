//
//  NoTripViewModel.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/14/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

final class NoTripViewModel {
    private let user: User
    private let currentUserId: String
    
    init?(user: User) {
        self.user = user
        guard let currentUserId = UserDefaults.standard.string(forKey: USERID) else {return nil}
        self.currentUserId = currentUserId
    }
    
    var message: String {
        return isCurrentUser ? "No Trips" : "\(user.firstname) doesn't have any public trip yet."
    }
    
    var isCurrentUser: Bool {
        return user.id == currentUserId
    }
}
