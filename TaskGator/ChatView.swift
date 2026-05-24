//
//  ChatView.swift
//  TaskGator
//
//  SwiftUI view for the Chat screen (conversation detail).
//  Redesigned with gradient header, modern bubbles, and attachment support.
//

import SwiftUI

struct ChatView: View {

    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            messageList
            if !viewModel.isDisabled {
                inputBar
            }
        }
        .ignoresSafeArea(.container, edges: .horizontal)
        .background(AppTheme.Colors.subtleBackground.ignoresSafeArea())
    }

    // MARK: - Header

    private var chatHeader: some View {
        HStack(spacing: 12) {
            // Back button
            Button(action: { viewModel.onBack?() }) {
                ZStack {
                    Circle()
                        .fill(SwiftUI.Color.white.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            // Avatar
            chatAvatar

            // Name + service
            VStack(alignment: .leading, spacing: 2) {
                SwiftUI.Text(viewModel.otherUserName.isEmpty ? "Chat" : viewModel.otherUserName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if !viewModel.serviceName.isEmpty {
                    SwiftUI.Text(viewModel.serviceName)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(SwiftUI.Color.white.opacity(0.65))
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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

    @ViewBuilder
    private var chatAvatar: some View {
        if !viewModel.otherUserImage.isEmpty {
            RemoteImageView(viewModel.otherUserImage,
                           contentMode: .scaleAspectFit,
                           placeholder: UIImage(named: "user_placeholder"))
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            let initials = avatarInitials(viewModel.otherUserName)
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
                    .frame(width: 40, height: 40)
                SwiftUI.Text(initials)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        Group {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                Spacer()
            } else if viewModel.messages.isEmpty {
                emptyState
            } else {
                scrollableMessages
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessun messaggio")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scrollableMessages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 4) {
                    // Loading indicator at bottom (older messages)
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                            .rotationEffect(.degrees(180))
                    }

                    // Messages in reverse order (newest at bottom)
                    ForEach(Array(viewModel.messages.enumerated().reversed()), id: \.offset) { index, msg in
                        let isMe = msg.from_user == (UserData.shared.getUser()?.user_id ?? "")
                        let showAvatar = shouldShowAvatar(at: viewModel.messages.count - 1 - index, isMe: isMe)
                        messageBubble(msg, isMe: isMe, showAvatar: showAvatar)
                            .onAppear { viewModel.loadMoreIfNeeded(index: index) }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(180))
        }
    }

    // MARK: - Bubble

    private func messageBubble(_ msg: Message, isMe: Bool, showAvatar: Bool) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isMe { Spacer(minLength: 50) }

            // Received avatar
            if !isMe {
                if showAvatar {
                    smallAvatar
                } else {
                    SwiftUI.Color.clear.frame(width: 28, height: 28)
                }
            }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 2) {
                // Bubble
                VStack(alignment: .leading, spacing: 6) {
                    if !msg.message_text.isEmpty {
                        SwiftUI.Text(msg.message_text.strippingHTML())
                            .font(.system(size: 14))
                            .foregroundColor(isMe ? .white : AppTheme.Colors.textDark)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Attachment
                    if !msg.appAttUrl.isEmpty {
                        Button(action: { viewModel.onOpenAttachment?(msg.appAttUrl) }) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 12))
                                SwiftUI.Text("Visualizza allegato")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(isMe
                                ? SwiftUI.Color.white.opacity(0.85)
                                : AppTheme.Colors.softBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                isMe
                                    ? SwiftUI.Color.white.opacity(0.15)
                                    : AppTheme.Colors.infoLightBg
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isMe
                        ? AnyView(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.deepPurple,
                                    AppTheme.Colors.richPurple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyView(SwiftUI.Color.white)
                )
                .clipShape(ChatBubbleShape(isMe: isMe))
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 4, x: 0, y: 1)

                // Timestamp
                if !msg.created_date.isEmpty {
                    SwiftUI.Text(msg.created_date)
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(AppTheme.Colors.greyDim)
                        .padding(.horizontal, 4)
                }
            }

            if !isMe { Spacer(minLength: 50) }
        }
    }

    @ViewBuilder
    private var smallAvatar: some View {
        if !viewModel.otherUserImage.isEmpty {
            RemoteImageView(viewModel.otherUserImage,
                           contentMode: .scaleAspectFit,
                           placeholder: UIImage(named: "user_placeholder"))
                .frame(width: 28, height: 28)
                .clipShape(Circle())
        } else {
            let initials = avatarInitials(viewModel.otherUserName)
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
                    .frame(width: 28, height: 28)
                SwiftUI.Text(initials)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            // Attachment preview
            if let fileName = viewModel.attachmentFileName {
                HStack(spacing: 8) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.deepPurple)
                    SwiftUI.Text(fileName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.greyDark)
                        .lineLimit(1)
                    Spacer()
                    Button(action: {
                        viewModel.attachmentFileName = nil
                        viewModel.selectedImage = nil
                        viewModel.pickedFileData = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.placeholder)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.Colors.sectionBackground)
            }

            Divider()

            HStack(alignment: .bottom, spacing: 8) {
                // Attachment button
                Button(action: { viewModel.onAttachmentTapped?() }) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.subtleBackground)
                            .frame(width: 38, height: 38)
                        Image(systemName: "paperclip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.Colors.greyFaded)
                    }
                }

                // Text field
                TextField("Scrivi un messaggio...", text: $viewModel.inputText)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.Colors.sectionBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
                    )

                // Send button
                Button(action: { viewModel.sendMessage() }) {
                    ZStack {
                        Circle()
                            .fill(
                                canSend
                                    ? LinearGradient(
                                        colors: [
                                            AppTheme.Colors.deepPurple,
                                            AppTheme.Colors.richPurple
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [AppTheme.Colors.borderSubtle],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .frame(width: 38, height: 38)
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 15))
                            .foregroundColor(canSend ? .white : AppTheme.Colors.border)
                            .offset(x: -1)
                    }
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(SwiftUI.Color.white.ignoresSafeArea(edges: .bottom))
    }

    private var canSend: Bool {
        !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || viewModel.selectedImage != nil
            || viewModel.pickedFileData != nil
    }

    // MARK: - Helpers

    private func shouldShowAvatar(at reverseIndex: Int, isMe: Bool) -> Bool {
        if isMe { return false }
        let msgs = viewModel.messages
        if reverseIndex == 0 { return true }
        let nextMsg = msgs[reverseIndex - 1]
        let currentUserId = UserData.shared.getUser()?.user_id ?? ""
        return nextMsg.from_user == currentUserId
    }

    private func avatarInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Bubble Shape

struct ChatBubbleShape: Shape {
    let isMe: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 18
        let tailRadius: CGFloat = 6

        var path = Path()

        if isMe {
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                       radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tailRadius))
            path.addArc(center: CGPoint(x: rect.maxX - tailRadius, y: rect.maxY - tailRadius),
                       radius: tailRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                       radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                       radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        } else {
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                       radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                       radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + tailRadius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + tailRadius, y: rect.maxY - tailRadius),
                       radius: tailRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                       radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        }

        path.closeSubpath()
        return path
    }
}
