//
//  ServiceDetailView.swift
//  bemyrider
//
//  Modernized SwiftUI view for service detail - simplified 2-tab layout:
//  1. "Prenota" - booking form, price, availability
//  2. "Info" - provider info and reviews
//

import SwiftUI

struct ServiceDetailView: View {

    @ObservedObject var viewModel: ServiceDetailViewModel
    @Namespace private var tabIndicator

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            tabBar
            tabContent
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        // Loading handled by AppDelegate UIKit loader (via Modal/WebRequester)
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 0) {
            // Top row: back + title
            HStack(spacing: 12) {
                Button(action: { viewModel.onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(SwiftUI.Color.white.opacity(0.18))
                        .clipShape(Circle())
                }

                SwiftUI.Text(viewModel.providerServiceDetail?.service_name ?? "Dettaglio Servizio")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                Button(action: { viewModel.toggleFavorite() }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isFavorite
                            ? AppTheme.Colors.error
                            : .white)
                        .frame(width: 36, height: 36)
                        .background(SwiftUI.Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 14)

            // Provider card
            providerCard
        }
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

    private var providerCard: some View {
        HStack(spacing: 12) {
            providerAvatar
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.providerServiceDetail?.user_name ?? "")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.starYellow)
                    Text(viewModel.providerServiceDetail?.avg_rating ?? "0.0")
                        .font(.system(size: 12, weight: .semibold))
                    Text("(\(viewModel.reviews.count))")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.textCaption)
                }
            }

            Spacer()

            // Quick price badge
            if let price = viewModel.providerServiceDetail?.price {
                Text("\(UserData.shared.currency)\(price)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.lightOrange)
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: SwiftUI.Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var providerAvatar: some View {
        if let imgUrl = viewModel.providerServiceDetail?.provider_image, !imgUrl.isEmpty {
            RemoteImageView(imgUrl,
                           contentMode: .scaleAspectFill,
                           placeholder: UIImage(named: "user_placeholder"))
                .clipShape(Circle())
        } else {
            let name = viewModel.providerServiceDetail?.user_name ?? ""
            let initials = avatarInitials(name)
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [AppTheme.Colors.berry,
                                AppTheme.Colors.violet],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                Text(initials)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(BookingTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.selectedBookingTab = tab.rawValue
                    }
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14, weight: .medium))
                            Text(tab.title)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(viewModel.selectedBookingTab == tab.rawValue
                            ? AppTheme.Colors.purple
                            : AppTheme.Colors.placeholder)

                        if viewModel.selectedBookingTab == tab.rawValue {
                            Capsule()
                                .fill(AppTheme.Colors.purple)
                                .frame(height: 3)
                                .matchedGeometryEffect(id: "indicator", in: tabIndicator)
                        } else {
                            Capsule()
                                .fill(SwiftUI.Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                }
            }
        }
        .padding(.horizontal, 20)
        .background(SwiftUI.Color.white)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch BookingTab(rawValue: viewModel.selectedBookingTab) {
        case .book:
            bookingTab
        case .info:
            infoTab
        case .none:
            bookingTab
        }
    }

    // MARK: - Booking Tab

    private var bookingTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Quick info
                quickInfoCard

                // Availability
                availabilityCard

                // Booking form
                bookingFormCard
            }
            .padding(16)
        }
    }

    private var quickInfoCard: some View {
        HStack(spacing: 16) {
            // Price
            VStack(spacing: 4) {
                Text("Tariffa")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textCaption)
                Text("\(UserData.shared.currency)\(viewModel.providerServiceDetail?.price ?? "0")")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.Colors.orange)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            // Hours
            VStack(spacing: 4) {
                Text("Durata")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textCaption)
                Text("\(viewModel.providerServiceDetail?.hours ?? "0")h")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.Colors.purple)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            // Vehicle type
            VStack(spacing: 4) {
                Text("Veicolo")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textCaption)
                Image(systemName: deliveryIcon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.purple)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var deliveryIcon: String {
        let dt = viewModel.deliveryType.lowercased()
        switch dt {
        case "small": return "bicycle"
        case "medium": return "motorcycle.fill"
        case "large": return "car.fill"
        default: return "bicycle"
        }
    }

    private var availabilityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Disponibilità")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.purple)
                    Text(viewModel.providerServiceDetail?.available_days_list ?? "N/D")
                        .font(.system(size: 13, weight: .medium))
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.purple)
                    if let start = viewModel.providerServiceDetail?.available_time_start,
                       let end = viewModel.providerServiceDetail?.available_time_end {
                        Text("\(start) - \(end)")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
            }
            .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var bookingFormCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Prenota Ora")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Hours selection (only for hourly services)
            if viewModel.providerServiceDetail?.service_master_type == "hourly" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Durata servizio")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    HStack(spacing: 12) {
                        ForEach(1...2, id: \.self) { hours in
                            Button(action: { viewModel.selectedHoursIndex = hours }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 12))
                                    Text("\(hours) ora\(hours > 1 ? "" : "")")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(viewModel.selectedHoursIndex == hours ? .white : AppTheme.Colors.purple)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(viewModel.selectedHoursIndex == hours ? AppTheme.Colors.purple : SwiftUI.Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.Colors.purple, lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }

            // Start time picker
            DatePicker(
                "Orario di inizio",
                selection: $viewModel.selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .environment(\.locale, Locale(identifier: "it_IT"))
            .font(.system(size: 14, weight: .medium))

            // Address
            Button(action: { viewModel.onOpenLocationPicker?() }) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.purple)

                    Text(viewModel.address.isEmpty ? "Indirizzo servizio" : viewModel.address)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.address.isEmpty
                            ? AppTheme.Colors.placeholder
                            : AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.border)
                }
                .padding(12)
                .background(AppTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Description
            TextField("Istruzioni per il rider (obbligatorio)", text: $viewModel.description)
                .font(.system(size: 14))
                .padding(12)
                .background(AppTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // Submit button
            Button(action: { viewModel.submitBookingRequest() }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "paperplane.fill")
                        Text("Invia Richiesta")
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.Colors.orange)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Info Tab

    private var infoTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                // About provider
                if let profile = viewModel.providerProfile {
                    aboutCard(profile)
                }

                // Reviews summary
                reviewsCard

                // All reviews
                if !viewModel.reviews.isEmpty {
                    ForEach(Array(viewModel.reviews.prefix(5).enumerated()), id: \.offset) { _, review in
                        compactReviewCard(review)
                    }

                    if viewModel.reviews.count > 5 {
                        Text("Mostra tutte le \(viewModel.reviews.count) recensioni")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.purple)
                            .padding(.top, 8)
                    }
                }
            }
            .padding(16)
        }
    }

    private func aboutCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chi Sono")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(profile.description.isEmpty ? "Nessuna descrizione disponibile." : profile.description)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.greyFaded)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.purple)
                    Text(profile.task_assigned)
                        .font(.system(size: 14, weight: .bold))
                    Text("lavori")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.textCaption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var reviewsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recensioni")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.starYellow)
                    Text(viewModel.providerServiceDetail?.avg_rating ?? "0.0")
                        .font(.system(size: 14, weight: .semibold))
                    Text("(\(viewModel.reviews.count) recensioni)")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textCaption)
                }
            }

            Spacer()

            // Rating bars
            VStack(alignment: .trailing, spacing: 2) {
                ForEach([5,4,3,2,1], id: \.self) { star in
                    HStack(spacing: 2) {
                        Text("\(star)")
                            .font(.system(size: 10))
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                    }
                    .foregroundColor(AppTheme.Colors.border)
                }
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func compactReviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Avatar
                reviewAvatar(review)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.user_name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(review.review_date)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.greyLight)
                }

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.starYellow)
                    Text(review.review_rating)
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.warmBackground)
                .clipShape(Capsule())
            }

            Text(review.review_desc)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.greyFaded)
                .lineLimit(2)
        }
        .padding(14)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    .fill(LinearGradient(
                        colors: [AppTheme.Colors.infoBlue,
                                AppTheme.Colors.accentBlue],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                Text(initials)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Helpers

    private var isFavorite: Bool {
        (viewModel.providerServiceDetail?.total_favorite ?? "0") > "0"
    }

    private func avatarInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Tab definition

enum BookingTab: Int, CaseIterable {
    case book = 0, info = 1

    var title: String {
        switch self {
        case .book: return "Prenota"
        case .info: return "Info"
        }
    }

    var icon: String {
        switch self {
        case .book: return "calendar.badge.clock"
        case .info: return "person.text.rectangle"
        }
    }
}

