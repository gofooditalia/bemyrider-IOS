//
//  LoginViewModel.swift
//  bemyrider
//
//  ViewModel for the SwiftUI LoginView.
//  Social login (FB / Google / Apple) still runs through UIKit SDKs;
//  the UIKit layer calls handleSocialLogin(...) after the SDK callback completes.
//

import Foundation

enum SocialProvider { case facebook, google, apple }

@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Form state

    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false
    @Published var isLoading = false
    @Published var alertMessage: String?

    // MARK: - Sheet state

    @Published var showForgotPassword = false
    @Published var forgotEmail = ""
    @Published var forgotSheetAlert: String?
    @Published var showResendActivation = false
    @Published var resendEmail = ""
    @Published var resendSheetAlert: String?

    // MARK: - Temp password state

    /// Flag set when forgot password succeeds — next login should prompt to change password.
    @Published var usedTempPassword = false
    /// Show the "update password" alert after login with temp password.
    @Published var showChangePasswordPrompt = false

    // MARK: - UIKit interop callbacks

    /// Called when the user taps a social login button; UIKit layer should trigger the SDK flow.
    var onSocialLoginTapped: ((SocialProvider) -> Void)?
    /// Called when the user taps "Sign Up".
    var onSignUpTapped: (() -> Void)?
    /// Called when login succeeds but the provider profile is incomplete.
    var onNeedProviderProfile: (() -> Void)?
    /// Called when login succeeds but the customer profile is incomplete.
    var onNeedCustomerProfile: (() -> Void)?
    /// Called when social login returns a brand-new user (user_type blank) — UIKit pushes SignUpVC.
    var onNeedSocialSignUp: (([String: Any]) -> Void)?
    /// Called when the user taps "Aggiorna password" in the temp password prompt.
    var onChangePasswordTapped: (() -> Void)?

    // MARK: - Email / password login

    func login() async {
        guard validate() else { return }
        isLoading = true
        Modal.sharedAppdelegate.startLoader()
        defer { isLoading = false; Modal.sharedAppdelegate.stoapLoader() }
        do {
            let response = try await APIClient.shared.login(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            processLoginResponse(response,
                                 email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                 password: password,
                                 isSocial: false)
        } catch let e as APIError {
            alertMessage = e.message
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    // MARK: - Social login result (called by UIKit after SDK callback)

    func handleSocialLogin(firstName: String, lastName: String,
                           loginType: String, socialId: String,
                           email: String, picture: String) async {
        var params: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "login_type": loginType,
            "email": email,
            "picture": picture
        ]
        switch loginType {
        case "g": params["googleid"] = socialId
        case "f": params["fbid"] = socialId
        case "a": params["apple_id"] = socialId
        default: break
        }
        isLoading = true
        Modal.sharedAppdelegate.startLoader()
        defer { isLoading = false; Modal.sharedAppdelegate.stoapLoader() }
        do {
            let response = try await APIClient.shared.socialLogin(params: params)
            processSocialLoginResponse(response, email: email)
        } catch let e as APIError {
            alertMessage = e.message
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    // MARK: - Forgot password

    func submitForgotPassword() async {
        let trimmed = forgotEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.isValidEmailId else {
            forgotSheetAlert = "Inserisci un indirizzo email valido"
            return
        }
        isLoading = true
        Modal.sharedAppdelegate.startLoader()
        defer { isLoading = false; Modal.sharedAppdelegate.stoapLoader() }
        do {
            _ = try await APIClient.shared.forgotPassword(email: trimmed)
            usedTempPassword = true
            showForgotPassword = false
            // Delay alert until sheet dismissal animation completes,
            // otherwise SwiftUI can't present the alert over the sheet.
            try? await Task.sleep(nanoseconds: 500_000_000)
            alertMessage = "Ti abbiamo inviato una password temporanea all'indirizzo \(trimmed). Controlla la tua casella di posta."
        } catch let e as APIError {
            forgotSheetAlert = Self.localizedLoginError(e.message, email: trimmed)
        } catch {
            forgotSheetAlert = error.localizedDescription
        }
    }

    // MARK: - Resend activation

    func submitResendActivation() async {
        let trimmed = resendEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            resendSheetAlert = "Inserisci il tuo indirizzo email"
            return
        }
        isLoading = true
        Modal.sharedAppdelegate.startLoader()
        defer { isLoading = false; Modal.sharedAppdelegate.stoapLoader() }
        do {
            _ = try await APIClient.shared.resendActivation(email: trimmed)
            showResendActivation = false
            try? await Task.sleep(nanoseconds: 500_000_000)
            alertMessage = "Ti abbiamo inviato nuovamente l'email di attivazione all'indirizzo \(trimmed). Controlla la tua casella di posta."
        } catch let e as APIError {
            resendSheetAlert = Self.localizedLoginError(e.message, email: trimmed)
        } catch {
            resendSheetAlert = error.localizedDescription
        }
    }
}

// MARK: - Private helpers

private extension LoginViewModel {

    static func localizedLoginError(_ message: String, email: String) -> String {
        let lower = message.lowercased()
        if lower.contains("not found") || lower.contains("not registered") || lower.contains("not exist") || lower.contains("invalid email") {
            return "L'indirizzo \(email) non risulta registrato."
        }
        if lower.contains("please provide valid data") {
            return "Inserisci dati validi"
        }
        if lower.contains("request failed") {
            return "Richiesta non riuscita. Riprova."
        }
        return message
    }

    func validate() -> Bool {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if e.isEmpty         { alertMessage = "Inserisci la tua email"; return false }
        if !e.isValidEmailId { alertMessage = "Inserisci un'email valida"; return false }
        if password.isEmpty  { alertMessage = "Inserisci la password"; return false }
        if password.count < 6 { alertMessage = "La password deve essere di almeno 6 caratteri"; return false }
        return true
    }

    func processLoginResponse(_ response: [String: Any], email: String, password: String, isSocial: Bool) {
        let data    = response["data"] as? [String: Any] ?? [:]
        let message = response["message"] as? String ?? ""

        if let active = data["isUserActive"] as? String, active.lowercased() == "d" {
            alertMessage = message
            return
        }

        _ = UserData.shared.setUserLoginData(dic: ["email": email, "password": password])
        _ = UserData.shared.setUser(dic: data)
        UserData.shared.setSocialLogin(social: isSocial)
        Modal.shared.autoSaveNotificationSettings()

        guard let user = UserData.shared.getUser() else { return }
        if user.user_type == "c" {
            if user.first_name.isBlank || user.last_name.isBlank || user.contact_number.isBlank {
                onNeedCustomerProfile?(); return
            }
        } else {
            if user.first_name.isBlank || user.last_name.isBlank || user.contact_number.isBlank || user.tax_id.isBlank {
                onNeedProviderProfile?(); return
            }
        }
        if usedTempPassword {
            showChangePasswordPrompt = true
        } else {
            Modal.sharedAppdelegate.rootToHome()
        }
    }

    func processSocialLoginResponse(_ response: [String: Any], email: String) {
        let data    = response["data"] as? [String: Any] ?? [:]
        let message = response["message"] as? String ?? ""

        if let active = data["isUserActive"] as? String, active.lowercased() == "d" {
            alertMessage = message
            return
        }

        // New user — no user_type yet, needs SignUpVC to complete registration
        let userType = data["user_type"] as? String ?? ""
        if userType.isBlank {
            onNeedSocialSignUp?(data); return
        }

        _ = UserData.shared.setUser(dic: data)
        _ = UserData.shared.setUserLoginData(dic: ["email": email])
        UserData.shared.setSocialLogin(social: true)
        Modal.shared.autoSaveNotificationSettings()
        Modal.sharedAppdelegate.rootToHome()
    }
}
