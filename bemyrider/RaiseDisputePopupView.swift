//
//  RaiseDisputePopupView.swift
//  bemyrider
//

import SwiftUI

struct RaiseDisputePopupView: View {

    @Binding var isPresented: Bool
    let serviceRequestId: String
    var onSuccess: (() -> Void)?

    private let reasons = [
        "Ritardo eccessivo",
        "Comportamento inadeguato",
        "Servizio non completato",
        "Danni a proprietà",
        "Altro"
    ]

    @State private var selectedReasonIndex = 0
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var shakeReason = false
    @State private var shakeDescription = false
    @State private var isDropdownOpen = false
    @State private var showSuccess = false
    @State private var checkmarkScale: CGFloat = 0

    var body: some View {
        ZStack {
            // Dim background
            SwiftUI.Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { if !isSubmitting && !showSuccess { isPresented = false } }

            if showSuccess {
                successOverlay
            } else {
                formContent
            }
        }
        .animation(.easeInOut(duration: 0.2), value: shakeReason)
        .animation(.easeInOut(duration: 0.2), value: shakeDescription)
        .animation(.easeInOut(duration: 0.2), value: errorMessage != nil)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showSuccess)
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(SwiftUI.Color.green.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                    .scaleEffect(checkmarkScale)
            }

            Text("Controversia creata!")
                .font(AppTheme.Fonts.bold(18))
                .foregroundColor(AppTheme.Colors.charcoalGrey)

            Text("Puoi comunicare con il rider e, se necessario, inoltrare la controversia all'amministrazione.")
                .font(AppTheme.Fonts.regular(13))
                .foregroundColor(AppTheme.Colors.extraLightGrey)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(SwiftUI.Color.white)
                .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 40)
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                checkmarkScale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isPresented = false
                onSuccess?()
            }
        }
    }

    // MARK: - Form Content

    private var formContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Solleva la disputa")
                        .font(AppTheme.Fonts.bold(18))
                        .foregroundColor(.white)
                    Text("Descrivi il problema riscontrato")
                        .font(AppTheme.Fonts.regular(12))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Button(action: { if !isSubmitting { isPresented = false } }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 30, height: 30)
                        .background(SwiftUI.Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .background(AppTheme.Colors.purple)

            // Form
            VStack(spacing: 16) {
                // Reason dropdown
                VStack(alignment: .leading, spacing: 6) {
                    Text("Motivo")
                        .font(AppTheme.Fonts.medium(12))
                        .foregroundColor(AppTheme.Colors.extraLightGrey)

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isDropdownOpen.toggle()
                        }
                    }) {
                        HStack {
                            Text(selectedReasonIndex == 0 ? "Seleziona un motivo" : reasons[selectedReasonIndex - 1])
                                .font(AppTheme.Fonts.regular(15))
                                .foregroundColor(selectedReasonIndex == 0 ? AppTheme.Colors.placeholder : SwiftUI.Color.black)
                            Spacer()
                            Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.placeholder)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    selectedReasonIndex == 0 && shakeReason
                                        ? SwiftUI.Color.red
                                        : AppTheme.Colors.placeholder.opacity(0.4),
                                    lineWidth: 1
                                )
                        )
                    }
                    .offset(x: shakeReason ? -5 : 0)

                    // Dropdown list
                    if isDropdownOpen {
                        VStack(spacing: 0) {
                            ForEach(0..<reasons.count, id: \.self) { index in
                                Button(action: {
                                    selectedReasonIndex = index + 1
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isDropdownOpen = false
                                    }
                                }) {
                                    HStack {
                                        Text(reasons[index])
                                            .font(AppTheme.Fonts.regular(14))
                                            .foregroundColor(
                                                selectedReasonIndex == index + 1
                                                    ? AppTheme.Colors.purple
                                                    : AppTheme.Colors.charcoalGrey
                                            )
                                        Spacer()
                                        if selectedReasonIndex == index + 1 {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(AppTheme.Colors.purple)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedReasonIndex == index + 1
                                            ? AppTheme.Colors.purple.opacity(0.06)
                                            : SwiftUI.Color.clear
                                    )
                                }
                                if index < reasons.count - 1 {
                                    Divider().padding(.horizontal, 10)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(SwiftUI.Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.Colors.placeholder.opacity(0.2), lineWidth: 1)
                        )
                        .transition(.opacity)
                    }
                }

                // Description field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Descrizione")
                        .font(AppTheme.Fonts.medium(12))
                        .foregroundColor(AppTheme.Colors.extraLightGrey)
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Descrivi il problema nel dettaglio...")
                                .font(AppTheme.Fonts.regular(15))
                                .foregroundColor(AppTheme.Colors.placeholder)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                        }
                        TextEditor(text: $description)
                            .font(SwiftUI.Font.custom("Roboto-Regular", size: 15))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .frame(minHeight: 100, maxHeight: 140)
                            .onAppear {
                                UITextView.appearance().backgroundColor = .clear
                            }
                            .background(SwiftUI.Color.clear)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                description.isEmpty && shakeDescription
                                    ? SwiftUI.Color.red
                                    : AppTheme.Colors.placeholder.opacity(0.4),
                                lineWidth: 1
                            )
                    )
                    .offset(x: shakeDescription ? -5 : 0)
                }

                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(AppTheme.Fonts.regular(12))
                        .foregroundColor(.red)
                        .transition(.opacity)
                }

                // Submit button
                Button(action: submit) {
                    HStack(spacing: 8) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isSubmitting ? "Invio..." : "Invia disputa")
                            .font(AppTheme.Fonts.bold(15))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.purple, AppTheme.Colors.purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(isSubmitting)
                .opacity(isSubmitting ? 0.7 : 1)
            }
            .padding(20)
            .background(SwiftUI.Color.white)
        }
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 24)
    }

    // MARK: - Submit

    private func submit() {
        errorMessage = nil

        if selectedReasonIndex == 0 {
            shakeReason = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shakeReason = false }
            errorMessage = "Seleziona un motivo"
            return
        }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDescription.isEmpty {
            shakeDescription = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shakeDescription = false }
            errorMessage = "Inserisci la descrizione"
            return
        }

        isSubmitting = true
        let params: [String: Any] = [
            "service_request_id": serviceRequestId,
            "title": reasons[selectedReasonIndex - 1],
            "message": trimmedDescription,
            "user_id": UserData.shared.getUser()?.user_id ?? ""
        ]

        Task {
            do {
                _ = try await APIClient.shared.raiseDispute(params: params)

                isSubmitting = false
                withAnimation {
                    showSuccess = true
                }
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
