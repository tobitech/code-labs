//
//  DogYearsUITests.swift
//  DogYearsUITests
//
//  Created by Oluwatobi Omotayo on 13/01/2020.
//  Copyright © 2020 Razeware. All rights reserved.
//

import XCTest

class DogYearsUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func isPortrait() -> Bool {
        return XCUIDevice.shared.orientation.isPortrait
    }
    
    func testCalculatorEntry() {
        
        let display = app.staticTexts.matching(identifier: "result").firstMatch
        app.buttons["2"].tap()
        app.buttons["4"].tap()
        XCTAssert(display.label == "24", "The calculator display value did not change")
    }

    func testExample() {

        let navBar = app.navigationBars["Master"]
        let button = navBar.buttons["Menu"]
        button.tap()
        
        XCTAssertFalse(navBar.exists, "The old navigation bar no longer exists.")
        
        let nav2 = app.navigationBars["Menu"]
        XCTAssert(nav2.exists, "The new navigation bar does not exist")
    
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    fileprivate func navigateBack() {
        if isPad() {
            if isPortrait() {
                app.buttons["Master"].tap()
            }
        } else {
            app.navigationBars["Master"].buttons["Menu"].tap()
        }
    }
    
    func testInformationViewNavigation() {
        
        navigateBack()
        
        let infoMenu = app.tables.staticTexts["Information"]
        infoMenu.tap()
        
        let infoNavBar = app.navigationBars["Information"]
        
        XCTAssert(infoNavBar.exists, "The information view navigation bar does not exist")
        
    }
    
    func testSettingsNavigation() {
        let navBar = app.navigationBars["Master"]
        let button = navBar.buttons["Menu"]
        button.tap()
        
        let settingsMenu = app.tables.staticTexts["Settings"]
        settingsMenu.tap()
        
        let settingsNavBar = app.navigationBars["Settings"]
        
        XCTAssert(settingsNavBar.exists, "The settings view navigation bar does not exist")
    }
    
    func testAboutNavigation() {
        let navBar = app.navigationBars["Master"]
        let button = navBar.buttons["Menu"]
        button.tap()
        
        let aboutMenu = app.tables.staticTexts["About"]
        aboutMenu.tap()
        
        let aboutNavBar = app.navigationBars["About"]
        
        XCTAssert(aboutNavBar.exists, "The about view navigation bar does not exist")
    }
    
    func testAboutRate() {
        let navBar = app.navigationBars["Master"]
        let button = navBar.buttons["Menu"]
        button.tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["About"].tap()
        tablesQuery.buttons["Rate Us On the App Store"].tap()
        let element = app.children(matching: .other).element(boundBy: 0)
        
        let pred = NSPredicate(format: "exists == true")
        let exp = expectation(for: pred, evaluatedWith: element, handler: nil)
        let res = XCTWaiter.wait(for: [exp], timeout: 5.0)
        XCTAssert(res == XCTWaiter.Result.completed, "Failed time out waiting for rating dialog")
        
        let title = element.staticTexts["Enjoying DogYears?"]
        
        XCTAssert(title.exists, "Enjoying DogYears dialog did not show!")
        
        element.staticTexts["Not Now"].tap()
        XCTAssert(!title.exists, "Enjoying DogYears dialog did not go away!")
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
