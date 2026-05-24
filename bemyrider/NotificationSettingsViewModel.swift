//
//  NotificationSettingsViewModel.swift
//  bemyrider
//
//  ViewModel for the SwiftUI Notification Settings screen.
//

import Foundation

@MainActor
final class NotificationSettingsViewModel: ObservableObject {

    struct Setting: Identifiable {
        let id: String
        var title: String
        var isOn: Bool
    }

    @Published var settings: [Setting] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var toastMessage: String?

    var onBack: (() -> Void)?

    // MARK: - Load

    func load() {
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        Task {
            do {
                let dic = try await APIClient.shared.getNotificationSettings(params: ["user_id": user.user_id])
                let arr = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data)
                self.settings = arr.compactMap { item -> Setting? in
                    guard let d = item as? [String: Any] else { return nil }
                    let obj = NotificationData(dictionary: d)
                    return Setting(id: obj.id, title: obj.title, isOn: obj.checked != "false")
                }
            } catch {
                // Fail silently
            }
            self.isLoading = false
        }
    }

    // MARK: - Toggle

    func toggle(id: String) {
        guard let idx = settings.firstIndex(where: { $0.id == id }) else { return }
        settings[idx].isOn.toggle()
    }

    // MARK: - Save

    func save() {
        guard let user = UserData.shared.getUser() else { return }
        isSaving = true

        var param: [String: Any] = ["user_id": user.user_id]
        for s in settings {
            param[s.id] = s.isOn ? "y" : "n"
        }

        Task {
            do {
                let dic = try await APIClient.shared.updateNotificationSettings(params: param)
                let message = ResponseKey.fatchDataAsString(res: dic, valueOf: .message)
                self.toastMessage = message.isEmpty ? "Impostazioni salvate" : message
            } catch {
                self.toastMessage = "Errore nel salvataggio"
            }
            self.isSaving = false
        }
    }
}
