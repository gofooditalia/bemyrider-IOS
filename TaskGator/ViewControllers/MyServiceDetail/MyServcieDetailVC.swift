//
//  MyServcieDetailVC.swift
//  TaskGator
//
//  Created by NCrypted on 19/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit


class MyServcieDetailVC: NewBaseViewController {
    
    
    static var storyboardInstance:MyServcieDetailVC? {
        return StoryBoard.myServiceDetail.instantiateViewController(withIdentifier: MyServcieDetailVC.identifier) as? MyServcieDetailVC
    }
    
    //    MARK: Properties
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblProviderNm: UILabel!
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius()
        }
    }
    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var greenStripe: UIView!
    @IBOutlet weak var btnService: UIButton!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnEditService: UIButton!
    
    var isChangeEditServiceImages = false
    var selectedMenu = 0
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
            onClickStar(btnStar)
        case 2:
            print(0)
            onClickGallery(btnGallery)
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //    MARK: ViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .menuChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addService(notification:)), name: .isAddService, object: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
        if isChangeEditServiceImages{
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @objc func addService(notification: Notification) {
        if (notification.object as! [String: Any])["isAddService"] as? Bool ?? false{
            isChangeEditServiceImages = true
        }
    }
    
    func setLang(){
        //btnEditService.setTitle(localizedString(key: "EDIT SERVICE"), for: .normal)
        btnEditService.setTitle("EDIT SERVICE".localized, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UIButton Click Events
    @IBAction func onClickDelete(_ sender: UIButton) {
        self.alert(title: "", message: "Are you sure you want to delete this service?".localized, actions: ["Ok".localized,"Cancel".localized]) { (flag) in
            if flag == 0{//delete
                self.callDeleteAPI()
            }else{// cancel
            }
        }
    }
    @IBAction func onClickEditservice(_ sender: UIButton) {
        //if let providerServiceDetail = providerServiceDetail, let providerService = providerService{
            let nextVC = AddNewServiceVC.storyboardInstance!
            //Below two variable are for edit the already created service
            nextVC.isEdit = true
            //nextVC.servicePrice = providerServiceDetail.price
            //nextVC.serviceType = providerService.service_type
//            nextVC.serviceDescription = providerServiceDetail._description
            self.navigationController?.pushViewController(nextVC, animated: true)
        //}
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
    @IBAction func onClickStar(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnStar.setImage(#imageLiteral(resourceName: "icon3_Green"), for: .normal)
        
        animationOnView(center: sender.center)
        selectedMenu = 1
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedMenu] as [String:Any])
    }
    
    @IBAction func onClickGallery(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        btnGallery.setImage(#imageLiteral(resourceName: "icon4_Green"), for: .normal)
        
        animationOnView(center: sender.center)
        selectedMenu = 2
        NotificationCenter.default.post(name: .menuChange, object: ["selectedMenu":selectedMenu] as [String:Any])
    }
}

//MARK: Custom function

extension MyServcieDetailVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: providerServiceDetail?.service_name ?? "", action: #selector(onClickMenu(_:)))
        
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title: providerServiceDetail?.service_name ?? "", isBack: true, rightButton: false)
        
        lblStatus.text?.addSpaceTrainlingAndLeading(spaceNum: 2)
        lblProviderNm.text = UserData.shared.getUser()?.user_name
        //TODO: #new - profile url of provider
        imgUser.downLoadImage(url: providerServiceDetail?.provider_image ?? UserData.shared.getUser()!.profile_img)
        lblRating.text = providerServiceDetail?.avg_rating
        
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func animationOnView(center point:CGPoint,vcWithIdentifier id:String = "") {
        
        switch selectedMenu {
        case 0:
            btnService.setImage(#imageLiteral(resourceName: "icon1_Grey"), for: .normal)
        case 1:
            btnStar.setImage(#imageLiteral(resourceName: "icon3_Grey"), for: .normal)
        case 2:
            btnGallery.setImage(#imageLiteral(resourceName: "icon4_Grey"), for: .normal)
        default:
            break
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.greenStripe.center.x = point.x
        }, completion: nil)
    }
    
    func callDeleteAPI() {
        let param = [
            "provider_service_id" : providerServiceDetail!.id,
            "user_id" : UserData.shared.getUser()!.user_id
        ]
        
        Modal.shared.deleteService(vc: self, param: param) { (dic) in
            print(dic)
            //TODO: raise notification
            NotificationCenter.default.post(name: .isAddService, object: ["isAddService":true] as [String:Any])
            self.navigationController?.popViewController(animated: true)
        }
    }
}
