//
//  UpdateTempPasswordView.swift
//  TaskGator
//
//  Dedicated screen shown after login with a temporary password.
//  The user enters the new password twice and confirms.
//

import SwiftUI

struct UpdateTempPasswordView: View {

    @StateObject private var vm = UpdateTempPasswordViewModel()

    /// The temporary password used to log in (passed from LoginViewModel).
    let tempPassword: String
    /// Called when the password is updated or the user taps "Dopo".
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            formSection
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .alert(isPresented: $vm.showAlert) {
            Alert(
                title: SwiftUI.Text(""),
                message: SwiftUI.Text(vm.alertMessage ?? ""),
                dismissButton: .default(SwiftUI.Text("OK")) {
                    if vm.didSucceed { onDone() }
                }
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white)

            SwiftUI.Text("Aggiorna la password")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            SwiftUI.Text("Hai effettuato l'accesso con una password temporanea.\nScegli una nuova password per il tuo account.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
        .padding(.bottom, 24)
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

    // MARK: - Form

    private var formSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    SwiftUI.Text("Nuova password")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    VStack(spacing: 10) {
                        SecureField("Inserisci la nuova password", text: $vm.newPassword)
                            .font(.system(size: 14, weight: .medium))
                            .padding(14)
                            .background(SwiftUI.Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.lightPurple, lineWidth: 1))

                        SecureField("Conferma la nuova password", text: $vm.confirmPassword)
                            .font(.system(size: 14, weight: .medium))
                            .padding(14)
                            .background(SwiftUI.Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
                    }
                }
                .padding(16)
                .background(SwiftUI.Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)

                // Save button
                Button {
                    vm.submit(tempPassword: tempPassword)
                } label: {
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    } else {
                        SwiftUI.Text("Salva nuova password")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .background(AppTheme.Colors.orange)
                .cornerRadius(25)
                .disabled(vm.isLoading)

                // Skip button
                Button {
                    onDone()
                } label: {
                    SwiftUI.Text("Dopo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.lightGrey)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - ViewModel

@MainActor
final class UpdateTempPasswordViewModel: ObservableObject {

    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    var didSucceed = false

    func submit(tempPassword: String) {
        guard !newPassword.isEmpty else {
            alertMessage = "Inserisci la nuova password"
            showAlert = true
            return
        }
        guard newPassword.count >= 6 else {
            alertMessage = "La password deve essere di almeno 6 caratteri"
            showAlert = true
            return
        }
        guard newPassword == confirmPassword else {
            alertMessage = "Le password non corrispondono"
            showAlert = true
            return
        }
        guard let user = UserData.shared.getUser() else { return }

        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                _ = try await APIClient.shared.changePassword(
                    userId: user.user_id,
                    currentPassword: tempPassword,
                    newPassword: newPassword,
                    confirmPassword: confirmPassword
                )
                didSucceed = true
                alertMessage = "Password aggiornata con successo!"
                showAlert = true
            } catch let e as APIError {
                alertMessage = Self.localizedError(e.message)
                showAlert = true
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private static func localizedError(_ message: String) -> String {
        let map: [String: String] = [
            "please provide valid data": "Inserisci dati validi",
            "current password is incorrect": "La password attuale non è corretta",
            "password is incorrect": "La password non è corretta",
            "new password must be different": "La nuova password deve essere diversa",
            "request failed": "Richiesta non riuscita"
        ]
        return map[message.lowercased()] ?? message
    }
}
