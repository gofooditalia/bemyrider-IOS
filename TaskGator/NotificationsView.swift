//
//  NotificationsView.swift
//  TaskGator
//
//  Modernized SwiftUI view for Notifications screen with gradient header
//  and card-based layout.
//

import SwiftUI

struct NotificationsView: View {

    @ObservedObject var viewModel: NotificationsViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentArea
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.load(reset: true) }
    }

    // MARK: - Header with gradient

    private var headerSection: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(SwiftUI.Color.white.opacity(0.18))
                    .clipShape(Circle())
            }

            SwiftUI.Text("Notifiche")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Spacer()

            if !viewModel.notifications.isEmpty {
                Button {
                    viewModel.markAllAsRead()
                } label: {
                    SwiftUI.Text("Segna tutto letto")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            Button(action: { viewModel.onSettings?() }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(SwiftUI.Color.white.opacity(0.18))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
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

    // MARK: - Content area

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && viewModel.notifications.isEmpty {
            Spacer()
        } else if viewModel.notifications.isEmpty {
            emptyState
        } else {
            notificationList
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessuna notifica")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)

            SwiftUI.Text("Le notifiche appariranno qui")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Notification list

    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.notifications.enumerated()), id: \.offset) { index, notif in
                    NotificationCard(notif: notif) {
                        viewModel.onTapNotification?(notif)
                    }
                    .onAppear { viewModel.loadMoreIfNeeded(index: index) }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Notification Card

private struct NotificationCard: View {

    let notif: NotificationCls.NotificationList
    let onTap: () -> Void

    private var isUnread: Bool {
        notif.isactive.lowercased() != "du"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar
                avatarView
                    .frame(width: 48, height: 48)

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        SwiftUI.Text(notif.user_name.isEmpty ? "Sistema" : notif.user_name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        if !notif.notification_date.isEmpty {
                            SwiftUI.Text(notif.notification_date)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(AppTheme.Colors.placeholder)
                                .lineLimit(1)
                        }
                    }

                    SwiftUI.Text(notif.message)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.textCaption)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(SwiftUI.Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isUnread ? AppTheme.Colors.orange.opacity(0.3) : SwiftUI.Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(MessageCardButtonStyle())
    }

    @ViewBuilder
    private var avatarView: some View {
        if !notif.image.isEmpty {
            RemoteImageView(notif.image,
                            contentMode: .scaleAspectFill,
                            placeholder: UIImage(named: "user_placeholder"))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isUnread ? AppTheme.Colors.orange : AppTheme.Colors.lightPurple, lineWidth: 1.5)
                )
        } else {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.berry,
                                AppTheme.Colors.violet
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "bell.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}
