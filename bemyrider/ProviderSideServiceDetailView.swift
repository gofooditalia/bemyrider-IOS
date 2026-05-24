import SwiftUI

struct ProviderSideServiceDetailView: View {
    @ObservedObject var viewModel: ProviderSideServiceDetailViewModel
    @State private var showImagePreview = false
    @State private var showRejectConfirmation = false
    @State private var showCancelSheet = false
    @State private var cancelReasonIndex = 0
    @State private var confirmText = ""
    @State private var acceptedTerms = false
    @State private var showCancelSuccess = false

    private let cancelReasons = [
        "Seleziona motivo",
        "Problemi tecnici al veicolo",
        "Emergenza salute",
        "Il cliente ha richiesto la cancellazione",
        "Motivi personali",
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
                                // 1. Cliente
                                customerCard(detail: detail)

                                // 2. Guadagno + Orario
                                earningsAndTimeCard(detail: detail)

                                // 3. Dove svolgere il servizio
                                locationCard(detail: detail)

                                // 4. Istruzioni dal cliente
                                if !detail.booking_details.isEmpty {
                                    instructionsCard(detail: detail)
                                }

                                Spacer(minLength: hasAnyButtons ? 80 : 16)
                            }
                            .padding(16)
                        }

                        if hasAnyButtons {
                            bottomButtons(detail: detail)
                        }
                    }
                }
            }
            .background(SwiftUI.Color(red: 0.96, green: 0.96, blue: 0.97).ignoresSafeArea())
            .onAppear {
                Task {
                    await viewModel.loadData()
                }
            }
            .sheet(isPresented: $showCancelSheet) {
                cancelConfirmationSheet
            }
            .alert(isPresented: $showCancelSuccess) {
                Alert(
                    title: Text("Prenotazione Cancellata"),
                    message: Text("La prenotazione è stata cancellata con successo."),
                    dismissButton: .default(Text("OK")) {
                        viewModel.onCancelSuccess?()
                    }
                )
            }

            // Fullscreen image preview
            if showImagePreview, let detail = viewModel.serviceDetail, !detail.customer_image.isEmpty {
                imagePreviewOverlay(url: detail.customer_image)
            }

            // Raise dispute popup
            if viewModel.showDisputePopup {
                RaiseDisputePopupView(
                    isPresented: $viewModel.showDisputePopup,
                    serviceRequestId: viewModel.serviceDetail?.service_request_id ?? "",
                    onSuccess: {
                        viewModel.onDisputeSuccess?()
                    }
                )
                .transition(.opacity)
            }
        }
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

            SwiftUI.Text("Dettaglio Prenotazione")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            if let detail = viewModel.serviceDetail {
                statusBadge(status: detail.service_status_dis)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [
                    SwiftUI.Color(red: 0.16, green: 0.13, blue: 0.40),
                    SwiftUI.Color(red: 0.22, green: 0.20, blue: 0.45),
                    SwiftUI.Color(red: 0.20, green: 0.22, blue: 0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - 1. Guadagno + Orario (card principale)

    private func earningsAndTimeCard(detail: ProviderServices) -> some View {
        VStack(spacing: 0) {
            // Guadagno in grande
            if !detail.booking_amount.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Guadagno")
                            .font(AppTheme.Fonts.medium(12))
                            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                        Text("\(UserData.shared.currency)\(detail.booking_amount)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.Colors.orange)
                    }
                    Spacer()
                    Image(systemName: "eurosign.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.Colors.orange.opacity(0.2))
                }
                .padding(16)

                Divider().padding(.horizontal, 16)
            }

            // Orario
            if !detail.booking_start_time.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.purple)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quando")
                            .font(AppTheme.Fonts.medium(12))
                            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                        Text("\(detail.booking_start_time)")
                            .font(AppTheme.Fonts.bold(15))
                            .foregroundColor(AppTheme.Colors.charcoalGrey)
                        if !detail.booking_end_time.isEmpty {
                            Text("fino a \(detail.booking_end_time)")
                                .font(AppTheme.Fonts.regular(13))
                                .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.7))
                        }
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

    private func locationCard(detail: ProviderServices) -> some View {
        let address = detail.booking_address.isEmpty ? detail.address : detail.booking_address

        return HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(AppTheme.Colors.orange)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("Dove")
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                Text(address)
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

    private func instructionsCard(detail: ProviderServices) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 22))
                .foregroundColor(AppTheme.Colors.purple)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("Note del cliente")
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                Text(detail.booking_details)
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

    // MARK: - 4. Tipo servizio

    private func serviceTypeCard(detail: ProviderServices) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(detail.service_name)
                .font(AppTheme.Fonts.bold(16))
                .foregroundColor(AppTheme.Colors.charcoalGrey)

            HStack(spacing: 8) {
                categoryChip(detail.category_name)
                if !detail.sub_category_name.isEmpty {
                    categoryChip(detail.sub_category_name)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - 5. Customer Card

    private func customerCard(detail: ProviderServices) -> some View {
        HStack(spacing: 14) {
            RemoteImageView(detail.customer_image,
                           contentMode: .scaleAspectFit,
                           placeholder: UIImage(named: "user_placeholder"))
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .background(Circle().fill(SwiftUI.Color(red: 0.93, green: 0.93, blue: 0.95)))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showImagePreview = true
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("Cliente")
                    .font(AppTheme.Fonts.medium(11))
                    .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.6))
                Text("\(detail.customer_fname) \(detail.customer_lname)")
                    .font(AppTheme.Fonts.bold(15))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
            }

            Spacer()
        }
        .padding(14)
        .background(SwiftUI.Color.white)
        .cornerRadius(16)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Helpers

    private var hasAnyButtons: Bool {
        viewModel.showAcceptRejectButtons ||
        viewModel.showCancelButton ||
        viewModel.showDownloadInvoice ||
        viewModel.showMessageButton ||
        viewModel.showDisputeButton
    }

    // MARK: - Status Badge

    private func statusBadge(status: String) -> some View {
        Text(status.isEmpty ? "Unknown" : status.capitalized)
            .font(AppTheme.Fonts.bold(11))
            .foregroundColor(SwiftUI.Color.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(viewModel.statusColor)
            .cornerRadius(12)
    }

    // MARK: - Helper Views

    private func categoryChip(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Fonts.medium(12))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.Colors.lightOrange)
            .foregroundColor(AppTheme.Colors.orange)
            .cornerRadius(16)
    }

    // MARK: - Bottom Buttons

    private func bottomButtons(detail: ProviderServices) -> some View {
        VStack(spacing: 8) {
            if viewModel.showAcceptRejectButtons {
                HStack(spacing: 10) {
                    // ACCETTA — azione immediata
                    Button(action: {
                        Task {
                            if await viewModel.acceptService() {
                                viewModel.onAcceptSuccess?()
                            }
                        }
                    }) {
                        Text("ACCETTA")
                            .font(AppTheme.Fonts.bold(16))
                            .foregroundColor(SwiftUI.Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(SwiftUI.Color.green)
                            .cornerRadius(12)
                    }

                    // RIFIUTA — doppia conferma
                    Button(action: {
                        showRejectConfirmation = true
                    }) {
                        Text("RIFIUTA")
                            .font(AppTheme.Fonts.bold(16))
                            .foregroundColor(SwiftUI.Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(SwiftUI.Color.red)
                            .cornerRadius(12)
                    }
                    .alert(isPresented: $showRejectConfirmation) {
                        Alert(
                            title: SwiftUI.Text("Conferma Rifiuto"),
                            message: SwiftUI.Text("Sei sicuro di voler rifiutare questa prenotazione? L'azione non può essere annullata."),
                            primaryButton: .destructive(SwiftUI.Text("Rifiuta")) {
                                Task {
                                    if await viewModel.rejectService() {
                                        viewModel.onRejectSuccess?()
                                    }
                                }
                            },
                            secondaryButton: .cancel(SwiftUI.Text("Annulla"))
                        )
                    }
                }
            }

            if viewModel.showCancelButton {
                Button(action: {
                    cancelReasonIndex = 0
                    confirmText = ""
                    acceptedTerms = false
                    showCancelSheet = true
                }) {
                    Text("CANCELLA PRENOTAZIONE")
                        .font(AppTheme.Fonts.bold(14))
                        .foregroundColor(SwiftUI.Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(SwiftUI.Color.red)
                        .cornerRadius(10)
                }
            }

            if viewModel.showDownloadInvoice {
                Button(action: {
                    viewModel.onDownloadInvoice?()
                }) {
                    Text("SCARICA FATTURA")
                        .font(AppTheme.Fonts.bold(14))
                        .foregroundColor(SwiftUI.Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(AppTheme.Colors.orange)
                        .cornerRadius(10)
                }
            }

            if viewModel.showMessageButton || viewModel.showDisputeButton {
                HStack(spacing: 10) {
                    if viewModel.showMessageButton {
                        Button(action: {
                            viewModel.onSendMessage?()
                        }) {
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
                        Button(action: {
                            viewModel.showDisputePopup = true
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Apri Controversia")
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
                            Task {
                                if await viewModel.cancelService(reason: reason) {
                                    showCancelSuccess = true
                                }
                            }
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

    // MARK: - Image Preview Overlay

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
}

// MARK: - URLImageView (iOS 14 compatible)

struct URLImageView: UIViewRepresentable {
    let url: String
    var mode: UIView.ContentMode = .scaleAspectFill

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = mode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear

        if let imageUrl = URL(string: url), !url.isEmpty {
            imageView.af_setImage(withURL: imageUrl, placeholderImage: UIImage(systemName: "person.circle.fill"))
        } else {
            imageView.image = UIImage(systemName: "person.circle.fill")
            imageView.tintColor = .gray
        }

        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.contentMode = mode
    }
}
