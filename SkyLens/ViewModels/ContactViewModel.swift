//
//  ContactViewModel.swift
//  SkyLens
//
//  Created by Sharjeel Ahmad on 2025-10-18.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ContactViewModel: ObservableObject {
    @Published var contact = Contact()
    @Published var validationErrors: [ContactValidationError] = []
    @Published var showSuccessAlert = false
    @Published var isSubmitting = false

    func submitForm() async {
        // First validate the form
        validationErrors = contact.validate()
        guard validationErrors.isEmpty else {
            return
        }

        // Simulate network request
        isSubmitting = true

        // Simulate a delay for the submission
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Show success
        isSubmitting = false
        showSuccessAlert = true

        // Reset the form
        contact = Contact()
    }

    func resetForm() {
        contact = Contact()
        validationErrors = []
        showSuccessAlert = false
    }

}