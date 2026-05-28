import SwiftUI

struct CustomerSideServiceDetailView: View {
    @ObservedObject var viewModel: CustomerSideServiceDetailViewModel
    @State private var showImagePreview = false
    @State private var showCancelSheet = false
    @State private var cancelReasonIndex = 0
    @State private var confirmText = ""
    @State private var acceptedTerms = false
    @State private var showCancelSuccess = false

    private let cancelReasons = [
        "Seleziona motivo",
        "Servizio non più necessario",
        "Prezzo errato",
        "Il rider ha richiesto la cancellazione",
        "Ho trovato un altro rider",
        "Altro"
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerSection

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if let detail = viewModel.serviceDetail {
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            VStack(spacing: 12) {
                                // 1. Rider card — sempre in cima
                                providerCard(detail: detail)

                                // 2. Costo + Orario — info cruciale in evidenza
                                costAndTimeCard(detail: detail)

                                // 3. Dove svolgere il servizio
                                if !detail.service_address.isEmpty {
                                    locationCard(detail: detail)
                                }

                                // 4. Istruzioni dal cliente
                                if !detail._description.isEmpty {
                                    instructionsCard(detail: detail)
                                }

                                // 5. Commissioni
                                if !detail.customer_commission_amount.isEmpty,
                                   detail.customer_commission_amount != "0",
                                   detail.customer_commission_amount != "0.0" {
                                    commissionCard(detail: detail)
                                }

                                Spacer(minLength: hasAnyButton ? 80 : 16)
                            }
                            .padding(16)
                        }

                        if hasAnyButton {
                            bottomButtons(detail: detail)
                        }
                    }
                }
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())

            if showImagePreview, let detail = viewModel.serviceDetail {
                imagePreviewOverlay(url: detail.provider_image)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .sheet(isPresented: $showCancelSheet) {
            cancelConfirmationSheet
        }
        .alert(isPresented: $viewModel.cancelDidSucceed) {
            Alert(
                title: Text("Prenotazione Cancellata"),
                message: Text("La prenotazione è stata cancellata con successo."),
                dismissButton: .default(Text("OK")) {
                    viewModel.onCancelSuccess?()
                }
            )
        }
        .overlay(
            Group {
                if viewModel.showDisputePopup {
                    RaiseDisputePopupView(
                        isPresented: $viewModel.showDisputePopup,
                        serviceRequestId: viewModel.customerItem?.service_request_id ?? "",
                        onSuccess: {
                            viewModel.onDisputeSuccess?()
                        }
                    )
                    .transition(.opacity)
                }
            }
        )
    }

    // MARK: - Cancel Confirmation Sheet

    private var cancelConfirmationSheet: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(SwiftUI.Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Conferma Annullamento")
                        .font(AppTheme.Fonts.bold(22))
                        .foregroundColor(AppTheme.Colors.charcoalGrey)

                    // Warning text
                    Text("Attenzione! Stai per annullare la prenotazione. Per procedere, digita 'CANCELLA' nel campo sottostante per confermare.")
                        .font(AppTheme.Fonts.regular(15))
                        .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)

                    // Reason picker
                    VStack(alignment: .leading, spacing: 6) {
                        Menu {
                            ForEach(0..<cancelReasons.count, id: \.self) { index in
                                Button(cancelReasons[index]) {
                                    cancelReasonIndex = index
                                }
                            }
                        } label: {
                            HStack {
                                Text(cancelReasons[cancelReasonIndex])
                                    .font(AppTheme.Fonts.regular(16))
                                    .foregroundColor(cancelReasonIndex == 0 ? SwiftUI.Color.gray : AppTheme.Colors.charcoalGrey)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(SwiftUI.Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    // Accept terms checkbox
                    Button(action: { acceptedTerms.toggle() }) {
                        HStack(spacing: 10) {
                            Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundColor(acceptedTerms ? AppTheme.Colors.purple : SwiftUI.Color.gray)
                            Text("Accetto i termini di cancellazione")
                                .font(AppTheme.Fonts.regular(15))
                                .foregroundColor(AppTheme.Colors.charcoalGrey)
                        }
                    }

                    // Confirm text field
                    TextField("Scrivi CANCELLA per confermare", text: $confirmText)
                        .font(AppTheme.Fonts.regular(16))
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(SwiftUI.Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .onChange(of: confirmText) { newValue in
                            let uppercased = newValue.uppercased()
                            if newValue != uppercased {
                                confirmText = uppercased
                            }
                        }

                    // Buttons
                    HStack(spacing: 12) {
                        Button(action: { showCancelSheet = false }) {
                            Text("NO")
                                .font(AppTheme.Fonts.bold(16))
                                .foregroundColor(AppTheme.Colors.charcoalGrey)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(SwiftUI.Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }

                        Button(action: {
                            let reason = cancelReasons[cancelReasonIndex]
                            showCancelSheet = false
                            viewModel.cancelService(reason: reason)
                        }) {
                            Text("SI")
                                .font(AppTheme.Fonts.bold(16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(cancelButtonEnabled ? AppTheme.Colors.purple : SwiftUI.Color.gray.opacity(0.4))
                                .cornerRadius(12)
                        }
                        .disabled(!cancelButtonEnabled)
                    }
                }
                .padding(24)
            }
        }
        .background(SwiftUI.Color.white.ignoresSafeArea())
        .modifier(PresentationDetentsModifier())
    }

    private var cancelButtonEnabled: Bool {
        cancelReasonIndex > 0 && acceptedTerms && confirmText.lowercased() == "cancella"
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

            SwiftUI.Text("Dettaglio Prenotazione")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            if let detail = viewModel.serviceDetail {
                Text(viewModel.isDispute ? "Disputa in corso" : (detail.service_status_dis.isEmpty ? detail.service_status.capitalized : detail.service_status_dis.capitalized))
                    .font(AppTheme.Fonts.bold(11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(viewModel.statusColor)
                    .cornerRadius(12)
            }
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

    // MARK: - 1. Costo + Orario (card principale)

    private func costAndTimeCard(detail: ProviderServiceDetail) -> some View {
        VStack(spacing: 0) {
            // Importo in grande
            if !detail.booking_amt.isEmpty, detail.booking_amt != "0" {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Importo")
                            .font(AppTheme.Fonts.medium(12))
                            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                        Text("\(UserData.shared.currency)\(detail.booking_amt)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.Colors.orange)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Image(systemName: "eurosign.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.Colors.orange.opacity(0.2))
                        if detail.service_master_type == "hourly" {
                            Text("Tariffa Oraria")
                                .font(AppTheme.Fonts.medium(11))
                                .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.5))
                        }
                    }
                }
                .padding(16)

                Divider().padding(.horizontal, 16)
            }

            // Orario
            if !detail.start_time.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.purple)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quando")
                            .font(AppTheme.Fonts.medium(12))
                            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                        Text(formattedTimeRange(start: detail.start_time, end: detail.end_time))
                            .font(AppTheme.Fonts.bold(15))
                            .foregroundColor(AppTheme.Colors.charcoalGrey)
                    }
                    Spacer()
                }
                .padding(16)
            }

            // Durata
            if !detail.booking_hours.isEmpty, detail.booking_hours != "0" {
                Divider().padding(.horizontal, 16)

                HStack(spacing: 12) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.purple)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Durata")
                            .font(AppTheme.Fonts.medium(12))
                            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                        Text("\(detail.booking_hours) ore")
                            .font(AppTheme.Fonts.bold(15))
                            .foregroundColor(AppTheme.Colors.charcoalGrey)
                    }
                    Spacer()
                }
                .padding(16)
            }

            // Mezzo di trasporto
            if !detail.delivery_type.isEmpty {
                Divider().padding(.horizontal, 16)

                HStack(spacing: 12) {
                    Image(systemName: deliveryIcon(for: detail.delivery_type))
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.purple)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mezzo")
                            .font(AppTheme.Fonts.medium(12))
                            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                        Text(deliveryLabel(for: detail.delivery_type))
                            .font(AppTheme.Fonts.bold(15))
                            .foregroundColor(AppTheme.Colors.charcoalGrey)
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func deliveryIcon(for type: String) -> String {
        switch type.lowercased() {
        case "small": return "bicycle"
        case "medium": return "motorcycle.fill"
        case "large": return "car.fill"
        default: return "bicycle"
        }
    }

    private func deliveryLabel(for type: String) -> String {
        switch type.lowercased() {
        case "small": return "E-Bike"
        case "medium": return "Moto"
        case "large": return "Auto"
        default: return type.capitalized
        }
    }

    // MARK: - 2. Dove

    private func locationCard(detail: ProviderServiceDetail) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(AppTheme.Colors.orange)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("Dove")
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                Text(detail.service_address)
                    .font(AppTheme.Fonts.bold(15))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - 3. Istruzioni

    private func instructionsCard(detail: ProviderServiceDetail) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 22))
                .foregroundColor(AppTheme.Colors.purple)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("Istruzioni per il servizio")
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                Text(detail._description)
                    .font(AppTheme.Fonts.regular(15))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - 4. Rider Card

    private func providerCard(detail: ProviderServiceDetail) -> some View {
        HStack(spacing: 14) {
            RemoteImageView(detail.provider_image,
                            contentMode: .scaleAspectFill,
                            placeholder: UIImage(named: "user_placeholder"))
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .background(Circle().fill(AppTheme.Colors.mist))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showImagePreview = true
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("Rider")
                    .font(AppTheme.Fonts.medium(11))
                    .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                Text(detail.provider_name)
                    .font(AppTheme.Fonts.bold(15))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(SwiftUI.Color.yellow)
                        .font(.system(size: 12))
                    Text(detail.avg_rating)
                        .font(AppTheme.Fonts.medium(13))
                        .foregroundColor(AppTheme.Colors.charcoalGrey)
                }
            }

            Spacer()

            Button(action: { viewModel.toggleFavourite() }) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(viewModel.isFavorite ? SwiftUI.Color.red : AppTheme.Colors.extraLightGrey)
            }
        }
        .padding(14)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - 5. Commission Card

    private func commissionCard(detail: ProviderServiceDetail) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "percent")
                .font(.system(size: 22))
                .foregroundColor(AppTheme.Colors.orange)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("Commissioni piattaforma")
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                Text("\(UserData.shared.currency)\(detail.customer_commission_amount)")
                    .font(AppTheme.Fonts.bold(15))
                    .foregroundColor(AppTheme.Colors.orange)
            }
            Spacer()
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Helpers

    private func categoryChip(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Fonts.medium(12))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.Colors.lightOrange)
            .foregroundColor(AppTheme.Colors.orange)
            .cornerRadius(16)
    }

    // MARK: - Image Preview

    private func imagePreviewOverlay(url: String) -> some View {
        ZStack {
            SwiftUI.Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showImagePreview = false
                    }
                }

            RemoteImageView(url,
                            contentMode: .scaleAspectFit,
                            placeholder: UIImage(named: "user_placeholder"))
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showImagePreview = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

    private func formattedTimeRange(start: String, end: String) -> String {
        let startParts = start.components(separatedBy: " ")
        let endParts = end.components(separatedBy: " ")

        if startParts.count >= 4 && endParts.count >= 4 {
            let date = startParts[0...2].joined(separator: " ")
            let startTime = startParts.last ?? ""
            let endTime = endParts.last ?? ""
            return "\(date), \(startTime) - \(endTime)"
        }
        return "\(start) - \(end)"
    }

    private var hasAnyButton: Bool {
        viewModel.showBookNow || viewModel.showCancel || viewModel.showExtendService ||
        viewModel.showPayExtendedService || viewModel.showDownloadInvoice ||
        viewModel.showAddReview || viewModel.showMessageButton || viewModel.showDisputeButton ||
        viewModel.showViewDispute
    }

    // MARK: - Bottom Buttons

    @ViewBuilder
    private func bottomButtons(detail: ProviderServiceDetail) -> some View {
        VStack(spacing: 8) {
            if viewModel.showBookNow {
                actionButton(title: "PRENOTA ORA", color: AppTheme.Colors.orange) {
                    viewModel.bookNow()
                }
            }

            if viewModel.showCancel {
                actionButton(title: "CANCELLA PRENOTAZIONE", color: SwiftUI.Color.red) {
                    cancelReasonIndex = 0
                    confirmText = ""
                    acceptedTerms = false
                    showCancelSheet = true
                }
            }

            if viewModel.showExtendService {
                actionButton(title: "PRENOTA ORA", color: AppTheme.Colors.orange) {
                    viewModel.onExtendService?()
                }
            }

            if viewModel.showPayExtendedService {
                actionButton(title: "PAGA SERVIZIO ESTESO", color: AppTheme.Colors.orange) {
                    viewModel.onPayExtendedService?()
                }
            }

            if viewModel.showDownloadInvoice {
                actionButton(title: "SCARICA FATTURA", color: AppTheme.Colors.orange) {
                    viewModel.onDownloadInvoice?()
                }
            }

            if viewModel.showAddReview {
                actionButton(title: "AGGIUNGI RECENSIONE", color: SwiftUI.Color.green) {
                    viewModel.onAddReview?()
                }
            }

            if viewModel.showViewDispute {
                actionButton(title: "Visualizza Disputa", color: SwiftUI.Color.red) {
                    viewModel.onViewDispute?()
                }
            }

            if viewModel.showMessageButton || viewModel.showDisputeButton {
                HStack(spacing: 10) {
                    if viewModel.showMessageButton {
                        Button(action: { viewModel.onSendMessage?() }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Invia Messaggio")
                            }
                            .font(AppTheme.Fonts.medium(13))
                            .foregroundColor(AppTheme.Colors.orange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.Colors.lightOrange)
                            .cornerRadius(10)
                        }
                    }

                    if viewModel.showDisputeButton {
                        Button(action: { viewModel.showDisputePopup = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Controversia")
                            }
                            .font(AppTheme.Fonts.medium(13))
                            .foregroundColor(SwiftUI.Color.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(SwiftUI.Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 0)
        .background(
            SwiftUI.Color.white
                .shadow(color: SwiftUI.Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func actionButton(title: String, color: SwiftUI.Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Fonts.bold(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(color)
                .cornerRadius(12)
        }
    }
}
