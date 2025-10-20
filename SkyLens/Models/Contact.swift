//
//  Contact.swift
//  SkyLens
//
//  Created by Sharjeel Ahmad on 2025-10-18.
//

import Foundation

struct Contact {
    var name: String = ""
    var email: String = ""
    var phone: String = ""

    func validate() -> [ContactValidationError] {
        var errors: [ContactValidationError] = []

        // Validate name
        if name.isEmpty {
            errors.append(.nameEmpty)
        } else if name.count < 4 {
            errors.append(.nameTooShort)
        } else if name.contains(where: { $0.isNumber }) {
            errors.append(.nameContainsDigits)
        }

        // Validate email
        if email.isEmpty {
            errors.append(.emailEmpty)
        } else if !isValidEmail(email) {
            errors.append(.emailInvalid)
        }

        // Validate phone
        if phone.isEmpty {
            errors.append(.phoneEmpty)
        } else if !isValidPhone(phone) {
            errors.append(.phoneInvalid)
        }

        return errors
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    private func isValidPhone(_ phone: String) -> Bool {
        return phone.allSatisfy {
            $0.isNumber
        }
    }
}

enum ContactValidationError: Error, Identifiable {
    case nameEmpty
    case nameTooShort
    case nameContainsDigits
    case emailEmpty
    case emailInvalid
    case phoneEmpty
    case phoneInvalid

    var id: String {
        localizedDescription
    }

    var localizedDescription: String {
        switch self {
        case .nameEmpty:
            return "Name cannot be empty"
        case .nameTooShort:
            return "Name must be at least 4 characters"
        case .nameContainsDigits:
            return "Name cannot contain numbers"
        case .emailEmpty:
            return "Email cannot be empty"
        case .emailInvalid:
            return "Please enter a valid email address"
        case .phoneEmpty:
            return "Phone number cannot be empty"
        case .phoneInvalid:
            return "Phone must contain digits only"
        }
    }
}