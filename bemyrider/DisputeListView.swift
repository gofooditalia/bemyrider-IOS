//
//  DisputeListView.swift
//  bemyrider
//
//  Modernized SwiftUI view for Resolution Center (Dispute List)
//  with gradient header and card-based layout.
//

import SwiftUI

struct DisputeListView: View {

    @ObservedObject var viewModel: DisputeListViewModel

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
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: { viewModel.onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(SwiftUI.Color.white.opacity(0.18))
                        .clipShape(Circle())
                }

                SwiftUI.Text("Resolution Center")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            SwiftUI.Text("Gestisci le tue controversie")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
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
        if viewModel.isLoading && viewModel.disputes.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
        } else if viewModel.disputes.isEmpty {
            emptyState
        } else {
            disputeList
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.bubble")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessuna controversia")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)

            SwiftUI.Text("Le tue controversie appariranno qui")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Dispute list

    private var disputeList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.disputes.enumerated()), id: \.element.dispute_id) { index, dispute in
                    DisputeCard(dispute: dispute) {
                        viewModel.onTapDispute?(dispute)
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

// MARK: - Dispute Card

private struct DisputeCard: View {

    let dispute: Dispute
    let onTap: () -> Void

    private var statusColor: SwiftUI.Color {
        switch dispute.status.lowercased() {
        case "open": return SwiftUI.Color.orange
        case "closed": return SwiftUI.Color.green
        case "pending": return SwiftUI.Color.yellow
        default: return SwiftUI.Color.gray
        }
    }

    private var statusText: String {
        switch dispute.status.lowercased() {
        case "open": return "Aperta"
        case "closed": return "Chiusa"
        case "pending": return "In attesa"
        default: return dispute.status
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header: Title + Status
                HStack {
                    SwiftUI.Text(dispute.dispute_title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        Text(statusText)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.12))
                    .clipShape(Capsule())
                }

                // Service info
                if !dispute.service_name.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.Colors.purple)
                        Text(dispute.service_name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textCaption)
                            .lineLimit(1)
                    }
                }

                // Date
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.placeholder)
                    Text(dispute.createdDate)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.Colors.placeholder)
                }

                // Last message preview
                if !dispute.dispute_message.isEmpty {
                    Text(dispute.dispute_message)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.textCaption)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .background(SwiftUI.Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(MessageCardButtonStyle())
    }
}
