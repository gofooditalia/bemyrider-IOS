//
//  MessagesView.swift
//  bemyrider
//
//  SwiftUI view for the Messages tab (conversation list).
//  Redesigned with gradient header, search bar, and card-based message list.
//

import SwiftUI

struct MessagesView: View {

    @ObservedObject var viewModel: MessagesViewModel
    @State private var searchText = ""

    private var filteredMessages: [MessageList] {
        if searchText.isEmpty { return viewModel.messages }
        let query = searchText.lowercased()
        return viewModel.messages.filter {
            $0.to_user_name.lowercased().contains(query) ||
            $0.message_text.lowercased().contains(query) ||
            $0.service_name.lowercased().contains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            SwiftUI.Text("Messaggi")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)

            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.textCaption)
                    .font(.system(size: 16, weight: .medium))

                TextField("Cerca messaggi...", text: $searchText)
                    .foregroundColor(AppTheme.Colors.textDark)
                    .font(.system(size: 14, weight: .medium))

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.border)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(SwiftUI.Color.white)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(
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
        )
    }

    // MARK: - Content

    private var content: some View {
        Group {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                Spacer()
            } else if filteredMessages.isEmpty {
                emptyState
            } else {
                messageList
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: searchText.isEmpty ? "bubble.left.and.bubble.right" : "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text(searchText.isEmpty ? "Nessun messaggio" : "Nessun messaggio trovato")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - List

    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredMessages.enumerated()), id: \.element.service_master_id) { index, msg in
                    Button(action: { viewModel.onTapMessage?(msg) }) {
                        messageCard(msg)
                    }
                    .buttonStyle(MessageCardButtonStyle())
                    .onAppear { viewModel.loadMoreIfNeeded(index: index) }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Card

    private func messageCard(_ msg: MessageList) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            avatarView(msg)

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                // Name
                SwiftUI.Text(msg.to_user_name.isEmpty ? "Utente" : msg.to_user_name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                // Service badge
                if !msg.service_name.isEmpty {
                    SwiftUI.Text(msg.service_name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.Colors.badgeOrange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(AppTheme.Colors.lightOrange)
                        .clipShape(Capsule())
                }

                // Message text
                SwiftUI.Text(messagePreview(msg))
                    .font(.system(size: 13.5))
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .lineLimit(1)

                // Date
                if !msg.createdDate.isEmpty {
                    SwiftUI.Text(msg.createdDate)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(AppTheme.Colors.greyMid)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .overlay(
            Group {
                if msg.isRead == "n" || msg.isRead == "0" || msg.isRead.isEmpty {
                    Circle()
                        .fill(AppTheme.Colors.link)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(AppTheme.Colors.link.opacity(0.3), lineWidth: 3)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(16)
                } else {
                    EmptyView()
                }
            }
        )
    }

    // MARK: - Avatar

    @ViewBuilder
    private func avatarView(_ msg: MessageList) -> some View {
        if !msg.to_profile_img.isEmpty {
            RemoteImageView(msg.to_profile_img,
                           contentMode: .scaleAspectFill,
                           placeholder: UIImage(named: "user_placeholder"))
                .frame(width: 48, height: 48)
                .clipShape(Circle())
        } else {
            // Gradient avatar with initials
            let initials = avatarInitials(msg.to_user_name)
            let gradient = avatarGradient(msg.to_user_name)
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 48, height: 48)
                SwiftUI.Text(initials)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Helpers

    private func messagePreview(_ msg: MessageList) -> String {
        if !msg.message_text.isEmpty { return msg.message_text.removingPercentEncodingSafe() }
        if !msg.appAttUrl.isEmpty { return "📎 Allegato" }
        return "Nessun messaggio"
    }

    private func avatarInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private func avatarGradient(_ name: String) -> [SwiftUI.Color] {
        let gradients: [[SwiftUI.Color]] = [
            [AppTheme.Colors.berry, AppTheme.Colors.violet],
            [AppTheme.Colors.mint, AppTheme.Colors.aqua],
            [AppTheme.Colors.warmOrange, AppTheme.Colors.warningRed],
            [AppTheme.Colors.infoBlue, AppTheme.Colors.accentBlue],
            [AppTheme.Colors.plum, AppTheme.Colors.magenta],
        ]
        let hash = abs(name.hashValue)
        return gradients[hash % gradients.count]
    }
}

// MARK: - Button Style (tap scale animation)

struct MessageCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// RoundedCorner is defined in ServiceDetailView.swift
