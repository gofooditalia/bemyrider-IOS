import UIKit
import SwiftUI

final class CustomerSideServiceDetailHostingVC: UIViewController {

    var providerServiceId: String?
    var serviceRequestId: String?
    var customerItem: CustomerServicesCls.CustomerServices?

    private let viewModel = CustomerSideServiceDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1)
        setupCallbacks()
        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Setup

private extension CustomerSideServiceDetailHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: CustomerSideServiceDetailView(viewModel: viewModel))
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

    func setupCallbacks() {
        viewModel.providerServiceId = providerServiceId
        viewModel.serviceRequestId = serviceRequestId
        viewModel.customerItem = customerItem
        viewModel.presentingVC = self

        viewModel.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onCancelSuccess = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onBookNowComplete = { [weak self] dicData in
            guard let self = self else { return }
            if let paymentIntentClientSecret = dicData["paymentIntentClientSecret"] as? String,
               let total_amount_to_charge_full = dicData["total_amount_to_charge_full"] as? String,
               let booking_amount = dicData["booking_amount"] as? String,
               let total_fees = dicData["total_fees"] as? String {
                let controller = StripeCheckoutHostingVC()
                controller.paymentIntentClientSecret = paymentIntentClientSecret
                controller.totalAmountToCharge = total_amount_to_charge_full
                controller.bookingAmount = booking_amount
                controller.totalFees = total_fees
                controller.serviceRequestId = self.viewModel.customerItem?.service_request_id ?? ""
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let ac = UIAlertController(title: "Errore", message: "Qualcosa e' andato storto, contatta l'assistenza", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }

        viewModel.onSendMessage = { [weak self] in
            guard let item = self?.viewModel.customerItem else { return }
            let dic: [String: Any] = [
                "from_user_id": UserData.shared.getUser()?.user_id ?? "",
                "to_user_id": item.provider_id,
                "service_master_id": item.service_id,
                "service_id": item.service_booking_id,
                "service_booking_id": item.service_booking_id
            ]
            let nextVC = ChatHostingVC()
            nextVC.param = dic
            nextVC.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(nextVC, animated: true)
        }

        viewModel.onDisputeSuccess = { [weak self] in
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onViewDispute = { [weak self] in
            guard let self = self else { return }
            let requestId = self.viewModel.serviceRequestId ?? self.viewModel.customerItem?.service_request_id ?? ""
            let param: [String: Any] = [
                "user_id": UserData.shared.getUser()?.user_id ?? "",
                "page": 1
            ]
            Modal.shared.getDisputelist(vc: self, param: param) { dic in
                let obj = DisputeCls(dictionary: dic)
                if let dispute = obj.disputeList.first(where: { $0.service_request_id == requestId }) {
                    DispatchQueue.main.async {
                        let nextVC = DisputeDetailHostingVC()
                        nextVC.disputeObj = dispute
                        nextVC.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                }
            }
        }

        viewModel.onAddReview = { [weak self] in
            guard let item = self?.viewModel.customerItem,
                  let nextVC = ReviewPopUpVC.storyboardInstance else { return }
            nextVC.delegate = self
            nextVC.serviceRequestId = item.service_request_id
            nextVC.presentAsPopUp(parentVC: self!)
        }

        viewModel.onDownloadInvoice = { [weak self] in
            guard let item = self?.viewModel.customerItem else { return }
            self?.downloadInvoice(requestId: item.service_request_id)
        }

        viewModel.onExtendService = { [weak self] in
            guard let item = self?.viewModel.customerItem else { return }
            Modal.shared.homeProviderServiceDetail(vc: self!, param: [
                "user_id": UserData.shared.getUser()?.user_id ?? "",
                "loginuser_id": UserData.shared.getUser()?.user_id ?? "",
                "provider_id": item.provider_id,
                "delivery_type": item.delivery_type,
                "request_type": "scheduled"
            ]) { dic in
                is_from_myservices = false
                let details = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
                providerServiceDetail = details
                topTitle = details.service_name
                let nextVC = ServiceDetailHostingVC()
                nextVC.provider_service_id = details.id
                nextVC.provider_id = item.provider_id
                nextVC.deliveryType = item.delivery_type
                nextVC.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(nextVC, animated: true)
            }
        }

        viewModel.onPayExtendedService = { [weak self] in
            guard let item = self?.viewModel.customerItem,
                  item.extend_service_data.count > 0 else { return }
            let md5String = md5HexString(item.service_request_id)
            let param: [String: Any] = [
                "user_id": UserData.shared.getUser()?.user_id ?? "",
                "extend_id": item.extend_service_data[0].extend_id,
                "service_request_token": md5String
            ]
            Modal.shared.payForextEndService(vc: self!, param: param) { _ in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    func downloadInvoice(requestId: String) {
        Modal.shared.downloadInvoice(vc: self, serviceRequestId: requestId) { dic in
            let data = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            let url = data["file_name"] as? String ?? ""
            if !url.isBlank, let downloadUrl = URL(string: url) {
                Downloader.loadFileAsync(url: downloadUrl) { path, error in
                    if error == nil, let _ = path {
                        CloudDataManager.sharedInstance.copyFileToCloud()
                        DispatchQueue.main.async {
                            self.showDownloadedFile(url: url)
                        }
                    }
                }
            }
        }
    }

    func showDownloadedFile(url: String) {
        guard let previewUrl = URL(string: url) else { return }
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(previewUrl.lastPathComponent)

        let ac = UIAlertController(title: "Salvato!", message: "Il documento e' stato salvato.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let controller = UIDocumentInteractionController()
            controller.delegate = self
            controller.url = destinationUrl
            controller.uti = destinationUrl.typeIdentifier ?? "public.data, public.content"
            controller.name = destinationUrl.localizedName ?? previewUrl.lastPathComponent
            controller.presentPreview(animated: true)
        })
        present(ac, animated: true)
    }
}

// MARK: - SubmitReviews

extension CustomerSideServiceDetailHostingVC: SubmitReviews {
    func reviewSubmitted(isSuccess: Bool) {
        if isSuccess {
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UIDocumentInteractionControllerDelegate

extension CustomerSideServiceDetailHostingVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return navigationController ?? self
    }
}
