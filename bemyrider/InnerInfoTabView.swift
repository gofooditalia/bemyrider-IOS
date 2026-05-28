//
//  InnerInfoTabView.swift
//  bemyrider
//
//  Info tab for ServiceDetailView — pricing, description, availability, booking form.
//

import SwiftUI

struct InnerInfoTabView: View {
    @ObservedObject var viewModel: ServiceDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Tags
                tagsCard

                // Pricing
                pricingCard

                // Description
                descriptionCard

                // Availability
                availabilityCard

                // Booking form
                bookingCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Tags

    private var tagsCard: some View {
        HStack(spacing: 8) {
            if let cat = viewModel.providerServiceDetail?.category_name, !cat.isEmpty {
                tagCapsule(cat)
            }
            let dt = viewModel.providerServiceDetail?.delivery_type ?? viewModel.deliveryType
            if !dt.isEmpty {
                tagCapsule(dt.localized)
            }
            Spacer()
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func tagCapsule(_ text: String) -> some View {
        SwiftUI.Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(AppTheme.Colors.gradientStart)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(AppTheme.Colors.gradientStart.opacity(0.08))
            .clipShape(Capsule())
    }

    // MARK: - Pricing

    private var pricingCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                SwiftUI.Text("Tariffa")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textCaption)

                if viewModel.providerServiceDetail?.service_master_type == "hourly" {
                    SwiftUI.Text("\(UserData.shared.currency)\(viewModel.providerServiceDetail?.price ?? "0") / Ora")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                } else {
                    SwiftUI.Text("\(UserData.shared.currency)\(viewModel.providerServiceDetail?.price ?? "0")")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                SwiftUI.Text("Ore Servizio")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textCaption)

                let hrs = viewModel.providerServiceDetail?.hours ?? "0"
                SwiftUI.Text("\(hrs) \(hrs == "1" ? "Ora" : "Ore")")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Description

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Modello Veicolo e Attrezzatura")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            SwiftUI.Text(viewModel.providerServiceDetail?._description ?? "")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.textDisabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Availability

    private var availabilityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SwiftUI.Text("Disponibilita")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Days
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.gradientStart)
                SwiftUI.Text(viewModel.providerServiceDetail?.available_days_list ?? "N/A")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            // Hours
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.gradientStart)

                if let start = viewModel.providerServiceDetail?.available_time_start,
                   let end = viewModel.providerServiceDetail?.available_time_end {
                    SwiftUI.Text("\(start) - \(end)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                } else {
                    SwiftUI.Text("N/A")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Booking Form

    private var bookingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SwiftUI.Text("Prenota Servizio")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Date picker
            DatePicker(
                "Data e ora*",
                selection: $viewModel.selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .environment(\.locale, Locale(identifier: UserData.shared.languageID == "1" ? "en_US" : "it_IT"))
            .font(.system(size: 14, weight: .medium))

            // Hours picker (hourly services)
            if viewModel.providerServiceDetail?.service_master_type == "hourly" {
                Picker("Seleziona Ore*", selection: $viewModel.selectedHoursIndex) {
                    SwiftUI.Text("Seleziona").tag(0)
                    SwiftUI.Text("1 Ora").tag(1)
                    SwiftUI.Text("2 Ore").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            // Address
            Button(action: { viewModel.onOpenLocationPicker?() }) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.gradientStart)

                    SwiftUI.Text(viewModel.address.isEmpty ? "Indirizzo*" : viewModel.address)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(
                            viewModel.address.isEmpty
                                ? AppTheme.Colors.placeholder
                                : AppTheme.Colors.textPrimary
                        )
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.border)
                }
                .padding(14)
                .background(AppTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            // Description field
            TextField("Descrizione*", text: $viewModel.description)
                .font(.system(size: 14, weight: .medium))
                .padding(14)
                .background(AppTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Submit button
            Button(action: { viewModel.submitBookingRequest() }) {
                SwiftUI.Text("INVIA RICHIESTA")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.gradientStart,
                                AppTheme.Colors.darkPurple
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// Helper Badge (kept for backward compatibility)
struct BadgeView: View {
    let text: String
    var body: some View {
        SwiftUI.Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(AppTheme.Colors.gradientStart)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.Colors.gradientStart.opacity(0.08))
            .clipShape(Capsule())
    }
}
