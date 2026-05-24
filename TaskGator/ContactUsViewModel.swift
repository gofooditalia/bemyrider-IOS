//
//  ContactUsViewModel.swift
//  TaskGator
//
//  ViewModel for Contact Us screen.
//

import UIKit

@MainActor
final class ContactUsViewModel: ObservableObject {

    var onBack: (() -> Void)?

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var countryCode = "+39"
    @Published var message = ""

    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false

    var onSubmitted: (() -> Void)?

    // MARK: - Validation

    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".")
    }

    // MARK: - Load countries

    func loadCountries() {
        Modal.shared.getCountryCode(vc: UIViewController(), param: [:]) { [weak self] list in
            DispatchQueue.main.async {
                self?.countries = list.sorted { $0.country_name < $1.country_name }
            }
        }
    }

    // MARK: - Submit

    func submitContact() {
        guard isValid else {
            alertMessage = "Compila tutti i campi obbligatori"
            showAlert = true
            return
        }

        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let param: [String: Any] = [
            "user_id": user.user_id,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "country_code": countryCode,
            "phone": phone,
            "message": message
        ]

        Modal.shared.contactus(
            vc: UIViewController(),
            param: param,
            failer: { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.alertMessage = error
                    self?.showAlert = true
                }
            },
            success: { [weak self] dic in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.alertMessage = "Messaggio inviato con successo!"
                    self?.showAlert = true
                    self?.clearForm()
                    self?.onSubmitted?()
                }
            }
        )
    }

    private func clearForm() {
        firstName = ""
        lastName = ""
        email = ""
        phone = ""
        message = ""
    }

    // MARK: - Load user data

    func loadUserData() {
        guard let user = UserData.shared.getUser() else { return }
        firstName = user.first_name
        lastName = user.last_name
        email = user.email_id
    }
}
