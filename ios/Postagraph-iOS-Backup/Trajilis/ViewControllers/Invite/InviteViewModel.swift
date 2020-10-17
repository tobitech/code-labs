//
//  InviteViewModel.swift
//  Trajilis
//
//  Created by Moses on 25/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

protocol IInviteViewModel {
    func invite(by api: TrajilisAPI, render: @escaping ((MStateModel<String>) -> Void) )
}


class InviteViewModel : IInviteViewModel {
    
    
    func invite(by api: TrajilisAPI, render: @escaping ((MStateModel<String>) -> Void) ) {
        
        let state = MState<String>.loading
        render(MStateModel<String>.init(state: state))
        
        APIController.makeRequest(request: api) { (response) in
            
            switch response {
            case .failure(let errorMessage):
                let state = MState<String>.error(errorMessage.localizedDescription)
                render(MStateModel<String>.init(state: state))
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                
                var message = ""
                if let meta = json?["meta"] as? JSONDictionary, let msg = meta["message"] as? String {
                    message = msg
                }
                let state = MState<String>.noData(message)
                render(MStateModel<String>.init(state: state))
            }
        }
    }
}
