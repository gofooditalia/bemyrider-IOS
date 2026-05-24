//
//  MyServicesView.swift
//  TaskGator
//
//  SwiftUI View for MyServices screen.
//

import SwiftUI

struct MyServicesView: View {
    @ObservedObject var viewModel: MyServicesViewModel
    var showHeader: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            if showHeader { headerSection }
            contentArea
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
    
    // MARK: - Header Section
    
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

            Text("I miei servizi")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            
            if !Modal.sharedAppdelegate.isCustomerLogin {
                Button(action: {
                    viewModel.addNewService()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(SwiftUI.Color.white)
                        .frame(width: 36, height: 36)
                        .background(SwiftUI.Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
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
    
    // MARK: - Content Area
    
    @ViewBuilder
    private var contentArea: some View {
        VStack(spacing: 0) {
            searchBarSection
            
            if viewModel.isLoading && viewModel.services.isEmpty {
                Spacer()
            } else if viewModel.showNoRecords {
                Spacer()
                noRecordsView
                Spacer()
            } else {
                servicesList
            }
        }
    }
    
    // MARK: - Search Bar Section
    
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.placeholder)
                
                TextField("Search services...", text: $viewModel.searchText)
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.refresh()
                    }
            }
            .padding(12)
            .background(SwiftUI.Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(SwiftUI.Color.white)
    }
    
    // MARK: - Services List
    
    private var servicesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.filteredServices.enumerated()), id: \.offset) { index, service in
                    ServiceCard(service: service)
                        .onTapGesture {
                            viewModel.selectService(service)
                        }
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: service)
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - No Records View
    
    private var noRecordsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.purple.opacity(0.5))
            
            Text("No Services Yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
            
            if !Modal.sharedAppdelegate.isCustomerLogin {
                Text("Add your first service to start receiving bookings")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.Colors.placeholder)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    viewModel.addNewService()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Service")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.orange)
                    .cornerRadius(12)
                    .shadow(color: AppTheme.Colors.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Service Card

struct ServiceCard: View {
    let service: ProviderService
    
    var body: some View {
        HStack(spacing: 14) {
            RemoteImageView(service.service_image, contentMode: .scaleAspectFill)
                .frame(width: 70, height: 70)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(service.service_name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.purple)
                    Text(service.category_name)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.Colors.placeholder)
                }
                
                if !service.address.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.Colors.lightGrey)
                        Text(service.address)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(AppTheme.Colors.lightGrey)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(UserData.shared.currency)\(service.price)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.orange)
                
                if service.service_type == "hourly" {
                    Text("/ora")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.Colors.placeholder)
                }
            }
        }
        .padding(14)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
    }
}
