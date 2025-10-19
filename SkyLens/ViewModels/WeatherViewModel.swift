import Foundation
import SwiftUI
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var state: ViewState = .loading
    @Published var selectedCity: City
    @Published var preferredUnit: TemperatureUnit

    private let networkService: NetworkService
    private let storageService: StorageService
    private var weatherInfo: WeatherInfo?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    enum ViewState {
        case loading
        case loaded
        case error(String)
    }

    init(
        networkService: NetworkService,
        storageService: StorageService
    ) {
        self.networkService = networkService
        self.storageService = storageService
        self.selectedCity = storageService.getLastSelectedCity()
        self.preferredUnit = storageService.getPreferredUnit()
    }

    func fetchWeather() async {
        state = .loading
        do {
            let info = try await networkService.fetchWeather(for: selectedCity, unit: preferredUnit)
            weatherInfo = info
            state = .loaded
        } catch let error as WeatherError {
            state = .error(error.userFriendlyMessage)
        } catch {
            state = .error("An unexpected error occurred. Please try again.")
        }
    }

    // Combined method to select city and fetch weather in one operation
    func selectCity(_ city: City) async {
        guard city != selectedCity else {
            return
        }

        selectedCity = city
        storageService.saveLastSelectedCity(city)
        await fetchWeather()
    }

    func toggleUnitAndFetch() async {
        let newUnit: TemperatureUnit = preferredUnit == .metric ? .imperial : .metric
        preferredUnit = newUnit
        storageService.savePreferredUnit(newUnit)
        await fetchWeather()
    }

    // MARK: - Accessor methods

    var cityName: String {
        weatherInfo?.cityName ?? selectedCity.displayName
    }

    var condition: String {
        weatherInfo?.condition ?? ""
    }

    var temperature: String {
        guard let temp = weatherInfo?.temperature else {
            return "--"
        }
        return String(format: "%.1f", temp)
    }

    var temperatureValue: Double {
        weatherInfo?.temperature ?? 0.0
    }

    var feelsLike: String {
        guard let feels = weatherInfo?.feelsLike else {
            return "--"
        }
        return String(format: "%.1f", feels)
    }

    var lastUpdated: String {
        guard let date = weatherInfo?.lastUpdated else {
            return "--"
        }
        return dateFormatter.string(from: date)
    }

    var unitSymbol: String {
        return self.preferredUnit.symbol
    }

    var weatherIconURL: URL? {
        weatherInfo?.iconURL
    }
}

// MARK: - Extensions for Equatable (needed for testing)

extension WeatherViewModel.ViewState: Equatable {
    public static func ==(lhs: WeatherViewModel.ViewState, rhs: WeatherViewModel.ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.loaded, .loaded): return true
        case (.error(let lhsMessage), .error(let rhsMessage)): return lhsMessage == rhsMessage
        default: return false
        }
    }
}