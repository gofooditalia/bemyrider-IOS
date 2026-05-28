//
//  EditProfileCustomerHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI EditProfileCustomerView.
//  Owns EditProfileCustomerViewModel and handles image picking
//  and address autocomplete.
//

import UIKit
import SwiftUI

final class EditProfileCustomerHostingVC: UIViewController {

    var isFirstTime = false
    var passUserData: UserProfile?

    private let vm = EditProfileCustomerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.presentingVC = self
        vm.isFirstTime  = isFirstTime
        if let data = passUserData { vm.loadFromProfile(data) }
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
            cropper.delegate = CustomerCropDelegate(vm: self.vm, name: name)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(cropper, animated: false)
            }
        }
    }
}

// MARK: - Setup

private extension EditProfileCustomerHostingVC {

    func wireCallbacks() {
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onPickProfileImage = { [weak self] in
            guard let self = self else { return }
            AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self)
        }
        vm.onPickAddress = { [weak self] in
            guard let self = self else { return }
            let ac = PlaceAutocompleteVC()
            ac.onPlaceSelected = { [weak self] address, lat, lng in
                self?.vm.setAddress(address, latitude: lat, longitude: lng)
            }
            self.present(UINavigationController(rootViewController: ac), animated: true)
        }
    }

    func embedView() {
        view.backgroundColor = .clear

        let child = UIHostingController(rootView: EditProfileCustomerView(viewModel: vm))
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

private final class CustomerCropDelegate: NSObject, ImageCropperDelegate {
    private weak var vm: EditProfileCustomerViewModel?
    private let name: String

    init(vm: EditProfileCustomerViewModel, name: String) {
        self.vm = vm
        self.name = name
    }

    func didCropImage(originalImage: UIImage, cropImage: UIImage) {
        let sized = cropImage.resizedImageWith(targetSize: CGSize(width: 300, height: 300)) ?? cropImage
        let n = name
        Task { @MainActor [weak self] in
            self?.vm?.setPickedProfileImage(sized, name: n)
        }
    }

    func didCancel() {}
}
