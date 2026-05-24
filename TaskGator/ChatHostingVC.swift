//
//  ChatHostingVC.swift
//  TaskGator
//
//  UIKit container for SwiftUI ChatView.
//  Handles attachment picking via AttachmentHandler + ImageCropper,
//  and opening attachments in SFSafariViewController.
//

import UIKit
import SwiftUI
import SafariServices
import MobileCoreServices.UTType

final class ChatHostingVC: UIViewController {

    private let vm = ChatViewModel()

    var param: [String: Any] = [:]
    var service_name: String = ""
    var delegate: ChatDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1)

        vm.param = param
        vm.serviceName = service_name
        vm.presentingVC = self

        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onAttachmentTapped = { [weak self] in
            guard let self = self else { return }
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        }
        vm.onOpenAttachment = { [weak self] urlString in
            guard let self = self, let url = URL(string: urlString) else { return }
            let safari = SFSafariViewController(url: url)
            self.present(safari, animated: true)
        }

        setupAttachmentHandlers()
        embedView()
        vm.refresh()

        // Listen for push-notification refreshes
        if Modal.sharedAppdelegate.isCustomerLogin {
            NotificationCenter.default.addObserver(self, selector: #selector(onPushMsg(_:)),
                                                   name: .messageScreenCustomer, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(onPushMsg(_:)),
                                                   name: .messageScreenProvider, object: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        delegate?.refreshMessageList()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func onPushMsg(_ notification: Notification) {
        if (notification.object as? [String: Any])?["isReceive"] as? Bool == true {
            vm.refresh()
        }
    }
}

// MARK: - Setup

private extension ChatHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: ChatView(viewModel: vm))
        child.view.backgroundColor = UIColor.clear
        addChildViewController(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        child.didMove(toParentViewController: self)
    }

    func setupAttachmentHandlers() {
        AttachmentHandler.shared.imagePickedBlock = { [weak self] image, imageName in
            guard let self = self else { return }
            self.vm.attachmentFileName = imageName
            self.vm.selectedImage = image

            let imageCropper = ImageCropper.storyboardInstance
            imageCropper.delegate = self
            imageCropper.image = image
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(imageCropper, animated: false)
            }
        }

        AttachmentHandler.shared.videoPickedBlock = { [weak self] url in
            guard let self = self else { return }
            let responseData = (url as URL).getDataAndFileNameBasedOnURL()
            self.vm.pickedFileData = responseData.fileData
            self.vm.attachmentFileName = responseData.fileName
        }

        AttachmentHandler.shared.filePickedBlock = { [weak self] filePath in
            guard let self = self else { return }
            let responseData = filePath.getDataAndFileNameBasedOnURL()
            self.vm.pickedFileData = responseData.fileData
            self.vm.attachmentFileName = responseData.fileName
        }
    }
}

// MARK: - ImageCropperDelegate

extension ChatHostingVC: ImageCropperDelegate {

    func didCropImage(originalImage: UIImage, cropImage: UIImage) {
        vm.selectedImage = cropImage.resizedImageWith(targetSize: CGSize(width: 800, height: 800)) ?? cropImage
    }

    func didCancel() {
        vm.selectedImage = nil
        vm.attachmentFileName = nil
    }
}
