import Foundation
import os.log

protocol NetworkService {
    func fetchWeather(for city: City, unit: TemperatureUnit) async throws -> WeatherInfo
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
}

class NetworkServiceImpl: NetworkService {
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    private var selectedCity: City = .toronto // Default

    init(session: URLSessionProtocol = URLSession.shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder

        // Configure decoder for date formatting
        decoder.dateDecodingStrategy = .iso8601
    }

    func fetchWeather(for city: City, unit: TemperatureUnit) async throws -> WeatherInfo {
        // Store the city for reference in mapToWeatherInfo
        self.selectedCity = city

        guard let url = makeWeatherURL(for: city, unit: unit) else {
            throw WeatherError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                throw WeatherError.invalidResponse
            }

            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            return mapToWeatherInfo(weatherResponse, unit: unit)
        } catch let error as DecodingError {
            throw WeatherError.decodingError(error)
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.networkError(error)
        }
    }

    private func makeWeatherURL(for city: City, unit: TemperatureUnit) -> URL? {
        let baseURL = "https://weatherapi.pelmorex.com/api/v1/observation/placecode/"
        let urlString = "\(baseURL)\(city.rawValue)?unit=\(unit.rawValue)"
        return URL(string: urlString)
    }

    private func mapToWeatherInfo(_ response: WeatherResponse, unit: TemperatureUnit) -> WeatherInfo {
        let observation = response.observation

        // Extract city name from the selected city since API doesn't provide it
        let cityName = getCityName(for: selectedCity)

        // Create ISO8601 date formatter to parse the time string
        let dateFormatter = ISO8601DateFormatter()
        let lastUpdated = dateFormatter.date(from: observation.time.utc) ?? Date()

        // Get the base URL for weather icons
        let imageBaseUrl = response.display.imageUrl

        return WeatherInfo(
            cityName: cityName,
            condition: observation.weatherCode.text,
            temperature: observation.temperature,
            feelsLike: observation.feelsLike,
            lastUpdated: lastUpdated,
            weatherCode: observation.weatherCode.icon,
            unit: unit,
            imageBaseUrl: imageBaseUrl
        )
    }

    // Helper method to get city name since API doesn't provide it
    private func getCityName(for city: City) -> String {
        return city.displayName
    }
}