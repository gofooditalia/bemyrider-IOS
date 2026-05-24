import UIKit
import SwiftUI

final class ProviderSideServiceDetailHostingVC: UIViewController {
    
    var serviceRequestId: String?
    private let viewModel = ProviderSideServiceDetailViewModel()
    
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
    
    private func setupCallbacks() {
        viewModel.serviceRequestId = serviceRequestId
        viewModel.presentingVC = self

        viewModel.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onAcceptSuccess = { [weak self] in
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onRejectSuccess = { [weak self] in
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onCancelSuccess = { [weak self] in
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onSendMessage = { [weak self] in
            guard let detail = self?.viewModel.serviceDetail else { return }
            let dic: [String: Any] = [
                "from_user_id": UserData.shared.getUser()?.user_id ?? "",
                "to_user_id": detail.customer_id,
                "service_master_id": detail.service_id,
                "service_id": detail.service_booking_id,
                "service_booking_id": detail.service_booking_id
            ]
            let nextVC = ChatHostingVC()
            nextVC.param = dic
            nextVC.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(nextVC, animated: true)
        }
        
        viewModel.onCustomerProfileTap = { [weak self] in
            guard let detail = self?.viewModel.serviceDetail,
                  let vc = CustomerProfileVC.storyboardInstance else { return }
            vc.customerIdFromProviderSide = detail.customer_id
            vc.userType = "p"
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewModel.onDisputeSuccess = { [weak self] in
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onSendProposal = { [weak self] in
            guard let detail = self?.viewModel.serviceDetail,
                  let nextVC = ProposalPopUpVC.storyboardInstance else { return }
            nextVC.delegate = self
            nextVC.proposalId = detail.service_request_id
            nextVC.presentAsPopUp(parentVC: self!)
        }
        
        viewModel.onDownloadInvoice = { [weak self] in
            guard let detail = self?.viewModel.serviceDetail else { return }
            self?.downloadInvoice(requestId: detail.service_request_id)
        }
    }
    
    private func embedView() {
        let child = UIHostingController(rootView: ProviderSideServiceDetailView(viewModel: viewModel))
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
    
    private func downloadInvoice(requestId: String) {
        Modal.shared.downloadInvoice(vc: self, serviceRequestId: requestId) { dic in
            let data = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            let url = data["file_name"] as? String ?? ""
            if !url.isBlank, let downloadUrl = URL(string: url) {
                Downloader.loadFileAsync(url: downloadUrl) { path, error in
                    if error == nil, let path = path {
                        CloudDataManager.sharedInstance.copyFileToCloud()
                        DispatchQueue.main.async {
                            self.showDownloadedFile(url: url, localPath: path)
                        }
                    }
                }
            }
        }
    }
    
    private func showDownloadedFile(url: String, localPath: String) {
        guard let previewUrl = URL(string: url) else { return }
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(previewUrl.lastPathComponent)
        
        let ac = UIAlertController(title: "Saved!", message: "Document is saved.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let documentInteractionController = UIDocumentInteractionController()
            documentInteractionController.delegate = self
            documentInteractionController.url = destinationUrl
            documentInteractionController.uti = destinationUrl.typeIdentifier ?? "public.data, public.content"
            documentInteractionController.name = destinationUrl.localizedName ?? previewUrl.lastPathComponent
            documentInteractionController.presentPreview(animated: true)
        }))
        present(ac, animated: true)
    }
}

// MARK: - SendProposalProtocol

extension ProviderSideServiceDetailHostingVC: SendProposalProtocol {
    func sendProposalComplete(isSuccess: Bool) {
        if isSuccess {
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func sendProposalStripeConnect() {
        let controller = StripeConnectWebVC.storyboardInstance
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UIDocumentInteractionControllerDelegate

extension ProviderSideServiceDetailHostingVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return navigationController ?? self
    }
}
