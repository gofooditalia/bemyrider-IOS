//
//  SignUpViewModel.swift
//  bemyrider
//
//  ViewModel for the SwiftUI SignUpView.
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {

    // MARK: - Form state

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var contactNumber = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var userType = "p"       // "p" = Provider, "c" = Customer
    @Published var termsAccepted = false
    @Published var isPasswordVisible = false
    @Published var isConfirmPasswordVisible = false

    // MARK: - UI state

    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showTerms = false
    @Published var signUpSucceeded = false

    // MARK: - Social login

    var isSocialLogin = false
    var socialUserId = ""

    // MARK: - UIKit interop callbacks

    var onLoginTapped: (() -> Void)?
    var onSignUpSuccess: (() -> Void)?
    var onContactUsTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?

    // MARK: - Submit

    func submit() async {
        guard validate() else { return }
        isLoading = true
        Modal.sharedAppdelegate.startLoader()
        defer { isLoading = false; Modal.sharedAppdelegate.stoapLoader() }
        if isSocialLogin {
            await performSocialSignUp()
        } else {
            await performNormalSignUp()
        }
    }
}

// MARK: - Private

private extension SignUpViewModel {

    func performNormalSignUp() async {
        do {
            let response = try await APIClient.shared.signUp(params: [
                "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                "password": password,
                "repassword": confirmPassword,
                "user_type": userType,
                "firstName": firstName,
                "lastName": lastName,
                "contact_number": contactNumber,
                "country_code": "105"
            ])
            password = ""
            confirmPassword = ""
            email = ""
            signUpSucceeded = true
            alertMessage = response["message"] as? String
                ?? "You have successfully registered. Please check your mail for the activation."
        } catch let e as APIError {
            alertMessage = e.message
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func performSocialSignUp() async {
        do {
            let response = try await APIClient.shared.socialSignUp(params: [
                "txt_fname": firstName,
                "txt_lname": lastName,
                "txt_contact_number": contactNumber,
                "sel_country_code": "105",
                "rdb_user_type": userType,
                "id": socialUserId
            ])
            let data = response["data"] as? [String: Any] ?? [:]
            _ = UserData.shared.setUser(dic: data)
            alertMessage = "Your account is registered successfully"
            onSignUpSuccess?()
        } catch let e as APIError {
            alertMessage = e.message
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func validate() -> Bool {
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci il tuo nome"; return false
        }
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci il tuo cognome"; return false
        }
        if !isSocialLogin {
            let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
            if e.isEmpty         { alertMessage = "Inserisci la tua email"; return false }
            if !e.isValidEmailId { alertMessage = "Inserisci un'email valida"; return false }
            if password.isEmpty  { alertMessage = "Inserisci una password"; return false }
            if password.count < 6 { alertMessage = "La password deve essere di almeno 6 caratteri"; return false }
            if confirmPassword.isEmpty { alertMessage = "Conferma la password"; return false }
            if confirmPassword != password { alertMessage = "Le password non coincidono"; return false }
        }
        if contactNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci il numero di telefono"; return false
        }
        return true
    }
}
