//
//  ContactView.swift
//  SkyLens
//
//  Created by Sharjeel Ahmad on 2025-10-18.
//

import SwiftUI

struct ContactView: View {
    @StateObject private var viewModel = ContactViewModel()
    @State private var selectedField: FormField? = nil
    @Environment(\.colorScheme) private var colorScheme

    enum FormField {
        case name, email, phone
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                headerSection

                // Form Card
                formCard

                // Submit Button
                submitButton
                    .padding(.horizontal, 20)
                    .disabled(viewModel.isSubmitting)
            }
            .padding(.vertical, 32)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
        )
        .navigationTitle("Contact Us")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Message Sent", isPresented: $viewModel.showSuccessAlert) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text("Thank you for your message! We'll get back to you soon.")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Contact Us")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

            Text("Get in Touch")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("We'd love to hear from you")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    // MARK: - Form Card
    private var formCard: some View {
        VStack(spacing: 24) {
            nameField
            emailField
            phoneField
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 20)
    }

    // MARK: - Form Fields
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.blue)
                Text("Name")
                    .foregroundColor(.primary.opacity(0.8))
            }
            .font(.system(size: 16, weight: .medium))

            TextField("", text: $viewModel.contact.name)
            .placeholder(when: viewModel.contact.name.isEmpty) {
                Text("Your name").foregroundColor(.secondary.opacity(0.5))
            }
            .font(.system(size: 17))
            .padding(12)
            .background(formFieldBackground(for: .name))
            .cornerRadius(10)
            .foregroundColor(.primary)
                .textContentType(.name)
                .autocorrectionDisabled()
            .onTapGesture {
                selectedField = .name
            }

            ForEach(viewModel.validationErrors.filter {
                switch $0 {
                case .nameEmpty, .nameTooShort, .nameContainsDigits:
                    return true
                default:
                    return false
                }
            }, id: \.id) { error in
                errorText(error: error)
            }
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.green)
                Text("Email")
                    .foregroundColor(.primary.opacity(0.8))
            }
            .font(.system(size: 16, weight: .medium))

            TextField("", text: $viewModel.contact.email)
            .placeholder(when: viewModel.contact.email.isEmpty) {
                Text("your.email@example.com").foregroundColor(.secondary.opacity(0.5))
            }
            .font(.system(size: 17))
            .padding(12)
            .background(formFieldBackground(for: .email))
            .cornerRadius(10)
            .foregroundColor(.primary)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            .onTapGesture {
                selectedField = .email
            }

            ForEach(viewModel.validationErrors.filter {
                switch $0 {
                case .emailEmpty, .emailInvalid:
                    return true
                default:
                    return false
                }
            }, id: \.id) { error in
                errorText(error: error)
            }
        }
    }

    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.orange)
                Text("Phone")
                    .foregroundColor(.primary.opacity(0.8))
            }
            .font(.system(size: 16, weight: .medium))

            TextField("", text: $viewModel.contact.phone)
            .placeholder(when: viewModel.contact.phone.isEmpty) {
                Text("Your phone number").foregroundColor(.secondary.opacity(0.5))
            }
            .font(.system(size: 17))
            .padding(12)
            .background(formFieldBackground(for: .phone))
            .cornerRadius(10)
            .foregroundColor(.primary)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
            .onTapGesture {
                selectedField = .phone
            }

            ForEach(viewModel.validationErrors.filter {
                switch $0 {
                case .phoneEmpty, .phoneInvalid:
                    return true
                default:
                    return false
                }
            }, id: \.id) { error in
                errorText(error: error)
            }
        }
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: {
            Task {
                await viewModel.submitForm()
            }
        }) {
            HStack(spacing: 10) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Sending...")
                        .font(.system(size: 18, weight: .semibold))
                } else {
                    Image(systemName: "paperplane.fill")
                    Text("Submit")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isSubmitting ? .gray.opacity(0.7) : .blue)
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: - Helper Views
    private func formFieldBackground(for field: FormField) -> some View {
        let isSelected = selectedField == field
        let hasError = viewModel.validationErrors.contains(where: {
            switch ($0, field) {
            case (.nameEmpty, .name),
                 (.nameTooShort, .name),
                 (.nameContainsDigits, .name):
                return true
            case (.emailEmpty, .email),
                 (.emailInvalid, .email):
                return true
            case (.phoneEmpty, .phone),
                 (.phoneInvalid, .phone):
                return true
            default:
                return false
            }
        })

        return RoundedRectangle(cornerRadius: 10)
            .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(hasError ? Color.red : (isSelected ? Color.blue : Color.gray.opacity(0.3)), lineWidth: hasError || isSelected ? 2 : 1)
            )
    }

    private func errorText(error: ContactValidationError) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12))
            Text(error.localizedDescription)
                .font(.system(size: 12))
        }
        .foregroundColor(.red)
        .padding(.leading, 4)
    }
}

// MARK: - Helper Extensions
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    NavigationStack {
        ContactView()
    }
}