//
//  EditProfileCustomerView.swift
//  bemyrider
//
//  SwiftUI replacement for EditProfileCustomerVC.
//  With gradient header and modern card-based layout.
//

import SwiftUI

struct EditProfileCustomerView: View {

    @ObservedObject var viewModel: EditProfileCustomerViewModel
    var showHeader: Bool = true

    var body: some View {
        Group {
            if showHeader {
                ZStack(alignment: .top) {
                    // Background gradient that extends behind status bar and to bottom
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.gradientStart,
                            AppTheme.Colors.gradientMid,
                            AppTheme.Colors.gradientEnd
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    // Content
                    ScrollView {
                        VStack(spacing: 0) {
                            headerContent
                            formContent
                        }
                        .background(SwiftUI.Color.clear)
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        photoSection
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        formContent
                    }
                }
                .background(AppTheme.Colors.background.ignoresSafeArea())
            }
        }
        .disabled(viewModel.isLoading)
        .alert(isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) {
            Alert(
                title: SwiftUI.Text(""),
                message: SwiftUI.Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(SwiftUI.Text("OK")) { viewModel.alertMessage = nil }
            )
        }
    }

    // MARK: - Header Content

    private var headerContent: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { viewModel.onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(SwiftUI.Color.white.opacity(0.18))
                        .clipShape(Circle())
                }

                SwiftUI.Text("Modifica Profilo")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            // Photo section
            photoSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    // MARK: - Form content

    private var formContent: some View {
        VStack(spacing: 20) {
            // Personal Info Card
            personalSection

            // Company Info Card
            companySection

            // Payment Method Card
            paymentSection

            // Save Button
            buttonsSection
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }   

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(spacing: 8) {
            SwiftUI.Button { viewModel.onPickProfileImage?() } label: {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let img = viewModel.profileImage {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            Image("user_placeholder").resizable().scaledToFill()
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(SwiftUI.Color.white.opacity(0.5), lineWidth: 2))

                    Image(systemName: "camera.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(AppTheme.Colors.orange)
                        .clipShape(Circle())
                }
            }
            SwiftUI.Text("Tocca per cambiare foto")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    // MARK: - Personal Section

    private var personalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Dati personali")

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    formField("Nome", text: $viewModel.firstName, placeholder: "Mario")
                    formField("Cognome", text: $viewModel.lastName, placeholder: "Rossi")
                }

                // Email (disabled)
                VStack(alignment: .leading, spacing: 4) {
                    SwiftUI.Text("Email")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textCaption)
                    Text(viewModel.email)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppTheme.Colors.textCaption)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.Colors.background)
                        .cornerRadius(8)
                }

                // Phone
                VStack(alignment: .leading, spacing: 4) {
                    SwiftUI.Text("Numero di telefono")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textCaption)
                    HStack(spacing: 0) {
                        SwiftUI.Text("+39")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textDark)
                            .padding(.horizontal, 10)
                            .frame(height: 44)
                            .background(AppTheme.Colors.background)
                        TextField("", text: $viewModel.contactNumber)
                            .keyboardType(.numberPad)
                            .font(.system(size: 14, weight: .regular))
                            .padding(.horizontal, 10)
                    }
                    .background(SwiftUI.Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
                }

                // Address
                Button { viewModel.onPickAddress?() } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        SwiftUI.Text("Indirizzo")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textCaption)
                        HStack {
                            Text(viewModel.address.isEmpty ? "Seleziona indirizzo" : viewModel.address)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(viewModel.address.isEmpty
                                    ? AppTheme.Colors.textCaption
                                    : AppTheme.Colors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "location")
                                .foregroundColor(AppTheme.Colors.textCaption)
                        }
                        .padding(12)
                        .background(SwiftUI.Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
                    }
                }
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Company Section

    private var companySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Dati azienda")

            VStack(spacing: 10) {
                formField("Nome azienda", text: $viewModel.companyName, placeholder: "Azienda Srl")
                formField("Partita IVA", text: $viewModel.vat, placeholder: "IT12345678901")
                formField("Codice destinatario", text: $viewModel.electronicCode, placeholder: "ABCDEF12")
                formField("PEC", text: $viewModel.certifiedEmail, placeholder: "email@pec.it", keyboardType: .emailAddress)
                formField("Città azienda", text: $viewModel.companyCity, placeholder: "Roma")
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Payment Section

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Metodo di pagamento predefinito")

            HStack(spacing: 12) {
                paymentOption(label: "Contanti", icon: "banknote.fill", mode: "c")
                paymentOption(label: "Wallet", icon: "wallet.pass.fill", mode: "w")
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func paymentOption(label: String, icon: String, mode: String) -> some View {
        let selected = viewModel.paymentMode == mode
        return Button { viewModel.paymentMode = mode } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(selected ? .white : AppTheme.Colors.purple)
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(selected ? .white : AppTheme.Colors.purple)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(selected ? AppTheme.Colors.purple : SwiftUI.Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.purple, lineWidth: 1))
        }
    }

    // MARK: - Buttons

    private var buttonsSection: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Salva modifiche")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.Colors.orange)
            .cornerRadius(25)
        }
        .disabled(viewModel.isLoading)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(AppTheme.Colors.purple)
    }

    private func formField(_ title: String, text: Binding<String>, placeholder: String = "", keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)
            TextField(placeholder.isEmpty ? title : placeholder, text: text)
                .font(.system(size: 14, weight: .regular))
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disableAutocorrection(keyboardType == .emailAddress)
                .padding(12)
                .background(SwiftUI.Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
        }
    }

}
