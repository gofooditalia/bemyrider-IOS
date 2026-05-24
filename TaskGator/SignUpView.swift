//
//  SignUpView.swift
//  TaskGator
//
//  SwiftUI replacement for SignUpVC.
//

import SwiftUI

struct SignUpView: View {

    @ObservedObject var viewModel: SignUpViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                logoSection
                    .padding(.top, 32)
                    .padding(.bottom, 24)

                userTypeSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                formSection
                    .padding(.horizontal, 24)

                termsSection
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                signUpButton
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer(minLength: 24)

                bottomSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Registrazione")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(viewModel.isLoading)
        .sheet(isPresented: $viewModel.showTerms) {
            SafariView(url: URL(string: "https://bemyrider.it/app/termini-e-condizioni-bemyrider/")!)
        }
        .alert(isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) {
            Alert(
                title: SwiftUI.Text(""),
                message: SwiftUI.Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(SwiftUI.Text("OK")) {
                    let succeeded = viewModel.signUpSucceeded
                    viewModel.alertMessage = nil
                    if succeeded {
                        viewModel.signUpSucceeded = false
                        viewModel.onLoginTapped?()
                    }
                }
            )
        }
    }
}

// MARK: - Sections

private extension SignUpView {

    var logoSection: some View {
        VStack(spacing: 8) {
            Image("bemyrider_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 70)
            SwiftUI.Text("bemyrider")
                .font(AppTheme.Fonts.bold(22))
                .foregroundColor(AppTheme.Colors.orange)
            SwiftUI.Text("Crea un account")
                .font(AppTheme.Fonts.bold(20))
                .foregroundColor(AppTheme.Colors.purple)
            SwiftUI.Text("La prima community di rider autonomi al diretto servizio degli esercenti")
                .font(AppTheme.Fonts.regular(13))
                .foregroundColor(AppTheme.Colors.lightGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    var userTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Iscriviti come")
                .font(AppTheme.Fonts.medium(13))
                .foregroundColor(AppTheme.Colors.extraLightGrey)
            HStack(spacing: 12) {
                userTypeButton(label: "Rider", value: "p") {
                    Image(systemName: "bicycle")
                        .resizable().scaledToFit()
                }
                userTypeButton(label: "Esercente", value: "c") {
                    Image(systemName: "building.2.fill")
                        .resizable().scaledToFit()
                }
            }
        }
    }

    func userTypeButton<Icon: View>(label: String, value: String, @ViewBuilder icon: () -> Icon) -> some View {
        let selected = viewModel.userType == value
        return SwiftUI.Button {
            viewModel.userType = value
        } label: {
            HStack(spacing: 8) {
                icon()
                    .frame(width: 22, height: 22)
                    .foregroundColor(selected ? .white : AppTheme.Colors.purple)
                SwiftUI.Text(label)
                    .font(AppTheme.Fonts.medium(14))
                    .foregroundColor(selected ? .white : AppTheme.Colors.purple)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? AppTheme.Colors.purple : SwiftUI.Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.Colors.purple, lineWidth: 1)
            )
        }
    }

    var formSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                inputField(placeholder: "Nome", text: $viewModel.firstName)
                inputField(placeholder: "Cognome", text: $viewModel.lastName)
            }

            if !viewModel.isSocialLogin {
                inputField(placeholder: "Indirizzo email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            contactField

            if !viewModel.isSocialLogin {
                passwordField(placeholder: "Password",
                              text: $viewModel.password,
                              visible: $viewModel.isPasswordVisible)
                passwordField(placeholder: "Conferma password",
                              text: $viewModel.confirmPassword,
                              visible: $viewModel.isConfirmPasswordVisible)
            }
        }
    }

    func inputField(placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            SwiftUI.Text(placeholder)
                .font(AppTheme.Fonts.medium(11))
                .foregroundColor(AppTheme.Colors.extraLightGrey)
            TextField("", text: text)
                .font(AppTheme.Fonts.regular(15))
                .padding(12)
                .background(SwiftUI.Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
        }
    }

    var contactField: some View {
        VStack(alignment: .leading, spacing: 4) {
            SwiftUI.Text("Numero di telefono")
                .font(AppTheme.Fonts.medium(11))
                .foregroundColor(AppTheme.Colors.extraLightGrey)
            HStack(spacing: 0) {
                SwiftUI.Text("+39")
                    .font(AppTheme.Fonts.medium(15))
                    .foregroundColor(AppTheme.Colors.charcoalGrey)
                    .padding(.horizontal, 10)
                    .frame(height: 44)
                    .background(SwiftUI.Color(UIColor.systemGray6))
                Divider().frame(height: 28)
                TextField("", text: $viewModel.contactNumber)
                    .keyboardType(.numberPad)
                    .font(AppTheme.Fonts.regular(15))
                    .padding(.horizontal, 10)
            }
            .background(SwiftUI.Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
        }
    }

    func passwordField(placeholder: String, text: Binding<String>, visible: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            SwiftUI.Text(placeholder)
                .font(AppTheme.Fonts.medium(11))
                .foregroundColor(AppTheme.Colors.extraLightGrey)
            HStack {
                Group {
                    if visible.wrappedValue {
                        TextField("", text: text)
                    } else {
                        SecureField("", text: text)
                    }
                }
                .font(AppTheme.Fonts.regular(15))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                SwiftUI.Button { visible.wrappedValue.toggle() } label: {
                    Image(systemName: visible.wrappedValue ? "eye" : "eye.slash")
                        .foregroundColor(AppTheme.Colors.extraLightGrey)
                }
            }
            .padding(12)
            .background(SwiftUI.Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.Colors.lightPurple, lineWidth: 1))
        }
    }

    var termsSection: some View {
        HStack(alignment: .top, spacing: 10) {
            SwiftUI.Button {
                viewModel.termsAccepted.toggle()
            } label: {
                Image(systemName: viewModel.termsAccepted ? "checkmark.square.fill" : "square")
                    .foregroundColor(viewModel.termsAccepted ? AppTheme.Colors.orange : AppTheme.Colors.extraLightGrey)
                    .font(.system(size: 22))
            }
            HStack(spacing: 4) {
                SwiftUI.Text("Accetto i")
                    .font(AppTheme.Fonts.regular(13))
                    .foregroundColor(AppTheme.Colors.lightGrey)
                SwiftUI.Button {
                    viewModel.showTerms = true
                } label: {
                    SwiftUI.Text("Termini e Condizioni")
                        .font(AppTheme.Fonts.medium(13))
                        .foregroundColor(AppTheme.Colors.purple)
                        .underline()
                }
            }
            Spacer()
        }
    }

    var signUpButton: some View {
        SwiftUI.Button {
            Task { await viewModel.submit() }
        } label: {
            SwiftUI.Text("Iscriviti ora")
                .font(AppTheme.Fonts.bold(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.termsAccepted
                    ? AppTheme.Colors.orange
                    : AppTheme.Colors.orange.opacity(0.4))
                .cornerRadius(25)
        }
        .disabled(!viewModel.termsAccepted)
    }

    var bottomSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                SwiftUI.Text("Hai già un account?")
                    .font(AppTheme.Fonts.regular(13))
                    .foregroundColor(AppTheme.Colors.lightGrey)
                SwiftUI.Button("Accedi qui!") {
                    viewModel.onLoginTapped?()
                }
                .font(AppTheme.Fonts.bold(13))
                .foregroundColor(AppTheme.Colors.purple)
            }

            HStack(spacing: 12) {
                actionButton(label: "Contattaci", systemImage: "phone") {
                    viewModel.onContactUsTapped?()
                }
                actionButton(label: "Informazioni", systemImage: "info.circle") {
                    viewModel.onInfoTapped?()
                }
            }
        }
    }

    func actionButton(label: String, systemImage: String, action: @escaping () -> Void) -> some View {
        SwiftUI.Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                SwiftUI.Text(label)
                    .font(AppTheme.Fonts.medium(13))
            }
            .foregroundColor(AppTheme.Colors.purple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(SwiftUI.Color.white)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.Colors.purple, lineWidth: 1))
        }
    }

}

// MARK: - Safari wrapper

private struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = SFSafariViewControllerWrapper(url: url)
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

import SafariServices
private final class SFSafariViewControllerWrapper: UIViewController {
    let url: URL
    init(url: URL) { self.url = url; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
}
