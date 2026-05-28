//
//  AccountSettingViewModel.swift
//  bemyrider
//
//  ViewModel for Account Settings screen.
//

import Foundation
import MOLH

@MainActor
final class AccountSettingViewModel: ObservableObject {

    var onBack: (() -> Void)?

    // Password fields
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""

    // Language
    @Published var selectedLanguage: String = ""
    @Published var languages: [String] = ["Italiano", "English"]

    // UI State
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var showDeleteConfirmation = false

    var onLogout: (() -> Void)?

    init() {
        selectedLanguage = UserData.shared.language.isEmpty ? "Italiano" : UserData.shared.language
    }

    // MARK: - Password Change

    func changePassword() {
        guard !currentPassword.isEmpty else {
            alertMessage = "Inserisci la password attuale"
            showAlert = true
            return
        }
        guard !newPassword.isEmpty else {
            alertMessage = "Inserisci la nuova password"
            showAlert = true
            return
        }
        guard newPassword == confirmPassword else {
            alertMessage = "Le password non corrispondono"
            showAlert = true
            return
        }
        guard newPassword.count >= 6 else {
            alertMessage = "La password deve essere di almeno 6 caratteri"
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
                    currentPassword: currentPassword,
                    newPassword: newPassword,
                    confirmPassword: confirmPassword
                )
                currentPassword = ""
                newPassword = ""
                confirmPassword = ""
                alertMessage = "Password cambiata con successo"
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

    // MARK: - Language

    func setLanguage(_ language: String) {
        selectedLanguage = language

        var langId = "1"
        var locale: MuliLangShortHand = .it

        switch language.lowercased() {
        case "italiano":
            langId = "1"
            locale = .it
        case "français":
            langId = "2"
            locale = .fr
        case "português":
            langId = "3"
            locale = .pt
        case "english":
            langId = "4"
            locale = .en
        default:
            break
        }

        UserData.shared.setLanguage(language: language)
        UserData.shared.setLanguageID(languageID: langId)
        MOLH.setLanguageTo(locale.rawValue)
    }

    // MARK: - Error localization

    private static func localizedError(_ message: String) -> String {
        let map: [String: String] = [
            "please provide valid data": "Inserisci dati validi",
            "current password is incorrect": "La password attuale non è corretta",
            "password is incorrect": "La password non è corretta",
            "new password must be different": "La nuova password deve essere diversa",
            "Request failed": "Richiesta non riuscita",
            "user not found": "Utente non trovato"
        ]
        return map[message.lowercased()] ?? message
    }

    // MARK: - Delete Account

    func deleteAccount() {
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let param: [String: Any] = [
            "user_id": user.user_id,
            "user_type": user.user_type
        ]

        Modal.shared.deactive(vc: UIViewController(), param: param) { _ in
            DispatchQueue.main.async {
                UserData.shared.logoutUser()
                Modal.sharedAppdelegate.rootToHome()
            }
        }
    }

    // MARK: - Logout

    func logout() {
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let param: [String: Any] = [
            "user_id": user.user_id,
            "device_token": UserData.shared.deviceToken
        ]

        Modal.shared.logOut(vc: UIViewController(), param: param) { _ in
            DispatchQueue.main.async {
                UserData.shared.logoutUser()
                Modal.sharedAppdelegate.rootToHome()
            }
        }
    }
}
