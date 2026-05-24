//
//  FavouritesView.swift
//  TaskGator
//
//  Modernized SwiftUI view for favourite services with gradient header,
//  card-based layout, and modern UI components.
//

import SwiftUI

struct FavouritesView: View {

    @ObservedObject var viewModel: FavouritesViewModel
    @State private var itemToDelete: FavoriteService?

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentArea
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.load(reset: true) }
        .alert(item: $itemToDelete) { item in
            Alert(
                title: Text("Rimuovi dai Preferiti"),
                message: Text("Sei sicuro di voler rimuovere \(item.provider_name) dai preferiti?"),
                primaryButton: .destructive(Text("Rimuovi")) {
                    viewModel.removeItem(item)
                },
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - Header with gradient

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                SwiftUI.Text("I tuoi Preferiti")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            searchField
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

    // MARK: - Search field

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)

            TextField("Cerca nei preferiti...", text: $viewModel.keyword)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.textDark)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if !viewModel.keyword.isEmpty {
                Button {
                    viewModel.keyword = ""
                    viewModel.search()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.border)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(SwiftUI.Color.white)
        .clipShape(Capsule())
    }

    // MARK: - Content area

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && viewModel.items.isEmpty {
            Spacer()
        } else if viewModel.items.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                        FavouriteCard(item: item, onDelete: {
                            itemToDelete = item
                        })
                        .onTapGesture { viewModel.onTapItem?(item) }
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
            .refreshableCompat { viewModel.refresh() }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessun preferito trovato")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)

            SwiftUI.Text("I servizi che aggiungi ai preferiti\nappariranno qui")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.placeholder)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Favourite Card (modern style)

private struct FavouriteCard: View {

    let item: FavoriteService
    let onDelete: () -> Void

    private var displayName: String {
        switch item.delivery_type.lowercased() {
        case "small":  return "E-Bike"
        case "medium": return "Moto"
        case "large":  return "Auto"
        default:       return item.service_name
        }
    }

    private var deliveryIcon: String {
        switch item.delivery_type.lowercased() {
        case "small":  return "bicycle"
        case "medium": return "car.fill"
        case "large":  return "van.fill"
        default:       return "bicycle"
        }
    }

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                // Avatar
                avatarView
                    .frame(width: 56, height: 56)

                // Info
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Image(systemName: deliveryIcon)
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.Colors.purple)

                        Text(displayName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }

                    Text(item.provider_name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textCaption)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Delete button
                Button(action: onDelete) {
                    ZStack {
                        Circle()
                            .fill(SwiftUI.Color.red.opacity(0.10))
                            .frame(width: 36, height: 36)
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(SwiftUI.Color.red)
                    }
                }
                .buttonStyle(PlainButtonStyle())
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
        if !item.profile_img.isEmpty {
            RemoteImageView(item.profile_img,
                            contentMode: .scaleAspectFill,
                            placeholder: UIImage(named: "user_placeholder"))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppTheme.Colors.lightPurple, lineWidth: 1)
                )
        } else {
            let initials = avatarInitials(from: item.provider_name)
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
                Text(initials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(SwiftUI.Color.white)
            }
        }
    }

    private func avatarInitials(from name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Refreshable compat (iOS 14 safe)

private extension View {
    @ViewBuilder
    func refreshableCompat(action: @escaping () -> Void) -> some View {
        if #available(iOS 15, *) {
            self.refreshable { action() }
        } else {
            self
        }
    }
}
