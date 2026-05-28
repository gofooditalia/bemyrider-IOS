//
//  MyServicesViewModel.swift
//  bemyrider
//
//  SwiftUI ViewModel for MyServices screen.
//

import Foundation
import UIKit

@MainActor
final class MyServicesViewModel: ObservableObject {
    @Published var services: [ProviderService] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFromProfile: Bool = false
    
    weak var presentingVC: UIViewController?
    
    var onServiceSelected: ((ProviderService) -> Void)?
    var onAddService: (() -> Void)?
    var onNavigateToDetail: (() -> Void)?
    var onBack: (() -> Void)?
    
    private var pagination: ProviderServiceCls.Pagination?
    
    var filteredServices: [ProviderService] {
        if searchText.isEmpty {
            return services
        }
        return services.filter {
            $0.service_name.localizedCaseInsensitiveContains(searchText) ||
            $0.category_name.localizedCaseInsensitiveContains(searchText) ||
            $0.subcategory_name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var showNoRecords: Bool {
        filteredServices.isEmpty && !isLoading
    }
    
    func loadServices() async {
        isLoading = true
        errorMessage = nil
        
        let nextPage = (pagination?.currentPage ?? 0) + 1
        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "keyword": searchText,
            "page": nextPage
        ]
        
        do {
            let dic = try await APIClient.shared.getProviderServices(params: param)
            let serviceObj = ProviderServiceCls(dictionary: dic)
            
            if services.count > 0 {
                services += serviceObj.serviceList
            } else {
                services = serviceObj.serviceList
            }
            pagination = serviceObj.pagination
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() {
        services = []
        pagination = nil
        Task {
            await loadServices()
        }
    }
    
    func selectService(_ service: ProviderService) {
        onServiceSelected?(service)
    }
    
    func addNewService() {
        onAddService?()
    }
    
    func loadMoreIfNeeded(currentItem: ProviderService) {
        guard let pagination = pagination,
              pagination.currentPage < pagination.total_pages,
              let lastItem = services.last,
              lastItem.provider_service_id == currentItem.provider_service_id else {
            return
        }
        Task {
            await loadServices()
        }
    }
}
