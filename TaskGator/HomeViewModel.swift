//
//  HomeViewModel.swift
//  TaskGator
//
//  ViewModel for the customer Home screen.
//  Manages provider list (3 vehicle types), search, pagination and filters.
//

import UIKit
import Combine

// MARK: - VehicleTab

enum VehicleTab: String, CaseIterable {
    case eBike = "E-Bike"
    case moto  = "Moto"
    case auto  = "Auto"

    var icon: String {
        switch self {
        case .eBike: return "bicycle"
        case .moto:  return "motorcycle"
        case .auto:  return "car.fill"
        }
    }

    var deliveryType: String {
        switch self {
        case .eBike: return "small"
        case .moto:  return "medium"
        case .auto:  return "large"
        }
    }

    var endpoint: String {
        switch self {
        case .eBike: return EndPoint.getSmallProviders
        case .moto:  return EndPoint.getMediumProviders
        case .auto:  return EndPoint.getLargeProviders
        }
    }
}

// MARK: - ViewModel

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var selectedTab: VehicleTab = .eBike
    @Published var providers: [DeliveryProivderList] = []
    @Published var isLoading = false
    @Published var searchKeyword = ""

    private var filterParams: [String: Any] = [:]
    private var providerModal: DeliveryProviderModal?
    private var cancellables = Set<AnyCancellable>()

    weak var presentingVC: UIViewController?

    // Callbacks → UIKit HostingVC
    var onTapProvider: ((DeliveryProivderList) -> Void)?
    var onOpenFilter: (() -> Void)?

    /// Read-only snapshot of active filter (used by HostingVC for ProviderFilterVC)
    var currentFilterParams: [String: Any] { filterParams }

    init() {
        // Debounce search: fire API 500ms after user stops typing
        $searchKeyword
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                self?.loadProviders(reset: true)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    func loadProviders(reset: Bool = true) {
        let nextPage: Int
        if reset {
            nextPage = 1
        } else {
            guard let pag = providerModal?.pagination,
                  pag.currentPage < pag.total_pages else { return }
            nextPage = pag.currentPage + 1
        }
        guard !isLoading else { return }
        isLoading = true

        if reset {
            providers = []
            providerModal = nil
        }

        var params: [String: Any] = [:]
        if let userId = UserData.shared.getUser()?.user_id {
            params["user_id"] = userId
        }
        params["page"] = String(nextPage)
        if !searchKeyword.trimmingCharacters(in: .whitespaces).isEmpty {
            params["search_keyword"] = searchKeyword
        }
        for (k, v) in filterParams { params[k] = v }

        let endpoint  = selectedTab.endpoint
        guard let vc = presentingVC else { isLoading = false; return }

        Task {
            let dic = await withCheckedContinuation { (cont: CheckedContinuation<[String: Any], Never>) in
                Modal.shared.deliveryProviderList(
                    vc: vc,
                    param: params,
                    isLoader: nextPage == 1,
                    action: endpoint
                ) { dic in
                    cont.resume(returning: dic)
                }
            }
            let modal = DeliveryProviderModal(
                dictionary: ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            )
            self.providerModal = modal
            if reset {
                self.providers = modal.providerList
            } else {
                self.providers += modal.providerList
            }
            self.isLoading = false
        }
    }

    /// Call from the last visible card's onAppear to trigger pagination.
    func loadMoreIfNeeded(provider: DeliveryProivderList) {
        guard providers.last?.provider_id == provider.provider_id else { return }
        loadProviders(reset: false)
    }

    func applyFilter(_ params: [String: Any]) {
        filterParams = params
        loadProviders(reset: true)
    }

    func clearFilter() {
        filterParams = [:]
        loadProviders(reset: true)
    }
}
