//
//  FavouritesViewModel.swift
//  TaskGator
//
//  ViewModel for the Favourites tab (customer only).
//

import UIKit

@MainActor
final class FavouritesViewModel: ObservableObject {

    @Published var items: [FavoriteService] = []
    @Published var isLoading = false
    @Published var keyword = ""

    private var favoriteObj: FavoriteServiceCls?

    var onTapItem: ((FavoriteService) -> Void)?

    // MARK: - Load

    func load(reset: Bool = true) {
        if reset {
            favoriteObj = nil
            items = []
        } else {
            guard let pag = favoriteObj?.pagination,
                  pag.currentPage < pag.total_pages else { return }
        }
        guard !isLoading else { return }
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let kw = keyword
        let nextPage = (favoriteObj?.pagination?.currentPage ?? 0) + 1
        let param: [String: Any] = [
            "user_id": user.user_id,
            "txt_search": kw,
            "page": nextPage
        ]

        Task {
            do {
                let dic = try await APIClient.shared.getFavoriteService(params: param)
                let obj = FavoriteServiceCls(dictionary: dic)
                self.favoriteObj = obj
                if reset {
                    self.items = obj.favoriteList
                } else {
                    self.items += obj.favoriteList
                }
            } catch {
                // fail silently
            }
            self.isLoading = false
        }
    }

    func search() { load(reset: true) }
    func refresh() { load(reset: true) }

    func loadMoreIfNeeded(index: Int) {
        guard index == items.count - 1 else { return }
        load(reset: false)
    }

    // MARK: - Remove from favourites

    func removeItem(_ item: FavoriteService) {
        guard let user = UserData.shared.getUser() else { return }
        let param: [String: Any] = [
            "service_id": item.provider_service_id,
            "provider_id": item.provider_id,
            "fvrt_val": "1",
            "user_id": user.user_id,
            "delivery_type": item.delivery_type,
            "request_type": item.request_type
        ]
        Task {
            do {
                let dic = try await APIClient.shared.likeDislikeService(params: param)
                // The API returns success without specific action for deletion
                // Just remove from local list
                await MainActor.run {
                    self.items.removeAll { $0.id == item.id }
                    NotificationCenter.default.post(
                        name: .providerDisLike,
                        object: ["isProviderDislike": true]
                    )
                }
            } catch {
                // fail silently
            }
        }
    }
}
