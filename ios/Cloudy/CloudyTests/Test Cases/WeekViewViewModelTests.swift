//
//  WeekViewViewModelTests.swift
//  CloudyTests
//
//  Created by Bart Jacobs on 05/12/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import XCTest
@testable import Cloudy

class WeekViewViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: WeekViewViewModel!

    // MARK: - Set Up & Tear Down

    override func setUp() {
        super.setUp()

        // Load Stub
        let data = loadStubFromBundle(withName: "darksky", extension: "json")
        let weatherData: WeatherData = try! JSONDecoder.decode(data: data)

        // Initialize View Model
        viewModel = WeekViewViewModel(weatherData: weatherData.dailyData)
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Tests for Number of Sections

    func testNumberOfSections() {
        XCTAssertEqual(viewModel.numberOfSections, 1)
    }

    // MARK: - Tests for Number of Days

    func testNumberOfDays() {
        XCTAssertEqual(viewModel.numberOfDays, 8)
    }

    // MARK: - Tests for View Model for Index

    func testViewModelForIndex() {
        let weatherDayViewViewModel = viewModel.viewModel(for: 5)

        XCTAssertEqual(weatherDayViewViewModel.day, "Saturday")
        XCTAssertEqual(weatherDayViewViewModel.date, "July 15")
    }
    
}
