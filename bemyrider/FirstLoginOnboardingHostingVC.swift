//
//  FirstLoginOnboardingHostingVC.swift
//  bemyrider
//
//  UIKit container for the first-login onboarding wizard.
//  Wires image pickers, address autocomplete, and AddService navigation.
//

import UIKit
import SwiftUI

final class FirstLoginOnboardingHostingVC: UIViewController {

    var userType: String = "c"
    var profileData: UserProfile?

    private lazy var onboardingVM = FirstLoginOnboardingViewModel(userType: userType)

    // Child VMs — created lazily based on userType
    private var editProviderVM: EditProfileProviderViewModel?
    private var editCustomerVM: EditProfileCustomerViewModel?
    private var myServicesVM: MyServicesViewModel?
    private var addServiceVM: AddServiceViewModel?

    // Image picker state (provider has profile + signature)
    private enum ImageTarget { case profile, signature }
    private var pendingImageTarget: ImageTarget = .profile

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildVMs()
        wireOnboardingCallbacks()
        embedView()
        // Resume from saved progress (e.g. app was killed mid-onboarding)
        onboardingVM.resumeFromSavedProgress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupImagePicker()

        // Refresh services when returning from AddService
        if onboardingVM.currentStep == 1 {
            myServicesVM?.refresh()
        }
    }
}

// MARK: - Setup

private extension FirstLoginOnboardingHostingVC {

    func setupChildVMs() {
        if userType == "c" {
            let vm = EditProfileCustomerViewModel()
            vm.presentingVC = self
            vm.isFirstTime = true
            if let data = profileData { vm.loadFromProfile(data) }
            vm.onBack = nil // No back during onboarding
            vm.onPickProfileImage = { [weak self] in
                self?.pendingImageTarget = .profile
                AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self!)
            }
            vm.onPickAddress = { [weak self] in
                guard let self = self else { return }
                let ac = PlaceAutocompleteVC()
                ac.onPlaceSelected = { [weak self] address, lat, lng in
                    self?.editCustomerVM?.setAddress(address, latitude: lat, longitude: lng)
                }
                self.present(UINavigationController(rootViewController: ac), animated: true)
            }
            vm.onProfileSaved = { [weak self] in
                self?.onboardingVM.finish()
            }
            editCustomerVM = vm
            onboardingVM.editCustomerVM = vm
        } else {
            // Provider: Step 1 = edit profile, Step 2 = my services
            let provVM = EditProfileProviderViewModel()
            provVM.presentingVC = self
            provVM.isFirstTime = true
            if let data = profileData { provVM.loadFromProfile(data) }
            provVM.onBack = nil // No back during onboarding
            provVM.onPickProfileImage = { [weak self] in
                self?.pendingImageTarget = .profile
                AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self!)
            }
            provVM.onPickSignatureImage = { [weak self] in
                self?.pendingImageTarget = .signature
                AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self!)
            }
            provVM.onPickAddress = { [weak self] in
                guard let self = self else { return }
                let ac = PlaceAutocompleteVC()
                ac.onPlaceSelected = { [weak self] address, lat, lng in
                    self?.editProviderVM?.setAddress(address, latitude: lat, longitude: lng)
                }
                self.present(UINavigationController(rootViewController: ac), animated: true)
            }
            provVM.onNavigateToMyServices = { [weak self] in
                self?.onboardingVM.advanceToNextStep()
            }
            editProviderVM = provVM
            onboardingVM.editProviderVM = provVM

            // MyServices VM for step 2
            let svcVM = MyServicesViewModel()
            svcVM.presentingVC = self
            svcVM.onBack = nil // No back during onboarding step 2
            svcVM.onAddService = { [weak self] in
                let vc = AddServiceHostingVC()
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            svcVM.onServiceSelected = { [weak self] service in
                guard let self = self else { return }
                let param: [String: Any] = [
                    "user_id": UserData.shared.getUser()!.user_id,
                    "provider_service_id": service.provider_service_id
                ]
                Modal.shared.providerServiceDetail(vc: self, param: param) { dic in
                    providerServiceDetail = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
                    providerService = service
                    let vc = ProviderServiceDetailHostingVC()
                    vc.serviceDetail = providerServiceDetail
                    vc.providerService = providerService
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            myServicesVM = svcVM
            onboardingVM.myServicesVM = svcVM

            // AddService VM for step 2 — shown directly in onboarding
            let addVM = AddServiceViewModel()
            addVM.presentingVC = self
            addVM.onBack = nil // No back during onboarding
            addVM.onServiceAdded = { [weak self] in
                self?.onboardingVM.advanceToNextStep()
            }
            addVM.onPickImage = { [weak self] in
                guard let self = self else { return }
                AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self)
                AttachmentHandler.shared.imagePickedBlock = { [weak self] image, _ in
                    self?.addServiceVM?.addImage(image)
                }
            }
            addVM.onError = { [weak self] message in
                let alert = UIAlertController(title: "Error".localized, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
                self?.present(alert, animated: true)
            }
            addServiceVM = addVM
            onboardingVM.addServiceVM = addVM

            // Stripe Connect VM for step 3
            let stripeVM = StripeConnectOnboardingViewModel()
            stripeVM.presentingVC = self
            stripeVM.onConnected = { [weak self] in
                self?.onboardingVM.finish()
            }
            stripeVM.onSkip = { [weak self] in
                self?.onboardingVM.finish()
            }
            onboardingVM.stripeConnectVM = stripeVM
        }
    }

    func wireOnboardingCallbacks() {
        onboardingVM.onComplete = {
            Modal.sharedAppdelegate.rootToHome()
        }
    }

    func setupImagePicker() {
        if userType == "c" {
            AttachmentHandler.shared.imagePickedBlock = { [weak self] image, name in
                guard let self = self else { return }
                let cropper = ImageCropper.storyboardInstance
                cropper.image = image
                cropper.delegate = OnboardingCustomerCropDelegate(vm: self.editCustomerVM!, name: name)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.present(cropper, animated: false)
                }
            }
        } else {
            AttachmentHandler.shared.imagePickedBlock = { [weak self] image, name in
                guard let self = self, let vm = self.editProviderVM else { return }
                let cropper = ImageCropper.storyboardInstance
                cropper.image = image
                if self.pendingImageTarget == .profile {
                    cropper.delegate = OnboardingProviderCropDelegate(vm: vm, isSignature: false)
                } else {
                    cropper.delegate = OnboardingProviderCropDelegate(vm: vm, isSignature: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.present(cropper, animated: false)
                }
            }
        }
    }

    func embedView() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1) // AppTheme background

        let rootView = FirstLoginOnboardingView(onboardingVM: onboardingVM)
        let child = UIHostingController(rootView: rootView)
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

// MARK: - ImageCropperDelegate helpers

private final class OnboardingCustomerCropDelegate: NSObject, ImageCropperDelegate {
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

private final class OnboardingProviderCropDelegate: NSObject, ImageCropperDelegate {
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
