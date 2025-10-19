import Foundation

// MARK: - API Response Models

struct WeatherResponse: Codable {
    let observation: Observation
    let display: Display

    struct Observation: Codable {
        let time: TimeInfo
        let weatherCode: WeatherCode
        let temperature: Double
        let feelsLike: Double
        // Other fields we might need but aren't using yet
        let dewPoint: Double?
        let wind: Wind?
        let relativeHumidity: Int?
        let pressure: Pressure?
        let visibility: Double?
        let ceiling: Double?

        struct TimeInfo: Codable {
            let local: String
            let utc: String
        }

        struct WeatherCode: Codable {
            let value: String
            let icon: Int
            let text: String
            let bgimage: String?
            let overlay: String?
        }

        struct Wind: Codable {
            let direction: String
            let speed: Int
            let gust: Int?
        }

        struct Pressure: Codable {
            let value: Double
            let trendKey: Int?
        }
    }

    struct Display: Codable {
        let imageUrl: String
        let unit: Units

        struct Units: Codable {
            let temperature: String
            let dewPoint: String?
            let wind: String?
            let relativeHumidity: String?
            let pressure: String?
            let visibility: String?
            let ceiling: String?
        }
    }
}

// MARK: - Domain Models

struct WeatherInfo {
    let cityName: String
    let condition: String
    let temperature: Double
    let feelsLike: Double
    let lastUpdated: Date
    let weatherCode: Int
    let unit: TemperatureUnit
    let imageBaseUrl: String

    var iconURL: URL? {
        URL(string: "\(imageBaseUrl)\(weatherCode).png")
    }
}

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case metric = "metric"
    case imperial = "imperial"

    var id: String {
        rawValue
    }

    var symbol: String {
        switch self {
        case .metric: return "°C"
        case .imperial: return "°F"
        }
    }
}

enum City: String, CaseIterable, Identifiable {
    case toronto = "CAON0696"
    case montreal = "CAON0423"
    case ottawa = "CAON0512"
    case vancouver = "CABC0308"
    case calgary = "CAAB0049"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .toronto: return "Toronto"
        case .montreal: return "Montreal"
        case .ottawa: return "Ottawa"
        case .vancouver: return "Vancouver"
        case .calgary: return "Calgary"
        }
    }
}

// MARK: - Errors

enum WeatherError: Error {
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case invalidURL

    var userFriendlyMessage: String {
        switch self {
        case .networkError:
            return "Unable to load weather data. Please check your connection and try again."
        case .decodingError, .invalidResponse:
            return "There was a problem processing the weather data. Please try again later."
        case .invalidURL:
            return "Invalid weather data source. Please contact support."
        }
    }
}