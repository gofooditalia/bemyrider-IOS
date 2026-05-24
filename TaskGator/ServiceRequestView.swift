//
//  ServiceRequestView.swift
//  TaskGator
//
//  SwiftUI replacement for ServiceRequest + ServiceRequestTableVC.
//  Supports both button-tap and swipe to switch tabs.
//

import SwiftUI

struct ServiceRequestView: View {

    @ObservedObject var viewModel: ServiceRequestViewModel
    @StateObject private var bulkDownloadViewModel = BulkInvoiceDownloadViewModel()
    @Namespace private var tabIndicator

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerSection
                tabBar
                if !viewModel.isCustomer {
                    searchBar
                }
                pageContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .onChange(of: viewModel.isLoading) { loading in
                if loading && isListEmpty {
                    Modal.sharedAppdelegate.startLoader()
                } else {
                    Modal.sharedAppdelegate.stoapLoader()
                }
            }

            // FAB per download bulk invoices (solo nel tab PAST)
            if viewModel.selectedTab == .past {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(icon: "arrow.down.circle.fill") {
                            bulkDownloadViewModel.startBulkDownload()
                        }
                        .padding([.trailing, .bottom], 16)
                    }
                }
            }

            // Loading overlay durante il download
            if bulkDownloadViewModel.isLoading {
                SwiftUI.Color.black.opacity(0.4)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(.white)
                    SwiftUI.Text("Generazione ricevute in corso...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $bulkDownloadViewModel.showPeriodSelector) {
            BulkInvoicePeriodSelector(isPresented: $bulkDownloadViewModel.showPeriodSelector) { period in
                bulkDownloadViewModel.handlePeriodSelection(period)
            }
        }
        .alert(isPresented: Binding(
            get: { bulkDownloadViewModel.errorMessage != nil },
            set: { if !$0 { bulkDownloadViewModel.clearMessages() } }
        )) {
            Alert(
                title: SwiftUI.Text("Errore"),
                message: SwiftUI.Text(bulkDownloadViewModel.errorMessage ?? ""),
                dismissButton: .default(SwiftUI.Text("OK")) {
                    bulkDownloadViewModel.clearMessages()
                }
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            SwiftUI.Text("Richieste Servizio")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 24)
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

    // MARK: - Tab bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ServiceRequestViewModel.Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.selectTab(tab)
                    }
                } label: {
                    VStack(spacing: 8) {
                        SwiftUI.Text(tab.title)
                            .font(.system(size: 13, weight: viewModel.selectedTab == tab ? .semibold : .medium))
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
                                    .matchedGeometryEffect(id: "indicator", in: tabIndicator)
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
        .padding(.top, 12)
        .background(SwiftUI.Color.white)
    }

    // MARK: - Search bar (provider only)

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.textCaption)
                .font(.system(size: 16, weight: .medium))

            TextField("Cerca...", text: $viewModel.keyword, onCommit: {
                viewModel.search()
            })
            .foregroundColor(AppTheme.Colors.textDark)
            .font(.system(size: 14, weight: .medium))

            if !viewModel.keyword.isEmpty {
                Button {
                    viewModel.keyword = ""
                    viewModel.search()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.border)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(SwiftUI.Color.white)
    }

    // MARK: - Page content

    private var isListEmpty: Bool {
        viewModel.isCustomer
            ? viewModel.customerItems.isEmpty
            : viewModel.providerItems.isEmpty
    }

    @ViewBuilder
    private var pageContent: some View {
        if viewModel.isCustomer {
            customerList
        } else {
            providerList
        }
    }

    // MARK: - Customer list

    private var customerList: some View {
        Group {
            if viewModel.customerItems.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(Array(viewModel.customerItems.enumerated()), id: \.offset) { index, item in
                        Button(action: { viewModel.onTapCustomerItem?(item) }) {
                            serviceCard(
                                imageURL: item.provider_image,
                                name: item.provider_fname + " " + item.provider_lname,
                                serviceName: item.service_name,
                                date: item.booking_start_time,
                                amount: "\(UserData.shared.currency)\(item.booking_amount)",
                                status: item.service_status,
                                statusLabel: item.service_status_dis
                            )
                        }
                        .buttonStyle(MessageCardButtonStyle())
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(SwiftUI.Color.clear)
                        .listRowSeparatorCompat()
                        .onAppear { viewModel.loadMoreIfNeeded(index: index) }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .listRowBackground(SwiftUI.Color.clear)
                            .listRowSeparatorCompat()
                    }
                }
                .listStyle(.plain)
                .background(AppTheme.Colors.background)
                .refreshableCompat { viewModel.refresh() }
            }
        }
    }

    // MARK: - Provider list

    private var providerList: some View {
        Group {
            if viewModel.providerItems.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(Array(viewModel.providerItems.enumerated()), id: \.offset) { index, item in
                        Button(action: { viewModel.onTapProviderItem?(item) }) {
                            serviceCard(
                                imageURL: item.customer_image,
                                name: item.customer_name,
                                serviceName: item.service_name,
                                date: item.booking_start_time,
                                amount: "\(UserData.shared.currency)\(item.booking_amount)",
                                status: item.service_status,
                                statusLabel: item.service_status_dis
                            )
                        }
                        .buttonStyle(MessageCardButtonStyle())
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(SwiftUI.Color.clear)
                        .listRowSeparatorCompat()
                        .onAppear { viewModel.loadMoreIfNeeded(index: index) }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .listRowBackground(SwiftUI.Color.clear)
                            .listRowSeparatorCompat()
                    }
                }
                .listStyle(.plain)
                .background(AppTheme.Colors.background)
                .refreshableCompat { viewModel.refresh() }
            }
        }
    }

    // MARK: - Service Card

    private func serviceCard(
        imageURL: String,
        name: String,
        serviceName: String,
        date: String,
        amount: String,
        status: String,
        statusLabel: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            if !imageURL.isEmpty {
                RemoteImageView(imageURL,
                               contentMode: .scaleAspectFill,
                               placeholder: UIImage(named: "user_placeholder"))
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                let initials = avatarInitials(name)
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
                        .frame(width: 48, height: 48)
                    SwiftUI.Text(initials)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                SwiftUI.Text(name.isEmpty ? "Utente" : name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                if !serviceName.isEmpty {
                    SwiftUI.Text(serviceName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.Colors.badgeOrange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(AppTheme.Colors.lightOrange)
                        .clipShape(Capsule())
                }

                if !date.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        SwiftUI.Text(date)
                            .font(.system(size: 11.5, weight: .medium))
                    }
                    .foregroundColor(AppTheme.Colors.textCaption)
                    .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right side: amount + status
            VStack(alignment: .trailing, spacing: 6) {
                SwiftUI.Text(amount)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                SwiftUI.Text(statusLabel.capitalizingFirstLetter())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SwiftUI.Color(StatusState.setStatusColor(status: status)))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessun risultato")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func avatarInitials(_ name: String) -> String {
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

    @ViewBuilder
    func listRowSeparatorCompat() -> some View {
        if #available(iOS 15, *) {
            self.listRowSeparator(.hidden)
        } else {
            self
        }
    }
}
