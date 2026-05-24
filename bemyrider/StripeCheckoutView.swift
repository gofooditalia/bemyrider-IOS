//
//  StripeCheckoutView.swift
//  bemyrider
//
//  Modern Stripe PaymentSheet checkout (replaces old StripeCheckoutVC)
//

import SwiftUI
import Stripe
import StripePaymentSheet
import PassKit

// MARK: - ViewModel

@MainActor
final class StripeCheckoutViewModel: NSObject, ObservableObject {

    @Published var isProcessing = false
    @Published var paymentResult: PaymentSheetResult?
    @Published var alertMessage: String?
    @Published var showAlert = false

    let bookingAmount: String
    let totalFees: String
    let totalAmount: String
    let paymentIntentClientSecret: String
    let serviceRequestId: String

    /// Callback fired after successful acknowledge — pops to root
    var onPaymentSuccess: (() -> Void)?
    /// Callback fired on back button — pops one level
    var onBack: (() -> Void)?

    private(set) var paymentSheet: PaymentSheet?

    weak var presentingVC: UIViewController?

    // MARK: - Init

    init(clientSecret: String,
         bookingAmount: String,
         totalFees: String,
         totalAmount: String,
         serviceRequestId: String) {
        self.paymentIntentClientSecret = clientSecret
        self.bookingAmount = bookingAmount
        self.totalFees = totalFees
        self.totalAmount = totalAmount
        self.serviceRequestId = serviceRequestId
        super.init()
        configurePaymentSheet()
    }

    // MARK: - PaymentSheet Configuration

    private func configurePaymentSheet() {
        STPAPIClient.shared.publishableKey = Domain.Stripe_Publishable_Live_Key

        var config = PaymentSheet.Configuration()
        config.merchantDisplayName = "BeMyRider"
        config.allowsDelayedPaymentMethods = false

        // Apple Pay disabled in PaymentSheet — handled via dedicated PKPaymentButton + STPApplePayContext
        // so that the app uses an official Apple Pay button design (Guideline 4.9)

        paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntentClientSecret,
            configuration: config
        )
    }

    // MARK: - Present PaymentSheet (UIKit bridge)

    func presentPaymentSheet() {
        guard let vc = presentingVC, let sheet = paymentSheet else { return }
        isProcessing = true

        sheet.present(from: vc) { [weak self] result in
            guard let self = self else { return }
            self.isProcessing = false
            self.paymentResult = result

            switch result {
            case .completed:
                self.acknowledgePayment()
            case .canceled:
                break // user dismissed — do nothing
            case .failed(let error):
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }

    // MARK: - Apple Pay Direct

    func presentApplePay() {
        guard let merchantId = Bundle.main.object(forInfoDictionaryKey: "ApplePayMerchantID") as? String,
              !merchantId.isEmpty else {
            alertMessage = "Apple Pay non configurato"
            showAlert = true
            return
        }

        let request = StripeAPI.paymentRequest(withMerchantIdentifier: merchantId, country: "IT", currency: "EUR")

        let amountValue = Double(totalAmount) ?? 0
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "BeMyRider", amount: NSDecimalNumber(value: amountValue))
        ]

        guard let applePayContext = STPApplePayContext(paymentRequest: request, delegate: self) else {
            alertMessage = "Apple Pay non disponibile su questo dispositivo"
            showAlert = true
            return
        }

        if let vc = presentingVC {
            isProcessing = true
            applePayContext.presentApplePay(on: vc)
        }
    }

    // MARK: - Acknowledge to backend

    func acknowledgePayment() {
        isProcessing = true

        // PaymentSheet handles the full confirm flow internally;
        // on .completed the PaymentIntent is already succeeded server-side.
        // We just need to tell OUR backend about it.
        // Extract PaymentIntent ID from clientSecret (format: "pi_xxx_secret_yyy")
        let paymentIntentId = paymentIntentClientSecret.components(separatedBy: "_secret_").first ?? paymentIntentClientSecret

        let param: dictionary = [
            "payment_instant_id": paymentIntentClientSecret,
            "payment_id": paymentIntentId,
            "amount": totalAmount,
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": serviceRequestId
        ]

        guard let vc = presentingVC else { return }

        Modal.shared.serviceRequestBookWithStripe(vc: vc, param: param, failer: { [weak self] msg in
            Modal.sharedAppdelegate.stoapLoader()
            self?.isProcessing = false
            self?.alertMessage = msg
            self?.showAlert = true
        }) { [weak self] dic in
            guard let self = self else { return }
            self.isProcessing = false
            let message = ResponseKey.fetchDataInString(res: dic, valueOf: "message")
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.alertMessage = message.isEmpty ? "Prenotazione effettuata con successo!" : message
            self.showAlert = true
        }
    }
}

// MARK: - STPApplePayContextDelegate

extension StripeCheckoutViewModel: STPApplePayContextDelegate {

    nonisolated func applePayContext(
        _ context: STPApplePayContext,
        didCreatePaymentMethod paymentMethod: STPPaymentMethod,
        paymentInformation: PKPayment,
        completion: @escaping STPIntentClientSecretCompletionBlock
    ) {
        // Provide the clientSecret so Stripe can confirm the PaymentIntent with Apple Pay
        completion(paymentIntentClientSecret, nil)
    }

    nonisolated func applePayContext(
        _ context: STPApplePayContext,
        didCompleteWith status: STPPaymentStatus,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isProcessing = false
            switch status {
            case .success:
                self.paymentResult = .completed
                self.acknowledgePayment()
            case .error:
                self.alertMessage = error?.localizedDescription ?? "Errore durante il pagamento"
                self.showAlert = true
            case .userCancellation:
                break
            @unknown default:
                break
            }
        }
    }
}

// MARK: - View

struct StripeCheckoutView: View {
    @ObservedObject var viewModel: StripeCheckoutViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            content
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: SwiftUI.Text(""),
                message: SwiftUI.Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(SwiftUI.Text("OK")) {
                    if case .completed? = viewModel.paymentResult {
                        viewModel.onPaymentSuccess?()
                    }
                }
            )
        }
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

            SwiftUI.Text("Pagamento")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
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

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 8)

            // Cost summary card
            costSummaryCard

            Spacer()

            // Apple Pay official button (PKPaymentButton)
            ApplePayButtonView(action: {
                viewModel.presentApplePay()
            })
            .frame(height: 50)
            .cornerRadius(12)

            // Card pay button
            payButton

            // Secure badge
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                SwiftUI.Text("Pagamento sicuro tramite Stripe")
                    .font(AppTheme.Fonts.regular(12))
            }
            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.4))
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Cost Summary

    private var costSummaryCard: some View {
        VStack(spacing: 0) {
            // Date
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppTheme.Colors.purple)
                SwiftUI.Text(formattedDate)
                    .font(AppTheme.Fonts.medium(14))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                Spacer()
            }
            .padding(16)

            Divider().padding(.horizontal, 16)

            // Price row
            summaryRow(label: "Prezzo", value: "\(UserData.shared.currency)\(viewModel.bookingAmount)")
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            Divider().padding(.horizontal, 16)

            // Fees row
            summaryRow(label: "Commissioni", value: "\(UserData.shared.currency)\(viewModel.totalFees)")
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            Divider().padding(.horizontal, 16)

            // Total row
            HStack {
                SwiftUI.Text("Totale")
                    .font(AppTheme.Fonts.bold(18))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                Spacer()
                SwiftUI.Text("\(UserData.shared.currency)\(viewModel.totalAmount)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.orange)
            }
            .padding(16)
        }
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            SwiftUI.Text(label)
                .font(AppTheme.Fonts.regular(15))
                .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.7))
            Spacer()
            SwiftUI.Text(value)
                .font(AppTheme.Fonts.medium(15))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
        }
    }

    // MARK: - Payment Methods Info

    private var paymentMethodsInfo: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.purple)

                VStack(alignment: .leading, spacing: 2) {
                    SwiftUI.Text("Metodi di pagamento accettati")
                        .font(AppTheme.Fonts.medium(13))
                        .foregroundColor(AppTheme.Colors.charcoalGrey)
                    SwiftUI.Text("Carta di credito/debito")
                        .font(AppTheme.Fonts.regular(12))
                        .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                }

                Spacer()
            }

            ApplePayButtonView(action: {
                viewModel.presentApplePay()
            })
            .frame(height: 44)
            .cornerRadius(8)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Pay Button

    private var payButton: some View {
        Button(action: {
            viewModel.presentPaymentSheet()
        }) {
            HStack(spacing: 10) {
                if viewModel.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                }
                SwiftUI.Text(viewModel.isProcessing ? "Elaborazione..." : "Paga \(UserData.shared.currency)\(viewModel.totalAmount)")
                    .font(AppTheme.Fonts.bold(18))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                viewModel.isProcessing
                    ? AppTheme.Colors.orange.opacity(0.6)
                    : AppTheme.Colors.orange
            )
            .cornerRadius(14)
            .shadow(color: AppTheme.Colors.orange.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(viewModel.isProcessing)
    }

    // MARK: - Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Official Apple Pay Button (PKPaymentButton wrapper)

struct ApplePayButtonView: UIViewRepresentable {
    let action: () -> Void

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .book, paymentButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.tapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        let action: () -> Void
        init(action: @escaping () -> Void) { self.action = action }
        @objc func tapped() { action() }
    }
}
