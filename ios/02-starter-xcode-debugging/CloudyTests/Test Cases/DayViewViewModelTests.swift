//
//  DayViewViewModelTests.swift
//  CloudyTests
//
//  Created by Bart Jacobs on 05/12/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import XCTest
@testable import Cloudy

class DayViewViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: DayViewViewModel!

    // MARK: - Set Up & Tear Down

    override func setUp() {
        super.setUp()

        // Load Stub
        let data = loadStubFromBundle(withName: "darksky", extension: "json")
        let weatherData: WeatherData = try! JSONDecoder.decode(data: data)

        // Initialize View Model
        viewModel = DayViewViewModel(weatherData: weatherData)
    }

    override func tearDown() {
        super.tearDown()

        // Reset User Defaults
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.timeNotation)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.unitsNotation)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.temperatureNotation)
    }

    // MARK: - Tests for Date

    func testDate() {
        XCTAssertEqual(viewModel.date, "Tue, July 11")
    }

    // MARK: - Tests for Time

    func testTime_TwelveHour() {
        let timeNotation: TimeNotation = .twelveHour
        UserDefaults.standard.set(timeNotation.rawValue, forKey: UserDefaultsKeys.timeNotation)

        XCTAssertEqual(viewModel.time, "01:57 PM")
    }

    func testTime_TwentyFourHour() {
        let timeNotation: TimeNotation = .twentyFourHour
        UserDefaults.standard.set(timeNotation.rawValue, forKey: UserDefaultsKeys.timeNotation)

        XCTAssertEqual(viewModel.time, "13:57")
    }

    // MARK: - Tests for Summary

    func testSummary() {
        XCTAssertEqual(viewModel.summary, "Clear")
    }

    // MARK: - Tests for Temperature

    func testTemperature_Fahrenheit() {
        let temperatureNotation: TemperatureNotation = .fahrenheit
        UserDefaults.standard.set(temperatureNotation.rawValue, forKey: UserDefaultsKeys.temperatureNotation)

        XCTAssertEqual(viewModel.temperature, "44.5 °F")
    }

    func testTemperature_Celsius() {
        let temperatureNotation: TemperatureNotation = .celsius
        UserDefaults.standard.set(temperatureNotation.rawValue, forKey: UserDefaultsKeys.temperatureNotation)

        XCTAssertEqual(viewModel.temperature, "6.9 °C")
    }

    // MARK: - Tests for Wind Speed

    func testWindSpeed_Imperial() {
        let unitsNotation: UnitsNotation = .imperial
        UserDefaults.standard.set(unitsNotation.rawValue, forKey: UserDefaultsKeys.unitsNotation)

        XCTAssertEqual(viewModel.windSpeed, "6 MPH")
    }

    func testWindSpeed_Metric() {
        let unitsNotation: UnitsNotation = .metric
        UserDefaults.standard.set(unitsNotation.rawValue, forKey: UserDefaultsKeys.unitsNotation)

        print(viewModel.windSpeed)

        XCTAssertEqual(viewModel.windSpeed, "10 KPH")
    }

    // MARK: - Tests for Image

    func testImage() {
        let viewModelImage = viewModel.image
        let imageDataViewModel = UIImagePNGRepresentation(viewModelImage!)!
        let imageDataReference = UIImagePNGRepresentation(UIImage(named: "clear-day")!)!

        XCTAssertNotNil(viewModelImage)
        XCTAssertEqual(viewModelImage!.size.width, 236.0)
        XCTAssertEqual(viewModelImage!.size.height, 236.0)
        XCTAssertEqual(imageDataViewModel, imageDataReference)
    }

}
