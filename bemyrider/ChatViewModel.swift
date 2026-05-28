//
//  ChatViewModel.swift
//  bemyrider
//
//  ViewModel for the Chat screen (conversation detail).
//

import UIKit

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var inputText = ""
    @Published var isDisabled = false   // true when isactive == "du"
    @Published var attachmentFileName: String?

    private var messageObj: MessageCls?

    // Injected from HostingVC
    var param: [String: Any] = [:]
    var serviceName: String = ""
    weak var presentingVC: UIViewController?

    // Callbacks → UIKit
    var onBack: (() -> Void)?
    var onAttachmentTapped: (() -> Void)?
    var onOpenAttachment: ((String) -> Void)?

    // Info derived from API response
    var otherUserName: String { messageObj?.to_user_name ?? "" }
    var otherUserImage: String { messageObj?.to_profile_img ?? "" }
    var myUserName: String { messageObj?.my_user_name ?? "" }
    var myProfileImage: String { messageObj?.my_profile_img ?? "" }

    // Attachment state (set from HostingVC)
    var selectedImage: UIImage?
    var pickedFileData: Data?

    // MARK: - Load

    func loadMessages(reset: Bool = true) {
        if reset {
            messageObj = nil
            messages = []
        } else {
            guard let pag = messageObj?.pagination,
                  pag.currentPage < pag.total_pages else { return }
        }
        guard !isLoading else { return }
        isLoading = true

        var p = param
        let nextPage = (messageObj?.pagination?.currentPage ?? 0) + 1
        p["page"] = nextPage
        if nextPage > 1, let lastId = messages.last?.message_id {
            p["last_message_id"] = lastId
        }

        Task {
            do {
                let dic = try await APIClient.shared.post(EndPoint.getMessage, params: p)
                let obj = MessageCls(dictionary: dic)
                self.messageObj = obj
                self.isDisabled = obj.isactive.lowercased() == "du"
                if reset {
                    self.messages = obj.conversationList
                } else {
                    self.messages += obj.conversationList
                }
            } catch {
                // Fail silently
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

    // MARK: - Send

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || selectedImage != nil || pickedFileData != nil else { return }

        guard let userId = UserData.shared.getUser()?.user_id else { return }

        var sendParam: [String: Any] = [:]

        if !messages.isEmpty, let obj = messageObj {
            sendParam = [
                "user_id": userId,
                "service_id": obj.service_id,
                "service_master_id": obj.service_master_id,
                "message_text": text,
            ]
            if customerSide_ProviderDetails != nil || providerSide_ProviderDetails != nil {
                sendParam["to_user_id"] = Modal.sharedAppdelegate.isCustomerLogin
                    ? customerSide_ProviderDetails!.provider_id
                    : providerSide_ProviderDetails!.customer_id
            } else {
                if messages.first!.to_user != userId {
                    sendParam["to_user_id"] = messages.first!.to_user
                } else {
                    sendParam["to_user_id"] = messages.first!.from_user
                }
            }
        } else {
            sendParam = [
                "user_id": userId,
                "to_user_id": param["to_user_id"] as? String ?? "",
                "service_id": param["service_id"] as? String ?? "",
                "service_master_id": param["service_master_id"] as? String ?? "",
                "message_text": text,
            ]
        }

        // Capture attachment state
        let image = selectedImage
        let fileName = attachmentFileName
        let fileData = pickedFileData

        // Optimistic insert
        let optimistic = Message(dictionary: [
            "from_user": userId,
            "message_text": text,
            "to_user": sendParam["to_user_id"] as? String ?? "",
            "appAttUrl": fileName ?? "",
            "created_date": "",
            "isRead": "0",
            "message_id": "",
            "msgType": ""
        ])
        messages.insert(optimistic, at: 0)

        // Clear input
        inputText = ""
        attachmentFileName = nil
        selectedImage = nil
        pickedFileData = nil

        if image == nil && fileData == nil {
            // Text-only
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let msgData = try await APIClient.shared.sendTextMessage(params: sendParam)
                    let message = Message(dictionary: msgData)
                    if !self.messages.isEmpty {
                        self.messages[0] = message
                    }
                } catch {
                    if !self.messages.isEmpty {
                        self.messages.removeFirst()
                    }
                }
            }
        } else {
            // File upload via Modal.shared
            guard let vc = presentingVC else { return }
            Modal.shared.sendMessage(vc: vc, param: sendParam, postImage: image, attachmentName: fileName, fileData: fileData, failer: { [weak self] _ in
                guard let self = self, !self.messages.isEmpty else { return }
                self.messages.removeFirst()
            }) { [weak self] dic in
                guard let self = self else { return }
                let message = Message(dictionary: ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data))
                if !self.messages.isEmpty {
                    self.messages[0] = message
                }
            }
        }
    }
}
