//
//  StateModel.swift
//  Trajilis
//
//  Created by Moses on 25/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

protocol IMStateModel {
    associatedtype T
    var state : MState<T> { get set }
}

struct MStateModel <E> : IMStateModel {
    typealias T = E
    var state: MState<E>
}

struct List<T> {
    var list = [T]()
    private init(){}
    
    init(list: [T]) {
        self.list = list
    }
}
