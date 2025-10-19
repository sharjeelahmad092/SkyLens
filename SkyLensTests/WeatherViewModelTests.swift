import XCTest
@testable import SkyLens

@MainActor
final class WeatherViewModelTests: XCTestCase {
    private var mockNetworkService: MockNetworkService!
    private var mockStorageService: MockStorageService!
    private var sut: WeatherViewModel!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockStorageService = MockStorageService()
        sut = WeatherViewModel(networkService: mockNetworkService, storageService: mockStorageService)
    }

    override func tearDown() {
        mockNetworkService = nil
        mockStorageService = nil
        sut = nil
        super.tearDown()
    }

    func testFetchWeatherSuccess() async {
        // Given
        let weatherInfo = createSampleWeatherInfo()
        mockNetworkService.weatherInfoToReturn = weatherInfo

        // When
        await sut.fetchWeather()

        // Then
        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.cityName, "Toronto")
        XCTAssertEqual(sut.condition, "Sunny")
        XCTAssertEqual(sut.temperature, "25.0")
        XCTAssertEqual(sut.feelsLike, "27.0")
        XCTAssertEqual(mockNetworkService.fetchWeatherCallCount, 1)
        XCTAssertEqual(mockNetworkService.lastRequestedCity, .toronto)
        XCTAssertEqual(mockNetworkService.lastRequestedUnit, .metric)
    }

    func testFetchWeatherError() async {
        // Given
        mockNetworkService.errorToThrow = WeatherError.networkError(NSError(domain: "test", code: 0))

        // When
        await sut.fetchWeather()

        // Then
        guard case let .error(message) = sut.state else {
            XCTFail("Expected error state")
            return
        }
        XCTAssertEqual(message, WeatherError.networkError(NSError(domain: "test", code: 0)).userFriendlyMessage)
    }

    func testChangeCity() async {
        // Given
        let weatherInfo = createSampleWeatherInfo()
        mockNetworkService.weatherInfoToReturn = weatherInfo

        // When
        sut.changeCity(.vancouver)

        // Then
        XCTAssertEqual(sut.selectedCity, .vancouver)
        XCTAssertEqual(mockStorageService.savedCity, .vancouver)

        // Wait a bit for the task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockNetworkService.lastRequestedCity, .vancouver)
    }

    func testToggleUnit() async {
        // Given
        let weatherInfo = createSampleWeatherInfo()
        mockNetworkService.weatherInfoToReturn = weatherInfo
        sut.preferredUnit = .metric

        // When
        sut.toggleUnit()

        // Then
        XCTAssertEqual(sut.preferredUnit, .imperial)
        XCTAssertEqual(mockStorageService.savedUnit, .imperial)

        // Wait a bit for the task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockNetworkService.lastRequestedUnit, .imperial)
    }

    // MARK: - Helpers

    private func createSampleWeatherInfo() -> WeatherInfo {
        return WeatherInfo(
            cityName: "Toronto",
            condition: "Sunny",
            temperature: 25.0,
            feelsLike: 27.0,
            lastUpdated: Date(),
            weatherCode: 32,
            unit: .metric
        )
    }
}

// MARK: - Mocks

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

// MARK: - Extensions for Equatable

extension WeatherViewModel.ViewState: Equatable {
    public static func ==(lhs: WeatherViewModel.ViewState, rhs: WeatherViewModel.ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}