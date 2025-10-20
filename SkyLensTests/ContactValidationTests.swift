//
//  ContactValidationTests.swift
//  SkyLensTests
//
//  Created by Sharjeel Ahmad on 2025-10-18.
//

import XCTest
@testable import SkyLens

final class ContactValidationTests: XCTestCase {

    func testEmptyContact() {
        // Given
        let contact = Contact()

        // When
        let errors = contact.validate()

        // Then
        XCTAssertEqual(errors.count, 3)
        XCTAssertTrue(errors.contains(.nameEmpty))
        XCTAssertTrue(errors.contains(.emailEmpty))
        XCTAssertTrue(errors.contains(.phoneEmpty))
    }

    func testValidContact() {
        // Given
        var contact = Contact()
        contact.name = "John Smith"
        contact.email = "john@example.com"
        contact.phone = "1234567890"

        // When
        let errors = contact.validate()

        // Then
        XCTAssertTrue(errors.isEmpty, "Expected no validation errors")
    }

    func testNameValidation() {
        // Short name
        var contact = Contact(name: "Joe", email: "joe@example.com", phone: "1234567890")
        var errors = contact.validate()
        XCTAssertTrue(errors.contains(.nameTooShort))

        // Name with digits
        contact = Contact(name: "John123", email: "john@example.com", phone: "1234567890")
        errors = contact.validate()
        XCTAssertTrue(errors.contains(.nameContainsDigits))
    }

    func testEmailValidation() {
        // Invalid email format
        var contact = Contact(name: "John Smith", email: "not-an-email", phone: "1234567890")
        var errors = contact.validate()
        XCTAssertTrue(errors.contains(.emailInvalid))

        // Valid email
        contact = Contact(name: "John Smith", email: "john.smith@example.com", phone: "1234567890")
        errors = contact.validate()
        XCTAssertFalse(errors.contains(.emailInvalid))
    }

    func testPhoneValidation() {
        // Phone with non-digit characters
        var contact = Contact(name: "John Smith", email: "john@example.com", phone: "123-456-7890")
        var errors = contact.validate()
        XCTAssertTrue(errors.contains(.phoneInvalid))

        // Valid phone (digits only)
        contact = Contact(name: "John Smith", email: "john@example.com", phone: "1234567890")
        errors = contact.validate()
        XCTAssertFalse(errors.contains(.phoneInvalid))
    }
}