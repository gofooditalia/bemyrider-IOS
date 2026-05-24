//
//  ServiceDetailViewModel.swift
//  bemyrider
//
//  ViewModel for managing the Provider Service Details and Booking Form state.
//

import Combine
import Foundation
import UIKit

class ServiceDetailViewModel: ObservableObject {
    
    // MARK: - Input Parameters
    var providerServiceId: String = ""
    var providerId: String = ""
    var deliveryType: String = ""
    
    // MARK: - API Data
    @Published var providerServiceDetail: ProviderServiceDetail?
    @Published var providerProfile: UserProfile?
    @Published var reviews: [Review] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Pagination for reviews
    private var currentReviewPage: Int = 1
    private var totalReviewPages: Int = 1

    // Tracks locally-toggled favourite state to survive API re-fetches
    private var localFavoriteOverride: String?
    private var didLoad = false
    
    // MARK: - Navigation/Tabs State
    @Published var selectedTab: Int = 0 // Legacy - kept for compatibility
    @Published var selectedBookingTab: Int = 0 // 0: Prenota, 1: Info
    
    // MARK: - Booking Form State
    @Published var selectedDate: Date = Date().nextHourQuarter
    @Published var selectedHoursIndex: Int = 0 // 0 = none, 1 = 1 hr, 2 = 2 hrs
    @Published var address: String = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var description: String = ""
    
    // MARK: - Output Callbacks
    var onBack: (() -> Void)?
    var onOpenLocationPicker: (() -> Void)?
    var onShowAlert: ((String, String, (() -> Void)?) -> Void)?
    var onPushToProfile: ((String) -> Void)?
    
    // MARK: - API Calls

    func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        fetchServiceDetails()
    }

    func fetchServiceDetails() {
        guard let user = UserData.shared.getUser() else { return }

        // Callers set the global providerServiceDetail before navigating here
        if self.providerServiceDetail == nil {
            loadFromGlobalDetail()
        }

        isLoading = true

        let param: [String: Any] = [
            "user_id": user.user_id,
            "provider_service_id": providerServiceId,
            "loginuser_id": user.user_id,
            "provider_id": providerId,
            "delivery_type": deliveryType,
            "request_type": "scheduled"
        ]

        Modal.shared.providerServiceDetail(vc: UIViewController(), param: param) { [weak self] dic in
            DispatchQueue.main.async {
                self?.isLoading = false
                let dataDic = ResponseKey.fatchData(res: dic, valueOf: .data).dic
                if !dataDic.isEmpty {
                    let detail = ProviderServiceDetail(dic: dataDic)
                    // Preserve locally-toggled favourite state across re-fetches
                    if let override = self?.localFavoriteOverride {
                        detail.isFavorite = override
                        detail.total_favorite = override
                    }
                    self?.providerServiceDetail = detail
                    if self?.providerProfile == nil {
                        self?.fetchProviderProfile()
                    }
                    if self?.reviews.isEmpty == true {
                        self?.fetchReviews()
                    }
                }
            }
        }
    }
    
    func fetchProviderProfile() {
        // Only fetch if we have an ID
        let profileId = providerId.isEmpty ? (providerServiceDetail?.provider_id ?? "") : providerId
        guard !profileId.isEmpty else { return }

        Modal.shared.getUserProfile(vc: UIViewController(), param: ["profile_id": profileId]) { [weak self] dic in
            DispatchQueue.main.async {
                let dataDic = ResponseKey.fatchData(res: dic, valueOf: .data).dic
                if !dataDic.isEmpty {
                    self?.providerProfile = UserProfile(dictionary: dataDic)
                }
            }
        }
    }
    
    func fetchReviews(isInitial: Bool = true) {
        let profileId = providerId.isEmpty ? (providerServiceDetail?.provider_id ?? "") : providerId
        guard !profileId.isEmpty else { return }
        
        if isInitial {
            currentReviewPage = 1
            reviews.removeAll()
        } else {
            guard currentReviewPage < totalReviewPages else { return }
            currentReviewPage += 1
        }
        
        let param: [String: Any] = [
            "user_id": profileId,
            "user_type": "p",
            "page": currentReviewPage
        ]

        Modal.shared.providerReviews(vc: UIViewController(), param: param) { [weak self] dic in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let reviewObj = ReviewCls(dictionary: dic)
                
                if let pagination = reviewObj.pagination {
                    self.currentReviewPage = Int(pagination.currentPage)
                    self.totalReviewPages = Int(pagination.total_pages)
                }
                
                self.reviews.append(contentsOf: reviewObj.reviewList)
            }
        }
    }
    
    func toggleFavorite() {
        guard let detail = providerServiceDetail else { return }

        // Same logic as CustomerSideServiceDetailViewModel.toggleFavourite()
        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": providerServiceId,
            "fvrt_val": detail.total_favorite > "0" ? "1" : "0",
            "lId": UserData.shared.languageID,
            "provider_id": detail.provider_id,
            "delivery_type": deliveryType,
            "request_type": detail.request_type
        ]

        Modal.shared.likeDislikeServices(vc: UIViewController(), param: param, isLoader: false, failer: nil, success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.providerServiceDetail?.total_favorite = (self?.providerServiceDetail?.total_favorite ?? "0") > "0" ? "0" : "1"
                self?.localFavoriteOverride = self?.providerServiceDetail?.total_favorite
                self?.objectWillChange.send()
                NotificationCenter.default.post(name: .providerDisLike, object: ["isProviderDislike": true])
            }
        })
    }
    
    func submitBookingRequest() {
        guard validateForm() else { return }
        guard let user = UserData.shared.getUser(), let detail = providerServiceDetail else { return }
        
        isLoading = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: selectedDate)
        
        var param: [String: Any] = [
            "provider_service_id": providerServiceId.isEmpty ? (detail.service_id.isEmpty ? detail.provider_service_id : detail.service_id) : providerServiceId,
            "login_service_id": user.user_id,
            "user_id": user.user_id,
            "service_address": address,
            "bookingLat": "\(latitude)",
            "bookingLong": "\(longitude)",
            "delivery_type": deliveryType,
            "request_type": "scheduled",
            "service_start_time": dateString,
            "service_details": description
        ]
        
        if detail.service_master_type == "fixed" {
            param["provider_service_hours"] = detail.provider_service_hours
        } else {
            param["sel_hours"] = "\(selectedHoursIndex)"
        }
        
        Modal.shared.sendServiceRequest(vc: UIViewController(), param: param) { [weak self] dic in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let type = dic["type"] as? String, type.lowercased() == "error", let message = dic["message"] as? String {
                    self?.onShowAlert?("Error".localized, message, nil)
                } else if let message = dic["message"] as? String {
                    self?.onShowAlert?("Success".localized, message) {
                        // Usually pops back
                    }
                }
            }
        }
    }
    
    // MARK: - Validation
    
    private func validateForm() -> Bool {
        if selectedDate.compare(Date()) != .orderedDescending {
            onShowAlert?("Error".localized, "Please select service start time greater than current time".localized, nil)
            return false
        }
        if providerServiceDetail?.service_master_type == "hourly" && selectedHoursIndex == 0 {
            onShowAlert?("Error".localized, "Seleziona la durata del servizio (1 o 2 ore)".localized, nil)
            return false
        }
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            onShowAlert?("Error".localized, "Please enter address".localized, nil)
            return false
        }
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            onShowAlert?("Error".localized, "Please write description".localized, nil)
            return false
        }
        return true
    }

    // MARK: - Global Detail Bridge

    private func loadFromGlobalDetail() {
        guard let global = _globalProviderServiceDetail() else { return }
        self.providerServiceDetail = global
        if providerId.isEmpty { providerId = global.provider_id }
        if providerServiceId.isEmpty { providerServiceId = global.provider_service_id.isEmpty ? global.service_id : global.provider_service_id }
        if deliveryType.isEmpty { deliveryType = global.delivery_type }
    }
}

// Free function to access the file-scope global without name collision
func _globalProviderServiceDetail() -> ProviderServiceDetail? {
    return providerServiceDetail
}
