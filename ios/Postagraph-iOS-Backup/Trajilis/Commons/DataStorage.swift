//
//  Storage.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Cache
import AVKit

let videoFolder = "TrajilisVideos"

class DataStorage {
    
    static let shared = DataStorage()
    
    let diskConfig = DiskConfig(name: "com.trajilis.trajilis")
    
    let dataStorage: Storage<Data>
    
    private init() {
       dataStorage = try!  Storage(
            diskConfig: diskConfig,
            memoryConfig: MemoryConfig.init(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forData()
        )
    }

}
