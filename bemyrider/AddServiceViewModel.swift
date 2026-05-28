//
//  AddServiceViewModel.swift
//  bemyrider
//
//  SwiftUI ViewModel for Add/Edit Service screen.
//

import Foundation
import UIKit

@MainActor
final class AddServiceViewModel: ObservableObject {
    @Published var categoryList: [Category] = []
    @Published var subCategoryList: [Category] = []
    @Published var serviceList: [ServiceList] = []

    @Published var selectedCategory: Category?
    @Published var selectedSubCategory: Category?
    @Published var selectedService: ServiceList?
    
    @Published var price: String = ""
    @Published var description: String = ""
    @Published var images: [UIImage] = []
    @Published var existingMedia: [ProviderServiceDetail.MediaData] = []
    private var removedMediaIds: [String] = []

    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var isAutoSelecting = false
    @Published var errorMessage: String?

    @Published var isEditMode = false
    weak var presentingVC: UIViewController?
    
    var editingService: ProviderServiceDetail?
    var editingProviderService: ProviderService?
    
    var onBack: (() -> Void)?
    var onServiceAdded: (() -> Void)?
    var onPickImage: (() -> Void)?
    var onError: ((String) -> Void)?
    
    var isFormValid: Bool {
        selectedCategory != nil &&
        selectedSubCategory != nil &&
        selectedService != nil &&
        !price.isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        let result: Any? = await withCheckedContinuation { continuation in
            Modal.shared.getCatagoryList(vc: presentingVC, param: [:], failer: { _ in
                continuation.resume(returning: nil)
            }) { response in
                continuation.resume(returning: response)
            }
        }

        if let dic = result as? [String: Any],
           let data = dic["data"] as? [[String: Any]] {
            categoryList = data.map { Category(dictionary: $0) }
                .sorted { $0.category_name < $1.category_name }
        }

        isLoading = false

        // Auto-select category → subcategory → service (skip if editing)
        if !isEditMode {
            await autoSelectAll()
        }
    }

    /// Automatically selects the first category, subcategory, and service
    func autoSelectAll() async {
        isAutoSelecting = true

        // Select first category
        guard let cat = categoryList.first else {
            isAutoSelecting = false
            return
        }
        selectedCategory = cat

        // Load and select first subcategory (silent — no alert on empty)
        await loadSubcategories(silent: true)
        guard let subCat = subCategoryList.first else {
            isAutoSelecting = false
            return
        }
        selectedSubCategory = subCat

        // Load and select first service (silent — no alert on empty)
        await loadServices(silent: true)
        if let svc = serviceList.first {
            selectedService = svc
        } else {
            // Service list may be empty if provider already has a service
            // of this type — create a default entry so the form stays valid
            let fallback = ServiceList(dic: [
                "service_id": "67",
                "service_name": "Prenotazione a Tariffa Oraria",
                "service_type": "hourly",
                "category_id": cat.category_id,
                "sub_category_id": subCat.category_id
            ])
            serviceList = [fallback]
            selectedService = fallback
        }

        isAutoSelecting = false
    }

    func loadSubcategories(silent: Bool = false) async {
        guard let category = selectedCategory else { return }

        isLoading = true

        let vc: UIViewController? = silent ? nil : presentingVC
        let result: Any? = await withCheckedContinuation { continuation in
            Modal.shared.getSubcategoryList(vc: vc, param: ["category_id": category.category_id], failer: { _ in
                continuation.resume(returning: nil)
            }) { response in
                continuation.resume(returning: response)
            }
        }

        if let dic = result as? [String: Any],
           let data = dic["data"] as? [[String: Any]] {
            subCategoryList = data.map { Category(dictionary: $0) }
                .sorted { $0.category_name < $1.category_name }
        }

        selectedSubCategory = nil
        selectedService = nil
        serviceList = []
        isLoading = false
    }

    func loadServices(silent: Bool = false) async {
        guard let subCategory = selectedSubCategory else { return }

        isLoading = true

        let vc: UIViewController? = silent ? nil : presentingVC
        let result: Any? = await withCheckedContinuation { continuation in
            Modal.shared.getServiceList(vc: vc, param: ["subcategory_id": subCategory.category_id], failer: { _ in
                continuation.resume(returning: nil)
            }) { response in
                continuation.resume(returning: response)
            }
        }

        if let dic = result as? [String: Any],
           let data = dic["data"] as? [[String: Any]] {
            serviceList = data.map { ServiceList(dic: $0) }
                .sorted { $0.service_name < $1.service_name }
        }

        selectedService = nil
        isLoading = false
    }
    
    func selectCategory(_ category: Category) {
        selectedCategory = category
        selectedSubCategory = nil
        selectedService = nil
        subCategoryList = []
        serviceList = []
        
        Task {
            await loadSubcategories()
        }
    }
    
    func selectSubCategory(_ subCategory: Category) {
        selectedSubCategory = subCategory
        selectedService = nil
        serviceList = []
        
        Task {
            await loadServices()
        }
    }
    
    func selectService(_ service: ServiceList) {
        selectedService = service
    }
    
    func addImage(_ image: UIImage) {
        images.append(image)
    }
    
    func removeImage(at index: Int) {
        guard index < images.count else { return }
        images.remove(at: index)
    }
    
    func removeExistingMedia(at index: Int) {
        guard index < existingMedia.count else { return }
        let media = existingMedia[index]
        if !media.media_id.isEmpty {
            removedMediaIds.append(media.media_id)
        }
        existingMedia.remove(at: index)
    }
    
    func submitService() async {
        guard !isSubmitting else { return }
        guard isFormValid else {
            errorMessage = "Please fill all required fields"
            return
        }

        isSubmitting = true
        errorMessage = nil

        // Delete removed existing media first
        if isEditMode {
            for mediaId in removedMediaIds {
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    Modal.shared.deleteMedia(vc: presentingVC ?? UIViewController(), param: ["media_id": mediaId], failer: { _ in
                        continuation.resume()
                    }) { _ in
                        continuation.resume()
                    }
                }
            }
            removedMediaIds.removeAll()
        }

        var param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "category_id": selectedCategory?.category_id ?? "",
            "subcategory_id": selectedSubCategory?.category_id ?? "",
            "service_id": selectedService?.service_id ?? "",
            "price": price,
            "description": description
        ]

        if isEditMode {
            let psId = editingService?.provider_service_id ?? editingProviderService?.provider_service_id ?? ""
            if !psId.isEmpty {
                param["provider_service_id"] = psId
            }
        }
        
        let imageNames = images.enumerated().map { "service_image_\($0.offset).jpeg" }

        // Pass nil as vc to suppress automatic error alerts from checkResponce
        let result: Any? = await withCheckedContinuation { continuation in
            Modal.shared.addMyServices(
                vc: nil,
                param: param,
                withPostImageAry: images,
                withPostImageNameAry: imageNames,
                failer: { message in
                    // Return the error message wrapped in a dict so we can check it
                    continuation.resume(returning: ["status": false, "message": message] as [String: Any])
                }
            ) { response in
                continuation.resume(returning: response)
            }
        }

        if let dic = result as? [String: Any],
           let statusOk = dic["status"] as? Bool, statusOk {
            isSubmitting = false
            NotificationCenter.default.post(name: .isAddService, object: nil)
            onServiceAdded?()
            return
        }

        let message = (result as? [String: Any])?["message"] as? String ?? "Failed to save service"

        // If provider already has this service, treat as success (service exists)
        if message.lowercased().contains("already added") {
            isSubmitting = false
            NotificationCenter.default.post(name: .isAddService, object: nil)
            onServiceAdded?()
            return
        }

        errorMessage = message
        isSubmitting = false
        onError?(message)
    }
    
    func loadForEdit(serviceDetail: ProviderServiceDetail?, providerService: ProviderService?) {
        guard let detail = serviceDetail else { return }

        isEditMode = true
        editingService = detail
        editingProviderService = providerService
        
        price = detail.price
        description = detail._description
        existingMedia = detail.media_data
        
        Task {
            isAutoSelecting = true
            await loadInitialData()

            let catId = detail.category_id
            if let category = categoryList.first(where: { $0.category_id == catId }) {
                selectedCategory = category
                await loadSubcategories(silent: true)

                let subCatId = detail.subcategory_id
                if let subCategory = subCategoryList.first(where: { $0.category_id == subCatId }) {
                    selectedSubCategory = subCategory
                    await loadServices(silent: true)

                    let servId = detail.service_id
                    if let service = serviceList.first(where: { $0.service_id == servId }) {
                        selectedService = service
                    } else {
                        // Service not in list (provider already has it) — create fallback
                        let fallback = ServiceList(dic: [
                            "service_id": servId,
                            "service_name": detail.service_name,
                            "service_type": "hourly",
                            "category_id": catId,
                            "sub_category_id": subCatId
                        ])
                        serviceList = [fallback]
                        selectedService = fallback
                    }
                }
            }

            isAutoSelecting = false
        }
    }
}
