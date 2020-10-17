//
//  WeekViewViewModel.swift
//  Cloudy
//
//  Created by Bart Jacobs on 01/12/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

struct WeekViewViewModel {

    // MARK: - Properties

    let weatherData: [WeatherDayData]

    // MARK: -

    var numberOfSections: Int {
        return 1
    }

    var numberOfDays: Int {
        return weatherData.count
    }

    // MARK: - Methods

    func viewModel(for index: Int) -> WeatherDayViewViewModel {
        return WeatherDayViewViewModel(weatherDayData: weatherData[index])
    }

}
