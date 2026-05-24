//
//  EditProfileCustomerViewModel.swift
//  TaskGator
//
//  ViewModel for the SwiftUI EditProfileCustomerView.
//

import UIKit
import Foundation

extension Notification.Name {
    static let isChangeProfile = Notification.Name("isChangeProfile")
}

@MainActor
final class EditProfileCustomerViewModel: ObservableObject {

    // MARK: - Form state

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var contactNumber = ""
    @Published var address = ""
    @Published var companyName = ""
    @Published var vat = ""
    @Published var electronicCode = ""
    @Published var certifiedEmail = ""
    @Published var companyCity = ""
    @Published var paymentMode = "c"   // "c" = cash, "w" = wallet

    // MARK: - Image state

    @Published var profileImage: UIImage? = nil
    var pickedProfileImageName: String?

    // MARK: - UI state

    @Published var isLoading = false
    @Published var alertMessage: String?

    var isFirstTime = false
    var latitude: Double = 0
    var longitude: Double = 0
    let countryId = "105"   // Italy hardcoded

    // MARK: - UIKit callbacks

    weak var presentingVC: UIViewController?
    var onPickProfileImage: (() -> Void)?
    var onPickAddress: (() -> Void)?
    var onBack: (() -> Void)?
    var onProfileSaved: (() -> Void)?

    // MARK: - Load

    func loadFromProfile(_ data: UserProfile) {
        firstName     = data.firstName
        lastName      = data.lastName
        email         = data.email
        contactNumber = data.contact_number
        address       = data.address.lowercased() == "n/a" ? "" : data.address
        companyName   = data.company_name
        vat           = data.vat
        electronicCode = data.receipt_code
        certifiedEmail = data.certified_email
        companyCity   = data.city_of_company
        paymentMode   = data.payment_mode.isEmpty ? "c" : data.payment_mode

        if !data.latitude.isBlank {
            latitude  = Double(data.latitude)  ?? 0
            longitude = Double(data.longitude) ?? 0
        }

        loadImage(from: data.profile_img) { [weak self] img in self?.profileImage = img }
    }

    func setPickedProfileImage(_ image: UIImage, name: String) {
        profileImage = image
        pickedProfileImageName = name
    }

    func setAddress(_ address: String, latitude: Double, longitude: Double) {
        self.address   = address
        self.latitude  = latitude
        self.longitude = longitude
    }

    // MARK: - Submit

    func submit() async {
        guard validate() else { return }
        guard let vc = presentingVC else { return }
        isLoading = true
        defer { isLoading = false }

        let param: [String: Any] = [
            "user_id":        UserData.shared.getUser()!.user_id,
            "firstName":      firstName,
            "lastName":       lastName,
            "address":        address,
            "latitude":       String(latitude),
            "longitude":      String(longitude),
            "country_code":   countryId,
            "contact_number": contactNumber,
            "payment_mode":   paymentMode,
            "company_name":   companyName,
            "vat":            vat,
            "certified_email": certifiedEmail,
            "receipt_code":   electronicCode,
            "city_of_company": companyCity
        ]

        let imgToUpload = pickedProfileImageName != nil ? profileImage : nil

        await withCheckedContinuation { continuation in
            Modal.shared.editProfile(
                vc: vc,
                param: param,
                postImage: imgToUpload,
                imageName: pickedProfileImageName,
                signImg: nil,
                signImgName: ""
            ) { [weak self] _ in
                Task { @MainActor in
                    UserData.shared.setPaymentPref(deviceToken: self?.paymentMode ?? "c")
                    self?.refreshProfile(vc: vc)
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Private

private extension EditProfileCustomerViewModel {

    func loadImage(from urlString: String, completion: @escaping (UIImage) -> Void) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let img = UIImage(data: data) {
                Task { @MainActor in completion(img) }
            }
        }.resume()
    }

    func refreshProfile(vc: UIViewController) {
        guard let userId = UserData.shared.getUser()?.user_id else { return }
        Modal.shared.getUserProfile(vc: vc, param: ["profile_id": userId]) { [weak self] dic in
            guard let self = self else { return }
            guard let data = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic) else { return }
            let userDic = UserData.shared.getUser()!
            userDic.first_name  = data.firstName
            userDic.last_name   = data.lastName
            userDic.user_name   = data.user_name
            userDic.profile_img = data.profile_img
            userDic.address     = data.address
            _ = UserData.shared.setUser(dic: userDic.dictionary)
            NotificationCenter.default.post(name: .isChangeProfile, object: ["isChangeProfile": true])
            if self.isFirstTime {
                Modal.sharedAppdelegate.isCustomerLogin = true
                if let onProfileSaved = self.onProfileSaved {
                    onProfileSaved()
                } else {
                    Modal.sharedAppdelegate.rootToHome()
                }
            } else {
                vc.navigationController?.popViewController(animated: true)
            }
        }
    }

    func validate() -> Bool {
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci il nome"; return false
        }
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci il cognome"; return false
        }
        if contactNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci il numero di telefono"; return false
        }
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci l'indirizzo"; return false
        }
        if companyCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci la città dell'azienda"; return false
        }
        if !certifiedEmail.isEmpty && !certifiedEmail.isValidEmailId {
            alertMessage = "Inserisci una PEC valida"; return false
        }
        return true
    }
}
