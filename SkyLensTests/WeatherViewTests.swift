//
//  WeatherViewTests.swift
//  SkyLensTests
//
//  Created by Sharjeel Ahmad on 2025-10-18.
//

import XCTest
import SwiftUI
@testable import SkyLens

final class WeatherViewTests: XCTestCase {

    // Test helper to access private properties
    private func getBackgroundColors(from view: WeatherView) -> [Color]? {
        // Using Mirror to access the private property
        // We need to access the computed backgroundColors property by invoking it
        // since it's now dependent on viewModel.state and lastStableColors
        // Get the object's Mirror
        let mirror = Mirror(reflecting: view)

        // First try direct access to the computed property
        for child in mirror.children {
            if child.label == "backgroundColors" {
                return child.value as? [Color]
            }
        }

        // If that fails (which is likely since it's a computed property),
        // try to invoke the property getter
        if let method = view.backgroundColors as? [Color] {
            return method
        }

        return nil
    }

    @MainActor
    func testBackgroundColorsForCelsiusTemperatures() async {
        // Create a view model with mock services
        let mockNetworkService = MockNetworkService()
        let mockStorageService = MockStorageService()
        mockStorageService.unitToReturn = .metric

        // Create weather info with specific temperatures to test
        let viewModel = WeatherViewModel(networkService: mockNetworkService, storageService: mockStorageService)

        // Test cold temperature in Celsius
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 5.0, unit: .metric)
        await viewModel.fetchWeather()
        viewModel.state = .loaded

        var weatherView = WeatherView(viewModel: viewModel)
        var colors = getBackgroundColors(from: weatherView)
        XCTAssertEqual(colors?[0], Color.indigo, "Cold temperature (5°C) should use indigo to purple gradient")
        XCTAssertEqual(colors?[1], Color.purple, "Cold temperature (5°C) should use indigo to purple gradient")

        // Test mild temperature in Celsius
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 15.0, unit: .metric)
        await viewModel.fetchWeather()
        viewModel.state = .loaded

        weatherView = WeatherView(viewModel: viewModel)
        colors = getBackgroundColors(from: weatherView)
        XCTAssertEqual(colors?[0], Color.blue, "Mild temperature (15°C) should use blue to cyan gradient")
        XCTAssertEqual(colors?[1], Color.cyan, "Mild temperature (15°C) should use blue to cyan gradient")

        // Test warm temperature in Celsius
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 25.0, unit: .metric)
        await viewModel.fetchWeather()
        viewModel.state = .loaded

        weatherView = WeatherView(viewModel: viewModel)
        colors = getBackgroundColors(from: weatherView)
        XCTAssertEqual(colors?[0], Color.orange, "Warm temperature (25°C) should use orange to yellow gradient")
        XCTAssertEqual(colors?[1], Color.yellow, "Warm temperature (25°C) should use orange to yellow gradient")

        // Test hot temperature in Celsius
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 35.0, unit: .metric)
        await viewModel.fetchWeather()
        viewModel.state = .loaded

        weatherView = WeatherView(viewModel: viewModel)
        colors = getBackgroundColors(from: weatherView)
        XCTAssertEqual(colors?[0], Color.red, "Hot temperature (35°C) should use red to orange gradient")
        XCTAssertEqual(colors?[1], Color.orange, "Hot temperature (35°C) should use red to orange gradient")
    }

    @MainActor
    func testBackgroundColorsForFahrenheitTemperatures() async {
        // Create a view model with mock services
        let mockNetworkService = MockNetworkService()
        let mockStorageService = MockStorageService()
        mockStorageService.unitToReturn = .imperial

        // Create weather info with specific temperatures to test
        let viewModel = WeatherViewModel(networkService: mockNetworkService, storageService: mockStorageService)

        // Test cold temperature in Fahrenheit
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 40.0, unit: .imperial)
        await viewModel.fetchWeather()
        viewModel.state = .loaded

        var weatherView = WeatherView(viewModel: viewModel)
        var colors = getBackgroundColors(from: weatherView)
        XCTAssertEqual(colors?[0], Color.indigo, "Cold temperature (40°F) should use indigo to purple gradient")
        XCTAssertEqual(colors?[1], Color.purple, "Cold temperature (40°F) should use indigo to purple gradient")

        // Test mild temperature in Fahrenheit
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 60.0, unit: .imperial)
        await viewModel.fetchWeather()
        viewModel.state = .loaded

        weatherView = WeatherView(viewModel: viewModel)
        colors = getBackgroundColors(from: weatherView)
        XCTAssertEqual(colors?[0], Color.blue, "Mild temperature (60°F) should use blue to cyan gradient")
        XCTAssertEqual(colors?[1], Color.cyan, "Mild temperature (60°F) should use blue to cyan gradient")

        // Test warm temperature in Fahrenheit
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 75.0, unit: .imperial)
        await viewModel.fetchWeather()
        viewModel.state = .loaded

        weatherView = WeatherView(viewModel: viewModel)
        colors = getBackgroundColors(from: weatherView)
        XCTAssertEqual(colors?[0], Color.orange, "Warm temperature (75°F) should use orange to yellow gradient")
        XCTAssertEqual(colors?[1], Color.yellow, "Warm temperature (75°F) should use orange to yellow gradient")

        // Test hot temperature in Fahrenheit
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 90.0, unit: .imperial)
        await viewModel.fetchWeather()
        viewModel.state = .loaded

        weatherView = WeatherView(viewModel: viewModel)
        colors = getBackgroundColors(from: weatherView)
        XCTAssertEqual(colors?[0], Color.red, "Hot temperature (90°F) should use red to orange gradient")
        XCTAssertEqual(colors?[1], Color.orange, "Hot temperature (90°F) should use red to orange gradient")
    }

    @MainActor
    func testConsistentBackgroundColorsBetweenUnits() async {
        // Create a view model with mock services
        let mockNetworkService = MockNetworkService()
        let mockStorageService = MockStorageService()

        // Create weather info with equivalent temperatures in different units
        let viewModel = WeatherViewModel(networkService: mockNetworkService, storageService: mockStorageService)

        // Test equivalent temperatures: ~77°F = 25°C (warm)
        mockStorageService.unitToReturn = .metric
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 25.0, unit: .metric)
        await viewModel.fetchWeather()
        viewModel.state = .loaded
        let celsiusView = WeatherView(viewModel: viewModel)
        let celsiusColors = getBackgroundColors(from: celsiusView)

        mockStorageService.unitToReturn = .imperial
        mockNetworkService.weatherInfoToReturn = createWeatherInfo(temperature: 77.0, unit: .imperial)
        await viewModel.fetchWeather()
        viewModel.state = .loaded
        let fahrenheitView = WeatherView(viewModel: viewModel)
        let fahrenheitColors = getBackgroundColors(from: fahrenheitView)

        // Both should show the same color gradient for equivalent temperatures
        XCTAssertEqual(celsiusColors?[0], fahrenheitColors?[0], "Equivalent temperatures should have the same background colors")
        XCTAssertEqual(celsiusColors?[1], fahrenheitColors?[1], "Equivalent temperatures should have the same background colors")
    }

    // Helper method to create weather info for testing
    private func createWeatherInfo(temperature: Double, unit: TemperatureUnit) -> WeatherInfo {
        return WeatherInfo(
            cityName: "Test City",
            condition: "Test Condition",
            temperature: temperature,
            feelsLike: temperature + 2.0,
            lastUpdated: Date(),
            weatherCode: 0,
            unit: unit,
            imageBaseUrl: "https://example.com/"
        )
    }
}

// Mock implementations needed for testing
class MockNetworkService: NetworkService {
    var weatherInfoToReturn: WeatherInfo?
    var errorToThrow: Error?
    var fetchWeatherCallCount = 0
    var lastRequestedCity: City?
    var lastRequestedUnit: TemperatureUnit?

    func fetchWeather(for city: City, unit: TemperatureUnit) async throws -> WeatherInfo {
        fetchWeatherCallCount += 1
        lastRequestedCity = city
        lastRequestedUnit = unit

        if let error = errorToThrow {
            throw error
        }

        guard let weatherInfo = weatherInfoToReturn else {
            throw WeatherError.invalidResponse
        }

        return weatherInfo
    }
}

class MockStorageService: StorageService {
    var cityToReturn: City = .toronto
    var unitToReturn: TemperatureUnit = .metric
    var savedCity: City?
    var savedUnit: TemperatureUnit?

    func getLastSelectedCity() -> City {
        return cityToReturn
    }

    func saveLastSelectedCity(_ city: City) {
        savedCity = city
    }

    func getPreferredUnit() -> TemperatureUnit {
        return unitToReturn
    }

    func savePreferredUnit(_ unit: TemperatureUnit) {
        savedUnit = unit
    }
}