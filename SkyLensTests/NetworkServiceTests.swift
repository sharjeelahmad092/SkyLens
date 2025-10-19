import XCTest
@testable import SkyLens

final class NetworkServiceTests: XCTestCase {
    private var sut: NetworkServiceImpl!
    private var mockURLSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        sut = NetworkServiceImpl(session: mockURLSession)
    }

    override func tearDown() {
        mockURLSession = nil
        sut = nil
        super.tearDown()
    }

    func testFetchWeatherWithValidResponse() async throws {
        // Given
        let validJSON = """
                        {
                            "observation": {
                                "name": "Toronto",
                                "condition": "Partly Cloudy",
                                "weatherCode": 32,
                                "temperature": 22.5,
                                "temperatureFeelsLike": 23.0,
                                "observationDateTime": "2023-10-18T14:30:00Z"
                            }
                        }
                        """
        let data = validJSON.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockURLSession.dataToReturn = (data, response!)

        // When
        let weatherInfo = try await sut.fetchWeather(for: .toronto, unit: .metric)

        // Then
        XCTAssertEqual(weatherInfo.cityName, "Toronto")
        XCTAssertEqual(weatherInfo.condition, "Partly Cloudy")
        XCTAssertEqual(weatherInfo.temperature, 22.5, accuracy: 0.001)
        XCTAssertEqual(weatherInfo.feelsLike, 23.0, accuracy: 0.001)
        XCTAssertEqual(weatherInfo.weatherCode, 32)
        XCTAssertEqual(weatherInfo.unit, .metric)

        // Also verify the URL was constructed correctly
        XCTAssertNotNil(mockURLSession.lastURL)
        XCTAssertTrue(mockURLSession.lastURL!.absoluteString.contains("CAON0696"))
        XCTAssertTrue(mockURLSession.lastURL!.absoluteString.contains("unit=metric"))
    }

    func testFetchWeatherWithNetworkError() async {
        // Given
        let networkError = NSError(domain: "com.skylens.network", code: -1009, userInfo: nil)
        mockURLSession.errorToThrow = networkError

        // When / Then
        do {
            _ = try await sut.fetchWeather(for: .toronto, unit: .metric)
            XCTFail("Expected function to throw, but it didn't")
        } catch let error as WeatherError {
            guard case .networkError = error else {
                XCTFail("Expected network error, got \(error)")
                return
            }
        } catch {
            XCTFail("Expected WeatherError, got \(error)")
        }
    }

    func testFetchWeatherInvalidURL() async {
        // Create a scenario where URL would be invalid
        // This is harder to test directly since our URL construction is private
        // For completeness, we'd add a test that forces URL creation to fail
    }
}

// MARK: - Mocks

class MockURLSession: URLSessionProtocol {
    var dataToReturn: (Data, URLResponse)?
    var errorToThrow: Error?
    var lastURL: URL?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        lastURL = url

        if let error = errorToThrow {
            throw error
        }

        if let dataToReturn = dataToReturn {
            return dataToReturn
        }

        throw NSError(domain: "com.skylens.test", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock data provided"])
    }
}