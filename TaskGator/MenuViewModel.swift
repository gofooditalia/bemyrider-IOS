//
//  MenuViewModel.swift
//  TaskGator
//
//  ViewModel for the Menu tab (customer + provider + guest).
//

import UIKit

@MainActor
final class MenuViewModel: ObservableObject {

    @Published var userName: String = ""
    @Published var userAddress: String = ""
    @Published var userImageURL: String = ""

    enum UserKind { case guest, customer, provider }

    var userKind: UserKind {
        guard let user = UserData.shared.getUser() else { return .guest }
        return user.user_type == "c" ? .customer : .provider
    }

    var isLoggedIn: Bool { UserData.shared.getUser() != nil }

    // MARK: - Menu item model

    struct MenuItem: Identifiable {
        let id = UUID()
        let icon: String        // SF Symbol name
        let title: String
        let type: MenuOption
        var isDestructive: Bool = false
    }

    var menuItems: [MenuItem] {
        switch userKind {
        case .guest:
            return [
                MenuItem(icon: "phone.fill",              title: "Contattaci",  type: .contactUs),
                MenuItem(icon: "info.circle.fill",        title: "Info",        type: .information),
                MenuItem(icon: "arrow.right.circle.fill", title: "Accedi",      type: .login),
            ]
        case .customer:
            return [
                MenuItem(icon: "bell.fill",                              title: "Notifiche",              type: .notifications),
                MenuItem(icon: "exclamationmark.bubble.fill",            title: "Resolution Center",      type: .resolutionCenter),
                MenuItem(icon: "creditcard.fill",                        title: "Storico Pagamenti",      type: .paymentHistory),
                MenuItem(icon: "gear",                                   title: "Impostazioni Account",   type: .accountSetting),
                MenuItem(icon: "info.circle.fill",                       title: "Info",                   type: .information),
                MenuItem(icon: "text.bubble.fill",                       title: "Feedback",               type: .feedback),
                MenuItem(icon: "phone.fill",                             title: "Contattaci",             type: .contactUs),
                MenuItem(icon: "rectangle.portrait.and.arrow.right",     title: "Logout",                 type: .logout, isDestructive: true),
            ]
        case .provider:
            return [
                MenuItem(icon: "link.circle.fill",                       title: "Stripe Connect",         type: .stripe),
                MenuItem(icon: "briefcase.fill",                         title: "I miei Servizi",         type: .myServices),
                MenuItem(icon: "chart.bar.fill",                         title: "Info Finanziarie",       type: .financialInfo),
                MenuItem(icon: "bell.fill",                              title: "Notifiche",              type: .notifications),
                MenuItem(icon: "exclamationmark.bubble.fill",            title: "Resolution Center",      type: .resolutionCenter),
                MenuItem(icon: "creditcard.fill",                        title: "Storico Pagamenti",      type: .paymentHistory),
                MenuItem(icon: "gear",                                   title: "Impostazioni Account",   type: .accountSetting),
                MenuItem(icon: "info.circle.fill",                       title: "Info",                   type: .information),
                MenuItem(icon: "text.bubble.fill",                       title: "Feedback",               type: .feedback),
                MenuItem(icon: "phone.fill",                             title: "Contattaci",             type: .contactUs),
                MenuItem(icon: "rectangle.portrait.and.arrow.right",     title: "Logout",                 type: .logout, isDestructive: true),
            ]
        }
    }

    // MARK: - Callbacks → UIKit HostingVC

    var onMenuTap: ((MenuOption) -> Void)?
    var onEditProfile: (() -> Void)?
    var onViewProfile: (() -> Void)?
    var onShareProfile: (() -> Void)?

    // MARK: - Data

    func loadUserData() {
        guard let user = UserData.shared.getUser() else {
            userName = ""
            userAddress = ""
            userImageURL = ""
            return
        }
        userName = "\(user.first_name) \(user.last_name)".trimmingCharacters(in: .whitespaces)
        userAddress = user.address
        userImageURL = user.profile_img
    }
}
