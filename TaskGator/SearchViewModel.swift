//
//  SearchViewModel.swift
//  TaskGator
//
//  ViewModel for advanced search and filters.
//

import Foundation
import Combine
import UIKit

@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Filter State
    @Published var selectedCategory: Category?
    @Published var selectedSubCategory: Category?
    @Published var selectedService: ServiceList?
    
    @Published var searchKeyword: String = ""
    @Published var locationName: String = ""
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    
    @Published var starRating: Double = 0.0
    
    @Published var minPrice: CGFloat = 0.0
    @Published var maxPrice: CGFloat = 5000.0
    @Published var selectedMinPrice: CGFloat = 0.0
    @Published var selectedMaxPrice: CGFloat = 5000.0
    
    @Published var sorting: String = "" // "asc" or "desc"
    
    // API Data
    @Published var categories: [Category] = []
    @Published var subCategories: [Category] = []
    @Published var services: [ServiceList] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    weak var presentingVC: UIViewController?
    
    // Callbacks for UI
    var onOpenLocationPicker: (() -> Void)?
    var onApplyFilter: (([String: Any]) -> Void)?
    var onClearFilter: (() -> Void)?
    
    // MARK: - Initialization
    func loadInitialData(existingParams: [String: Any]?) {
        // Pre-fill existing filters if provided
        if let params = existingParams {
            self.latitude = params["search_lat"] as? String ?? ""
            self.longitude = params["search_long"] as? String ?? ""
            self.locationName = params["search_location"] as? String ?? ""
            self.searchKeyword = params["search_keyword"] as? String ?? ""
            self.sorting = params["sort"] as? String ?? ""
            
            if let ratingStr = params["search_rating"] as? String, let r = Double(ratingStr) {
                self.starRating = r
            }
        }
        
        Task {
            await fetchMinMaxPrice()
            await fetchCategories()
        }
    }
    
    // MARK: - Actions
    func applyFilter() {
        var params: [String: Any] = [:]
        
        params["search_keyword"] = searchKeyword
        params["search_rating"] = starRating > 0 ? "\(starRating)" : ""
        params["search_lat"] = latitude
        params["search_long"] = longitude
        params["search_location"] = locationName
        params["sort"] = sorting
        
        // Expose to delegate
        onApplyFilter?(params)
    }
    
    func clearFilter() {
        self.selectedCategory = nil
        self.selectedSubCategory = nil
        self.selectedService = nil
        self.searchKeyword = ""
        self.locationName = ""
        self.latitude = ""
        self.longitude = ""
        self.starRating = 0.0
        self.selectedMinPrice = self.minPrice
        self.selectedMaxPrice = self.maxPrice
        self.sorting = ""
        
        onClearFilter?()
    }
    
    // MARK: - Category Management
    func didSelectCategory(_ category: Category?) {
        self.selectedCategory = category
        self.selectedSubCategory = nil
        self.selectedService = nil
        self.subCategories = []
        self.services = []
        
        if let cat = category {
            Task {
                await fetchSubCategories(for: cat.category_id)
            }
        }
    }
    
    func didSelectSubCategory(_ subCategory: Category?) {
        self.selectedSubCategory = subCategory
        self.selectedService = nil
        self.services = []
        
        if let subCat = subCategory {
            Task {
                await fetchServices(for: subCat.category_id)
            }
        }
    }
    
    // MARK: - API Calls (wrapped in async/await)
    private func fetchMinMaxPrice() async {
        guard let vc = presentingVC else { return }
        let result: [String: Any]? = await withCheckedContinuation { continuation in
            Modal.shared.minmaxPrice(vc: vc) { response in
                continuation.resume(returning: response)
            }
        }
        
        if let dic = result {
            let rangeDic = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            let minStr = rangeDic["min_price"] as? String ?? "0"
            let maxStr = rangeDic["max_price"] as? String ?? "5000"
            
            self.minPrice = CGFloat(Double(minStr) ?? 0)
            self.maxPrice = CGFloat(Double(maxStr) ?? 5000)
            
            // Set initials if not already customized
            if self.selectedMinPrice == 0 { self.selectedMinPrice = self.minPrice }
            if self.selectedMaxPrice == 5000 { self.selectedMaxPrice = self.maxPrice }
        }
    }
    
    private func fetchCategories() async {
        guard let vc = presentingVC else { return }
        isLoading = true
        let result: [String: Any]? = await withCheckedContinuation { continuation in
            Modal.shared.getCatagoryList(vc: vc, param: [:]) { response in
                continuation.resume(returning: response)
            }
        }
        isLoading = false
        
        if let dic = result {
            let list = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).compactMap { Category(dictionary: $0 as! [String: Any]) }
            self.categories = list.sorted { $0.category_name < $1.category_name }
        }
    }
    
    private func fetchSubCategories(for categoryId: String) async {
        guard let vc = presentingVC else { return }
        isLoading = true
        let result: [String: Any]? = await withCheckedContinuation { continuation in
            Modal.shared.getSubcategoryList(vc: vc, param: ["category_id": categoryId]) { response in
                continuation.resume(returning: response)
            }
        }
        isLoading = false
        
        if let dic = result {
            let list = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).compactMap { Category(dictionary: $0 as! [String: Any]) }
            self.subCategories = list.sorted { $0.category_name < $1.category_name }
        }
    }
    
    private func fetchServices(for subCategoryId: String) async {
        guard let vc = presentingVC else { return }
        isLoading = true
        let result: [String: Any]? = await withCheckedContinuation { continuation in
            Modal.shared.getServiceList(vc: vc, param: ["subcategory_id": subCategoryId]) { response in
                continuation.resume(returning: response)
            }
        }
        isLoading = false
        
        if let dic = result {
            let list = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).compactMap { ServiceList(dictionary: $0 as! [String: Any]) }
            self.services = list.sorted { $0.service_name < $1.service_name }
        }
    }
}
