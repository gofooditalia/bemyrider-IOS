//
//  HomeView.swift
//  TaskGator
//
//  Customer home screen: gradient header, vehicle-type tabs (E-Bike / Moto / Auto),
//  search bar, filters, scrollable provider cards.
//

import SwiftUI

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel
    @Namespace private var vehicleIndicator

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            vehicleTabBar
            providerListSection
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            viewModel.loadProviders(reset: true)
        }
        .onChange(of: viewModel.selectedTab) { _ in
            viewModel.loadProviders(reset: true)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            SwiftUI.Text("Trova il tuo rider")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                searchField
                filterButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
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

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.textCaption)
                .font(.system(size: 16, weight: .medium))

            TextField("Cerca rider...", text: $viewModel.searchKeyword)
                .foregroundColor(AppTheme.Colors.textDark)
                .font(.system(size: 14, weight: .medium))

            if !viewModel.searchKeyword.isEmpty {
                Button(action: {
                    viewModel.searchKeyword = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.border)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(SwiftUI.Color.white)
        .clipShape(Capsule())
    }

    private var filterButton: some View {
        Button(action: { viewModel.onOpenFilter?() }) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(SwiftUI.Color.white.opacity(0.18))
                .clipShape(Circle())
        }
    }

    // MARK: - Vehicle tab bar

    private var vehicleTabBar: some View {
        HStack(spacing: 0) {
            ForEach(VehicleTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 13, weight: .medium))
                            SwiftUI.Text(tab.rawValue)
                                .font(.system(size: 13, weight: viewModel.selectedTab == tab ? .semibold : .medium))
                        }
                        .foregroundColor(
                            viewModel.selectedTab == tab
                                ? AppTheme.Colors.gradientStart
                                : AppTheme.Colors.greyLight
                        )
                        .animation(.easeOut(duration: 0.2), value: viewModel.selectedTab)

                        ZStack {
                            if viewModel.selectedTab == tab {
                                Capsule()
                                    .fill(AppTheme.Colors.gradientStart)
                                    .frame(height: 3)
                                    .matchedGeometryEffect(id: "vehicleIndicator", in: vehicleIndicator)
                            } else {
                                Capsule()
                                    .fill(SwiftUI.Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .background(SwiftUI.Color.white)
    }

    // MARK: - Provider list

    private var providerListSection: some View {
        Group {
            if viewModel.isLoading && viewModel.providers.isEmpty {
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.providers.isEmpty {
                emptyView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.providers, id: \.provider_id) { provider in
                            ProviderCardView(provider: provider) {
                                viewModel.onTapProvider?(provider)
                            }
                            .onAppear {
                                viewModel.loadMoreIfNeeded(provider: provider)
                            }
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
    }

    private var emptyView: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessun rider disponibile")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ProviderCardView

private struct ProviderCardView: View {

    let provider: DeliveryProivderList
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar
                avatarView
                    .frame(width: 56, height: 56)

                // Info
                VStack(alignment: .leading, spacing: 5) {
                    SwiftUI.Text("\(provider.provider_first_name) \(provider.provider_last_name)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.Colors.starYellow)
                        SwiftUI.Text(provider.avg_rating.isEmpty ? "-" : provider.avg_rating)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    // Location
                    if !provider.address.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 10))
                            SwiftUI.Text(provider.address)
                                .font(.system(size: 11.5, weight: .medium))
                                .lineLimit(1)
                        }
                        .foregroundColor(AppTheme.Colors.textCaption)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Price badge
                if !provider.hour_rate.isEmpty {
                    SwiftUI.Text(provider.hour_rate)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.badgeOrange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.Colors.lightOrange)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(SwiftUI.Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(MessageCardButtonStyle())
    }

    @ViewBuilder
    private var avatarView: some View {
        if !provider.provider_image.isEmpty {
            RemoteImageView(provider.provider_image,
                           contentMode: .scaleAspectFill,
                           placeholder: UIImage(named: "user_placeholder"))
                .clipShape(Circle())
        } else {
            let name = "\(provider.provider_first_name) \(provider.provider_last_name)"
            let parts = name.split(separator: " ")
            let initials = parts.count >= 2
                ? String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
                : String(name.prefix(2)).uppercased()
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
                SwiftUI.Text(initials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}
