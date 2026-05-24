//
//  ProviderProfileViewModel.swift
//  TaskGator
//
//  ViewModel for the Provider Profile tab (provider only).
//

import UIKit

@MainActor
final class ProviderProfileViewModel: ObservableObject {

    @Published var profile: UserProfile?
    @Published var isAvailable = false
    @Published var isLoading = false

    var onBack: (() -> Void)?
    var onEditTapped: (() -> Void)?
    var onViewAllReviews: (() -> Void)?
    var onSendEmail: ((String) -> Void)?
    var onCallPhone: ((String) -> Void)?

    var profilePhone: String {
        guard let p = profile, !p.contact_number.isEmpty else { return "" }
        return (p.country_code + " " + p.contact_number).trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Load

    func loadProfile() {
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true
        Task {
            do {
                let dic = try await APIClient.shared.getUserProfile(params: ["profile_id": user.user_id])
                let data = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
                if let data = data {
                    profile = data
                    isAvailable = data.is_available == "y"
                    // Update UserData cache
                    let userDic = UserData.shared.getUser()!
                    userDic.first_name = data.firstName
                    userDic.last_name = data.lastName
                    userDic.user_name = data.user_name
                    userDic.profile_img = data.profile_img
                    userDic.address = data.address
                    _ = UserData.shared.setUser(dic: userDic.dictionary)
                    Modal.sharedAppdelegate.processNotification()
                }
            } catch {
                // fail silently
            }
            isLoading = false
        }
    }

    // MARK: - Availability toggle

    /// Called by .onChange — the toggle binding already flipped `isAvailable`,
    /// so we just fire the API and revert on failure.
    func syncAvailability(_ available: Bool) {
        guard let user = UserData.shared.getUser() else { return }
        Task {
            do {
                let param: [String: Any] = [
                    "user_id": user.user_id,
                    "isAvailable": available ? "y" : "n"
                ]
                _ = try await APIClient.shared.updateAvailableStatus(params: param)
            } catch {
                isAvailable = !available
            }
        }
    }
}
