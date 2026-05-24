//
//  ProviderSideServiceDetailVC.swift
//  TaskGator
//
//  Created by NCT 24 on 11/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SafariServices

var providerSide_ProviderDetails:ProviderServices?


extension Notification.Name {
    static let reloadProviderTasks = Notification.Name("reloadProviderTasks")
}


class ProviderSideServiceDetailVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:ProviderSideServiceDetailVC? {
        return StoryBoard.providerSideServiceDetails.instantiateViewController(withIdentifier: ProviderSideServiceDetailVC.identifier) as? ProviderSideServiceDetailVC
    }
    
    @IBOutlet weak var constGreenCenter: NSLayoutConstraint!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblProviderNm: UILabel!
    @IBOutlet weak var btnFavourite: UIButton!
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius()
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(pushToCustomerProfile))
            imgUser.addGestureRecognizer(tapGest)
        }
    }
    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var greenStripe: UIView!
    @IBOutlet weak var btnService: UIButton!
    //@IBOutlet weak var btnUser: UIButton!
    
    @IBOutlet weak var btnSendProposal: UIButton!{
        didSet{
            btnSendProposal.isHidden = true
        }
    }
    @IBOutlet weak var btnInvoiceDescription: UIButton!
    @IBOutlet weak var btnDownloadInvoice: UIButton!{
        didSet{
            btnDownloadInvoice.isHidden = true
        }
    }
    @IBOutlet weak var btnCancel: UIButton!{
        didSet{
            btnCancel.isHidden = true
        }
    }
    @IBOutlet weak var stackViewBtnAcceptReject: UIStackView!{
        didSet{
            stackViewBtnAcceptReject.isHidden = true
        }
    }
    
    
    
    @IBOutlet weak var viewSendMsg: UIView!
    @IBOutlet weak var viewRaisedDispute: UIView!
    
    //@IBOutlet weak var bottomBtnHeightConst: NSLayoutConstraint!
    @IBOutlet weak var topConstStackViewMenubar: NSLayoutConstraint!
    @IBOutlet weak var stackViewMenuBar: UIStackView!
    @IBOutlet weak var stackViewTopConst: NSLayoutConstraint!
    
    
    @IBOutlet weak var btnAccept: GreenButton!
    @IBOutlet weak var btnReject: UIButton!{
        didSet{
            btnReject.border(side: .all, color: Color.green.theam, borderWidth: 1.0)
        }
    }
    
    
    @IBOutlet weak var lblSendMsg: UILabel!
    @IBOutlet weak var lblRaiseDispute: UILabel!
    
    @IBOutlet weak var btnRaiseDispute: UIButton!
    @IBOutlet weak var btnSendMessage: UIButton!
    @IBOutlet weak var lblWaitMsg: UILabel!
    
    
    enum BottomButtonType:Int {
        case accepte_reject
        case cancel
        case downloadInvoice
        case sendProposal
        case allHide
    }
    
    var selectedMenu = 0
    var serviceRequestId:String?
    var providerServiceList :ProviderServices = ProviderServices(dictionary: [:])
    var providerServicesObj: ProviderServicesList?
    //var methosAry:[] = []
    
    @objc func menuChange(notification: Notification) {
        let data = notification.object as! [String: Any]
        guard let index = data["Pagevc_index"] as? Int else { return }
        
        switch index {
        case 0:
            print(0)
            onClickService(btnService)
        case 1:
            print(1)
            onClickInvoiceDesc(btnInvoiceDescription)
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: ViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .menuChange, object: nil)
        //self.storyboard?.instantiateViewController(withIdentifier: "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
        setLang()
        setData()
    }
    
    @objc func pushToCustomerProfile(){
        if let providerId = providerServicesObj?.providerServices.customer_id{
            if let vc = CustomerProfileVC.storyboardInstance {
                vc.customerIdFromProviderSide = providerId
                vc.userType = "p"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    @IBAction func onClickSendProposal(_ sender: UIButton) {
        let parentVC = self
        guard let nextVC = ProposalPopUpVC.storyboardInstance else {return}
        nextVC.delegate = self
        nextVC.proposalId = providerSide_ProviderDetails!.service_request_id
        nextVC.presentAsPopUp(parentVC: parentVC)
    }
    
    @IBAction func onClickAccept(_ sender: UIButton) {
        self.alert(title: "Alert".localized, message: "Are you sure you want to accept this services?".localized, actions: ["Ok".localized,"Cancel".localized]) { (btnNo) in
            if btnNo == 0 {
                self.callAccepteRejectAPI(isAccepted: true)
            }
            else {
                //Do nothing
            }
        }
    }
    @IBAction func onClickReject(_ sender: UIButton) {
        self.alert(title: "Alert".localized, message: "Are you sure you want to reject this services?".localized, actions: ["Ok".localized,"Cancel".localized]) { (btnNo) in
            if btnNo == 0 {
                self.callAccepteRejectAPI(isAccepted: false)
            }
            else {
                //Do nothing
            }
        }
    }
    
    @IBAction func onClickService(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnService.setImage(#imageLiteral(resourceName: "icon1_Green"), for: .normal)
        animationOnView(center: sender.center)
        self.selectedMenu = 0
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedMenu] as [String:Any])
    }
    
    @IBAction func onClickInvoiceDesc(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnInvoiceDescription.setImage(#imageLiteral(resourceName: "ic_cost_summary"), for: .normal)
        animationOnView(center: sender.center)
        self.selectedMenu = 1
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedMenu] as [String:Any])
    }
    
    @IBAction func onClickDownloadInvoice(_ sender: UIButton) {
        callDownloadInvoiceAPI()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.alert(title: "", message: "Are you sure you want to cancel this service?".localized, actions: ["Ok".localized,"Cancel".localized]) { (btnNum) in
            if btnNum == 0{
                self.callCancelAPI()
            }
            else{
                //cancel
            }
        }
    }
    
    @IBAction func onClickRaiseDispute(_ sender: UIButton) {
        if let providerSide_ProviderDetails = providerSide_ProviderDetails{
            let parentVC = self
            guard let nextVC = RaiseDisputeVC.storyboardInstance else {return}
            nextVC.delegate = self
            nextVC.serviceRequestId = providerSide_ProviderDetails.service_request_id
            nextVC.presentAsPopUp(parentVC: parentVC)
        }
        
    }
    
    @IBAction func onClickSendMsg(_ sender: UIButton) {
        if let providerSide_ProviderDetails = providerSide_ProviderDetails{
            let dic:[String:Any] = [
                "from_user_id": UserData.shared.getUser()!.user_id,
                "to_user_id": providerSide_ProviderDetails.customer_id,
                "service_master_id": providerSide_ProviderDetails.service_id,
                "service_id": providerSide_ProviderDetails.service_booking_id,
                "service_booking_id":providerSide_ProviderDetails.service_booking_id
                
            ]
            //            "service_id":fatchedParam["service_id"] as! String,//service_booking_id
            //            "service_master_id":fatchedParam["service_master_id"] as! String, //service_id
            let nextVC = ChatHostingVC()
            nextVC.param = dic
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
}

//MARK: Custom function
extension ProviderSideServiceDetailVC {
    
    func setLang(){
        //lblFav.text = localizedString(key: "Favorite")
        //lblSendMsg.text = localizedString(key: "Send Message")
        //lblRiseDispute.text = localizedString(key: "Raise Dispute")
        btnAccept.setTitle("ACCEPT".localized, for: .normal)
        btnReject.setTitle("REJECT".localized, for: .normal)
        btnDownloadInvoice.setTitle("DOWNLOAD INVOICE".localized, for: .normal)
        btnCancel.setTitle("CANCEL".localized, for: .normal)
        btnSendProposal.setTitle("SEND PROPOSAL".localized, for: .normal)
        lblSendMsg.text = "Send Message".localized
        lblRaiseDispute.text = "Raise Dispute".localized
    }
    
    func callAccepteRejectAPI(isAccepted:Bool) {
        let param = ["user_id":UserData.shared.getUser()!.user_id,
                     "service_id":providerSide_ProviderDetails!.service_request_id,
                     "provider_service_id":providerSide_ProviderDetails!.provider_service_id,
                     "provider_id":providerSide_ProviderDetails!.provider_id,
                     "status_type": ( isAccepted ? "accepted" : "rejected")]
        
        Modal.sharedAppdelegate.startLoader()
        Modal.shared.acceptService(vc: nil, param: param, failer: { (dic,message) in
            Modal.sharedAppdelegate.stoapLoader()
            //            let message = ResponseKey.fatchDataAsString(res: dic, valueOf: .message)
            
            if let type = dic["type"] as? String, type == "error" || message == "Please connect with stripe before accepting service" || message.lowercased() == "connettiti con stripe prima di accettare il servizio" {
                self.alert(title: "", message: message, actions: ["OK","Connect Account?"]) { flag in
                    if flag == 1 {
                        let controller = StripeConnectWebVC.storyboardInstance
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }else{
                self.alert(title: "", message: message, actions: ["OK"]) { flag in
                }
            }
        }) { (dic) in
            print(dic)
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.navigationController?.popViewController(animated: true)
            
            
        }
        
    }
    
    func callCancelAPI() {
        let param = ["user_id":UserData.shared.getUser()!.user_id,
                     "service_id":providerSide_ProviderDetails!.service_request_id]
        Modal.shared.cancelService(vc: self, param: param) { (dic) in
            print(dic)
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func callDownloadInvoiceAPI() {
        Modal.shared.downloadInvoice(vc: self, serviceRequestId: providerSide_ProviderDetails!.service_request_id) { (dic) in
            print(dic)
            let data = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            let url = data["file_name"] as? String ?? ""
            if !url.isBlank{
                Downloader.loadFileAsync(url: URL(string: url)!) { (str, err) in
                    if err == nil, str != nil{
                        print("Download: \(str!)")
                        //TODO: Save file into iCloud
                        CloudDataManager.sharedInstance.copyFileToCloud()
                        DispatchQueue.main.async {
                            
                            let ac = UIAlertController(title: "Saved!".localized, message: "Documents is saved.".localized, preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title:"OK".localized, style: .default, handler: { (action) in
                                
                                if let previewUrl = URL(string: url) {
                                    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                    let destinationUrl = documentsUrl.appendingPathComponent(previewUrl.lastPathComponent)
                                    let documentInteractionController = UIDocumentInteractionController()
                                    documentInteractionController.delegate = self
                                    documentInteractionController.url = destinationUrl
                                    documentInteractionController.uti = destinationUrl.typeIdentifier ?? "public.data, public.content"
                                    documentInteractionController.name = destinationUrl.localizedName ?? previewUrl.lastPathComponent
                                    documentInteractionController.presentPreview(animated: true)
                                }
                            }))
                            self.viewController?.present(ac, animated: true, completion: nil)
                        }
                    }
                    else{
                        let ac = UIAlertController(title: "Save error".localized, message: err?.localizedDescription, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                        self.viewController?.present(ac, animated: true, completion: nil)
                        print("Error in Save Document")
                    }
                }
            }
            else{
                print("No URL found")
            }
        }
    }
    
    func getProviderData() {
        Task {
            do {
                let param:[String:Any] = [
                    "user_id":UserData.shared.getUser()!.user_id,
                    "service_request_id":serviceRequestId ?? ""
                ]
                let dic = try await APIClient.shared.getProviderServiceData(params: param)
                await MainActor.run {
                    print(dic)
                    self.providerServicesObj = ProviderServicesList(dictionary: dic)
                    self.providerServiceList = self.providerServicesObj!.providerServices
                    providerSide_ProviderDetails = self.providerServiceList
                    self.setData()
                    NotificationCenter.default.post(name: .reloadFirstServiceData, object: [:])
                }
            } catch {
                if let apiError = error as? APIError {
                    await MainActor.run {
                        self.alert(title: "Alert".localized, message: apiError.message)
                    }
                }
            }
        }
    }
    
    func setData(){
        if let providerSide_ProviderDetails = providerSide_ProviderDetails{
            imgUser.downLoadImage(url: providerSide_ProviderDetails.customer_image)
            lblStatus.text = providerSide_ProviderDetails.service_status_dis.capitalizingFirstLetter()
            //            lblStatus.text?.addSpaceTrainlingAndLeading(char: " ", spaceNum: 2)
            lblStatus.textAlignment = .center
            lblStatus.backgroundColor = StatusState.setStatusColor(status: providerSide_ProviderDetails.service_status)
            lblProviderNm.text = "\(providerSide_ProviderDetails.customer_fname) \(providerSide_ProviderDetails.customer_lname)"
            //            lblRating.isHidden = false
            //            imgStar.isHidden = false
                        lblRating.text = providerSide_ProviderDetails.rating
            if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.completed.rawValue){
                viewSendMsg.isHidden = true
                displayBottomButton(type: .downloadInvoice)
                hideTopMenuBar(isHide: false)
                btnRaiseDispute.isHidden = true
                viewRaisedDispute.isHidden = true
                
            }
            else if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.hired.rawValue){
                viewSendMsg.isHidden = false
                viewRaisedDispute.isHidden = false
                btnRaiseDispute.isHidden = false
                displayBottomButton(type: .cancel)
            }
            else if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.dispute.rawValue) {
                viewSendMsg.isHidden = false
            }
            else if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.onGoing.rawValue) {
                viewSendMsg.isHidden = false
                
                viewRaisedDispute.isHidden = false
                btnRaiseDispute.isHidden = false
            }
            else if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.pending.rawValue) {
                displayBottomButton(type: .accepte_reject)
                if providerSide_ProviderDetails.proposal_service_data.count <= 0{
                    displayBottomButton(type: .sendProposal)
                }
            }
            else if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.rejected.rawValue) {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
            }
            else if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.accepted.rawValue) {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
            }
            else if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.cancelled.rawValue) {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
            }
            else if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.expired.rawValue) {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
            }
            
            if providerSide_ProviderDetails.isactive.lowercased() == "du" {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
                btnRaiseDispute.isHidden = true
                btnSendMessage.isHidden = true
                
            }
            
            if providerSide_ProviderDetails.proposal_service_data.count > 0 {
                btnSendProposal.isHidden = true
                
            }
        }
    }
    
    func setUpUI() {
        self.setupNavigationBar(title: "Service Details".localized, isBack: true, rightButton: false)
        self.applyStatusbar(color: Color.Theme.purple)
        getProviderData()
        btnDownloadInvoice.setTitle("DOWNLOAD INVOICE".localized, for: .normal)
        //TODO: Condition apply for see the send msg and dispute service option
        viewSendMsg.isHidden = true
        viewRaisedDispute.isHidden = true
        btnRaiseDispute.isHidden = true
        //Bottom button display
        displayBottomButton(type: .allHide)
        
        //Topmenu Bar
        hideTopMenuBar()
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func displayBottomButton(type: BottomButtonType) {
        switch type {
        case .accepte_reject:
            stackViewBtnAcceptReject.isHidden = false
            self.lblWaitMsg.isHidden = false
            break
        case .cancel:
            btnCancel.isHidden = false
            self.lblWaitMsg.isHidden = true
            break
        case .downloadInvoice:
//                        btnDownloadInvoice.isHidden = true
            btnDownloadInvoice.isHidden = false
            self.lblWaitMsg.isHidden = true
            break
        case .sendProposal:
            btnSendProposal.isHidden = false
            break
        case .allHide:
            stackViewBtnAcceptReject.isHidden = true
            self.lblWaitMsg.isHidden = true
            btnDownloadInvoice.isHidden = true
            btnCancel.isHidden = true
            btnSendProposal.isHidden = true
            break
        }
    }
    
    func hideTopMenuBar(isHide:Bool = true) {
        stackViewMenuBar.isHidden = isHide
        //topConstStackViewMenubar.constant = (isHide ? 0.0 : 30.0)
        //self.view.layoutIfNeeded()
        btnService.isHidden = isHide
        btnInvoiceDescription.isHidden = isHide
        greenStripe.isHidden = isHide
    }
    
    func animationOnView(center point:CGPoint,vcWithIdentifier id:String = "") {
        switch selectedMenu {
        case 0:
            btnService.setImage(#imageLiteral(resourceName: "icon1_Grey"), for: .normal)
        case 1:
            btnInvoiceDescription.setImage(#imageLiteral(resourceName: "ic_cost_summary_grey"), for: .normal)
        default:
            break
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.greenStripe.center.x = point.x
        }, completion: nil)
        //print("Old\(self.greenStripe.center.x)")
        // print("New:\(point.x)")
        //        self.greenStripe.frame.origin.x = point.x
        //        slef.constGreenCenter =
        print("setedNewVal:\(self.greenStripe.center.x)")
    }
}

extension ProviderSideServiceDetailVC: RaiseDisputeProtocol{
    func raiseDisputeComplete(isSuccess: Bool) {
        if isSuccess{
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension ProviderSideServiceDetailVC: SendProposalProtocol{
    func sendProposalComplete(isSuccess: Bool) {
        if isSuccess{
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func sendProposalStripeConnect() {
        let controller = StripeConnectWebVC.storyboardInstance
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProviderSideServiceDetailVC: UIDocumentInteractionControllerDelegate {
    /// If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        return navVC
    }
}
