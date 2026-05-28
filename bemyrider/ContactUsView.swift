//
//  ContactUsView.swift
//  bemyrider
//
//  Modernized SwiftUI view for Contact Us screen
//  with gradient header and form layout.
//

import SwiftUI

struct ContactUsView: View {

    @ObservedObject var viewModel: ContactUsViewModel
    @State private var showCountryPicker = false

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            formContent
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            viewModel.loadCountries()
            viewModel.loadUserData()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: SwiftUI.Text(""), message: SwiftUI.Text(viewModel.alertMessage ?? "") , dismissButton: .default(SwiftUI.Text("OK")))
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerSheet(
                countries: viewModel.countries,
                selectedCode: $viewModel.countryCode
            )
        }
    }

    // MARK: - Header with gradient

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: { viewModel.onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(SwiftUI.Color.white.opacity(0.18))
                        .clipShape(Circle())
                }

                SwiftUI.Text("Contattaci")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            SwiftUI.Text("Scrivici per qualsiasi domanda")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.gradientStart,
                    AppTheme.Colors.gradientMid,
                    AppTheme.Colors.gradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Form content

    private var formContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Name fields
                HStack(spacing: 12) {
                    formField("Nome", text: $viewModel.firstName, placeholder: "Mario")
                    formField("Cognome", text: $viewModel.lastName, placeholder: "Rossi")
                }

                // Email
                formField("Email", text: $viewModel.email, placeholder: "mario@esempio.com", keyboardType: .emailAddress)

                // Phone with country code
                phoneField

                // Message
                messageField

                // Submit button
                submitButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Form fields

    private func formField(_ title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)

            TextField(placeholder, text: text)
                .font(.system(size: 14, weight: .medium))
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disableAutocorrection(keyboardType == .emailAddress)
                .padding(14)
                .background(SwiftUI.Color.white)
                .cornerRadius(12)
        }
    }

    // MARK: - Phone field

    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Telefono")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)

            HStack(spacing: 8) {
                Button {
                    showCountryPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.countryCode)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textDark)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textCaption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.background)
                    .cornerRadius(12)
                }

                TextField("Numero telefono", text: $viewModel.phone)
                    .font(.system(size: 14, weight: .medium))
                    .keyboardType(.phonePad)
                    .padding(14)
                    .background(SwiftUI.Color.white)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Message field

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Messaggio")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)

            TextEditor(text: $viewModel.message)
                .font(.system(size: 14, weight: .medium))
                .frame(minHeight: 120)
                .padding(10)
                .background(SwiftUI.Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.message.isEmpty ? AppTheme.Colors.separator : SwiftUI.Color.clear, lineWidth: 1)
                )
        }
    }

    // MARK: - Submit button

    private var submitButton: some View {
        Button {
            viewModel.submitContact()
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Invia Messaggio")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isValid ? AppTheme.Colors.orange : AppTheme.Colors.orange.opacity(0.5))
            .cornerRadius(12)
        }
        .disabled(!viewModel.isValid || viewModel.isLoading)
    }
}

// MARK: - Country Picker Sheet

private struct CountryPickerSheet: View {

    let countries: [Country]
    @Binding var selectedCode: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(countries, id: \.country_code) { country in
                    Button {
                        selectedCode = country.country_code
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Text(country.country_name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textDark)

                            Spacer()

                            Text(country.country_code)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.Colors.textCaption)

                            if selectedCode == country.country_code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.Colors.purple)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Seleziona Paese")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
