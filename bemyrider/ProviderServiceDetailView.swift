//
//  ProviderServiceDetailView.swift
//  bemyrider
//
//  SwiftUI View for Provider Service Detail screen.
//

import SwiftUI

struct ProviderServiceDetailView: View {
    @ObservedObject var viewModel: ProviderServiceDetailViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            tabBar
            tabContent
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
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

            SwiftUI.Text(viewModel.providerService?.service_name ?? viewModel.serviceDetail?.service_name ?? "Dettaglio Servizio")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            Button(action: { viewModel.onEditService?() }) {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(SwiftUI.Color.white.opacity(0.18))
                    .clipShape(Circle())
            }

            Button(action: { viewModel.onDeleteService?() }) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.error)
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
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<viewModel.tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        viewModel.selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(viewModel.tabs[index])
                            .font(AppTheme.Fonts.medium(14))
                            .foregroundColor(viewModel.selectedTab == index ? AppTheme.Colors.purple : AppTheme.Colors.placeholder)

                        Rectangle()
                            .fill(viewModel.selectedTab == index ? AppTheme.Colors.purple : SwiftUI.Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .background(SwiftUI.Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case 0:
            serviceInfoTab
        case 1:
            reviewsTab
        case 2:
            galleryTab
        default:
            serviceInfoTab
        }
    }
    
    // MARK: - Service Info Tab
    
    private var serviceInfoTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let detail = viewModel.serviceDetail {
                    ServiceInfoCard(title: "Descrizione", content: detail._description)
                    ServiceInfoCard(title: "Categoria", content: detail.category_name)
                    ServiceInfoCard(title: "Sottocategoria", content: detail.sub_category_name)
                    ServiceInfoCard(title: "Tariffa", content: "\(UserData.shared.currency)\(detail.price)")
                    ServiceInfoCard(title: "Tipo", content: detail.service_master_type == "hourly" ? "Oraria" : "Fissa")
                }
            }
            .padding()
        }
    }
    
    // MARK: - Reviews Tab
    
    private var reviewsTab: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let reviews = viewModel.serviceDetail?.review_data, !reviews.isEmpty {
                    ForEach(Array(reviews.enumerated()), id: \.offset) { _, review in
                        ReviewCard(review: review)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.Colors.placeholder)
                        Text("Nessuna Recensione")
                            .font(AppTheme.Fonts.medium(16))
                            .foregroundColor(AppTheme.Colors.placeholder)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Gallery Tab
    
    private var galleryTab: some View {
        ScrollView {
            if let media = viewModel.serviceDetail?.media_data, !media.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(Array(media.enumerated()), id: \.offset) { _, item in
                        RemoteImageView(item.media_url)
                            .frame(height: 120)
                            .clipped()
                    }
                }
                .padding()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.Colors.placeholder)
                    Text("Nessuna Immagine")
                        .font(AppTheme.Fonts.medium(16))
                        .foregroundColor(AppTheme.Colors.placeholder)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            }
        }
    }
}

// MARK: - Service Info Card

struct ServiceInfoCard: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTheme.Fonts.medium(12))
                .foregroundColor(AppTheme.Colors.placeholder)
            Text(content)
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(SwiftUI.Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Review Card

struct ReviewCard: View {
    let review: ProviderServiceDetail.ReviewData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RemoteImageView(review.profile_img)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.user_name)
                        .font(AppTheme.Fonts.medium(14))
                        .foregroundColor(AppTheme.Colors.charcoalGrey)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < (Int(review.rating) ?? 0) ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Spacer()
            }
            
            Text(review.review)
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
            
            Text(review.created_date)
                .font(AppTheme.Fonts.regular(12))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .padding()
        .background(SwiftUI.Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
