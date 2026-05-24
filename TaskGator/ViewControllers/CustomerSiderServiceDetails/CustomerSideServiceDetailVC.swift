//
//  CustomerSideServiceDetailVC.swift
//  TaskGator
//
//  Created by NCT 24 on 11/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SafariServices

var customerSide_ProviderDetails:CustomerServicesCls.CustomerServices?

class CustomerSideServiceDetailVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:CustomerSideServiceDetailVC? {
        return StoryBoard.customerSideServiceDetails.instantiateViewController(withIdentifier: CustomerSideServiceDetailVC.identifier) as? CustomerSideServiceDetailVC
    }
    
    enum BottomButtonType:Int {
        case bookNow
        case cancel
        case downloadInvoice
    }
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblProviderNm: UILabel!{
        didSet{
            //            let tapGest = UITapGestureRecognizer(target: self, action: #selector(pushToProviderProfile))
            //            lblProviderNm.addGestureRecognizer(tapGest)
        }
    }
    
    @IBOutlet weak var btnFavourite: UIButton!{
        didSet{
            btnFavourite.setImage(#imageLiteral(resourceName: "heart1Big"), for: .normal)
            btnFavourite.setImage(#imageLiteral(resourceName: "heartBig"), for: .selected)
        }
    }
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius()
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(pushToProviderProfile))
            imgUser.addGestureRecognizer(tapGest)
        }
    }
    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var greenStripe: UIView!
    @IBOutlet weak var btnService: UIButton!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    
    @IBOutlet weak var bottomBtnHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var lblSendMsg: UILabel!
    @IBOutlet weak var lblRaiseDispute: UILabel!
    @IBOutlet weak var lblFavourite: UILabel!
    
    @IBOutlet weak var viewSendMsg: UIView!
    @IBOutlet weak var viewRaisedDispute: UIView!
    
    @IBOutlet weak var btnBottom: GreenButton!{
        didSet{
            btnBottom.isHidden = true
        }
    }
    @IBOutlet weak var btnBookNow: UIButton!{
        didSet{
            btnBookNow.isHidden = true
        }
    }
    @IBOutlet weak var btnCancel: UIButton!{
        didSet{
            btnCancel.isHidden = true
        }
    }
    @IBOutlet weak var btnDownloadInvoice: UIButton!{
        didSet{
            btnDownloadInvoice.isHidden = true
        }
    }
    
    @IBOutlet weak var btnAddReview: UIButton!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                //                self.btnAddReview.border(side: .all, color: Color.green.theam, borderWidth: 1.0)
            }
        }
    }
    
    @IBOutlet weak var btnPayForExtendedService: UIButton!{
        didSet{
            btnPayForExtendedService.isHidden = true
        }
    }
    @IBOutlet weak var btnExtendService: UIButton!{
        didSet{
            btnExtendService.isHidden = true
        }
    }
    
    var selectedCustInnerMenu = 0
    var providerServiceId:String?
    var serviceRequestId:String?
    deinit {
        selectedCustInnerMenu = 0
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar(title: topTitle ?? "", isBack: true, rightButton: false)
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .menuChange, object: nil)
        getproviderServiceDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnBottom.setTitle("", for: .normal)
        setLang()
    }
    
    func setLang() {
        lblSendMsg.text = "Send Message".localized
        lblRaiseDispute.text = "Raise Dispute".localized
        btnAddReview.setTitle("ADD REVIEW".localized, for: .normal)
        btnBottom.setTitle("SEND REQUEST".localized, for: .normal)
        btnBookNow.setTitle("BOOK NOW".localized, for: .normal)
        btnCancel.setTitle("CANCEL".localized, for: .normal)
        btnDownloadInvoice.setTitle("DOWNLOAD INVOICE".localized, for: .normal)
//        btnExtendService.setTitle("EXTEND SERVICE".localized, for: .normal)
        btnExtendService.setTitle("BOOK NOW".localized, for: .normal)
        btnPayForExtendedService.setTitle("PAY FOR EXTENDED SERVICE".localized, for: .normal)
    }
    
    @objc func pushToProviderProfile(){
        if let providerId = customerSide_ProviderDetails?.provider_id{
            if let vc = CustomerSideProviderProfileVC.storyboardInstance {
                vc.providerId = providerId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    @IBAction func onClickRaiseDispute(_ sender: UIButton) {
        if let customerSide_ProviderDetails = customerSide_ProviderDetails{
            let parentVC = self
            guard let nextVC = RaiseDisputeVC.storyboardInstance else {return}
            nextVC.delegate = self
            nextVC.serviceRequestId = customerSide_ProviderDetails.service_request_id
            nextVC.presentAsPopUp(parentVC: parentVC)
        }
    }
    
    @IBAction func onClickSendMsg(_ sender: UIButton) {
        if let customerSide_ProviderDetails = customerSide_ProviderDetails{
            let dic:[String:Any] = [
                "from_user_id": UserData.shared.getUser()!.user_id,
                "to_user_id": customerSide_ProviderDetails.provider_id,
                "service_master_id": customerSide_ProviderDetails.service_id,
                "service_id": customerSide_ProviderDetails.service_booking_id,
                "service_booking_id":customerSide_ProviderDetails.service_booking_id
            ]
            //            "service_id":fatchedParam["service_id" ] as! String,//service_booking_id
            //            "service_master_id":fatchedParam["service_master_id"] as! String, //service_id
            let nextVC = ChatHostingVC()
            nextVC.param = dic
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @IBAction func onClickBookNow(_ sender: UIButton) {
        callBookNowAPI()
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
    
    @IBAction func onClickDownloadInvoice(_ sender: UIButton) {
        callDownloadInvoiceAPI()
        //        doShare()
    }
    
    @IBAction func onClickAddReview(_ sender: UIButton) {
        
        if let customerSide_ProviderDetails = customerSide_ProviderDetails{
            let parentVC = self
            guard let nextVC = ReviewPopUpVC.storyboardInstance else {return}
            nextVC.delegate = self
            nextVC.serviceRequestId = customerSide_ProviderDetails.service_request_id
            nextVC.presentAsPopUp(parentVC: parentVC)
        }
        
    }
    
    @IBAction func onClickExtendService(_ sender: UIButton) {
        //TODO: extendSerivice Popup open
//        let parentVC = self
//        guard let nextVC = ExtendServicePopUp.storyboardInstance else {return}
//        nextVC.delegate = self
//        //nextVC.proposalId = pendingProposal.id
//        nextVC.presentAsPopUp(parentVC: parentVC)
        
        if let customerSide_ProviderDetails = customerSide_ProviderDetails{
            Modal.shared.homeProviderServiceDetail(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id, "loginuser_id":UserData.shared.getUser()!.user_id,"provider_id":customerSide_ProviderDetails.provider_id,"delivery_type":customerSide_ProviderDetails.delivery_type,"request_type":"scheduled"]) { (dic) in
                print(dic)
                is_from_myservices = false
                let nextVC = ServiceDetailHostingVC()
                let details  = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
                providerServiceDetail = details
                topTitle = details.service_name
                nextVC.provider_service_id = details.id
                nextVC.provider_id = customerSide_ProviderDetails.provider_id
                nextVC.deliveryType = customerSide_ProviderDetails.delivery_type
                nextVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
 
        
    }
    
    @IBAction func onClickPayForExtendedService(_ sender: UIButton) {
        if let customerSide_ProviderDetails = customerSide_ProviderDetails, customerSide_ProviderDetails.extend_service_data.count > 0{
            
            let md5String = md5HexString(customerSide_ProviderDetails.service_request_id)
            let param = [
                "user_id": UserData.shared.getUser()!.user_id,
                "extend_id" : customerSide_ProviderDetails.extend_service_data[0].extend_id,
                "service_request_token" : md5String, //customerSide_ProviderDetails.service_request_id
            ]
            Modal.shared.payForextEndService(vc: self, param: param) { (dic) in
                print(dic)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //    func md5(_ string: String) -> String {
    //        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
    //        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
    //        CC_MD5_Init(context)
    //        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
    //        CC_MD5_Final(&digest, context)
    //        context.deallocate()
    //        var hexString = ""
    //        for byte in digest {
    //            hexString += String(format:"%02x", byte)
    //        }
    //        return hexString
    //    }
    
    @IBAction func onClickBottom(_ sender: UIButton) {
        print("BootomBtn Press")
        if let title = sender.titleLabel?.text, title == "BOOK NOW" || title == "SEND REQUEST" {
            callBookNowAPI()
        }
        else if let title = sender.titleLabel?.text, title == "CANCEL"{
            callCancelAPI()
        }
        //        else if let title = sender.titleLabel?.text, title == "DOWNLOAD INVOICE"{
        //            callDownloadInvoiceAPI()
        //        }
    }
    
    @IBAction func onClickService(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnService.setImage(#imageLiteral(resourceName: "icon1_Green"), for: .normal)
        
        
        //TODO: Condition for status change
        if let customerSide_ProviderDetails = providerServiceDetail , customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.accepted.rawValue) {
            btnBookNow.isHidden = false
        }else{
            btnBookNow.isHidden = true
        }
        
        
        animationOnView(center: sender.center)
        selectedCustInnerMenu = 0
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedCustInnerMenu] as [String:Any])
    }
    
    @IBAction func onClickUser(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnUser.setImage(#imageLiteral(resourceName: "icon2_Green"), for: .normal)
        btnBookNow.isHidden = true
        
        animationOnView(center: sender.center)
        selectedCustInnerMenu = 1
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedCustInnerMenu] as [String:Any])
    }
    
    @IBAction func onClickStar(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnStar.setImage(#imageLiteral(resourceName: "icon3_Green"), for: .normal)
        btnBookNow.isHidden = true
        
        animationOnView(center: sender.center)
        selectedCustInnerMenu = 2
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedCustInnerMenu] as [String:Any])
    }
    
    @IBAction func onClickGallery(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnGallery.setImage(#imageLiteral(resourceName: "icon4_Green"), for: .normal)
        btnBookNow.isHidden = true
        
        animationOnView(center: sender.center)
        selectedCustInnerMenu = 3
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedCustInnerMenu] as [String:Any])
    }
    
    @IBAction func onClickFavorite(_ sender: UIButton) {
        //Come from favourite provider screen
        //0 = add to favourite, 1 = remove from favourite
        if let data = providerServiceDetail {
            let param = [
                "user_id": UserData.shared.getUser()!.user_id,
                "service_id":customerSide_ProviderDetails!.provider_service_id,
                "fvrt_val": (data.total_favorite > "0" ? "1" : "0"),
                "lId":UserData.shared.languageID,
                "provider_id":data.provider_id,
                "delivery_type":data.delivery_type,
                "request_type":data.request_type]
            
            callFavouriteUnfavoriteAPI(param: param)
        }
    }
    
}

//MARK: Custom function
extension CustomerSideServiceDetailVC {
    func getproviderServiceDetail(){
        let param:[String:Any] = [
            "user_id":UserData.shared.getUser()!.user_id,
            "provider_service_id":providerServiceId ?? "",
            "service_request_id":serviceRequestId ?? ""]
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let dic = try await APIClient.shared.getProviderServiceDetail(params: param)
                await MainActor.run {
                    providerServiceDetail = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
                    self.setUpUI()
                    NotificationCenter.default.post(name: .reloadFirstServiceData, object: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if self.selectedCustInnerMenu == 2 {
                            self.onClickStar(self.btnStar)
                            self.btnService.setImage(#imageLiteral(resourceName: "icon1_Grey"), for: .normal)
                            self.btnStar.setImage(#imageLiteral(resourceName: "icon3_Green"), for: .normal)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func setBottomButton(type: BottomButtonType){
        btnBookNow.isHidden = true
        btnDownloadInvoice.isHidden = true
        btnCancel.isHidden = true
        
        switch type {
        case .bookNow:
            btnBookNow.isHidden = false
            btnBottom.isHidden = true
        case .cancel:
            btnCancel.isHidden = false
            btnBottom.isHidden = true
        case .downloadInvoice:
            btnDownloadInvoice.isHidden = false
            btnBottom.isHidden = true
        }
    }
    
    func callDownloadInvoiceAPI() {
        Modal.shared.downloadInvoice(vc: self, serviceRequestId: customerSide_ProviderDetails!.service_request_id) { (dic) in
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
    
    func callBookNowAPI() {
        let param = ["user_id":UserData.shared.getUser()!.user_id,
                     "service_id":customerSide_ProviderDetails!.service_request_id]
        Modal.shared.serviceRequestBookNow(vc: self, param: param) { (dic) in
            print(dic)
            self.sharedAppdelegate.stoapLoader()
            //            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            let dicData = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            
            //SDK PAYMENT FLOW
            if let paymentIntentClientSecret = dicData["paymentIntentClientSecret"] as? String,
               let total_amount_to_charge_full = dicData["total_amount_to_charge_full"] as? String,
               let booking_amount = dicData["booking_amount"] as? String,
               let total_fees = dicData["total_fees"] as? String {
                
                let controller = StripeCheckoutVC.storyboardInstance
                controller.paymentIntentClientSecret = paymentIntentClientSecret
                controller.total_amount_to_charge = total_amount_to_charge_full
                controller.booking_amount = booking_amount
                controller.total_fees = total_fees
                self.navigationController?.pushViewController(controller, animated: true)
            }else{
                let ac = UIAlertController(title: "Error".localized, message: "Something went wrong,Please contact admin", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                self.viewController?.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    func callCancelAPI() {
        let param = ["user_id":UserData.shared.getUser()!.user_id,
                     "service_id":customerSide_ProviderDetails!.service_request_id]
        Modal.shared.cancelService(vc: self, param: param) { (dic) in
            print(dic)
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func menuChange(notification: Notification) {
        let data = notification.object as! [String: Any]
        guard let index = data["Pagevc_index"] as? Int else { return }
        
        switch index {
        case 0:
            onClickService(btnService)
        case 1:
            onClickUser(btnUser)
        case 2:
            onClickStar(btnStar)
        case 3:
            onClickGallery(btnGallery)
        default:
            break
        }
        
    }
    
    
    func setUpUI() {
        lblProviderNm.text = providerServiceDetail?.provider_name
        imgUser.downLoadImage(url: providerServiceDetail?.provider_image ?? "")
        lblRating.text = providerServiceDetail?.avg_rating
        btnFavourite.isSelected = (providerServiceDetail!.total_favorite > "0" ? true : false)
        
        //TODO: Condition apply for see the send msg and dispute service option
        viewSendMsg.isHidden = true
        viewRaisedDispute.isHidden = true
        btnAddReview.isHidden = true
        btnBottom.isHidden = true
        
        //TODO: Condition for status change
        if let customerSide_ProviderDetails = providerServiceDetail{
            lblStatus.text = "\(customerSide_ProviderDetails.service_status_dis.capitalizingFirstLetter()) "
            //            lblStatus.text?.addSpaceTrainlingAndLeading(char: " ", spaceNum: 2)
            lblStatus.textAlignment = .center
            lblStatus.backgroundColor = StatusState.setStatusColor(status: customerSide_ProviderDetails.service_status)
            if (customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.completed.rawValue)){
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
                btnAddReview.isHidden = customerSide_ProviderDetails.isReviewGiven.lowercased() == "n" ? false : true
                btnBottom.isHidden =  customerSide_ProviderDetails.isReviewGiven.lowercased() == "n" ? false : true //(customerSide_ProviderDetails.review_data.count > 0)
                //btnBottom.setTitle("DOWNLOAD INVOICE", for: .normal)
                //bottomBtnHeightConst.constant = 55.0
                setBottomButton(type: .downloadInvoice)
            }
            else if providerServiceDetail!.service_status.caseInsensitiveCompare(string: StatusState.StatusType.dispute.rawValue) {
                viewSendMsg.isHidden = false
            }
            else if providerServiceDetail!.service_status.caseInsensitiveCompare(string: StatusState.StatusType.onGoing.rawValue) {
                
                if providerServiceDetail?.payment_preference == "wallet"{
                    viewSendMsg.isHidden = false
                    viewRaisedDispute.isHidden = false
                }
                //Set visibility of pay for button
                if customerSide_ProviderDetails.extend_service_data.count == 0{
                    if customerSide_ProviderDetails.service_master_type == "hourly" {
                        //If User payment prefreence is wallet then It allows to extendServise
                        //if UserData.shared.paymentPref == "Wallet"{
                        btnExtendService.isHidden = false // hidden based on client reuqirement 18-9-2023
                        btnBottom.isHidden = true // Changed 5-7-22
                        //}
                    }else{
                        btnExtendService.isHidden = true
                        btnBottom.isHidden = true
                    }
                }
                else if customerSide_ProviderDetails.extend_service_data.count > 0{
                    if customerSide_ProviderDetails.extend_service_data[0].serviceStatus == StatusState.StatusType.accepted.rawValue{
                        btnPayForExtendedService.isHidden = true
                        btnBottom.isHidden = true // // Changed 5-7-22
                    }
                }
            }
            
            else if customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.hired.rawValue) {
                setBottomButton(type: .cancel)
                //btnBottom.setTitle("CANCEL", for: .normal)
                //bottomBtnHeightConst.constant = 55.0
                viewSendMsg.isHidden = false
                viewRaisedDispute.isHidden = false
            }
            else if customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.accepted.rawValue) {
                //btnBottom.setTitle("BOOK NOW", for: .normal)
                //bottomBtnHeightConst.constant = 55.0
                setBottomButton(type: .bookNow)
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
                
            }
            else if customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.rejected.rawValue) {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
            }
            else if customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.cancelled.rawValue) {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
            }
            else if customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.pending.rawValue) {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
            }
            else if customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.expired.rawValue) {
                viewSendMsg.isHidden = true
                viewRaisedDispute.isHidden = true
            }
        }
    }
    
    func callFavouriteUnfavoriteAPI(param: [String:Any]) {
        Modal.shared.likeDislikeServices(vc: self, param: param) { (dic) in
            print(dic)
            //inserted
            //deleted
            if let _ = providerServiceDetail {
                print("Before: \(providerServiceDetail!.total_favorite > "0" ? "liked" : "Disliked")")
                providerServiceDetail!.total_favorite = (providerServiceDetail!.total_favorite > "0" ? "0" : "1") //Reverse condition for like/dislike
                self.btnFavourite.isSelected = (providerServiceDetail!.total_favorite > "0" ? true : false)
                print("After: \(providerServiceDetail!.total_favorite > "0" ? "liked" : "Disliked")")
                //TODO: raised notification for load new list of favouriteProvider
                NotificationCenter.default.post(name: .providerDisLike, object: ["isProviderDislike":true])
            }
        }
    }
    
    func callData(param:[String:Any]){
        Modal.shared.likeDislikeServices(vc: self, param: param) { (dic) in
            print(dic)
            if let _ = providerServiceDetail{
                print("Before: \(providerServiceDetail!.total_favorite > "0" ? "liked" : "Disliked")")
                providerServiceDetail?.total_favorite = (providerServiceDetail!.total_favorite > "0" ? "0":"1")
                self.btnFavourite.isSelected = (providerServiceDetail!.total_favorite > "0" ? true : false)
                print("After: \(providerServiceDetail!.total_favorite > "0" ? "liked" : "disliked")")
                NotificationCenter.default.post(name: .providerDisLike, object: ["isProviderDislike":true])
            }
        }
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func animationOnView(center point:CGPoint,vcWithIdentifier id:String = "") {
        
        switch selectedCustInnerMenu {
        case 0:
            btnService.setImage(#imageLiteral(resourceName: "icon1_Grey"), for: .normal)
        case 1:
            btnUser.setImage(#imageLiteral(resourceName: "icon2_Grey"), for: .normal)
        case 2:
            btnStar.setImage(#imageLiteral(resourceName: "icon3_Grey"), for: .normal)
        case 3:
            btnGallery.setImage(#imageLiteral(resourceName: "icon4_Grey"), for: .normal)
        default:
            break
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.greenStripe.center.x = point.x
        }, completion: nil)
        
    }
    
}

extension CustomerSideServiceDetailVC: SubmitReviews{
    func reviewSubmitted(isSuccess: Bool) {
        if isSuccess {
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension CustomerSideServiceDetailVC: ExtendServiceProtocol{
    func sendExtendServiceComplete(isSuccess: Bool) {
        if isSuccess{
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension CustomerSideServiceDetailVC: RaiseDisputeProtocol{
    func raiseDisputeComplete(isSuccess: Bool) {
        if isSuccess{
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension CustomerSideServiceDetailVC: UIDocumentInteractionControllerDelegate {
    /// If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        return navVC
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
