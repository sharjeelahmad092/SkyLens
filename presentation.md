# SkyLens Interview Presentation Guide

## Introduction (1-2 minutes)

"Hello, I'm Sharjeel Ahmad, and today I'd like to present SkyLens, a weather application I developed as part of this
assessment. SkyLens provides current weather information for five Canadian cities, with a clean, modern interface and
robust architecture."

"The app is built with Swift 5.10 and SwiftUI, following MVVM architecture. I'll walk you through the key features,
architectural decisions, technical implementation, and my approach to problem-solving."

## App Demo (2-3 minutes)

### Demo Script

1. **Start with the splash screen**
    - "The app begins with a simple, elegant splash screen showing the SkyLens brand."
    - "I've implemented this using SwiftUI animations for a smooth transition into the app."

2. **Show the main weather view**
    - "Here's the main weather view showing the current weather in Toronto."
    - "Notice the dynamic background that changes color based on temperature - cooler colors for lower temperatures and
      warmer colors for higher temperatures."
    - "The interface uses glass-morphism effects for a modern look while maintaining readability."

3. **Demonstrate city selection**
    - "Users can easily switch between five Canadian cities using this dropdown."
    - "Let me switch to Vancouver... notice how the UI updates with the new city's weather data and the background color
      adapts to Vancouver's cooler temperature."

4. **Show unit toggle**
    - "Users can toggle between Celsius and Fahrenheit with this button."
    - "The toggle smoothly updates all temperature values throughout the interface."

5. **Demonstrate the contact form**
    - "SkyLens also includes a contact form with validation."
    - "If I try to submit with empty fields, you'll see validation errors."
    - "Now I'll fill in valid information, and you can see the submission is simulated."

6. **Show iPad layout (if possible)**
    - "The app is fully responsive and works equally well on iPad."

## Architecture Overview (3-4 minutes)

### MVVM Implementation

"I implemented MVVM architecture for clear separation of concerns and better testability:"

- **Models**: "Core data structures representing weather and city information"
    - `WeatherInfo`: Domain model for weather data
    - `City`: Enum with the five supported cities
    - `TemperatureUnit`: Enum for metric/imperial units

- **Views**: "Pure presentation layer built with SwiftUI"
    - `WeatherView`: Displays weather information
    - `ContactView`: Handles the contact form

- **ViewModels**: "Business logic and state management"
    - `WeatherViewModel`: Manages weather state and API interactions
    - `ContactViewModel`: Handles form validation

Show this code snippet:

```swift
@MainActor
class WeatherViewModel: ObservableObject {
    @Published var state: ViewState = .loading
    @Published var selectedCity: City
    @Published var preferredUnit: TemperatureUnit
    
    // State management via enum
    enum ViewState {
        case loading
        case loaded
        case error(String)
    }
}
```

### Protocol-First Design

"I used protocol-first design for all services to enable dependency injection and facilitate testing:"

Show this code snippet:

```swift
protocol NetworkService {
    func fetchWeather(for city: City, unit: TemperatureUnit) async throws -> WeatherInfo
}

class NetworkServiceImpl: NetworkService {
    // Implementation using URLSession
}
```

"This approach made it easy to create mock implementations for testing."

## Key Technical Decisions (3-4 minutes)

### Modern Concurrency

"I leveraged Swift's modern async/await for clean, structured concurrency:"

```swift
func fetchWeather() async {
    state = .loading
    do {
        let info = try await networkService.fetchWeather(for: selectedCity, unit: preferredUnit)
        weatherInfo = info
        state = .loaded
    } catch let error as WeatherError {
        state = .error(error.userFriendlyMessage)
    }
}
```

"This approach eliminates callback hell and makes the code more readable and maintainable."

### Persistent Storage

"For persistence, I used a protocol-based approach with UserDefaults:"

```swift
protocol StorageService {
    func getLastSelectedCity() -> City
    func saveLastSelectedCity(_ city: City)
    func getPreferredUnit() -> TemperatureUnit
    func savePreferredUnit(_ unit: TemperatureUnit)
}
```

"This simple approach is perfect for the app's needs without overengineering."

### Error Handling

"I implemented a comprehensive error handling system:"

```swift
enum WeatherError: Error {
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case invalidURL
    
    var userFriendlyMessage: String {
        // User-friendly messages for each case
    }
}
```

"This approach ensures users see helpful error messages while maintaining detailed error information for debugging."

## UI Design Decisions (2-3 minutes)

### Dynamic UI

"The UI dynamically responds to temperature changes:"

```swift
private var backgroundColors: [Color] {
    switch viewModel.temperatureValue {
    case 30...:
        return [Color.red, Color.orange]
    case 20..<30:
        return [Color.orange, Color.yellow]
    case 10..<20:
        return [Color.blue, Color.cyan]
    case ..<10:
        return [Color.indigo, Color.purple]
    default:
        return [Color.blue, Color.indigo]
    }
}
```

### Glass-Morphism Effects

"I used SwiftUI's `.ultraThinMaterial` for a modern glass effect:"

```swift
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
.shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
```

### Responsive Design

"The app uses flexible layouts that adapt to different screen sizes:"

- Proper use of SwiftUI containers (VStack, HStack, etc.)
- Responsive grid for weather details
- Adaptable font sizes and spacing

## Testing Approach (2-3 minutes)

"I implemented comprehensive testing at multiple levels:"

### Unit Tests

- Tests for `WeatherViewModel` and state transitions
- Tests for the `NetworkService` implementation
- Tests for `Contact` validation logic

```swift
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
}
```

### UI Tests

"I added UI tests for critical user flows:"

```swift
func testContactFormValidation() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Navigate and test form validation
    // ...
}
```

## Challenges and Solutions (2-3 minutes)

### API Integration Challenge

"The API response format was different from what I initially expected:"

- **Challenge**: The actual API response nested data differently than anticipated
- **Solution**: Created a flexible mapping layer in the NetworkService

```swift
private func mapToWeatherInfo(_ response: WeatherResponse, unit: TemperatureUnit) -> WeatherInfo {
    // Map from API response to domain model
}
```

### Concurrency Management

"Ensuring proper UI updates from background operations:"

- **Challenge**: SwiftUI views need to update on the main thread
- **Solution**: Used `@MainActor` annotation and proper task management

```swift
@MainActor
class WeatherViewModel: ObservableObject {
    // ViewModel implementation
}
```

### UI Testing Stability

- **Challenge**: UI tests can be brittle with timing issues
- **Solution**: Made tests more resilient with proper waits and flexible element detection

```swift
XCTAssertTrue(app.buttons["Refresh"].waitForExistence(timeout: 5))
```

## If I Had More Time... (1-2 minutes)

"Given more time, I would enhance the app with:"

- **Weather Forecast**: Show multi-day forecasts
- **Location Detection**: Get weather for current location
- **Detailed Weather Data**: Add more weather metrics (humidity, wind, etc.)
- **Offline Support**: Add robust caching for offline use
- **Animations**: Weather condition animations (rain, snow, etc.)
- **Localization**: Support for multiple languages
- **Accessibility**: Enhanced VoiceOver support

## Conclusion (1 minute)

"To summarize, SkyLens demonstrates:"

- **Modern iOS Development**: Using SwiftUI, MVVM, and async/await
- **Clean Architecture**: With separation of concerns and dependency injection
- **User-Focused Design**: Dynamic UI that responds to weather conditions
- **Quality Assurance**: Comprehensive test coverage

"The project showcases my approach to building maintainable, testable iOS applications with a focus on both code quality
and user experience."

"Thank you for your time. I'd be happy to answer any questions about my implementation decisions or discuss any aspect
of the project in more detail."

## Potential Questions and Answers

### Why did you choose MVVM over other architectural patterns?

"I chose MVVM because it pairs exceptionally well with SwiftUI's declarative paradigm. The @Published properties in the
ViewModel naturally connect to the View, creating a reactive relationship. It also provides clear separation of
concerns, with the ViewModel handling business logic and state management while the View focuses solely on presentation.
This separation makes the code more testable, as evidenced by my unit tests."

### How would you scale this app for more features?

"I'd maintain the modular approach while expanding the architecture. For more complex navigation, I might introduce a
coordinator pattern. If data requirements grew, I'd consider a more robust persistence layer like Core Data with a
repository pattern. For expanded network needs, I'd enhance the NetworkService with request combining and caching
strategies. The protocol-first design I've established would make these enhancements straightforward."

### What was the most challenging part of the project?

"Adapting to the actual API response format was the most interesting challenge. I had to design a flexible mapping layer
that could handle the nested structure of the response. This reinforced the value of separating the API response models
from domain models, allowing the app to work with a clean internal representation regardless of the external API
structure."

### How would you handle offline support?

"I'd implement a more robust caching strategy. While the app currently uses URLCache for basic HTTP caching, I'd add a
persistent cache layer, potentially using Core Data or a lightweight solution like SQLite. This would store parsed
WeatherInfo objects rather than raw responses. I'd update the NetworkService to check this cache first, with appropriate
staleness checks, before making network requests."

### What aspects of your code are you most proud of?

"I'm particularly proud of the error handling system. It provides detailed error types for debugging while offering
user-friendly messages. I'm also satisfied with the state management approach using the ViewState enum, which made
handling loading, success, and error states clean and predictable. Finally, I'm pleased with how the protocol-first
design enabled comprehensive unit testing without complex mocking frameworks."