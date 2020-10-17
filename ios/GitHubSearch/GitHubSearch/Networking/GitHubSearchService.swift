//
//  SearchService.swift
//  GitHubSearch
//
//  Created by Oluwatobi Omotayo on 18/05/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import Foundation
import Moya
import RxMoya
import RxSwift

class GitHubSearchService: GitHubSearchServiceType {
    
    private var github: MoyaProvider<GitHub>
    
    init(github: MoyaProvider<GitHub> = MoyaProvider<GitHub>()) {
        self.github = github
    }
    
    func search(_ text: String) -> Observable<[Repository]> {
        return github.rx
            .request(.search)
            .map([Repository].self)
            .asObservable()
    }
}
