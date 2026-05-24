//
//  AccountSettingView.swift
//  bemyrider
//
//  Modernized SwiftUI view for Account Settings
//  with gradient header and card-based layout.
//

import SwiftUI

struct AccountSettingView: View {

    @ObservedObject var viewModel: AccountSettingViewModel

    @State private var showLanguagePicker = false

    private var activeAlert: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.showAlert || viewModel.showDeleteConfirmation },
            set: { newValue in
                if !newValue {
                    viewModel.showAlert = false
                    viewModel.showDeleteConfirmation = false
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentArea
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .alert(isPresented: activeAlert) {
            if viewModel.showDeleteConfirmation {
                return Alert(
                    title: SwiftUI.Text("Elimina Account"),
                    message: SwiftUI.Text("Sei sicuro di voler eliminare definitivamente il tuo account? Questa azione è irreversibile e tutti i tuoi dati andranno persi."),
                    primaryButton: .destructive(SwiftUI.Text("Elimina")) {
                        viewModel.deleteAccount()
                    },
                    secondaryButton: .cancel(SwiftUI.Text("Annulla"))
                )
            } else {
                return Alert(title: SwiftUI.Text(""), message: SwiftUI.Text(viewModel.alertMessage ?? ""), dismissButton: .default(SwiftUI.Text("OK")))
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet(
                languages: viewModel.languages,
                selectedLanguage: $viewModel.selectedLanguage,
                onSelect: { language in
                    viewModel.setLanguage(language)
                }
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

                SwiftUI.Text("Impostazioni")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            SwiftUI.Text("Gestisci il tuo account")
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

    // MARK: - Content area

    private var contentArea: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Password section
                passwordSection

                // Language section
                languageSection

                // Delete account section
                deleteAccountSection

                // Logout section
                logoutSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Password Section

    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SwiftUI.Text("Cambia Password")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            VStack(spacing: 10) {
                SecureField("Password attuale", text: $viewModel.currentPassword)
                    .font(.system(size: 14, weight: .medium))
                    .padding(14)
                    .background(AppTheme.Colors.background)
                    .cornerRadius(12)

                SecureField("Nuova password", text: $viewModel.newPassword)
                    .font(.system(size: 14, weight: .medium))
                    .padding(14)
                    .background(AppTheme.Colors.background)
                    .cornerRadius(12)

                SecureField("Conferma password", text: $viewModel.confirmPassword)
                    .font(.system(size: 14, weight: .medium))
                    .padding(14)
                    .background(AppTheme.Colors.background)
                    .cornerRadius(12)
            }

            Button {
                viewModel.changePassword()
            } label: {
                SwiftUI.Text("Salva Password")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.orange)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Language Section

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SwiftUI.Text("Lingua")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Button {
                showLanguagePicker = true
            } label: {
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.purple)

                    Text(viewModel.selectedLanguage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textDark)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.placeholder)
                }
                .padding(14)
                .background(AppTheme.Colors.background)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Delete Account Section

    private var deleteAccountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SwiftUI.Text("Elimina Account")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            SwiftUI.Text("Se non pensi di utilizzare più BeMyRider e desideri eliminare il tuo account, possiamo farlo per te. Tieni presente che non potrai riattivare il tuo account né recuperare i contenuti o le informazioni che hai aggiunto.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.placeholder)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                viewModel.showDeleteConfirmation = true
            } label: {
                SwiftUI.Text("ELIMINA IL MIO ACCOUNT")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(SwiftUI.Color.red)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Logout Section

    private var logoutSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.logout()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SwiftUI.Color.red)

                    SwiftUI.Text("Esci dall'account")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(SwiftUI.Color.red)

                    Spacer()
                }
                .padding(16)
                .background(SwiftUI.Color.red.opacity(0.08))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Language Picker Sheet

private struct LanguagePickerSheet: View {

    let languages: [String]
    @Binding var selectedLanguage: String
    let onSelect: (String) -> Void

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(languages, id: \.self) { language in
                    Button {
                        onSelect(language)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Text(language)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textDark)

                            Spacer()

                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.Colors.purple)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Seleziona Lingua")
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
