//
//  CustomerSideProviderProfileVC.swift
//  TaskGator
//
//  Created by admin on 8/21/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class CustomerSideProviderProfileVC: NewBaseViewController {
    
    static var storyboardInstance:CustomerSideProviderProfileVC? {
        return StoryBoard.profiles.instantiateViewController(withIdentifier: CustomerSideProviderProfileVC.identifier) as? CustomerSideProviderProfileVC
    }
    
    //    @IBOutlet weak var imgCover: UIImageView!
    //    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.setRadius()
        }
    }
    @IBOutlet weak var imgProfile: UIImageView!{
        didSet{
            imgProfile.setRadius()
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var lblPayEmail: UILabel!
    @IBOutlet weak var lblPositiveRating: UILabel!
    @IBOutlet weak var lblWorkOnTask: UILabel!
    @IBOutlet weak var lblStaAbout: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblStaAvailability: UILabel!
    @IBOutlet weak var lblAvailibility: UILabel!
    @IBOutlet weak var lblStaTime: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblStaRating: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblStaMyServices: UILabel!
    @IBOutlet weak var lblMyServices: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!{
        didSet{
            // btnViewAll.underline()//
        }
    }
    //    @IBOutlet weak var btnServiceViewAll: UIButton!{
    //        didSet{
    //          //  btnServiceViewAll.underline()
    //        }
    //    }
    @IBOutlet weak var btnFlag: UIButton!
    
    
    var providerData:UserProfile?
    var providerId:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar(title: "Provider Profile".localized, isBack: true, rightButton: false)
        self.applyStatusbar(color: Color.Theme.purple)
        callGetProfile()
        
        setLang()
        
    }
    
    func setLang() {
        lblStaAvailability.text = "Availability".localized
        lblStaMyServices.text = "My Service".localized
        lblStaRating.text = "My Retings".localized
        lblStaTime.text = "Time".localized
        lblStaAbout.text = "About".localized
        btnViewAll.setTitle("View All".localized, for: .normal)
        //        btnServiceViewAll.setTitle("View All".localized, for: .normal)
        btnViewAll.underline()
        //        btnServiceViewAll.underline()
        
    }
    @objc func onClickBack(){
        self.navigationController?.popViewController(animated: true )
    }
    @IBAction func onClickRatingViewAll(_ sender: UIButton) {
        let vc = ReviewList.storyboardInstance!
        vc.userId = providerData?.id
        vc.userType = "p"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onClickViewAllServices(_ sender: UIButton) {
        let vc = MyServicesHostingVC()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onClickFlaguser(_ sender: Any) {
        
        Modal.shared.flagUser(vc: self, param: ["user_id":UserData.shared.getUser()?.user_id ?? "","flag_user_id":self.providerId ?? "",
                                               ], failer: { (message) in
            //Display Error
            self.alert(title: "Error".localized, message: message)
            
        }) { (dic) in
            print(dic)
            let message =  ResponseKey.fatchDataAsString(res: dic, valueOf: .message)
            self.btnFlag.isSelected = !self.btnFlag.isSelected
            self.alert(title: "Alert".localized, message: message)
        }
    }
}

extension CustomerSideProviderProfileVC{
    func callGetProfile() {
        
        Modal.shared.getUserProfile(vc: self, param: ["profile_id":providerId ?? ""]) { (dic) in
            print(dic)
            let data = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            self.setUserData(data: data!)
            self.providerData = data
            print(self.providerData!.dictionaryRepresentation)
        }
    }
    
    func setUserData(data: UserProfile) {
        lblPositiveRating.text = data.positive_rating + " " + "Positive Ratings".localized
        lblWorkOnTask.text = "Worked on".localized + " " + data.task_assigned + " " + "Tasks".localized
        //        imgCover.downLoadImage(url: data.profile_img)
        imgProfile.downLoadImage(url: data.profile_img)
        lblName.text = data.user_name
        lblPhoneNumber.text = data.country_code + " " + data.contact_number
        lblEmailId.text = data.email
        lblPayEmail.text = data.paypal_email
        //        imgIconPaypal.isHidden = Modal.sharedAppdelegate.isCustomerLogin
        //        lblPayEmail.isHidden = Modal.sharedAppdelegate.isCustomerLogin
        lblTime.text = data.available_time_start + " - " + data.available_time_end
        lblRating.text = String(data.star_rating!)
        if data.description == ""{
            lblAbout.text = "There is nothing to display here, please write something about yourself".localized
        }
        else
        {
            lblAbout.text = data.description
        }
        lblAvailibility.text = data.available_days_list
        lblMyServices.text = data.total_review
        
        if data.is_flag.lowercased() == "y" {
            btnFlag.isSelected = true
        }
    }
}
