//
//  ProviderProfileView.swift
//  bemyrider
//
//  Modernized SwiftUI replacement for ProviderProfileVC.
//  Gradient header, stats bar, contact actions, card-based info sections.
//

import SwiftUI

struct ProviderProfileView: View {

    @ObservedObject var viewModel: ProviderProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentArea
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.loadProfile() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            // Avatar + Name row
            HStack(spacing: 14) {
                RemoteImageView(viewModel.profile?.profile_img ?? "")
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(SwiftUI.Color.white.opacity(0.5), lineWidth: 2))

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.profile?.user_name ?? "")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // Contact info (display only)
                    if !viewModel.profilePhone.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 10))
                            Text(viewModel.profilePhone)
                                .font(AppTheme.Fonts.regular(12))
                        }
                        .foregroundColor(SwiftUI.Color.white.opacity(0.8))
                    }

                    if let email = viewModel.profile?.email, !email.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 10))
                            Text(email)
                                .font(AppTheme.Fonts.regular(12))
                                .lineLimit(1)
                        }
                        .foregroundColor(SwiftUI.Color.white.opacity(0.8))
                    }
                }

                Spacer()
            }

            // Availability toggle
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.isAvailable
                          ? AppTheme.Colors.seaGreen
                          : AppTheme.Colors.borderMedium)
                    .frame(width: 7, height: 7)
                Text(viewModel.isAvailable ? "Disponibile ora".localized : "Non disponibile".localized)
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(.white)
                Toggle("", isOn: $viewModel.isAvailable)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.orange))
                    .frame(width: 50)
                    .onChange(of: viewModel.isAvailable) { newValue in
                        viewModel.syncAvailability(newValue)
                    }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 14)
            .background(SwiftUI.Color.white.opacity(0.12))
            .cornerRadius(18)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 14)
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

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        if let profile = viewModel.profile {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Stats bar
                    statsBar(profile)

                    // Info sections
                    infoSections(profile)

                    // Personal details
                    if hasPersonalDetails(profile) {
                        personalDetailsCard(profile)
                    }

                    // Edit button
                    editButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        } else if viewModel.isLoading {
            Spacer()
        }
    }

    // MARK: - Stats Bar

    private func statsBar(_ profile: UserProfile) -> some View {
        HStack(spacing: 0) {
            // Rating
            VStack(spacing: 6) {
                HStack(spacing: 2) {
                    let rating = profile.star_rating ?? 0
                    ForEach(0..<5) { index in
                        Image(systemName: starIcon(for: index, rating: rating))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppTheme.Colors.gold)
                    }
                }
                Text(String(format: "%.1f", profile.star_rating ?? 0))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                Text("Valutazione".localized)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.Colors.placeholder)
            }
            .frame(maxWidth: .infinity)

            statDivider

            // Reviews
            VStack(spacing: 6) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.purple)
                Text(profile.total_review)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                Text("Recensioni".localized)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.Colors.placeholder)
            }
            .frame(maxWidth: .infinity)
            .onTapGesture {
                if let count = Int(profile.total_review), count > 0 {
                    viewModel.onViewAllReviews?()
                }
            }

            statDivider

            // Delivery types
            VStack(spacing: 6) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.orange)
                Text(deliveryCount(profile))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                Text("Lavori svolti".localized)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.Colors.placeholder)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 18)
        .background(
            SwiftUI.Color.white
                .cornerRadius(20)
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
    }

    private var statDivider: some View {
        Rectangle()
            .fill(AppTheme.Colors.mist)
            .frame(width: 1, height: 48)
    }

    // MARK: - Info Sections

    private func infoSections(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            // Time
            if let timeText = formattedTime(profile), !timeText.isEmpty {
                modernInfoRow(icon: "clock.fill",
                              iconColor: AppTheme.Colors.orange,
                              bgColor: AppTheme.Colors.lightOrange,
                              title: "Orario servizio".localized,
                              value: timeText)
            }

            // About Me
            modernInfoRow(icon: "person.text.rectangle.fill",
                          iconColor: AppTheme.Colors.purple,
                          bgColor: AppTheme.Colors.lightPurple,
                          title: "Biografia".localized,
                          value: profile.description.isEmpty
                              ? "Non hai ancora scritto nulla su di te".localized
                              : profile.description)

            // Available Days
            if !profile.available_days_list.isEmpty {
                modernInfoRow(icon: "calendar",
                              iconColor: AppTheme.Colors.teal,
                              bgColor: AppTheme.Colors.successLightBg,
                              title: "Giorni disponibili".localized,
                              value: profile.available_days_list)
            }

            // Delivery Type
            modernInfoRow(icon: "shippingbox.fill",
                          iconColor: AppTheme.Colors.orange,
                          bgColor: AppTheme.Colors.lightOrange,
                          title: "Veicoli".localized,
                          value: deliveryText(profile))

            // Work on Task
            if !profile.task_assigned.isEmpty {
                modernInfoRow(icon: "checkmark.circle.fill",
                              iconColor: AppTheme.Colors.success,
                              bgColor: AppTheme.Colors.successLightBg,
                              title: "Lavoro svolti".localized,
                              value: profile.task_assigned)
            }

        }
    }

    // MARK: - Personal Details Card

    private func hasPersonalDetails(_ profile: UserProfile) -> Bool {
        !profile.city_of_birth.isEmpty ||
        !profile.date_of_birth.isEmpty ||
        !profile.city_of_residence.isEmpty ||
        !profile.residential_address.isEmpty
    }

    private func personalDetailsCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.purple)
                Text("Dati Personali".localized)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
            }

            VStack(spacing: 0) {
                if !profile.city_of_birth.isEmpty {
                    detailRow(icon: "building.columns.fill", label: "Città di nascita".localized, value: profile.city_of_birth)
                    if !profile.date_of_birth.isEmpty || !profile.city_of_residence.isEmpty || !profile.residential_address.isEmpty {
                        thinDivider
                    }
                }
                if !profile.date_of_birth.isEmpty {
                    detailRow(icon: "birthday.cake.fill", label: "Data di nascita".localized, value: profile.date_of_birth)
                    if !profile.city_of_residence.isEmpty || !profile.residential_address.isEmpty {
                        thinDivider
                    }
                }
                if !profile.city_of_residence.isEmpty {
                    detailRow(icon: "house.fill", label: "Città di residenza".localized, value: profile.city_of_residence)
                    if !profile.residential_address.isEmpty {
                        thinDivider
                    }
                }
                if !profile.residential_address.isEmpty {
                    detailRow(icon: "location.fill", label: "Indirizzo di residenza".localized, value: profile.residential_address)
                }
            }
        }
        .padding(20)
        .background(
            SwiftUI.Color.white
                .cornerRadius(20)
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.Colors.cardBackground)
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.purple)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.Colors.placeholder)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    // MARK: - Modern Info Row

    private func modernInfoRow(icon: String, iconColor: SwiftUI.Color, bgColor: SwiftUI.Color, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(bgColor)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.placeholder)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)

            Spacer()
        }
        .padding(16)
        .background(
            SwiftUI.Color.white
                .cornerRadius(16)
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Edit Button

    private var editButton: some View {
        Button(action: { viewModel.onEditTapped?() }) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 15, weight: .medium))
                Text("Modifica Profilo".localized)
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.purple, AppTheme.Colors.mediumPurple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: AppTheme.Colors.purple.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .padding(.top, 4)
    }

    // MARK: - Helpers

    private var thinDivider: some View {
        Rectangle()
            .fill(AppTheme.Colors.subtleBackground)
            .frame(height: 1)
            .padding(.leading, 52)
    }

    private func formattedTime(_ profile: UserProfile) -> String? {
        let start = profile.available_time_start.lowercased()
        let end = profile.available_time_end.lowercased()
        guard !start.isEmpty && start != "n/a" else { return nil }
        if end.isEmpty || end == "n/a" { return profile.available_time_start }
        return profile.available_time_start + " - " + profile.available_time_end
    }

    private func deliveryText(_ profile: UserProfile) -> String {
        var parts: [String] = []
        if profile.small_delivery.lowercased() == "y" { parts.append("E-Bike") }
        if profile.medium_delivery.lowercased() == "y" { parts.append("Moto") }
        if profile.large_delivery.lowercased() == "y" { parts.append("Auto") }
        return parts.isEmpty ? "N/A" : parts.joined(separator: ", ")
    }

    private func deliveryCount(_ profile: UserProfile) -> String {
        var count = 0
        if profile.small_delivery.lowercased() == "y" { count += 1 }
        if profile.medium_delivery.lowercased() == "y" { count += 1 }
        if profile.large_delivery.lowercased() == "y" { count += 1 }
        return "\(count)"
    }

    private func starIcon(for index: Int, rating: Double) -> String {
        let position = Double(index) + 1
        if rating >= position { return "star.fill" }
        else if rating >= position - 0.5 { return "star.leadinghalf.filled" }
        else { return "star" }
    }
}