//
//  InfoView.swift
//  TaskGator
//
//  Modernized SwiftUI view for Info screen (CMS pages list)
//  with gradient header and card-based layout.
//

import SwiftUI

struct InfoView: View {

    @ObservedObject var viewModel: InfoViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentArea
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.load() }
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

                SwiftUI.Text("Info")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            SwiftUI.Text("Informazioni su bemyrider")
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
        if viewModel.isLoading && viewModel.infoPages.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
        } else if viewModel.infoPages.isEmpty {
            emptyState
        } else {
            infoList
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessuna informazione")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Info list

    private var infoList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.infoPages.enumerated()), id: \.element.id) { index, page in
                    InfoCard(page: page) {
                        viewModel.onTapPage?(page)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Info Card

private struct InfoCard: View {

    let page: infoData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.lightOrange)
                        .frame(width: 44, height: 44)
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.Colors.orange)
                }

                Text(page.pageTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textDark)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.placeholder)
            }
            .padding(16)
            .background(SwiftUI.Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(MessageCardButtonStyle())
    }
}
