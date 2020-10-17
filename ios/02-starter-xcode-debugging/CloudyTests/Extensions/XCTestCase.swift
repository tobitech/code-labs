//
//  XCTestCase.swift
//  CloudyTests
//
//  Created by Bart Jacobs on 05/12/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import XCTest

extension XCTestCase {

    // MARK: - Helper Methods
    
    func loadStubFromBundle(withName name: String, extension: String) -> Data {
        let bundle = Bundle(for: classForCoder)
        let url = bundle.url(forResource: name, withExtension: `extension`)

        return try! Data(contentsOf: url!)
    }

}
