//
//  DisputeDetailView.swift
//  bemyrider
//

import SwiftUI

struct DisputeDetailView: View {

    @ObservedObject var viewModel: DisputeDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView {
                if viewModel.isLoading && viewModel.messages.isEmpty {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else {
                    infoCard
                    if viewModel.isEscalated {
                        escalatedBanner
                    } else {
                        escalateButton
                    }
                    messagesList
                }
            }
            if !viewModel.isEscalated {
                messageInputBar
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.loadDetails() }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Controversia"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Header

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

            VStack(alignment: .leading, spacing: 2) {
                Text("Dettaglio Controversia")
                    .font(AppTheme.Fonts.bold(20))
                    .foregroundColor(.white)
            }
            Spacer()

            statusBadge
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
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

    private var statusBadge: some View {
        let text = viewModel.statusText
        let color: SwiftUI.Color = viewModel.isEscalated
            ? SwiftUI.Color.orange
            : SwiftUI.Color.green

        return Text(text)
            .font(AppTheme.Fonts.medium(11))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .cornerRadius(12)
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(spacing: 12) {
            infoRow(icon: "doc.text", label: "Motivo", value: viewModel.disputeTitle)
            Divider()
            infoRow(icon: "person", label: "Creata da", value: viewModel.raisedByName)
            Divider()
            infoRow(icon: "calendar", label: "Data", value: viewModel.createdDate)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(SwiftUI.Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.purple)
                .frame(width: 28, height: 28)
                .background(AppTheme.Colors.purple.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.Fonts.regular(11))
                    .foregroundColor(AppTheme.Colors.extraLightGrey)
                Text(value)
                    .font(AppTheme.Fonts.medium(14))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
            }
            Spacer()
        }
    }

    // MARK: - Messages List

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    // Reversed: newest at bottom
                    ForEach(Array(viewModel.messages.reversed().enumerated()), id: \.element.message_id) { _, message in
                        messageBubble(message)
                            .id(message.message_id)
                            .onAppear { viewModel.loadMoreIfNeeded(message: message) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    private func messageBubble(_ message: DisputeMsg) -> some View {
        let isMine = viewModel.isCurrentUser(message)
        let senderName = viewModel.senderName(for: message)

        return HStack {
            if isMine { Spacer(minLength: 60) }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                if !isMine {
                    Text(senderName)
                        .font(AppTheme.Fonts.medium(11))
                        .foregroundColor(AppTheme.Colors.purple)
                }

                Text(message.dispute_message)
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(isMine ? .white : AppTheme.Colors.charcoalGrey)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isMine
                            ? AnyView(
                                LinearGradient(
                                    colors: [AppTheme.Colors.purple, AppTheme.Colors.purple.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyView(SwiftUI.Color.white)
                    )
                    .cornerRadius(16, corners: isMine
                        ? [.topLeft, .topRight, .bottomLeft]
                        : [.topLeft, .topRight, .bottomRight]
                    )
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)

                // Attachment link
                if !message.appAttUrl.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "paperclip")
                            .font(.system(size: 11))
                        Text("Allegato")
                            .font(AppTheme.Fonts.regular(11))
                    }
                    .foregroundColor(AppTheme.Colors.purple)
                }

                Text(message.createdDate)
                    .font(AppTheme.Fonts.regular(10))
                    .foregroundColor(AppTheme.Colors.placeholder)
            }

            if !isMine { Spacer(minLength: 60) }
        }
    }

    // MARK: - Escalated Banner

    private var escalatedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Controversia in gestione")
                    .font(AppTheme.Fonts.bold(13))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                Text("L'amministrazione sta gestendo la controversia")
                    .font(AppTheme.Fonts.regular(11))
                    .foregroundColor(AppTheme.Colors.extraLightGrey)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.Colors.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.orange.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Escalate Button

    private var escalateButton: some View {
        Button(action: { viewModel.escalateToAdmin() }) {
            HStack(spacing: 8) {
                if viewModel.isEscalating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(viewModel.isEscalating ? "Inoltro..." : "Inoltra all'amministrazione")
                    .font(AppTheme.Fonts.bold(14))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.orange, AppTheme.Colors.orange.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(viewModel.isEscalating)
        .opacity(viewModel.isEscalating ? 0.7 : 1)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Message Input

    private var messageInputBar: some View {
        HStack(spacing: 10) {
            TextField("Scrivi un messaggio...", text: $viewModel.messageText)
                .font(AppTheme.Fonts.regular(14))
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(SwiftUI.Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppTheme.Colors.placeholder.opacity(0.3), lineWidth: 1)
                        )
                )

            Button(action: { 
                print("Send button tapped - messageText: \(viewModel.messageText)")
                viewModel.sendMessage() 
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AppTheme.Colors.placeholder
                            : AppTheme.Colors.purple
                    )
                    .clipShape(Circle())
            }
            .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            SwiftUI.Color.white
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Corner Radius Helper

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
