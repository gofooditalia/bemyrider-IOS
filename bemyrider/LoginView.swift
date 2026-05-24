//
//  LoginView.swift
//  bemyrider
//
//  SwiftUI replacement for LoginVC.
//
//  Integration: wrap in UIHostingController and push onto the existing
//  UINavigationController from SignUpVC (or wherever LoginVC was used).
//
//  Example:
//    let vm = LoginViewModel()
//    vm.onSignUpTapped = { [weak self] in self?.navigationController?.popViewController(animated: true) }
//    vm.onSocialLoginTapped = { [weak self] provider in self?.startSocialFlow(provider) }
//    let hostingVC = UIHostingController(rootView: LoginView(viewModel: vm))
//    navigationController?.pushViewController(hostingVC, animated: true)
//

import SwiftUI

struct LoginView: View {

    @ObservedObject var viewModel: LoginViewModel
    @State private var showUpdatePasswordScreen = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                logoSection
                    .padding(.top, 40)
                    .padding(.bottom, 32)

                formSection
                    .padding(.horizontal, 24)

                signInButton
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Spacer(minLength: 32)

                bottomLinks
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Accedi")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(viewModel.isLoading)
        // Forgot password sheet
        .sheet(isPresented: $viewModel.showForgotPassword) { forgotPasswordSheet }
        // Resend activation sheet
        .sheet(isPresented: $viewModel.showResendActivation) { resendActivationSheet }
        // Alert (iOS 13-compatible form)
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
        // Temp password prompt — shown after login with temp password
        .background(
            SwiftUI.Text("")
                .alert(isPresented: $viewModel.showChangePasswordPrompt) {
                    Alert(
                        title: SwiftUI.Text("Aggiorna la password"),
                        message: SwiftUI.Text("Hai effettuato l'accesso con una password temporanea. Ti consigliamo di aggiornarla per la sicurezza del tuo account."),
                        primaryButton: .default(SwiftUI.Text("Aggiorna password")) {
                            showUpdatePasswordScreen = true
                        },
                        secondaryButton: .cancel(SwiftUI.Text("Dopo")) {
                            Modal.sharedAppdelegate.rootToHome()
                        }
                    )
                }
        )
        .fullScreenCover(isPresented: $showUpdatePasswordScreen) {
            UpdateTempPasswordView(
                tempPassword: viewModel.password,
                onDone: {
                    showUpdatePasswordScreen = false
                    Modal.sharedAppdelegate.rootToHome()
                }
            )
        }
    }
}

// MARK: - Sections

private extension LoginView {

    var logoSection: some View {
        VStack(spacing: 12) {
            Image("bemyrider_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
            SwiftUI.Text("bemyrider")
                .font(AppTheme.Fonts.bold(22))
                .foregroundColor(AppTheme.Colors.orange)
            SwiftUI.Text("Accedi")
                .font(AppTheme.Fonts.bold(20))
                .foregroundColor(AppTheme.Colors.purple)
        }
    }

    var formSection: some View {
        VStack(spacing: 16) {
            // Email
            VStack(alignment: .leading, spacing: 4) {
                SwiftUI.Text("Indirizzo email")
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.extraLightGrey)
                TextField("", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(AppTheme.Fonts.regular(15))
                    .padding(12)
                    .background(SwiftUI.Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.Colors.lightPurple, lineWidth: 1)
                    )
            }

            // Password
            VStack(alignment: .leading, spacing: 4) {
                SwiftUI.Text("Password")
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.extraLightGrey)
                HStack {
                    Group {
                        if viewModel.isPasswordVisible {
                            TextField("", text: $viewModel.password)
                        } else {
                            SecureField("", text: $viewModel.password)
                        }
                    }
                    .font(AppTheme.Fonts.regular(15))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    SwiftUI.Button {
                        viewModel.isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(AppTheme.Colors.extraLightGrey)
                    }
                }
                .padding(12)
                .background(SwiftUI.Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.Colors.lightPurple, lineWidth: 1)
                )
            }
        }
    }

    var signInButton: some View {
        SwiftUI.Button {
            Task { await viewModel.login() }
        } label: {
            SwiftUI.Text("Accedi")
                .font(AppTheme.Fonts.bold(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.Colors.orange)
                .cornerRadius(25)
        }
    }

    var orDivider: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(AppTheme.Colors.lightPurple)
            SwiftUI.Text("or")
                .font(AppTheme.Fonts.regular(13))
                .foregroundColor(AppTheme.Colors.extraLightGrey)
                .padding(.horizontal, 8)
            Rectangle().frame(height: 1).foregroundColor(AppTheme.Colors.lightPurple)
        }
        .padding(.horizontal, 24)
    }

    var socialSection: some View {
        HStack(spacing: 16) {
            socialButton(image: "fb", label: "Facebook") {
                viewModel.onSocialLoginTapped?(.facebook)
            }
            socialButton(image: "btn_google_light_normal_ios", label: "Google") {
                viewModel.onSocialLoginTapped?(.google)
            }
            appleButton
        }
    }

    func socialButton(image: String, label: String, action: @escaping () -> Void) -> some View {
        SwiftUI.Button(action: action) {
            HStack(spacing: 6) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                SwiftUI.Text(label)
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(SwiftUI.Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.Colors.lightPurple, lineWidth: 1)
            )
        }
    }

    var appleButton: some View {
        SwiftUI.Button {
            viewModel.onSocialLoginTapped?(.apple)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                SwiftUI.Text("Apple")
                    .font(AppTheme.Fonts.medium(12))
            }
            .foregroundColor(AppTheme.Colors.charcoalGrey)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(SwiftUI.Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.Colors.lightPurple, lineWidth: 1)
            )
        }
    }

    var bottomLinks: some View {
        VStack(spacing: 12) {
            SwiftUI.Button {
                viewModel.forgotEmail = ""
                viewModel.showForgotPassword = true
            } label: {
                SwiftUI.Text("Password dimenticata?")
                    .font(AppTheme.Fonts.regular(13))
                    .foregroundColor(AppTheme.Colors.purple)
                    .underline()
            }

            SwiftUI.Button {
                viewModel.resendEmail = ""
                viewModel.showResendActivation = true
            } label: {
                SwiftUI.Text("Non hai ricevuto l'email di attivazione?")
                    .font(AppTheme.Fonts.regular(13))
                    .foregroundColor(AppTheme.Colors.purple)
                    .underline()
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 4) {
                SwiftUI.Text("Non hai un account?")
                    .font(AppTheme.Fonts.regular(13))
                    .foregroundColor(AppTheme.Colors.lightGrey)
                SwiftUI.Button("Registrati") {
                    viewModel.onSignUpTapped?()
                }
                .font(AppTheme.Fonts.bold(13))
                .foregroundColor(AppTheme.Colors.orange)
            }
        }
    }

}

// MARK: - Forgot password sheet

private extension LoginView {

    var forgotPasswordSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                SwiftUI.Text("Inserisci la tua email per recuperare la password")
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.lightGrey)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                TextField("Indirizzo email", text: $viewModel.forgotEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(AppTheme.Fonts.regular(15))
                    .padding(12)
                    .background(SwiftUI.Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
                    .padding(.horizontal, 24)

                SwiftUI.Button {
                    Task { await viewModel.submitForgotPassword() }
                } label: {
                    SwiftUI.Text("Recupera password")
                        .font(AppTheme.Fonts.bold(15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.orange)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("Password dimenticata")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    SwiftUI.Button("Annulla") { viewModel.showForgotPassword = false }
                }
            }
            .alert(isPresented: Binding(
                get: { viewModel.forgotSheetAlert != nil },
                set: { if !$0 { viewModel.forgotSheetAlert = nil } }
            )) {
                Alert(
                    title: SwiftUI.Text(""),
                    message: SwiftUI.Text(viewModel.forgotSheetAlert ?? ""),
                    dismissButton: .default(SwiftUI.Text("OK")) { viewModel.forgotSheetAlert = nil }
                )
            }
        }
    }

    var resendActivationSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                SwiftUI.Text("Inserisci la tua email per ricevere nuovamente la mail di attivazione")
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.lightGrey)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                TextField("Indirizzo email", text: $viewModel.resendEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(AppTheme.Fonts.regular(15))
                    .padding(12)
                    .background(SwiftUI.Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
                    .padding(.horizontal, 24)

                SwiftUI.Button {
                    Task { await viewModel.submitResendActivation() }
                } label: {
                    SwiftUI.Text("Reinvia email di attivazione")
                        .font(AppTheme.Fonts.bold(15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.orange)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("Reinvia attivazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    SwiftUI.Button("Annulla") { viewModel.showResendActivation = false }
                }
            }
            .alert(isPresented: Binding(
                get: { viewModel.resendSheetAlert != nil },
                set: { if !$0 { viewModel.resendSheetAlert = nil } }
            )) {
                Alert(
                    title: SwiftUI.Text(""),
                    message: SwiftUI.Text(viewModel.resendSheetAlert ?? ""),
                    dismissButton: .default(SwiftUI.Text("OK")) { viewModel.resendSheetAlert = nil }
                )
            }
        }
    }
}
