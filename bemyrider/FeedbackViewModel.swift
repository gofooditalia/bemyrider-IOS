//
//  FeedbackViewModel.swift
//  bemyrider
//
//  ViewModel for Feedback screen.
//

import UIKit

@MainActor
final class FeedbackViewModel: ObservableObject {

    var onBack: (() -> Void)?

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var message = ""
    @Published var selectedImage: UIImage?

    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var isSubmitted = false

    // MARK: - Validation

    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".")
    }

    // MARK: - Submit

    func submitFeedback() {
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
            "message": message
        ]

        let postImage: UIImage? = selectedImage
        let imageName: String? = selectedImage != nil ? "feedback_\(user.user_id).jpg" : nil

        Modal.shared.sendFeedBack(
            vc: UIViewController(),
            param: param,
            postImage: postImage,
            imageName: imageName,
            failer: { [weak self] (error: String) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.alertMessage = error
                    self?.showAlert = true
                }
            },
            success: { [weak self] (dic: [String: Any]) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.alertMessage = "Grazie per il tuo feedback!"
                    self?.showAlert = true
                    self?.isSubmitted = true
                    self?.clearForm()
                }
            }
        )
    }

    private func clearForm() {
        firstName = ""
        lastName = ""
        email = ""
        message = ""
        selectedImage = nil
    }

    // MARK: - Load user data

    func loadUserData() {
        guard let user = UserData.shared.getUser() else { return }
        firstName = user.first_name
        lastName = user.last_name
        email = user.email_id
    }
}
