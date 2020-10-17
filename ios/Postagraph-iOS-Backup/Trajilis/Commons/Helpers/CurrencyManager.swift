//
//  CurrencyManager.swift
//  Trajilis
//
//  Created by bharats802 on 18/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

var kUserCurrencySymbol:String {
    get {
        return CurrencyManager.shared.getUserCurrencySymbol()
    }
}
class CurrencyManager: NSObject {
    static let shared = CurrencyManager()
    
    var selectedCurrency:Currency?
    var allCurrencies:[Currency]?
    func updateSelectedCurrency() {
        
        self.getCurrencies { (currencies) in
            if let currencies = currencies {
                let selCurrencyCode = self.getUserCurrencyCode()
                let selectedCurrency = currencies.filter({ (cur) -> Bool in
                    if cur.currency == selCurrencyCode {
                        return true
                    }
                    return false
                })
                self.selectedCurrency = selectedCurrency.first
            }
        }
        
    }
    func getUserCurrencyCode() -> String {
        var currnecy = CurrencyViewController.getCurrencyInSettings()
        if currnecy == kDefaultCurrency {
            currnecy = "USD"
        }
        return currnecy
    }
    func getSymbol(forCurrency:String) -> String {
        let currnecy = forCurrency
        if currnecy == kDefaultCurrency {
            return "$"
        } else {
            if let curencies = self.allCurrencies {
                let selCur = curencies.filter { (cur) -> Bool in
                    if cur.currency == forCurrency {
                        return true
                    }
                    return false
                }
                if let sel = selCur.first {
                   return sel.currencySymbol
                }
            } else {
                return "$"
            }
        }
        return forCurrency
    }
    func getUserCurrencySymbol() -> String {
        let currnecy = CurrencyViewController.getCurrencyInSettings()
        return self.getSymbol(forCurrency: currnecy)
    }
    func callCurrenciesAPI() {
        var userID = "0"
        if let userId = UserDefaults.standard.value(forKey: USERID) as? String, !userId.isEmpty {
            userID = userId
        }
        DispatchQueue.global(qos: .background).async {
            APIController.makeRequest(request: .getCurrencyList(userId: userID)) { (response) in
                switch response {
                case .failure(_):
                    self.getCurrencies(onCompletion: { (crncies) in
                        self.allCurrencies = crncies
                    })
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else { return }
                    
                    guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    let fileUrl = documentDirectoryUrl.appendingPathComponent("currencies.json")
                    // Transform array into data and save it into file
                    do {
                        let data = try JSONSerialization.data(withJSONObject: data, options: [])
                        try data.write(to: fileUrl, options: [])
                        self.getCurrencies(onCompletion: { (crncies) in
                                self.allCurrencies = crncies
                        })
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func getCurrencies(onCompletion:(([Currency]?)->Void)?) {
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("currencies.json")
        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [JSONDictionary] {
                    let list = json.compactMap{ Currency.init($0) }
                    onCompletion?(list)
                } else {
                    onCompletion?(nil)
                }
                
            } catch {
                onCompletion?(nil)
                print(error.localizedDescription)
            }
            
            
        } catch {
            print(error)
            onCompletion?(nil)
        }
    }
}
