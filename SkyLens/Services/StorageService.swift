import Foundation
import Combine

protocol StorageService {
    func getLastSelectedCity() -> City
    func saveLastSelectedCity(_ city: City)
    func getPreferredUnit() -> TemperatureUnit
    func savePreferredUnit(_ unit: TemperatureUnit)
}

class StorageServiceImpl: StorageService {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let lastSelectedCity = "lastSelectedCity"
        static let preferredUnit = "preferredUnit"
    }

    func getLastSelectedCity() -> City {
        guard let cityString = defaults.string(forKey: Keys.lastSelectedCity),
              let city = City(rawValue: cityString)
        else {
            return .toronto // Default to Toronto
        }
        return city
    }

    func saveLastSelectedCity(_ city: City) {
        defaults.setValue(city.rawValue, forKey: Keys.lastSelectedCity)
    }

    func getPreferredUnit() -> TemperatureUnit {
        guard let unitString = defaults.string(forKey: Keys.preferredUnit),
              let unit = TemperatureUnit(rawValue: unitString)
        else {
            return .metric // Default to metric
        }
        return unit
    }

    func savePreferredUnit(_ unit: TemperatureUnit) {
        defaults.setValue(unit.rawValue, forKey: Keys.preferredUnit)
    }
}