//
//  SearchServiceType.swift
//  GitHubSearch
//
//  Created by Oluwatobi Omotayo on 18/05/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import Foundation
import RxSwift

protocol GitHubSearchServiceType {
    func search(_ text: String) -> Observable<[Repository]>
}
