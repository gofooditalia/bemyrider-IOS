//
//  EditProfileProviderViewModel.swift
//  bemyrider
//
//  ViewModel for the SwiftUI EditProfileProviderView.
//

import UIKit
import Foundation

@MainActor
final class EditProfileProviderViewModel: ObservableObject {

    var onBack: (() -> Void)?

    // MARK: - Form state

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var contactNumber = ""
    @Published var address = ""
    @Published var aboutMe = ""
    @Published var startTime: Date? = nil
    @Published var endTime: Date? = nil
    @Published var dateOfBirth: Date? = nil
    @Published var availableDays: Set<Int> = []   // 0 = Dom … 6 = Sab
    @Published var smallDelivery = false
    @Published var mediumDelivery = false
    @Published var largeDelivery = false

    // Tax data
    @Published var companyName = ""
    @Published var vat = ""
    @Published var electronicCode = ""
    @Published var certifiedEmail = ""
    @Published var cityOfBirth = ""
    @Published var cityOfResidence = ""
    @Published var residentialAddress = ""
    @Published var taxIdCode = ""

    // MARK: - Image state

    @Published var profileImage: UIImage? = nil
    @Published var signatureImage: UIImage? = nil
    var pickedProfileImageName: String?
    var pickedSignatureImageName: String?

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
    var onPickSignatureImage: (() -> Void)?
    var onPickAddress: (() -> Void)?
    var onNavigateToMyServices: (() -> Void)?

    // MARK: - Load

    func loadFromProfile(_ data: UserProfile) {
        firstName        = data.firstName
        lastName         = data.lastName
        email            = data.email
        contactNumber    = data.contact_number
        address          = data.address.lowercased() == "n/a" ? "" : data.address
        aboutMe          = data.description.lowercased() == "n/a" ? "" : data.description

        let tf = DateFormatter(); tf.locale = Locale(identifier: "en_US_POSIX"); tf.dateFormat = "HH:mm"
        startTime = data.available_time_start.lowercased() == "n/a" ? nil : tf.date(from: data.available_time_start)
        endTime   = data.available_time_end.lowercased()   == "n/a" ? nil : tf.date(from: data.available_time_end)

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        if !data.date_of_birth.isEmpty && data.date_of_birth.lowercased() != "n/a" {
            df.dateFormat = "dd/MM/yyyy"
            if let parsed = df.date(from: data.date_of_birth) {
                dateOfBirth = parsed
            } else {
                df.dateFormat = "yyyy-MM-dd"
                dateOfBirth = df.date(from: data.date_of_birth)
            }
        }

        if !data.latitude.isBlank {
            latitude  = Double(data.latitude)  ?? 0
            longitude = Double(data.longitude) ?? 0
        }

        companyName         = data.company_name
        vat                 = data.vat
        electronicCode      = data.receipt_code
        certifiedEmail      = data.certified_email
        cityOfBirth         = data.city_of_birth
        cityOfResidence     = data.city_of_residence
        residentialAddress  = data.residential_address
        taxIdCode           = data.tax_id

        smallDelivery  = data.small_delivery.lowercased()  == "y"
        mediumDelivery = data.medium_delivery.lowercased() == "y"
        largeDelivery  = data.large_delivery.lowercased()  == "y"

        availableDays = Set(data.available_days.components(separatedBy: ",").compactMap { Int($0) })

        loadImage(from: data.profile_img)   { [weak self] img in self?.profileImage   = img }
        loadImage(from: data.signature_img_url) { [weak self] img in self?.signatureImage = img }
    }

    func setPickedProfileImage(_ image: UIImage, name: String) {
        profileImage = image
        pickedProfileImageName = name
    }

    func setPickedSignatureImage(_ image: UIImage, name: String) {
        signatureImage = image
        pickedSignatureImageName = name
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

        let tf = DateFormatter(); tf.locale = Locale(identifier: "en_US_POSIX"); tf.dateFormat = "HH:mm"
        let df = DateFormatter(); df.locale = Locale(identifier: "en_US_POSIX"); df.dateFormat = "dd/MM/yyyy"

        let param: [String: Any] = [
            "user_id":              UserData.shared.getUser()!.user_id,
            "firstName":            firstName,
            "lastName":             lastName,
            "address":              address,
            "country_code":         countryId,
            "contact_number":       contactNumber,
            "description":          aboutMe,
            "available_time_start": startTime.map { tf.string(from: $0) } ?? "",
            "available_time_end":   endTime.map   { tf.string(from: $0) } ?? "",
            "avl_dat":              availableDays.sorted().map { "\($0)" }.joined(separator: ","),
            "latitude":             String(latitude),
            "longitude":            String(longitude),
            "small_delivery":       smallDelivery  ? "y" : "n",
            "medium_delivery":      mediumDelivery ? "y" : "n",
            "large_delivery":       largeDelivery  ? "y" : "n",
            "company_name":         companyName,
            "vat":                  vat,
            "tax_id":               taxIdCode,
            "certified_email":      certifiedEmail,
            "receipt_code":         electronicCode,
            "city_of_birth":        cityOfBirth,
            "date_of_birth":        dateOfBirth.map { df.string(from: $0) } ?? "",
            "city_of_residence":    cityOfResidence,
            "residential_address":  residentialAddress
        ]

        let imgToUpload  = pickedProfileImageName  != nil ? profileImage   : nil
        let signToUpload = pickedSignatureImageName != nil ? signatureImage : nil

        await withCheckedContinuation { continuation in
            Modal.shared.editProfile(
                vc: vc,
                param: param,
                postImage: imgToUpload,
                imageName: pickedProfileImageName,
                signImg:   signToUpload,
                signImgName: pickedSignatureImageName ?? ""
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.refreshProfile(vc: vc)
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Private

private extension EditProfileProviderViewModel {

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
                Modal.sharedAppdelegate.isCustomerLogin = false
                self.onNavigateToMyServices?()
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
        if cityOfBirth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci la città di nascita"; return false
        }
        if dateOfBirth == nil {
            alertMessage = "Inserisci la data di nascita"; return false
        }
        if cityOfResidence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci la città di residenza"; return false
        }
        if residentialAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci l'indirizzo di residenza"; return false
        }
        if taxIdCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci il codice fiscale"; return false
        }
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci l'indirizzo"; return false
        }
        if !certifiedEmail.isEmpty && !certifiedEmail.isValidEmailId {
            alertMessage = "Inserisci una PEC valida"; return false
        }
        if aboutMe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Inserisci la descrizione"; return false
        }
        if startTime == nil {
            alertMessage = "Inserisci l'orario di inizio"; return false
        }
        if endTime == nil {
            alertMessage = "Inserisci l'orario di fine"; return false
        }
        if let s = startTime, let e = endTime, s >= e {
            alertMessage = "L'orario di inizio deve essere precedente a quello di fine"; return false
        }
        return true
    }
}
