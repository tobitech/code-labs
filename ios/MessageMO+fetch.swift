//
//  ChatMO.swift
//  Hollaport
//
//  Created by Oluwatobi Omotayo on 23/11/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import CoreData

extension MessageMO {
    
    class func fetchChatMessages(chatId: String, offset: Int) throws -> [MessageMO] {
        
        let managedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
        
        // Helpers
        var messages: [MessageMO] = []
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<MessageMO> = MessageMO.fetchRequest() as! NSFetchRequest<MessageMO>
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        fetchRequest.fetchLimit = 40
        fetchRequest.fetchOffset = offset
        
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", chatId)
        
        // perform fetch request
        messages = try managedObjectContext.fetch(fetchRequest)
        
        return messages
    }
    
}
