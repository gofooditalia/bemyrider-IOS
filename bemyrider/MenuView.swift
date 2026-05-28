//
//  MenuView.swift
//  bemyrider
//
//  SwiftUI Menu tab: profile header + items list.
//

import SwiftUI

struct MenuView: View {

    @ObservedObject var viewModel: MenuViewModel

    var body: some View {
        ZStack(alignment: .top) {
            // Background gradient
            LinearGradient(
                colors: [
                    AppTheme.Colors.gradientStart,
                    AppTheme.Colors.gradientMid,
                    AppTheme.Colors.gradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            // Content
            ScrollView {
                VStack(spacing: 0) {
                    SwiftUI.Color.clear.frame(height: 10)

                    headerContent

                    menuSections
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear { viewModel.loadUserData() }
    }

    // MARK: - Header Content

    private var headerContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                avatarView
                Spacer()
                if viewModel.isLoggedIn {
                    VStack(spacing: 8) {
                        if viewModel.userKind == .provider {
                            shareButton
                        }
                    }
                }
            }

            if viewModel.isLoggedIn {
                userInfoSection
            } else {
                SwiftUI.Text("Accedi per continuare")
                    .font(AppTheme.Fonts.medium(15))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private var avatarView: some View {
        Button(action: { viewModel.onViewProfile?() }) {
            Group {
                if viewModel.isLoggedIn && !viewModel.userImageURL.isEmpty {
                    RemoteImageView(viewModel.userImageURL,
                                   contentMode: .scaleAspectFill,
                                   placeholder: UIImage(named: "user_placeholder"))
                        .frame(width: 74, height: 74)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(SwiftUI.Color.white.opacity(0.5), lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 74, height: 74)
                        .foregroundColor(SwiftUI.Color.white.opacity(0.6))
                }
            }
        }
    }



    private var shareButton: some View {
        Button(action: { viewModel.onShareProfile?() }) {
            HStack(spacing: 5) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 11, weight: .medium))
                SwiftUI.Text("Condividi")
                    .font(AppTheme.Fonts.medium(13))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(SwiftUI.Color.white.opacity(0.55), lineWidth: 1)
            )
        }
    }

    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SwiftUI.Text(viewModel.userName.isEmpty ? "Utente" : viewModel.userName)
                .font(AppTheme.Fonts.bold(18))
                .foregroundColor(.white)

            if !viewModel.userAddress.isEmpty {
                HStack(spacing: 5) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    SwiftUI.Text(viewModel.userAddress)
                        .font(AppTheme.Fonts.regular(13))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
        }
    }

    // MARK: - Menu Sections

    private var menuSections: some View {
        VStack(spacing: 16) {
            // Section 1: Account & Activity
            menuSection(title: "Account", items: accountItems)

            // Section 2: Support
            menuSection(title: "Supporto", items: supportItems)

            // Section 3: Logout
            logoutButton
        }
        .padding(.horizontal, 16)
    }

    private var accountItems: [MenuViewModel.MenuItem] {
        viewModel.menuItems.filter { $0.type != .logout && $0.type != .login && $0.type != .contactUs && $0.type != .information && $0.type != .feedback }
    }

    private var supportItems: [MenuViewModel.MenuItem] {
        viewModel.menuItems.filter { $0.type == .contactUs || $0.type == .information || $0.type == .feedback }
    }

    private func menuSection(title: String, items: [MenuViewModel.MenuItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(SwiftUI.Color.white.opacity(0.7))
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    menuRow(item)
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 58)
                    }
                }
            }
            .background(SwiftUI.Color.white)
            .cornerRadius(16)
            .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }

    private var logoutButton: some View {
        Button {
            viewModel.onMenuTap?(.logout)
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)

                SwiftUI.Text("Esci")
                    .font(AppTheme.Fonts.medium(15))
                    .foregroundColor(.red)

                Spacer()
            }
            .padding(16)
            .background(SwiftUI.Color.white)
            .cornerRadius(16)
            .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Menu Row

    private func menuRow(_ item: MenuViewModel.MenuItem) -> some View {
        Button(action: { viewModel.onMenuTap?(item.type) }) {
            HStack(spacing: 14) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.lightOrange)
                        .frame(width: 36, height: 36)
                    Image(systemName: item.icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.Colors.orange)
                }

                SwiftUI.Text(item.title)
                    .font(AppTheme.Fonts.medium(15))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.Colors.placeholder)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}
