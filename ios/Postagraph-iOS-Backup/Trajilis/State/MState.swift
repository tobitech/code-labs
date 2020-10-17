//
//  State.swift
//  Trajilis
//
//  Created by Moses on 25/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation


enum MState<T> {
    case loading
    case error(String)
    case noData(String)
    case dataLoaded(T, String)
}


