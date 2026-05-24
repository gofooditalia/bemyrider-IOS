//
//  CustomerProfile.swift
//  TaskGator
//
//  Created by NCT 24 on 13/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
//import LinkedinSwift

class CustomerProfileVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:CustomerProfileVC? {
        return StoryBoard.profiles.instantiateViewController(withIdentifier: CustomerProfileVC.identifier) as? CustomerProfileVC
    }
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.setRadius()
        }
    }
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: UIColor.white)
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNum: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var btnFB: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var btnLinkedIn: UIButton!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblWorkTask: UILabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var lblVat: UILabel!
    @IBOutlet weak var lblElectornicCode: UILabel!
    @IBOutlet weak var lblCeritifedAddress: UILabel!
    
    @IBOutlet weak var btnEdit: UIButton!{
        didSet{
            btnEdit.setRadius()
        }
    }
    
    @IBOutlet weak var lblDefaultPaymrentMethod: UILabel!
    @IBOutlet weak var lbl_Address: UILabel!
    @IBOutlet weak var lblWorkOn: UILabel!
    
    @IBOutlet weak var paymentMethodView: UIView!{
        didSet{
            paymentMethodView.setRadiusWithShadow(10,color: UIColor(white: 1.0, alpha: 1.0))
        }
    }
    
    @IBOutlet weak var addressView: UIView!{
        didSet{
            addressView.setRadiusWithShadow(10,color: UIColor(white: 1.0, alpha: 1.0))
        }
    }
    @IBOutlet weak var assignedTaskView: UIView!{
        didSet{
            assignedTaskView.setRadiusWithShadow(10,color: UIColor(white: 1.0, alpha: 1.0))
        }
    }
    @IBOutlet weak var companyView: UIView!{
        didSet{
            companyView.setRadiusWithShadow(10,color: UIColor(white: 1.0, alpha: 1.0))
        }
    }
    
    @IBOutlet weak var vatView: UIView!{
        didSet{
            vatView.setRadiusWithShadow(10,color: UIColor(white: 1.0, alpha: 1.0))
        }
    }
    @IBOutlet weak var electronicView: UIView!{
        didSet{
            electronicView.setRadiusWithShadow(10,color: UIColor(white: 1.0, alpha: 1.0))
        }
    }
    @IBOutlet weak var certifiedAddressView: UIView!{
        didSet{
            certifiedAddressView.setRadiusWithShadow(10,color: UIColor(white: 1.0, alpha: 1.0))
        }
    }
    
    @IBOutlet weak var lblConstCompany: UILabel!
    @IBOutlet weak var lblConstVat: UILabel!
    @IBOutlet weak var lblConstElectronicCode: UILabel!
    @IBOutlet weak var lblConstCertifiedMailAddress: UILabel!
    
    
    @IBOutlet weak var stackViewHight: NSLayoutConstraint!
    @IBOutlet weak var stachViewTop: NSLayoutConstraint!
    @IBOutlet weak var socialStack: UIStackView!
    
    var storeUserData:UserProfile?
    var customerIdFromProviderSide:String?
    var userType:String?
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFacebook()
        setUpUI()
        callGetProfile()
        NotificationCenter.default.addObserver(self, selector: #selector(changeProfile(notification:)), name: .isChangeProfile, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
        configureGoogle()
    }
    
    func setLang() {
        lblDefaultPaymrentMethod?.text = "Default Payment Method".localized
        lbl_Address?.text = "Shop Address".localized
        lblWorkOn?.text = "Assigned Task".localized
        lblConstCompany?.text = "Company".localized
        lblConstVat?.text = "VAT".localized
        lblConstElectronicCode?.text = "Electronic Invoice Recipient Code".localized
        lblConstCertifiedMailAddress?.text = "Certified Mail Address".localized
    }
    
    //MARK:- UIButton Click Events
    
    @IBAction func onClickGoogle(_ sender: UIButton) {
        if storeUserData?.gmail_id == "" {
            let _ = GIDConfiguration.init(clientID: Google.clientId)
            
            GIDSignIn.sharedInstance.signIn(withPresenting: self ){ result, error in
                guard error == nil, let user = result?.user else { return }
                let userId = user.userID                  // For client-side use only!
                let idToken = user.idToken?.tokenString // Safe to send to the server
                let fullName = user.profile?.name
                let firstName = user.profile?.givenName
                let lastName = user.profile?.familyName
                let email = user.profile?.email
                let profile_url = String(describing: user.profile?.imageURL(withDimension: 100))
                //  userId = self.md5(userId!)
                // ...
                print("==========================")
                print("userId: \(userId!)")
                print("==========================")
                print("idToken: \(idToken!)")
                print("==========================")
                print("fullName: \(fullName!)")
                print("==========================")
                print("givenName: \(firstName!)")
                print("==========================")
                print("familyName: \(lastName!)")
                print("==========================")
                print("email:\(email!)")
                print("==========================")
                
                self.socilaLogin(fNm: firstName!, lNm: lastName!, loginType: "g", socialId: idToken!, email: email!, profile_pic:profile_url)
                
                // If sign in succeeded, display the app's main content View.
            }
            
        }else{
            // socilaLogin(fNm: (self.storeUserData?.firstName)!, lNm: (self.storeUserData?.lastName)!, loginType:"g", socialId: (storeUserData?.gmail_id)!, email: (storeUserData?.email)!, profile_pic: (storeUserData?.profile_img)!)
        }
    }
    @IBAction func onclickFB(_ sender: UIButton) {
        if storeUserData?.fb_id == "" {
            LoginManager().logOut()
            if let accessToken = AccessToken.current {
                // User is logged in, use 'accessToken' here.
                print("accessToken:\(accessToken)")
                self.getFBUserData()
            }
            else{
                let loginManager = LoginManager()
                let readPermissions: [Permission] = [.publicProfile, .email /*.userBirthday*/]
                loginManager.logIn(permissions: readPermissions, viewController: self) { (loginResult) in
                    switch loginResult {
                    case .failed(let error):
                        print(error)
                    case .cancelled:
                        print("Users cancelled login.")
                    case .success(granted: let grantedPermissions, declined: let declinedPermissions, token: _):
                        print("Logged in!")
                        print("grantedPermissions:\(grantedPermissions.description)")
                        print("declinedPermissions:\(declinedPermissions.description)")
                        //if grantedPermissions.contains(Permission(name: "email")) == true { .. }
                        self.getFBUserData()
                        
                    }
                }
            }
        }else{
            // socilaLogin(fNm: (self.storeUserData?.firstName)!, lNm: (self.storeUserData?.lastName)!, loginType:"f", socialId: (storeUserData?.fb_id)!, email: (storeUserData?.email)!, profile_pic: (storeUserData?.profile_img)!)
        }
    }
    @IBAction func onClickLinkdin(_ sender: UIButton) {
        if storeUserData?.linkedin_id == "" {
//            loginWithLinkedInSwift()
        }else{
            //s socilaLogin(fNm: (self.storeUserData?.firstName)!, lNm: (self.storeUserData?.lastName)!, loginType:"l", socialId: (storeUserData?.linkedin_id)!, email: (storeUserData?.email)!, profile_pic: (storeUserData?.profile_img)!)
        }
        
    }
    
    @IBAction func onClickEdit(_ sender: UIButton) {
        let nextVc = EditProfileCustomerHostingVC()
        guard let passData = storeUserData else {return}
        nextVc.passUserData = passData
        self.navigationController?.pushViewController(nextVc, animated: true)
    }
    
}

//MARK: Custom function
extension CustomerProfileVC {
    
    
    func setUpUI() {
        self.applyStatusbar(color: Color.Theme.purple)
        //            self.view.backgroundColor = Color.Theme.purple
        
        //            setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "User Profile".localized, action: #selector(onClickMenu(_:)))
        self.setupNavigationBar(title: "Restaurant Owner", isBack: true, rightButton: false)
        if customerIdFromProviderSide != nil {
            
            self.btnEdit.isHidden = true
        }
        
        lblName?.text = ""
        lblPhoneNum?.text = ""
        lblEmailId?.text = ""
        lblAddress?.text = ""
        lblWorkTask?.text = ""
        
        if !Modal.sharedAppdelegate.isCustomerLogin || userType == "p"{
            //                btnEdit.isHidden = true
            //                stackViewHight.constant = 0.0
            //                stachViewTop.constant = 8.0
        }
        
    }
    
    @objc func changeProfile(notification: Notification) {
        if (notification.object as! [String: Any])["isChangeProfile"] as? Bool ?? false{
            callGetProfile()
        }
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        //sideMenuController?.showLeftView(animated: true, completionHandler: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func callGetProfile() {
        Task {
            do {
                let param:[String:Any] = ["profile_id":self.customerIdFromProviderSide ?? (Modal.sharedAppdelegate.isCustomerLogin ? UserData.shared.getUser()!.user_id : self.customerIdFromProviderSide ?? "")]
                let dic = try await APIClient.shared.getUserProfile(params: param)
                await MainActor.run {
                    let data = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
                    self.storeUserData = data!
                    print(self.storeUserData!.dictionaryRepresentation)
                    self.setUserData(data: data!)
                    //Update userdefault values
                    let userDic = UserData.shared.getUser()!
                    userDic.first_name = data!.firstName
                    userDic.last_name = data!.lastName
                    userDic.user_name = data!.user_name
                    userDic.profile_img = data!.profile_img
                    userDic.address = data!.address
                    _ = UserData.shared.setUser(dic: userDic.dictionary)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func setUserData(data: UserProfile) {
        //            imgCover.downLoadImage(url: data.profile_img)
        imgUser?.downLoadImage(url: data.profile_img)
        lblName?.text = data.user_name
        lblPhoneNum?.text = data.country_code + " " + data.contact_number
        lblEmailId?.text = data.email
        lblAddress?.text = data.address
        lblWorkTask?.text = data.task_assigned
        lblPaymentMethod?.text = (data.payment_mode == "w" ? "Wallet".localized : "Cash".localized)
        UserData.shared.setPaymentPref(deviceToken: data.payment_mode)

        if data.fb_id != "" {
            btnFB?.setImage(#imageLiteral(resourceName: "fb_verify"), for: .normal)
        }else{
            btnFB?.setImage(#imageLiteral(resourceName: "fb_unverify"), for: .normal)
        }
        if data.gmail_id != "" {
            btnGoogle?.setImage(#imageLiteral(resourceName: "google_verify"), for: .normal)
        }else{
            btnGoogle?.setImage(#imageLiteral(resourceName: "google_unverify"), for: .normal)
        }
        if data.linkedin_id != "" {
            btnLinkedIn?.setImage(#imageLiteral(resourceName: "linkedin_verify"), for: .normal)
        }else{
            btnLinkedIn?.setImage(#imageLiteral(resourceName: "linkedin_unverify"), for: .normal)
        }

        lblCompanyName?.text = data.company_name
        lblVat?.text = data.vat
        lblElectornicCode?.text = data.receipt_code
        lblCeritifedAddress?.text = data.certified_email
    }
    
}

//MARK:- GoogleSignIn
extension CustomerProfileVC {
    
    func configureGoogle() {
        //            GIDSignIn.sharedInstance()?.presentingViewController = self
        //            GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance.signOut()
        
    }
    
    //MARK: Google Delegate
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.idToken?.tokenString // Safe to send to the server
            let fullName = user.profile?.name
            let firstName = user.profile?.givenName
            let lastName = user.profile?.familyName
            let email = user.profile?.email
            let profile_url = String(describing: user.profile?.imageURL(withDimension: 100))
            //  userId = self.md5(userId!)
            // ...
            print("==========================")
            print("userId: \(userId!)")
            print("==========================")
            print("idToken: \(idToken!)")
            print("==========================")
            print("fullName: \(fullName!)")
            print("==========================")
            print("givenName: \(firstName!)")
            print("==========================")
            print("familyName: \(lastName!)")
            print("==========================")
            print("email:\(email!)")
            print("==========================")
            
            self.socilaLogin(fNm: firstName!, lNm: lastName!, loginType: "g", socialId: idToken!, email: email!, profile_pic:profile_url)
            
        } else {
            print(String(describing: error))
        }
    }
    
    // [START disconnect_handler]
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        
    }
    // [END disconnect_handler]
    
    func fatchGenderFromGoolgeAPI(token:String, callback:@escaping (_ gender:String) -> Void ) {
        //https://stackoverflow.com/questions/35809947/how-to-retrieve-age-and-gender-from-google-sign-in
        let gplusapi = "https://www.googleapis.com/oauth2/v3/userinfo?access_token=\(token)"
        let url = URL(string: gplusapi)!
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            do {
                let userData = try JSONSerialization.jsonObject(with: data!, options:[]) as? [String:Any]
                callback(userData!["gender"] as? String ?? "" )
            } catch {
                print("Account Information could not be loaded")
            }
        }).resume()
    }
}

extension CustomerProfileVC{
    func socilaLogin(fNm:String, lNm:String, loginType:String, socialId:String, email:String, profile_pic:String) {
        var dicParam = ["first_name":fNm,
                        "last_name": lNm,
                        "login_type": loginType,
                        "email": email,
                        "picture":profile_pic,
                        "device_token" : UserData.shared.deviceToken]
        switch loginType {
        case "g":
            dicParam["googleid"] = socialId
        case "f":
            dicParam["fbid"] = socialId
        case "l":
            dicParam["linkedinid"] = socialId
        default:
            break
        }
        Modal.shared.socialLogin(vc: self, param: dicParam) { (dic) in
            print("Social Login respoence: \(dic)")
            self.callGetProfile()
        }
    }
}


//MARK:- FB login methods
extension CustomerProfileVC {
    
    func configureFacebook(){
        //btnFacebook.readPermissions = ["public_profile", "email", "user_friends"];
        //btnFacebook.delegate = self
        
        
        //let loginManager = LoginManager().
        //loginManager.logOut()
        
    }
    
    @objc func loginButtonClicked() {
        LoginManager().logOut()
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            print("accessToken:\(accessToken)")
            self.getFBUserData()
        }
        else{
            let loginManager = LoginManager()
            let readPermissions: [Permission] = [.publicProfile, .email, /*.userBirthday*/]
            loginManager.logIn(permissions: readPermissions, viewController: self) { (loginResult) in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("Users cancelled login.")
                case .success(granted: let grantedPermissions, declined: let declinedPermissions, token: _):
                    print("Logged in!")
                    print("grantedPermissions:\(grantedPermissions.description)")
                    print("declinedPermissions:\(declinedPermissions.description)")
                    //if grantedPermissions.contains(Permission(name: "email")) == true { .. }
                    self.getFBUserData()
                    //                    AccessToken.refreshCurrentToken({ (accessToken, error) in
                    //                        self.getFBUserData()
                    //                    })
                }
            }
        }
    }
    
    //function is fetching the user data
    func getFBUserData(){
        FacebookSignInManager.basicInfoWithCompletionHandler(self) { (userInfo, error) in
            
            if(error != nil) {
                //Model.sharedAppDelegate.stopLoader()
                //                socialVC.showAlert(message: (error?.localizedDescription)!)
            } else {
                if let userInfo = userInfo {
                    print("User info : \(userInfo)")
                    let first_name = userInfo["first_name"] as? String ?? ""
                    let last_name = userInfo["last_name"] as? String ?? ""
                    let socialId = userInfo["id"] as? String ?? ""
                    let email = userInfo["email"] as? String ?? ""
                    var profileUrl = ""
                    if let picture = userInfo["picture"] as? [String: Any], let pictureData = picture["data"] as? [String : Any], let url = pictureData["url"] as? String {
                        profileUrl = url
                    }
                    print("\(first_name) : \(last_name) : \(socialId) : \(email)")
                    self.socilaLogin(fNm: first_name, lNm: last_name, loginType: "f", socialId: socialId, email: email, profile_pic: profileUrl)
                    
                    
                } else {
                    self.alert(title: "", message: "Something went wrong, Please try again.")
                }
            }
        }
    }
}
