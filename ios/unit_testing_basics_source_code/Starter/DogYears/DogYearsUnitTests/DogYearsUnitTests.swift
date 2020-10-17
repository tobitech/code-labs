//
//  DogYearsUnitTests.swift
//  DogYearsUnitTests
//
//  Created by Brian on 11/30/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import XCTest
@testable import DogYears

class DogYearsUnitTests: XCTestCase {
  
    let calc = Calculator()
    var resData: Data? = nil
  
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMenuFailing() {
        
        var menu = Menu()
        menu.loadMenu(path: "Dummy.plist")
        
        let count = menu.count
        XCTAssert(count == 0, "Menu loaded menu items for non-existent menu file")
        
    }

    func testAdd() {
      let result = calc.evaluate(op: "+", arg1: 2.0, arg2: 9.0)
      XCTAssert(result == 11.0, "Calculator add operation failed")
    }
  
    func testSubtract() {
      
      let result = calc.evaluate(op: "-", arg1: 9.0, arg2: 2.0)
      XCTAssert(result == 7.0, "Calculator subtraction operation failed")
      
    }
  
    func testResult() {
        let res1 = calc.evaluate(op: "+", arg1: 2.0, arg2: 2.0)
        let res2 = calc.result
        
        XCTAssert(res1 == res2, "Calculator displayed result does not match calculation result.")
    }

    func testClear() {

        calc.clear()
        let result = calc.result
        
        XCTAssert(result == 0.0, "Calculator clear operation failed")
    }
    
    /*
    func testInfoLoading() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        XCTAssertNotNil(sb, "Could not instantiate storyboard for Info View Content Loading")
        
        guard let vc = sb.instantiateViewController(withIdentifier: "InformationView") as? InfoViewController else {
            XCTAssert(false, "Could not instantiate view controller for Info view content loading")
            return
        }
        
        _ = vc.view
        
        guard let txt = vc.txtInfo.text else {
            XCTAssert(false, "Could not get Initial text content for InfoView content loading")
            return
        }
        
        vc.loadContent()
        let pred = NSPredicate(format: "text != %@", txt)
        let exp = expectation(for: pred, evaluatedWith: vc.txtInfo, handler: nil)
        let result = XCTWaiter.wait(for: [exp], timeout: 5.0)
        
        XCTAssert(result == XCTWaiter.Result.completed, "Loading content for Info View did not change")
    }
    */
    
    func testInfoLoading() {
        
        let url = "https://raw.githubusercontent.com/FahimF/Test/master/DogYears-Info.rtf"
        
        let session = MockSession()
        let client = HTTPClient(session: session)
        
        client.get(url: url) { data, error in
            self.resData = data
        }
        
        let pred = NSPredicate(format: "resData != nil")
        let exp = expectation(for: pred, evaluatedWith: self, handler: nil)
        let res = XCTWaiter.wait(for: [exp], timeout: 5.0)
        
        if res == XCTWaiter.Result.completed {
            XCTAssertNotNil(resData, "No data received from the server for InfoView content")
        } else {
            XCTAssert(false, "The call to get the URL ran into some other error")
        }
        
    }
    
    /*
    func testSettingsScreen() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        XCTAssertNotNil(sb, "Could not instantiate main storyboard for settings view")
        
        let vc = sb.instantiateViewController(withIdentifier: "SettingsView") as? SettingsViewController
        XCTAssertNotNil(vc, "Could not instantiate settings view controller")
        
        _ = vc?.view
    }
    */
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
