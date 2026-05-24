//
//  ProviderPaymentHistoryView.swift
//  bemyrider
//
//  SwiftUI View for Provider Payment History screen.
//

import SwiftUI

struct ProviderPaymentHistoryView: View {
    @ObservedObject var viewModel: ProviderPaymentHistoryViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.showNoRecords {
                noRecordsView
            } else {
                transactionsList
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            Task {
                await viewModel.loadTransactions()
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

                SwiftUI.Text("Storico Pagamenti")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            SwiftUI.Text("Visualizza le tue transazioni")
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
    
    // MARK: - No Records View
    
    private var noRecordsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.5))
            Text("No Payment History")
                .font(AppTheme.Fonts.medium(16))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Transactions List
    
    private var transactionsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.transactions.enumerated()), id: \.offset) { index, transaction in
                    ProviderTransactionCard(transaction: transaction)
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: transaction)
                        }
                }
                
                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
    }
}

// MARK: - Provider Transaction Card

struct ProviderTransactionCard: View {
    let transaction: PaymentHistory.TransactionList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RemoteImageView(transaction.profile_image)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.username)
                        .font(AppTheme.Fonts.medium(16))
                        .foregroundColor(AppTheme.Colors.charcoalGrey)
                    
                    Text(transaction.servicename)
                        .font(AppTheme.Fonts.regular(14))
                        .foregroundColor(AppTheme.Colors.placeholder)
                }
                
                Spacer()
                
                Text(transaction.recived_amount)
                    .font(AppTheme.Fonts.bold(16))
                    .foregroundColor(AppTheme.Colors.orange)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Transaction ID".localized, value: transaction.transection_id)
                InfoRow(label: "Received Amount".localized, value: transaction.recived_amount)
                InfoRow(label: "Date Of Completion".localized, value: transaction.completion_date)
                InfoRow(label: "Total Working Hours".localized, value: transaction.totel_hours)
            }
        }
        .padding()
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Fonts.regular(13))
                .foregroundColor(AppTheme.Colors.placeholder)
            Spacer()
            Text(value)
                .font(AppTheme.Fonts.medium(13))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
        }
    }
}
