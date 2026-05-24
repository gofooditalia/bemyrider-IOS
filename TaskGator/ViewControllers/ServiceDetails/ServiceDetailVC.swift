//
//  ServiceDetailVC.swift
//  TaskGator
//
//  Created by NCT 24 on 30/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

extension Notification.Name{
    static let providerDisLike = Notification.Name("providerDisLike")
    static let reloadFirstServiceData = Notification.Name("reloadFirstServiceData")
}


//This dicationary for get data which entered in innerService for "senf request"
var requestDic:[String:Any] = [:]
var deliveryType:String = ""

class ServiceDetailVC: NewBaseViewController {
    
    //MARK: Properties
    static var storyboardInstance:ServiceDetailVC? {
        return StoryBoard.serviceProviderDetail.instantiateViewController(withIdentifier: ServiceDetailVC.identifier) as? ServiceDetailVC
    }
    
    //    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblProviderNm: UILabel!{
        didSet{
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(pushToProviderProfile))
            lblProviderNm.addGestureRecognizer(tapGest)
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
    
    
    var selectedMenu = 0
    var userId:String?
    var profile:String?
    var provider_service_id:String = ""
    //var methosAry:[] = []
    
    @objc func menuChange(notification: Notification) {
        let data = notification.object as! [String: Any]
        guard let index = data["Pagevc_index"] as? Int else { return }
        print("Raised notification")
        switch index {
        case 0:
            print(0)
            onClickService(btnService)
        case 1:
            print(0)
            onClickUser(btnUser)
        case 2:
            print(0)
            onClickStar(btnStar)
        case 3:
            print(0)
            onClickGallery(btnGallery)
        default:
            break
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var lblFavourite: UILabel!
    @IBOutlet weak var btnSendRequest: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
        
    }
    
    func setLang() {
        lblFavourite.text = "Favorite".localized
        btnSendRequest.setTitle("SEND REQUEST".localized, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .menuChange, object: nil)
        //self.storyboard?.instantiateViewController(withIdentifier: "")
        //requestDic.removeAll()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchAddrDic.removeAll()
    }
    
    func setUpUI() {
        
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: topTitle!, isBack: true, rightButton: false)
    
        
        //        if !(lblStatus.text?.isEmpty)!{
        //            lblStatus.text?.addSpaceTrainlingAndLeading(spaceNum: 2)
        //        }
        if userId != UserData.shared.getUser()?.user_id{
            lblProviderNm.text = providerServiceDetail?.user_name
            lblRating.text = providerServiceDetail?.avg_rating
            imgUser.downLoadImage(url: providerServiceDetail?.provider_image ?? "")
        }else{
            lblProviderNm.text = providerDetails?.provider_name
            imgUser.downLoadImage(url: providerDetails?.provider_image ?? "")
            lblRating.text = providerServiceDetail?.avg_rating
        }
        
        if let favId = providerDetails?.favorite_id, !(favId.isEmpty){
            print("Come from searchProvider screen")
            btnFavourite.isSelected = (favId > "0" ? true : false)
        }
        else{
            print("Come from FavouriteProvider screen")
            btnFavourite.isSelected = (providerServiceDetail!.total_favorite > "0" ? true : false)
        }
    }
    
    @objc func pushToProviderProfile(){
        if let providerId = providerDetails?.provider_id{
            if let vc = CustomerSideProviderProfileVC.storyboardInstance {
                vc.providerId = providerId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func onClickService(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnService.setImage(#imageLiteral(resourceName: "icon1_Green"), for: .normal)
        
        animationOnView(center: sender.center)
        selectedMenu = 0
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedMenu] as [String:Any])
    }
    
    @IBAction func onClickUser(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnUser.setImage(#imageLiteral(resourceName: "icon2_Green"), for: .normal)
        
        animationOnView(center: sender.center)
        selectedMenu = 1
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedMenu] as [String:Any])
    }
    
    @IBAction func onClickStar(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnStar.setImage(#imageLiteral(resourceName: "icon3_Green"), for: .normal)
        
        animationOnView(center: sender.center)
        selectedMenu = 2
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedMenu] as [String:Any])
    }
    
    @IBAction func onClickGallery(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnGallery.setImage(#imageLiteral(resourceName: "icon4_Green"), for: .normal)
        
        animationOnView(center: sender.center)
        selectedMenu = 3
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedMenu] as [String:Any])
    }
    
    
    
    @IBAction func onClickFavorite(_ sender: UIButton) {
            
        //Come from search provide screen
        if let favId = providerDetails?.favorite_id, !(favId.isEmpty){
            //0 = add to favourite, 1 = remove from favourite
            if let data = providerDetails {
                let param = [
                    "user_id": UserData.shared.getUser()!.user_id,
                    "service_id":data.service_id,
                    "fvrt_val": (data.favorite_id > "0" ? "1" : "0"),
                    "provider_id":data.provider_id,
//                    "delivery_type":data.delivery_type,
//                    "request_type":data.request_type,
                    "lId":UserData.shared.languageID,
                ]
                callFavouriteUnfavoriteAPI(param: param)
            }
        }
            //Come from favourite provider screen
        else{
            //0 = add to favourite, 1 = remove from favourite
            if let data = providerServiceDetail {
                let param = [
                    "user_id": UserData.shared.getUser()!.user_id,
                    "service_id":data.service_id,
                    "fvrt_val": (data.total_favorite > "0" ? "1" : "0"),
                    "lId":UserData.shared.languageID,
                    "provider_id":data.provider_id,
                    "delivery_type":deliveryType,
                    "request_type":data.request_type
                ]
                callFavouriteUnfavoriteAPI(param: param)
            }
        }
    }
    
    
    func isValidated(param:[String:Any]) -> Bool {
        var ErrorMsg = ""
        if !param.keys.contains("service_start_time"){
            ErrorMsg = "Please select time".localized
        }
        else if ((param["service_start_time"] as? String ?? "").isBlank){
            ErrorMsg = "Please select time".localized
        }
        else if let service_master_type = providerServiceDetail?.service_master_type, service_master_type == "hourly" && (!param.keys.contains("sel_hours")){
            ErrorMsg = "Please select hours".localized
        }
        else if let service_master_type = providerServiceDetail?.service_master_type, service_master_type == "hourly" && ((param["sel_hours"] as? String ?? "").isBlank){
            ErrorMsg = "Please select hours".localized
        }else if ((param["service_address"] as? String ?? "").isBlank){
            ErrorMsg = "Please enter address".localized
        }
        else if !param.keys.contains("service_details"){
            ErrorMsg = "Please write description".localized
        }
        else if ((param["service_details"] as? String ?? "").isBlank){
            ErrorMsg = "Please write description".localized
        }
        
        if let start_time = param["service_start_time"] as? String{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if formatter.date(from: start_time)!.compare(Date()) == .orderedAscending || formatter.date(from: start_time)!.compare(Date()) == .orderedSame {
                ErrorMsg = "Please select service start time greater than current time".localized
                
            }
        }
        //        //Change pass dictionary
        //        if let service_master_type = providerServiceDetail?.service_master_type, service_master_type == "fixed" {
        //            requestDic["provider_service_hours"] = providerServiceDetail!.provider_service_hours
        //        }
        //        else{
        //            requestDic["sel_hours"] = selectedHours
        //        }
        
        if ErrorMsg != "" {
            let alert = UIAlertController(title: "Error".localized, message: ErrorMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func onClickSendRequest(_ sender: UIButton) {
        if userId == UserData.shared.getUser()?.user_id{
            var param: [String:Any] = [
                //"service_details": providerServiceDetail!._description,
                "provider_service_id": provider_service_id.isEmpty ? (providerServiceDetail?.service_id ?? providerServiceDetail?.provider_service_id ?? "") : provider_service_id,
                "login_service_id": UserData.shared.getUser()!.user_id,
                "user_id": UserData.shared.getUser()!.user_id,
                //"service_address": providerDetails!.address,
                "service_address": searchAddrDic["search_location"] ?? "",
                "bookingLat": searchAddrDic["bookingLat"] ?? "",
               
                "bookingLong": searchAddrDic["bookingLong"] ?? "",
                "delivery_type":deliveryType,
                "request_type":"scheduled",
            ]
            print("requestDic:\(requestDic)")
            
            requestDic.forEach({ param[$0.0] = $0.1; print("\($0.0):\($0.1)") })
            if isValidated(param: param){
                Modal.shared.sendServiceRequest(vc: self, param: param) { (dic) in
                    print(dic)
                    searchAddrDic.removeAll()
//                    requestDic.removeAll()
                    /*
                     customer_commission" = 10;
                     "deposit_commission" = 5;
                     "service_amount" = 10;
                     "wallet_Amount" = 0;
                     */
                    //TODO: Wallet haven't bal. so redirect to paypal for add bal to wallet
                    /*
                     let dicData = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
                     if (dicData["customer_commission"] as! String) > "0" {
                     let nextVC = DepositAmountVC.storyboardInstance!
                     nextVC.depositeDic = dicData
                     nextVC.serviceRequestDic = param
                     self.navigationController?.pushViewController(nextVC, animated: true)
                     }
                     else{
                     self.navigationController?.popViewController(animated: true)
                     }
                     */
                    
                    if let type = dic["type"] as? String, type.lowercased() == "error", let message = dic["message"] as? String{
                        self.alert(title: "", message: message)
                    }else if  let message = dic["message"] as? String{
                        self.alert(title: "", message: message) {
//                            self.navigationController?.popViewController(animated: true)
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
            }
        }else{
            var param: [String:Any] = [
                //"service_details": providerServiceDetail!._description,
                "provider_service_id": provider_service_id.isEmpty ? (providerServiceDetail?.service_id ?? providerServiceDetail?.provider_service_id ?? "") : provider_service_id,
                "login_service_id": UserData.shared.getUser()!.user_id,
                "user_id": UserData.shared.getUser()!.user_id,
                "delivery_type":deliveryType,
                "request_type":"scheduled"]
            print("requestDic:\(requestDic)")
            
            requestDic.forEach({ param[$0.0] = $0.1; print("\($0.0):\($0.1)") })
            if isValidated(param: param){
                Modal.shared.sendServiceRequest(vc: self, param: param) { (dic) in
                    print(dic)
//                    requestDic.removeAll()
                    searchAddrDic.removeAll()
                    /*
                     customer_commission" = 10;
                     "deposit_commission" = 5;
                     "service_amount" = 10;
                     "wallet_Amount" = 0;
                     */
                    //TODO: Wallet haven't bal. so redirect to paypal for add bal to wallet
                    /*
                     let dicData = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
                     if (dicData["customer_commission"] as! String) > "0" {
                     let nextVC = DepositAmountVC.storyboardInstance!
                     nextVC.depositeDic = dicData
                     nextVC.serviceRequestDic = param
                     self.navigationController?.pushViewController(nextVC, animated: true)
                     }
                     else{
                     self.navigationController?.popViewController(animated: true)
                     }
                     */
                    if let type = dic["type"] as? String, type.lowercased() == "error", let message = dic["message"] as? String{
                        self.alert(title: "", message: message)
                    }else if  let message = dic["message"] as? String{
                        self.alert(title: "", message: message) {
//                            self.navigationController?.popViewController(animated: true)
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                    
                }
            }
        }
    }
}

//MARK: Custom function
//MARK: Custom function
extension ServiceDetailVC {
    

    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func animationOnView(center point:CGPoint,vcWithIdentifier id:String = "") {
        
        switch selectedMenu {
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
    
    func callFavouriteUnfavoriteAPI(param: [String:Any]) {
        Modal.shared.likeDislikeServices(vc: self, param: param) { (dic) in
            print(dic)
            //inserted
            //deleted
            if let favId = providerDetails?.favorite_id, !(favId.isEmpty){
                print("Before: \(providerDetails!.favorite_id > "0" ? "liked" : "Disliked")")
                providerDetails!.favorite_id = (providerDetails!.favorite_id > "0" ? "0" : "1")
                self.btnFavourite.isSelected = (providerDetails!.favorite_id > "0" ? true : false)
                print("After: \(providerDetails!.favorite_id > "0" ? "liked" : "Disliked")")
            }
            else if let _ = providerServiceDetail {
                print("Before: \(providerServiceDetail!.total_favorite > "0" ? "liked" : "Disliked")")
                print("Before: \(providerServiceDetail!.total_favorite > "0" ? "liked" : "Disliked")")
                providerServiceDetail!.total_favorite = (providerServiceDetail!.total_favorite > "0" ? "0" : "1") //Reverse condition for like/dislike
                self.btnFavourite.isSelected = (providerServiceDetail!.total_favorite > "0" ? true : false)
                print("After: \(providerServiceDetail!.total_favorite > "0" ? "liked" : "Disliked")")
            }
            //TODO: raised notification for load new list of favouriteProvider
            NotificationCenter.default.post(name: .providerDisLike, object: ["isProviderDislike":true])
        }
    }
    
}
