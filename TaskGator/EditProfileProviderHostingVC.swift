//
//  EditProfileProviderHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI EditProfileProviderView.
//  Owns EditProfileProviderViewModel and handles image picking,
//  address autocomplete, and navigation to MyServices.
//

import UIKit
import SwiftUI

final class EditProfileProviderHostingVC: UIViewController {

    var isFirstTime = false
    var providerData: UserProfile?

    private let vm = EditProfileProviderViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.presentingVC = self
        vm.isFirstTime  = isFirstTime
        if let data = providerData { vm.loadFromProfile(data) }
        wireCallbacks()
        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        AttachmentHandler.shared.imagePickedBlock = { [weak self] image, name in
            guard let self = self else { return }
            let cropper = ImageCropper.storyboardInstance
            cropper.image = image
            if self.pendingImageTarget == .profile {
                cropper.delegate = ProfileCropDelegate(vm: self.vm, isSignature: false)
            } else {
                cropper.delegate = ProfileCropDelegate(vm: self.vm, isSignature: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(cropper, animated: false)
            }
            self._pendingImageName = name
        }
    }

    // MARK: - Private

    private enum ImageTarget { case profile, signature }
    private var pendingImageTarget: ImageTarget = .profile
    private var _pendingImageName: String = ""
}

// MARK: - Setup

private extension EditProfileProviderHostingVC {

    func wireCallbacks() {
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onPickProfileImage = { [weak self] in
            self?.pendingImageTarget = .profile
            AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self!)
        }
        vm.onPickSignatureImage = { [weak self] in
            self?.pendingImageTarget = .signature
            AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self!)
        }
        vm.onPickAddress = { [weak self] in
            guard let self = self else { return }
            let ac = PlaceAutocompleteVC()
            ac.onPlaceSelected = { [weak self] address, lat, lng in
                self?.vm.setAddress(address, latitude: lat, longitude: lng)
            }
            self.present(UINavigationController(rootViewController: ac), animated: true)
        }
        vm.onNavigateToMyServices = { [weak self] in
            guard let self = self else { return }
            let vc = MyServicesHostingVC()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func embedView() {
        let child = UIHostingController(rootView: EditProfileProviderView(viewModel: vm))
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
}

// MARK: - ImageCropperDelegate helper

private final class ProfileCropDelegate: NSObject, ImageCropperDelegate {
    private weak var vm: EditProfileProviderViewModel?
    private let isSignature: Bool

    init(vm: EditProfileProviderViewModel, isSignature: Bool) {
        self.vm = vm
        self.isSignature = isSignature
    }

    func didCropImage(originalImage: UIImage, cropImage: UIImage) {
        let sized = cropImage.resizedImageWith(targetSize: CGSize(width: 300, height: 300)) ?? cropImage
        let sig = isSignature
        Task { @MainActor [weak self] in
            guard let vm = self?.vm else { return }
            if sig {
                vm.setPickedSignatureImage(sized, name: "signature.png")
            } else {
                vm.setPickedProfileImage(sized, name: "profile.png")
            }
        }
    }

    func didCancel() {}
}
