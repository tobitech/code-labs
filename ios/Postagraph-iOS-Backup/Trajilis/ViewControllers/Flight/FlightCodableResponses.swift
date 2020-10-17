//
//  CodableResponses.swift
//  Trajilis
//
//  Created by Oluwatobi Omotayo on 11/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

struct OutboundFlightsResponse<T: Codable>: Codable {
    let data: OutboundFlightsResults<T>
}

struct OutboundFlightsResults<T: Codable>: Codable {
    let outboundFlights: [T]
}
