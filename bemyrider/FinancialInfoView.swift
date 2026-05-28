//
//  FinancialInfoView.swift
//  bemyrider
//
//  SwiftUI View for Financial Info screen.
//

import SwiftUI

struct FinancialInfoView: View {
    @ObservedObject var viewModel: FinancialInfoViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView {
                VStack(spacing: 16) {
                    descriptionText

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        totalEarnedCard
                        completedServicesCard
                        commissionCard
                        netEarnedCard
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                Button(action: { viewModel.onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(SwiftUI.Color.white.opacity(0.18))
                        .clipShape(Circle())
                }

                SwiftUI.Text("Info Finanziarie")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            SwiftUI.Text("Riepilogo dei tuoi guadagni")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
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
    
    // MARK: - Description
    
    private var descriptionText: some View {
        Text("Credits of ongoing projects, and that can be given to provider after task completion.")
            .font(AppTheme.Fonts.regular(14))
            .foregroundColor(AppTheme.Colors.charcoalGrey)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    // MARK: - Cards
    
    private var totalEarnedCard: some View {
        FinancialCard(
            title: "Total Earned".localized,
            value: viewModel.totalEarned,
            icon: "dollarsign.circle.fill",
            color: AppTheme.Colors.orange
        )
    }
    
    private var completedServicesCard: some View {
        FinancialCard(
            title: "Completed Services".localized,
            value: viewModel.completedServices,
            icon: "checkmark.circle.fill",
            color: AppTheme.Colors.purple
        )
    }
    
    private var commissionCard: some View {
        FinancialCard(
            title: "Commission".localized,
            value: viewModel.commission,
            icon: "percent",
            color: .red
        )
    }
    
    private var netEarnedCard: some View {
        FinancialCard(
            title: "Net Earned".localized,
            value: viewModel.netEarned,
            icon: "banknote.fill",
            color: AppTheme.Colors.purple
        )
    }
}

// MARK: - Financial Card Component

struct FinancialCard: View {
    let title: String
    let value: String
    let icon: String
    let color: SwiftUI.Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                
                Text(value)
                    .font(AppTheme.Fonts.bold(18))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
