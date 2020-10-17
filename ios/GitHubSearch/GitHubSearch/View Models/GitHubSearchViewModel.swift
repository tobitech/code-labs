//
//  GitHubSearchViewModel.swift
//  GitHubSearch
//
//  Created by Oluwatobi Omotayo on 18/05/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class GitHubSearchViewModel {
    var data: Observable<[Repository]>!
    var error: Observable<String?>!
    var searchService = GitHubSearchService()
    var processing: Observable<Bool>!
    var searchCache = [String: [Repository]]()
    
    func configure(search: Observable<String>) {
        let result = search
            .flatMapLatest {[unowned self] text -> Observable<Event<[Repository]>> in
                if text.isEmpty {
                    return .just(.next([]))
                }
                // check cache...
                let key = text.lowercased()
                if let cachedResult = self.searchCache[key] {
                    return .just(.next(cachedResult))
                }
                return self.searchService.search(text)
                    .do(onNext: { (results) in
                        // cache results
                        self.searchCache[key] = results
                    })
                    .materialize()
            }
        .observeOn(MainScheduler.instance)
        .share()
        
        data = result.map { $0.element ?? [] }
        
        error = result
            .map { $0.error?.localizedDescription }
            .share()
        
        processing = Observable<Bool>
            .merge(search.map { _ in true}, data.map { _ in false })
    }
}
