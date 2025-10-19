import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel: WeatherViewModel

    init(viewModel: WeatherViewModel? = nil) {
        let vm = viewModel ?? WeatherViewModel(
            networkService: NetworkServiceImpl(),
            storageService: StorageServiceImpl()
        )
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: backgroundColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                        // Main Weather Content
                        switch viewModel.state {
                        case .loading:
                            loadingView
                        case .loaded:
                            mainWeatherSection
                        case .error(let message):
                            errorView(message: message)
                        }
                    }
                }
                .refreshable {
                    await viewModel.fetchWeather()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task {
                await viewModel.fetchWeather()
            }
        }
    }

    // MARK: - Background Colors
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

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // City Selector
            citySelector

            Spacer()

            // Unit Toggle
            unitToggleButton
        }
    }

    private var citySelector: some View {
        Menu {
            Picker("City", selection: $viewModel.selectedCity) {
                ForEach(City.allCases) { city in
                    Text(city.displayName).tag(city)
                }
            }
            .pickerStyle(.inline)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                Text(viewModel.selectedCity.displayName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .onChange(of: viewModel.selectedCity) {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.changeCity(viewModel.selectedCity)
            }
        }
    }

    private var unitToggleButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                viewModel.toggleUnit()
            }
        }) {
            Text(viewModel.unitSymbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Main Weather Section
    private var mainWeatherSection: some View {
        LazyVStack(spacing: 32) {
            // Current Weather Card
            currentWeatherCard
                .padding(.horizontal, 20)
                .padding(.top, 40)

            // Weather Details Grid
            weatherDetailsGrid
                .padding(.horizontal, 20)

            // Last Updated
            lastUpdatedSection
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
    }

    private var currentWeatherCard: some View {
        VStack(spacing: 24) {
            // Weather Icon
            if let iconURL = viewModel.weatherIconURL {
                AsyncImage(url: iconURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 160, height: 160)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
                    } else if phase.error != nil {
                        weatherIconFallback
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .frame(width: 140, height: 140)
                    }
                }
            } else {
                weatherIconFallback
            }

            // Temperature Display
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 4) {
                    Text(viewModel.temperature)
                        .font(.system(size: 72, weight: .thin, design: .rounded))
                        .foregroundColor(.white)

                    Text(viewModel.unitSymbol)
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                }

                Text(viewModel.condition)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
    }

    private var weatherIconFallback: some View {
        Image(systemName: "cloud.sun.fill")
            .font(.system(size: 80, weight: .light))
            .foregroundColor(.white)
            .frame(width: 140, height: 140)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 160, height: 160)
            )
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
    }

    private var weatherDetailsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            // Feels Like Temperature
            WeatherDetailCard(
                title: "Feels Like",
                value: "\(viewModel.feelsLike)\(viewModel.unitSymbol)",
                icon: "thermometer.medium",
                iconColor: .orange
            )

            // City Name
            WeatherDetailCard(
                title: "Location",
                value: viewModel.cityName,
                icon: "location.fill",
                iconColor: .blue
            )
        }
    }

    private var lastUpdatedSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.fetchWeather()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                    Text("Refresh")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }

            Text("Last updated: \(viewModel.lastUpdated)")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Loading State
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)

            Text("Loading weather data...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    // MARK: - Error State
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.yellow)

            Text("Weather Unavailable")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)

            Text(message)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button(action: {
                Task {
                    await viewModel.fetchWeather()
                }
            }) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Weather Detail Card Component
struct WeatherDetailCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                Text(value)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    WeatherView()
}
