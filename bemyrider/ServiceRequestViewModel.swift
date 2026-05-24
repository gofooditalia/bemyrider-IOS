//
//  ServiceRequestViewModel.swift
//  bemyrider
//
//  ViewModel for the Service Request tab (customer & provider).
//

import UIKit

@MainActor
final class ServiceRequestViewModel: ObservableObject {

    enum Tab: Int, CaseIterable {
        case upcoming = 0, ongoing = 1, past = 2

        var title: String {
            switch self {
            case .upcoming: return "UPCOMING".localized
            case .ongoing:  return "ON GOING".localized
            case .past:     return "PAST".localized
            }
        }

        var apiTab: String {
            switch self {
            case .upcoming: return "history"
            case .ongoing:  return "ongoing"
            case .past:     return "past"
            }
        }
    }

    @Published var selectedTab: Tab = .upcoming
    @Published var customerItems: [CustomerServicesCls.CustomerServices] = []
    @Published var providerItems: [ProviderServices] = []
    @Published var isLoading = false
    @Published var keyword = ""

    let isCustomer: Bool

    private var customerObj: CustomerServicesCls?
    private var providerObj: ProviderServicesCls?

    var onTapCustomerItem: ((CustomerServicesCls.CustomerServices) -> Void)?
    var onTapProviderItem: ((ProviderServices) -> Void)?

    init() {
        isCustomer = Modal.sharedAppdelegate.isCustomerLogin
    }

    // MARK: - Tab selection

    func selectTab(_ tab: Tab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        load(reset: true)
    }

    // MARK: - Load

    func load(reset: Bool = true) {
        if reset {
            customerObj = nil
            providerObj = nil
            customerItems = []
            providerItems = []
        } else {
            if isCustomer {
                guard let pag = customerObj?.pagination,
                      pag.currentPage < pag.total_pages else { return }
            } else {
                guard let pag = providerObj?.pagination,
                      pag.currentPage < pag.total_pages else { return }
            }
        }
        guard !isLoading else { return }
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let tab = selectedTab.apiTab
        let kw = keyword

        if isCustomer {
            let nextPage = (customerObj?.pagination?.currentPage ?? 0) + 1
            let param: [String: Any] = [
                "user_id": user.user_id,
                "tab": tab,
                "keyword": kw,
                "page": nextPage
            ]
            Task {
                do {
                    let dic = try await APIClient.shared.getCustomerServices(params: param)
                    let obj = CustomerServicesCls(dictionary: dic)
                    self.customerObj = obj
                    if reset {
                        self.customerItems = obj.customerServicesList
                    } else {
                        self.customerItems += obj.customerServicesList
                    }
                } catch {
                    // fail silently — list stays as-is
                }
                self.isLoading = false
            }
        } else {
            let nextPage = (providerObj?.pagination?.currentPage ?? 0) + 1
            let param: [String: Any] = [
                "user_id": user.user_id,
                "tab": tab,
                "keyword": kw,
                "page": nextPage
            ]
            Task {
                do {
                    let dic = try await APIClient.shared.getProviderTasks(params: param)
                    let obj = ProviderServicesCls(dictionary: dic)
                    self.providerObj = obj
                    if reset {
                        self.providerItems = obj.providerServicesList
                    } else {
                        self.providerItems += obj.providerServicesList
                    }
                } catch {
                    // fail silently
                }
                self.isLoading = false
            }
        }
    }

    func loadMoreIfNeeded(index: Int) {
        let total = isCustomer ? customerItems.count : providerItems.count
        guard index == total - 1 else { return }
        load(reset: false)
    }

    func refresh() {
        load(reset: true)
    }

    func search() {
        load(reset: true)
    }
}
