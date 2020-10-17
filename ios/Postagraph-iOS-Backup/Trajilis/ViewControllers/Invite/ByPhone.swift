//
//  ByPhone.swift
//  Trajilis
//
//  Created by Moses on 25/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import Contacts

struct ByPhone : Equatable {
    var name : String
    var number: String
    
    
    static func phoneStrings (_ phones: [ByPhone]) -> [String] {
        return phones.compactMap({ $0.number })
    }
    
    public static func == (lhs: ByPhone, rhs: ByPhone) -> Bool {
        return lhs.name == rhs.name && lhs.number == rhs.number
    }
    
    public static func fetch(_ phones: @escaping (([ByPhone]) -> Void)) {
        
        let contactStore = CNContactStore()
        var contacts = [ByPhone]()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        
        do {
            
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                
                let name = contact.givenName + " " + contact.familyName
                if let number = contact.phoneNumbers.first?.value.stringValue {
                   contacts.append(ByPhone.init(name: name, number: number))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        phones(contacts)
    }
}
