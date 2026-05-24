//
//  FeedbackView.swift
//  bemyrider
//
//  Modernized SwiftUI view for Feedback screen
//  with gradient header and form layout.
//

import SwiftUI

struct FeedbackView: View {

    @ObservedObject var viewModel: FeedbackViewModel
    @State private var showImagePicker = false

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            formContent
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.loadUserData() }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: SwiftUI.Text(""), message: SwiftUI.Text(viewModel.alertMessage ?? ""), dismissButton: .default(SwiftUI.Text("OK")) {
                if viewModel.isSubmitted {
                    viewModel.isSubmitted = false
                }
            })
        }
        .sheet(isPresented: $showImagePicker) {
            FeedbackImagePicker(image: $viewModel.selectedImage)
        }
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

                SwiftUI.Text("Feedback")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            SwiftUI.Text("Invia il tuo feedback")
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

    // MARK: - Form content

    private var formContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Name fields
                HStack(spacing: 12) {
                    formField("Nome", text: $viewModel.firstName, placeholder: "Mario")
                    formField("Cognome", text: $viewModel.lastName, placeholder: "Rossi")
                }

                // Email
                formField("Email", text: $viewModel.email, placeholder: "mario@esempio.com", keyboardType: .emailAddress)

                // Photo upload
                photoUploadSection

                // Message
                messageField

                // Submit button
                submitButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Form fields

    private func formField(_ title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)

            TextField(placeholder, text: text)
                .font(.system(size: 14, weight: .medium))
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disableAutocorrection(keyboardType == .emailAddress)
                .padding(14)
                .background(SwiftUI.Color.white)
                .cornerRadius(12)
        }
    }

    // MARK: - Photo upload

    private var photoUploadSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Foto (opzionale)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)

            Button {
                showImagePicker = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.purple)

                    if viewModel.selectedImage != nil {
                        Text("Foto selezionata")
                            .font(.system(size: 14, weight: .medium))
                    } else {
                        Text("Carica una foto")
                            .font(.system(size: 14, weight: .medium))
                    }

                    Spacer()

                    if viewModel.selectedImage != nil {
                        Button {
                            viewModel.selectedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.Colors.placeholder)
                        }
                    }
                }
                .padding(14)
                .background(SwiftUI.Color.white)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Message field

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Messaggio")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)

            TextEditor(text: $viewModel.message)
                .font(.system(size: 14, weight: .medium))
                .frame(minHeight: 120)
                .padding(10)
                .background(SwiftUI.Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.message.isEmpty ? AppTheme.Colors.separator : SwiftUI.Color.clear, lineWidth: 1)
                )
        }
    }

    // MARK: - Submit button

    private var submitButton: some View {
        Button {
            viewModel.submitFeedback()
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Invia Feedback")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isValid ? AppTheme.Colors.orange : AppTheme.Colors.orange.opacity(0.5))
            .cornerRadius(12)
        }
        .disabled(!viewModel.isValid || viewModel.isLoading)
    }
}

// MARK: - Image Picker

struct FeedbackImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: FeedbackImagePicker

        init(_ parent: FeedbackImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
