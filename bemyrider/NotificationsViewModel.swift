//
//  NotificationsViewModel.swift
//  bemyrider
//
//  ViewModel for the Notifications screen.
//

import UIKit

@MainActor
final class NotificationsViewModel: ObservableObject {

    @Published var notifications: [NotificationCls.NotificationList] = []
    @Published var isLoading = false

    private var notificationObj: NotificationCls?

    var onBack: (() -> Void)?
    var onSettings: (() -> Void)?
    var onTapNotification: ((NotificationCls.NotificationList) -> Void)?

    // MARK: - Load

    func loadNotifications(reset: Bool = true) {
        if reset {
            notificationObj = nil
            notifications = []
        } else {
            guard let pag = notificationObj?.pagination,
                  pag.currentPage < pag.total_pages else { return }
        }
        guard !isLoading else { return }
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let nextPage = (notificationObj?.pagination?.currentPage ?? 0) + 1
        let param: [String: Any] = [
            "user_id": user.user_id,
            "user_type": user.user_type,
            "page": nextPage
        ]

        Task {
            do {
                let dic = try await APIClient.shared.getNotificationListing(params: param)
                let obj = NotificationCls(dictionary: dic)
                self.notificationObj = obj
                if reset {
                    self.notifications = obj.notificationList
                } else {
                    self.notifications += obj.notificationList
                }
            } catch {
                // Fail silently — list stays unchanged
            }
            self.isLoading = false
        }
    }

    func loadMoreIfNeeded(index: Int) {
        guard index == notifications.count - 1 else { return }
        loadNotifications(reset: false)
    }

    func refresh() {
        loadNotifications(reset: true)
    }

    func load(reset: Bool = true) {
        loadNotifications(reset: reset)
    }

    func markAllAsRead() {
        guard let user = UserData.shared.getUser() else { return }
        let param: [String: Any] = [
            "user_id": user.user_id,
            "user_type": user.user_type
        ]
        
        Modal.shared.updateNotificationSettings(vc: UIViewController(), param: param) { [weak self] _ in
            DispatchQueue.main.async {
                for i in self?.notifications.indices ?? 0..<0 {
                    self?.notifications[i].isactive = "du"
                }
            }
        }
    }
}
