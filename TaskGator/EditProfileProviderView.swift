//
//  EditProfileProviderView.swift
//  TaskGator
//
//  Modernized SwiftUI edit form for Provider Profile.
//  Gradient header, card-based sections, refined inputs.
//

import SwiftUI

struct EditProfileProviderView: View {

    @ObservedObject var viewModel: EditProfileProviderViewModel
    var showHeader: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            if showHeader { headerSection }
            formContent
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .disabled(viewModel.isLoading)
        .alert(isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) {
            Alert(
                title: SwiftUI.Text(""),
                message: SwiftUI.Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(SwiftUI.Text("OK")) { viewModel.alertMessage = nil }
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Top bar
            HStack(spacing: 12) {
                Button(action: { viewModel.onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(SwiftUI.Color.white.opacity(0.18))
                        .clipShape(Circle())
                }

                SwiftUI.Text("Modifica Profilo")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            // Photo
            photoSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
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

    // MARK: - Form Content

    private var formContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if !showHeader {
                    photoSection
                        .padding(.top, 4)
                }
                personalCard
                availabilityCard
                deliveryCard
                taxCard
                signatureCard
                buttonsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Sections

private extension EditProfileProviderView {

    // MARK: Photo

    var photoSection: some View {
        VStack(spacing: 8) {
            SwiftUI.Button { viewModel.onPickProfileImage?() } label: {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let img = viewModel.profileImage {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            Image("user_placeholder").resizable().scaledToFill()
                        }
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(SwiftUI.Color.white.opacity(0.5), lineWidth: 3))
                    .shadow(color: SwiftUI.Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.Colors.orange)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(SwiftUI.Color.white, lineWidth: 2))
                }
            }
            SwiftUI.Text("Tocca per cambiare foto")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: Personal Card

    var personalCard: some View {
        formCard(icon: "person.fill", title: "Dati personali") {
            HStack(spacing: 12) {
                inputField("Nome", text: $viewModel.firstName)
                inputField("Cognome", text: $viewModel.lastName)
            }

            // Email (disabled)
            VStack(alignment: .leading, spacing: 4) {
                fieldLabel("Email")
                Text(viewModel.email)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.Colors.placeholder)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.background)
                    .cornerRadius(10)
            }

            // Phone
            VStack(alignment: .leading, spacing: 4) {
                fieldLabel("Numero di telefono")
                HStack(spacing: 0) {
                    SwiftUI.Text("+39")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.charcoalGrey)
                        .padding(.horizontal, 12)
                        .frame(height: 46)
                        .background(AppTheme.Colors.background)
                    Rectangle()
                        .fill(AppTheme.Colors.lightPurple)
                        .frame(width: 1, height: 28)
                    TextField("", text: $viewModel.contactNumber)
                        .keyboardType(.numberPad)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.horizontal, 12)
                }
                .background(SwiftUI.Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
            }

            // Address
            VStack(alignment: .leading, spacing: 4) {
                fieldLabel("Città in cui ti trovi")
                SwiftUI.Button { viewModel.onPickAddress?() } label: {
                    HStack {
                        SwiftUI.Text(viewModel.address.isEmpty ? "Seleziona indirizzo" : viewModel.address)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(viewModel.address.isEmpty
                                ? AppTheme.Colors.placeholder
                                : AppTheme.Colors.charcoalGrey)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                        Image(systemName: "location.fill")
                            .foregroundColor(AppTheme.Colors.orange)
                    }
                    .padding(12)
                    .background(SwiftUI.Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
                }
            }

            inputField("Biografia", text: $viewModel.aboutMe)
        }
    }

    // MARK: Availability Card

    var availabilityCard: some View {
        formCard(icon: "clock.fill", title: "Disponibilità") {
            HStack(spacing: 12) {
                timePicker("Inizio", selection: Binding(
                    get: { viewModel.startTime ?? Date() },
                    set: { viewModel.startTime = $0 }
                ))
                timePicker("Fine", selection: Binding(
                    get: { viewModel.endTime ?? Date() },
                    set: { viewModel.endTime = $0 }
                ))
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Giorni disponibili")
                let days = ["Dom", "Lun", "Mar", "Mer", "Gio", "Ven", "Sab"]
                HStack(spacing: 6) {
                    ForEach(0..<7) { i in
                        dayToggle(label: days[i], index: i)
                    }
                }
            }
        }
    }

    func timePicker(_ label: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            fieldLabel(label)
            DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(SwiftUI.Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
        }
    }

    func dayToggle(label: String, index: Int) -> some View {
        let selected = viewModel.availableDays.contains(index)
        return SwiftUI.Button {
            if selected { viewModel.availableDays.remove(index) }
            else        { viewModel.availableDays.insert(index) }
        } label: {
            SwiftUI.Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(selected ? .white : AppTheme.Colors.charcoalGrey)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selected
                        ? AnyView(LinearGradient(
                            colors: [AppTheme.Colors.purple, AppTheme.Colors.mediumPurple],
                            startPoint: .top, endPoint: .bottom))
                        : AnyView(SwiftUI.Color.white)
                )
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? SwiftUI.Color.clear : AppTheme.Colors.lightPurple, lineWidth: 1))
        }
    }

    // MARK: Delivery Card

    var deliveryCard: some View {
        formCard(icon: "shippingbox.fill", title: "Veicoli") {
            HStack(spacing: 10) {
                deliveryToggle(label: "E-Bike", icon: "bicycle",    isOn: $viewModel.smallDelivery)
                deliveryToggle(label: "Moto",   icon: "motorcycle", isOn: $viewModel.mediumDelivery)
                deliveryToggle(label: "Auto",   icon: "car.fill",   isOn: $viewModel.largeDelivery)
            }
        }
    }

    func deliveryToggle(label: String, icon: String, isOn: Binding<Bool>) -> some View {
        SwiftUI.Button { isOn.wrappedValue.toggle() } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isOn.wrappedValue
                              ? AppTheme.Colors.purple.opacity(0.15)
                              : AppTheme.Colors.background)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isOn.wrappedValue ? AppTheme.Colors.purple : AppTheme.Colors.placeholder)
                }
                SwiftUI.Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isOn.wrappedValue ? AppTheme.Colors.purple : AppTheme.Colors.placeholder)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isOn.wrappedValue
                        ? AppTheme.Colors.lightPurple
                        : SwiftUI.Color.white)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(isOn.wrappedValue ? AppTheme.Colors.purple : AppTheme.Colors.lightPurple, lineWidth: 1.5))
        }
    }

    // MARK: Tax Card

    var taxCard: some View {
        formCard(icon: "building.2.fill", title: "Dati fiscali") {
            inputField("Nome completo", text: $viewModel.companyName)
            inputField("Partita IVA/Codice fiscale", text: $viewModel.vat)
            inputField("Codice fiscale", text: $viewModel.taxIdCode)
            inputField("Città di nascita", text: $viewModel.cityOfBirth)
                        VStack(alignment: .leading, spacing: 4) {
                fieldLabel("Data di nascita")
                DatePicker("", selection: Binding(
                    get: { viewModel.dateOfBirth ?? Date() },
                    set: { viewModel.dateOfBirth = $0 }
                ), displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(SwiftUI.Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
            }
            inputField("Città di residenza", text: $viewModel.cityOfResidence)
            inputField("Indirizzo di residenza", text: $viewModel.residentialAddress)
            inputField("Codice destinatario", text: $viewModel.electronicCode)
            inputField("PEC", text: $viewModel.certifiedEmail, keyboardType: .emailAddress)
            
            
        }
    }

    // MARK: Signature Card

    var signatureCard: some View {
        formCard(icon: "signature", title: "Firma") {
            SwiftUI.Button { viewModel.onPickSignatureImage?() } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8, 5]))
                        .foregroundColor(AppTheme.Colors.purple.opacity(0.4))
                        .frame(height: 90)
                        .background(
                            AppTheme.Colors.cardBackground
                                .cornerRadius(12)
                        )
                    if let sig = viewModel.signatureImage {
                        Image(uiImage: sig)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                    } else {
                        VStack(spacing: 6) {
                            Image(systemName: "scribble.variable")
                                .font(.system(size: 24, weight: .light))
                            SwiftUI.Text("Tocca per aggiungere firma")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(AppTheme.Colors.purple.opacity(0.6))
                    }
                }
            }
        }
    }

    // MARK: Buttons

    var buttonsSection: some View {
        VStack(spacing: 12) {
            SwiftUI.Button {
                Task { await viewModel.submit() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                        SwiftUI.Text("Aggiorna profilo")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.orange, AppTheme.Colors.alertOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: AppTheme.Colors.orange.opacity(0.3), radius: 10, x: 0, y: 4)
            }
            .disabled(viewModel.isLoading)

            if showHeader {
                SwiftUI.Button {
                    viewModel.onNavigateToMyServices?()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 14))
                        SwiftUI.Text("I miei servizi")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.Colors.purple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(SwiftUI.Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.Colors.purple, lineWidth: 1.5))
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Reusable Components

    func formCard<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.purple)
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
            }

            content()
        }
        .padding(20)
        .background(
            SwiftUI.Color.white
                .cornerRadius(20)
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
    }

    func fieldLabel(_ text: String) -> some View {
        SwiftUI.Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(AppTheme.Colors.placeholder)
    }

    func inputField(_ placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            fieldLabel(placeholder)
            TextField("", text: text)
                .font(.system(size: 14, weight: .regular))
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disableAutocorrection(keyboardType == .emailAddress)
                .padding(12)
                .background(SwiftUI.Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
        }
    }
}