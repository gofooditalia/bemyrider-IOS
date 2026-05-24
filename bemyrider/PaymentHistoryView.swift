//
//  PaymentHistoryView.swift
//  bemyrider
//
//  Modernized SwiftUI view for Payment History
//  with gradient header and card-based layout.
//

import SwiftUI

struct PaymentHistoryView: View {

    @ObservedObject var viewModel: PaymentHistoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentArea
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.load(reset: true) }
    }

    // MARK: - Header with gradient

    private var headerSection: some View {
        VStack(spacing: 16) {
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

    // MARK: - Content area

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && viewModel.transactions.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
        } else if viewModel.transactions.isEmpty {
            emptyState
        } else {
            transactionList
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "creditcard")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessuna transazione")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)

            SwiftUI.Text("Le tue transazioni appariranno qui")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Transaction list

    private var transactionList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.transactions.enumerated()), id: \.offset) { index, transaction in
                    TransactionCard(transaction: transaction)
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
    }
}

// MARK: - Transaction Card

private struct TransactionCard: View {

    let transaction: DepositHistoryList

    private var isPositive: Bool {
        guard let amount = Double(transaction.amount.replacingOccurrences(of: "-", with: "")) else { return false }
        return amount > 0
    }

    private var formattedAmount: String {
        return transaction.amount
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(SwiftUI.Color.green.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "banknote")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(SwiftUI.Color.green)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text("Transazione")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                if !transaction.transaction_id.isEmpty {
                    Text("ID: \(transaction.transaction_id)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.Colors.placeholder)
                        .lineLimit(1)
                }

                Text(transaction.date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.Colors.placeholder)
            }

            Spacer()

            // Amount
            Text(formattedAmount)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isPositive ? SwiftUI.Color.green : AppTheme.Colors.orange)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
