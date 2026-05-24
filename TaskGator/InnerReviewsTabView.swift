//
//  InnerReviewsTabView.swift
//  TaskGator
//
//  Reviews tab for ServiceDetailView — paginated review cards.
//

import SwiftUI

struct InnerReviewsTabView: View {
    @ObservedObject var viewModel: ServiceDetailViewModel

    var body: some View {
        ScrollView {
            if viewModel.reviews.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    emptyState
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(0..<viewModel.reviews.count, id: \.self) { index in
                        reviewCard(viewModel.reviews[index])
                            .onAppear {
                                if index == viewModel.reviews.count - 1 {
                                    viewModel.fetchReviews(isInitial: false)
                                }
                            }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
    }

    // MARK: - Review card

    private func reviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                // Avatar
                reviewAvatar(review)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    SwiftUI.Text(review.user_name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    SwiftUI.Text(review.review_date)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(AppTheme.Colors.greyLight)
                }

                Spacer()

                // Rating badge
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.starYellow)
                    SwiftUI.Text(review.review_rating)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.Colors.warmBackground)
                .clipShape(Capsule())
            }

            SwiftUI.Text(review.review_desc)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    @ViewBuilder
    private func reviewAvatar(_ review: Review) -> some View {
        if !review.user_image.isEmpty {
            RemoteImageView(review.user_image,
                           contentMode: .scaleAspectFill,
                           placeholder: UIImage(named: "user_placeholder"))
                .clipShape(Circle())
        } else {
            let parts = review.user_name.split(separator: " ")
            let initials = parts.count >= 2
                ? String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
                : String(review.user_name.prefix(2)).uppercased()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.infoBlue,
                                AppTheme.Colors.accentBlue
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                SwiftUI.Text(initials)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "star.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessuna recensione")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
