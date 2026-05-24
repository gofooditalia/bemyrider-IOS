//
//  AddServiceView.swift
//  TaskGator
//
//  SwiftUI View for Add/Edit Service screen.
//

import SwiftUI

struct AddServiceView: View {
    @ObservedObject var viewModel: AddServiceViewModel
    var showHeader: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            if showHeader { headerSection }

            ScrollView {
                VStack(spacing: 20) {
                    priceSection
                    descriptionSection
                    imagesSection
                    submitButton
                }
                .padding(16)
                .background(SwiftUI.Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                .padding(16)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            Task {
                await viewModel.loadInitialData()
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

            VStack(alignment: .leading, spacing: 2) {
                SwiftUI.Text(viewModel.isEditMode ? "Modifica Servizio" : "Nuovo Servizio")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                SwiftUI.Text(viewModel.isEditMode ? "Modifica i dettagli del servizio" : "Compila i campi per aggiungere un servizio")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
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
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Seleziona categoria*")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Menu {
                ForEach(viewModel.categoryList, id: \.category_id) { category in
                    Button(action: { viewModel.selectCategory(category) }) {
                        SwiftUI.Text(category.category_name)
                    }
                }
            } label: {
                HStack {
                    SwiftUI.Text(viewModel.selectedCategory?.category_name ?? "Seleziona categoria")
                        .foregroundColor(viewModel.selectedCategory == nil ? AppTheme.Colors.placeholder : AppTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppTheme.Colors.textCaption)
                }
                .font(.system(size: 15))
                .padding(14)
                .background(AppTheme.Colors.background)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - SubCategory Section
    
    private var subCategorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Seleziona Sottocategoria*")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Menu {
                ForEach(viewModel.subCategoryList, id: \.category_id) { subCategory in
                    Button(action: { viewModel.selectSubCategory(subCategory) }) {
                        SwiftUI.Text(subCategory.category_name)
                    }
                }
            } label: {
                HStack {
                    SwiftUI.Text(viewModel.selectedSubCategory?.category_name ?? "Seleziona sottocategoria")
                        .foregroundColor(viewModel.selectedSubCategory == nil ? AppTheme.Colors.placeholder : AppTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppTheme.Colors.textCaption)
                }
                .font(.system(size: 15))
                .padding(14)
                .background(AppTheme.Colors.background)
                .cornerRadius(12)
            }
            .disabled(viewModel.subCategoryList.isEmpty)
            .opacity(viewModel.subCategoryList.isEmpty ? 0.5 : 1)
        }
    }
    
    // MARK: - Service Section
    
    private var serviceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Seleziona Servizio*")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Menu {
                ForEach(viewModel.serviceList, id: \.service_id) { service in
                    Button(action: { viewModel.selectService(service) }) {
                        SwiftUI.Text(service.service_name)
                    }
                }
            } label: {
                HStack {
                    SwiftUI.Text(viewModel.selectedService?.service_name ?? "Seleziona servizio")
                        .foregroundColor(viewModel.selectedService == nil ? AppTheme.Colors.placeholder : AppTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppTheme.Colors.textCaption)
                }
                .font(.system(size: 15))
                .padding(14)
                .background(AppTheme.Colors.background)
                .cornerRadius(12)
            }
            .disabled(viewModel.serviceList.isEmpty)
            .opacity(viewModel.serviceList.isEmpty ? 0.5 : 1)
        }
    }
    
    // MARK: - Price Section

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Tariffa oraria (€)*")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)

            TextField("Prezzo all'ora", text: $viewModel.price)
                .keyboardType(.numberPad)
                .font(.system(size: 15))
                .padding(14)
                .background(AppTheme.Colors.background)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Modello e attrezzatura del veicolo*")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)

            TextEditor(text: $viewModel.description)
                .frame(minHeight: 100)
                .font(.system(size: 15))
                .padding(8)
                .background(SwiftUI.Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Images Section
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Carica Immagini")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    addImageButton
                    
                    ForEach(Array(viewModel.existingMedia.enumerated()), id: \.offset) { index, media in
                        existingImageCell(media: media, index: index)
                    }
                    
                    ForEach(Array(viewModel.images.enumerated()), id: \.offset) { index, image in
                        newImageCell(image: image, index: index)
                    }
                }
            }
        }
    }
    
    private var addImageButton: some View {
        Button(action: {
            viewModel.onPickImage?()
        }) {
            VStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.orange)
                SwiftUI.Text("Aggiungi")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .frame(width: 80, height: 80)
            .background(AppTheme.Colors.background)
            .cornerRadius(12)
        }
    }
    
    private func existingImageCell(media: ProviderServiceDetail.MediaData, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            RemoteImageView(media.media_url)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button(action: { viewModel.removeExistingMedia(at: index) }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .background(Circle().fill(SwiftUI.Color.white))
            }
            .offset(x: 8, y: -8)
        }
    }
    
    private func newImageCell(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button(action: { viewModel.removeImage(at: index) }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .background(Circle().fill(SwiftUI.Color.white))
            }
            .offset(x: 8, y: -8)
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button(action: {
            Task {
                await viewModel.submitService()
            }
        }) {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    SwiftUI.Text(viewModel.isEditMode ? "AGGIORNA SERVIZIO" : "PUBBLICA SERVIZIO")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isFormValid ? AppTheme.Colors.orange : AppTheme.Colors.borderMedium)
            .cornerRadius(16)
        }
        .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
    }
}
