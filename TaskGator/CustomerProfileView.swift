//
//  CustomerProfileView.swift
//  TaskGator
//
//  Modernized SwiftUI view for Customer Profile
//  with gradient header, stats bar, and card-based layout.
//

import SwiftUI

struct CustomerProfileView: View {

    @ObservedObject var viewModel: CustomerProfileViewModel

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
        VStack(spacing: 16) {
            // Top bar
            HStack(spacing: 12) {
                Button(action: { viewModel.onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(SwiftUI.Color.white.opacity(0.18))
                        .clipShape(Circle())
                }

                SwiftUI.Text("Profilo")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if viewModel.isOwnProfile {
                    Button(action: { viewModel.onEditTap?() }) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(SwiftUI.Color.white.opacity(0.18))
                            .clipShape(Circle())
                    }
                }
            }

            // Avatar + Name + Rating
            VStack(spacing: 14) {
                avatarView
                    .frame(width: 96, height: 96)
                    .shadow(color: SwiftUI.Color.black.opacity(0.2), radius: 12, x: 0, y: 6)

                Text(viewModel.displayName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                if let rating = viewModel.profile?.star_rating, rating > 0 {
                    HStack(spacing: 6) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: starIcon(for: index, rating: rating))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.gold)
                            }
                        }
                        if let reviews = viewModel.profile?.total_review, !reviews.isEmpty {
                            SwiftUI.Text("(\(reviews))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }

            // Edit button pill
            if viewModel.isOwnProfile {
                Button(action: { viewModel.onEditTap?() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 13, weight: .medium))
                        SwiftUI.Text("Modifica Profilo")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.Colors.purple)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(SwiftUI.Color.white)
                    .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
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

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && viewModel.profile == nil {
            Spacer()
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Quick stats
                    if viewModel.profile != nil {
                        statsRow
                    }

                    contactInfoCard
                    paymentMethodCard
                    socialAccountsCard
                    if viewModel.hasCompanyInfo {
                        companyInfoCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Quick Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(
                icon: "phone.fill",
                color: AppTheme.Colors.teal,
                bgColor: AppTheme.Colors.successLightBg,
                label: "Telefono",
                value: viewModel.profile?.contact_number.isEmpty == false ? "Attivo" : "—"
            )

            statDivider

            statItem(
                icon: "envelope.fill",
                color: AppTheme.Colors.purple,
                bgColor: AppTheme.Colors.lightPurple,
                label: "Email",
                value: viewModel.profile?.email.isEmpty == false ? "Attiva" : "—"
            )

            statDivider

            statItem(
                icon: viewModel.profile?.payment_mode == "w" ? "creditcard.fill" : "banknote.fill",
                color: AppTheme.Colors.orange,
                bgColor: AppTheme.Colors.lightOrange,
                label: "Pagamento",
                value: viewModel.paymentMethodText
            )
        }
        .padding(.vertical, 16)
        .background(
            SwiftUI.Color.white
                .cornerRadius(20)
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
    }

    private func statItem(icon: String, color: SwiftUI.Color, bgColor: SwiftUI.Color, label: String, value: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(AppTheme.Colors.separator)
            .frame(width: 1, height: 44)
    }

    // MARK: - Avatar

    @ViewBuilder
    private var avatarView: some View {
        if let imgURL = viewModel.profile?.profile_img, !imgURL.isEmpty {
            RemoteImageView(imgURL,
                            contentMode: .scaleAspectFill,
                            placeholder: UIImage(named: "user_placeholder"))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(SwiftUI.Color.white.opacity(0.5), lineWidth: 3)
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
                Image(systemName: "person.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Contact Info Card

    private var contactInfoCard: some View {
        modernCard(icon: "person.crop.circle", iconColor: AppTheme.Colors.purple, title: "Informazioni di Contatto") {
            VStack(spacing: 0) {
                infoRow(icon: "phone.fill", title: "Telefono", value: viewModel.phoneNumber)
                thinDivider
                infoRow(icon: "envelope.fill", title: "Email", value: viewModel.profile?.email ?? "")
                if let address = viewModel.profile?.address, !address.isEmpty {
                    thinDivider
                    infoRow(icon: "mappin.circle.fill", title: "Indirizzo", value: address)
                }
            }
        }
    }

    // MARK: - Payment Method Card

    private var paymentMethodCard: some View {
        modernCard(icon: "creditcard", iconColor: AppTheme.Colors.orange, title: "Metodo di Pagamento") {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.Colors.lightOrange)
                        .frame(width: 48, height: 48)
                    Image(systemName: viewModel.profile?.payment_mode == "w" ? "creditcard.fill" : "banknote.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppTheme.Colors.orange)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.paymentMethodText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.charcoalGrey)
                    Text("Metodo preferito")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.Colors.placeholder)
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.success)
            }
        }
    }

    // MARK: - Social Accounts Card

    private var socialAccountsCard: some View {
        modernCard(icon: "link.circle", iconColor: AppTheme.Colors.teal, title: "Account Collegati") {
            VStack(spacing: 0) {
                socialRow(icon: "f.circle.fill",
                          color: AppTheme.Colors.navyBlue,
                          title: "Facebook",
                          isVerified: viewModel.isFacebookVerified)
                thinDivider
                socialRow(icon: "g.circle.fill",
                          color: AppTheme.Colors.deepRed,
                          title: "Google",
                          isVerified: viewModel.isGoogleVerified)
                thinDivider
                socialRow(icon: "in.circle.fill",
                          color: AppTheme.Colors.oceanBlue,
                          title: "LinkedIn",
                          isVerified: viewModel.isLinkedInVerified)
            }
        }
    }

    // MARK: - Company Info Card

    private var companyInfoCard: some View {
        modernCard(icon: "building.2", iconColor: AppTheme.Colors.purple, title: "Informazioni Aziendali") {
            VStack(spacing: 0) {
                if let company = viewModel.profile?.company_name, !company.isEmpty {
                    infoRow(icon: "building.2.fill", title: "Azienda", value: company)
                    if hasMoreCompanyRows(after: "company") { thinDivider }
                }
                if let vat = viewModel.profile?.vat, !vat.isEmpty {
                    infoRow(icon: "number.circle.fill", title: "Partita IVA", value: vat)
                    if hasMoreCompanyRows(after: "vat") { thinDivider }
                }
                if let receipt = viewModel.profile?.receipt_code, !receipt.isEmpty {
                    infoRow(icon: "doc.text.fill", title: "Codice Scontrino", value: receipt)
                    if hasMoreCompanyRows(after: "receipt") { thinDivider }
                }
                if let certified = viewModel.profile?.certified_email, !certified.isEmpty {
                    infoRow(icon: "envelope.badge.fill", title: "Email Certificata", value: certified)
                }
            }
        }
    }

    // MARK: - Modern Card Container

    private func modernCard<Content: View>(icon: String, iconColor: SwiftUI.Color, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
            }

            content()
        }
        .padding(20)
        .background(
            SwiftUI.Color.white
                .cornerRadius(20)
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
    }

    // MARK: - Info Row

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.Colors.cardBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.Colors.purple)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.Colors.placeholder)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    // MARK: - Social Row

    private func socialRow(icon: String, color: SwiftUI.Color, title: String, isVerified: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isVerified ? color : AppTheme.Colors.borderMedium)
                .frame(width: 32)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.charcoalGrey)

            Spacer()

            if isVerified {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text("Collegato")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(AppTheme.Colors.success)
            } else {
                Text("Non collegato")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.Colors.placeholder)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private var thinDivider: some View {
        Rectangle()
            .fill(AppTheme.Colors.subtleBackground)
            .frame(height: 1)
            .padding(.leading, 54)
    }

    private func hasMoreCompanyRows(after field: String) -> Bool {
        guard let p = viewModel.profile else { return false }
        switch field {
        case "company":
            return !p.vat.isEmpty || !p.receipt_code.isEmpty || !p.certified_email.isEmpty
        case "vat":
            return !p.receipt_code.isEmpty || !p.certified_email.isEmpty
        case "receipt":
            return !p.certified_email.isEmpty
        default:
            return false
        }
    }

    private func starIcon(for index: Int, rating: Double) -> String {
        let position = Double(index) + 1
        if rating >= position { return "star.fill" }
        else if rating >= position - 0.5 { return "star.leadinghalf.filled" }
        else { return "star" }
    }
}