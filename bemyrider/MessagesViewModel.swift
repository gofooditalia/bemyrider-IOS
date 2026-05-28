//
//  MessagesViewModel.swift
//  bemyrider
//
//  ViewModel for the Messages tab (conversation list).
//

import UIKit

@MainActor
final class MessagesViewModel: ObservableObject {

    @Published var messages: [MessageList] = []
    @Published var isLoading = false

    private var messageListObj: MessageListCls?

    weak var presentingVC: UIViewController?

    // Callbacks → UIKit HostingVC
    var onTapMessage: ((MessageList) -> Void)?

    // MARK: - Load

    func loadMessages(reset: Bool = true) {
        if reset {
            messageListObj = nil
            messages = []
        } else {
            guard let pag = messageListObj?.pagination,
                  pag.currentPage < pag.total_pages else { return }
        }
        guard !isLoading else { return }
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let nextPage = (messageListObj?.pagination?.currentPage ?? 0) + 1
        let param: [String: Any] = ["user_id": user.user_id, "page": nextPage]

        Task {
            do {
                // Use APIClient directly — no startLoader(), no global overlay
                let response = try await APIClient.shared.post(EndPoint.getMessageListing, params: param)
                
                // DEBUG: Copy the API response to the clipboard
                if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    UIPasteboard.general.string = jsonString
                }

                let obj = MessageListCls(dictionary: response)
                self.messageListObj = obj
                if reset {
                    self.messages = obj.usersList
                } else {
                    self.messages += obj.usersList
                }
            } catch {
                // Fail silently — list stays unchanged, isLoading clears
            }
            self.isLoading = false
        }
    }

    func loadMoreIfNeeded(index: Int) {
        guard index == messages.count - 1 else { return }
        loadMessages(reset: false)
    }

    func refresh() {
        loadMessages(reset: true)
    }
}
