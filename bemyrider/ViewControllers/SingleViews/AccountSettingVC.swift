//
//  AccountSettingVC.swift
//  bemyrider
//
//  Created by NCT 24 on 16/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import MOLH

class AccountSettingVC: NewBaseViewController {
    
    //MARK: Properties
    static var storyboardInstance:AccountSettingVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: AccountSettingVC.identifier) as? AccountSettingVC
    }
    
    //var selectedLang = ""
    var languageList = [ServerLanguage]()
    var selectedLanguage: ServerLanguage?
    
    @IBOutlet weak var deactivateView: UIView!{
        didSet{
            deactivateView.setRadius(10)
        }
    }
    @IBOutlet weak var txtCurrentPwd: RobotoRegular14TextField!
    @IBOutlet weak var txtNewPwd: RobotoRegular14TextField!
    @IBOutlet weak var txtConfirmNewPwd: RobotoRegular14TextField!
    
    @IBOutlet weak var btnSaveChanges: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblDeactiveYourAccount: UILabel!
    @IBOutlet weak var btnDeactive: GreenButton!{
        didSet{
//            btnDeactive.backgroundColor = UIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)

            
        }
    }
    //@IBOutlet weak var btnSaveChangesCurrency: UIButton!
    
    
    let languagePickerView = UIPickerView()
    @IBOutlet weak var txtLanguage: RightViewArrowTextField!{
        didSet{
            languagePickerView.delegate = self
            txtLanguage.inputView = languagePickerView
            txtLanguage.delegate = self
            txtLanguage.rightViewImage =  #imageLiteral(resourceName: "dropdown")
//            txtLanguage.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "dropdown"))
        }
    }
    
    //    @IBOutlet weak var txtCurrency: SkyFloatingLabelTextField!{
    //        didSet{
    ////            let pickerView = UIPickerView()
    ////            pickerView.delegate = self
    ////            pickerView.tag = 222
    ////            txtCurrency.inputView = pickerView
    ////            txtCurrency.delegate = self
    ////            txtCurrency.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "dropdown"))
    //        }
    //    }
    //
    
    @IBOutlet weak var lblDeactivateMsg: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        callLanguageList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    @IBAction func onClickLanguage(_ sender: UIButton) {
        //txtLanguage.becomeFirstResponder()
        
        //TODO: Save Lan into UerDefault
        //Re-Launch the app in changed language
        updateAppLang()
        
        
        
    }
    
    @IBAction func onClickSaveChange(_ sender: UIButton) {
        if isValidated(){
            callChangePassword()
        }
    }
    
    //    @IBAction func onClickCurrency(_ sender: UIButton) {
    //        txtCurrency.becomeFirstResponder()
    //    }
    @IBAction func onClickDeactive(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Account".localized,
            message: "Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive) { _ in
            self.deactiveUser()
        })
        present(alert, animated: true)
    }
    
}
//MARK: Custom function
extension AccountSettingVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Account Settings".localized, action: #selector(onClickMenu(_:)))
        
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title:"Account Settings".localized, isBack: true, rightButton: false)
        
        var msg:String = "If you do not think you will use bemyrider again and would like your account deleted, we can take care of this for you. Keep in mind that you will not be able to reactivate your account or retrieve any of the content or information you have added.".localized

       msg =  msg.appendingFormat("\n\n %@\"%@\"", "If you would still like your account deleted, click ".localized,"DELETE MY ACCOUNT".localized)
        
        lblDeactivateMsg.text = msg
        
        btnSaveChanges.titleLabel?.font = RobotoFont.bold(with: (btnSaveChanges.titleLabel?.font.pointSize)!)
        btnContinue.titleLabel?.font = RobotoFont.bold(with: (btnContinue.titleLabel?.font.pointSize)!)
        //btnSaveChangesCurrency.titleLabel?.font = RobotoFont.bold(with: (btnContinue.titleLabel?.font.pointSize)!)
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callLanguageList() {
        Modal.shared.getLanguages(vc: self) { (dic) in
            self.languageList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({ ServerLanguage(dictionary: $0 as! [String:Any])})
            self.languagePickerView.reloadAllComponents()
            //check and set language as per intial level language selection
            let index = self.languageList.index(where: { $0.id.caseInsensitiveCompare(string: UserData.shared.languageID)})
            if let i = index{
                self.selectedLanguage = self.languageList[i]
                self.txtLanguage.text = self.selectedLanguage!.languageName
            }
            else{
                self.selectedLanguage = self.languageList.first!
                self.txtLanguage.text = self.selectedLanguage!.languageName
            }
        }
    }
    
    func callChangePassword() {
        let param = [
            "user_id":UserData.shared.getUser()!.user_id,
            "currentpwd":txtCurrentPwd.text!,
            "newpwd":txtNewPwd.text!,
            "renewpwd":txtConfirmNewPwd.text!]
        Modal.shared.changePassword(vc: self, param: param) { (dic) in
            let str = ResponseKey.fatchDataAsString(res: dic, valueOf: .message)
            self.alert(title: "", message: str, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func deactiveUser() {
        let param = [
            "user_id":UserData.shared.getUser()!.user_id,
            "user_type":UserData.shared.getUser()!.user_type
        ]
        Modal.shared.deactive(vc: self, param: param) { (dic) in
            let str = ResponseKey.fatchDataAsString(res: dic, valueOf: .message)
            self.alert(title: "", message: str, completion: {
                Modal.sharedAppdelegate.window?.rootViewController = StoryBoard.main.instantiateInitialViewController()
                Modal.sharedAppdelegate.window?.makeKeyAndVisible()
            })
        }
    }
    func isValidated() -> Bool {
        
        var ErrorMsg = ""
        if (txtCurrentPwd.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter current password".localized
        }
        else if (txtCurrentPwd.text!.count < 6){
            ErrorMsg = "Please enter a password with minimum 6 characters".localized
        }
        else if (txtNewPwd.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter new password".localized
        }
        else if (txtNewPwd.text!.count < 6){
            ErrorMsg = "Please enter new password with minimum 6 characters".localized
        }
        else if (txtConfirmNewPwd.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter confirm password".localized
        }
        else if txtNewPwd.text! != txtConfirmNewPwd.text! {
            ErrorMsg = "New password and confirm new password not match!".localized
        }
        
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
}

extension AccountSettingVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtLanguage{
            return false
        }
        else {
            return true
        }
    }
}

//For multilanguage
extension AccountSettingVC{
    
    func updateAppLang(){
        //let isLang = UserData.shared.language//UserDefaults.standard.string(forKey: "IS_Lang")
        if let selectedLanguage = self.selectedLanguage{
            UserData.shared.setLanguage(language: selectedLanguage.languageName.capitalized.trimmingCharacters(in: .whitespaces))
            UserData.shared.setLanguageID(languageID: selectedLanguage.id)
            //UIView.appearance().semanticContentAttribute = .forceRightToLeft
            if selectedLanguage.languageName.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare(string: MuliLanguage.french.rawValue){
                MOLH.setLanguageTo(MuliLangShortHand.fr.rawValue)
            }
            else if selectedLanguage.languageName.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare(string: MuliLanguage.portuguese.rawValue){
                MOLH.setLanguageTo(MuliLangShortHand.pt.rawValue)
            }
            else{
                MOLH.setLanguageTo(MuliLangShortHand.en.rawValue)
            }
            MOLH.reset()
        }
        
        //TODO: Change
        self.setLang()
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Account Settings".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title:"Account Settings".localized, isBack: true, rightButton: false)
        
        
        
        //        let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        //        rootviewcontroller.rootViewController = LoginVC.storyboardInstance!
        //        let mainwindow = (UIApplication.shared.delegate?.window!)!
        //        mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
        //        UIView.transition(with: mainwindow, duration: 0.55001, options: .transitionFlipFromLeft, animations: { () -> Void in
        //        }) { (finished) -> Void in
        //        }
        
        self.sharedAppdelegate.rootToHome()
//        if UserData.shared.getUser()?.user_type == "c" {
//            print("Login=>Customer")
//            Modal.sharedAppdelegate.isCustomerLogin = true
//            Modal.sharedAppdelegate.sideMenuController.rootViewController = CategoryVC.storyboardInstance!
//            Modal.sharedAppdelegate.sideMenuController.leftViewController = LeftSideMenu.storyboardInstance!
//        }
//        else{
//            print("Login=>Provider")
//            Modal.sharedAppdelegate.isCustomerLogin = false
//            Modal.sharedAppdelegate.sideMenuController.rootViewController = ProviderProfileVC.storyboardInstance!
//            Modal.sharedAppdelegate.sideMenuController.leftViewController = LeftSideMenu.storyboardInstance!
//        }
        
    }
    
    func setLang(){
        txtCurrentPwd.placeholder = "\("Current Password*".localized)"
        txtNewPwd.placeholder = "\("New Password*".localized)"
        txtConfirmNewPwd.placeholder = "\("Confirm New Password*".localized)"
        txtLanguage.placeholder = "\("Language*".localized)"
        btnContinue.setTitle("CONTINUE".localized, for: .normal)
        btnSaveChanges.setTitle("SAVE CHANGE".localized, for: .normal)
        lblDeactiveYourAccount.text = "Delete Your Account".localized
        btnDeactive.setTitle("DELETE MY ACCOUNT".localized, for: .normal)
        
        //txtCurrency.placeholder = "\("Currency*".localized)"
        //btnSaveChangesCurrency.setTitle("SAVE CHANGE".localized, for: .normal)
        
        //        txtCurrentPwd.localized()
        //        txtNewPwd.localized()
        //        txtConfirmNewPwd.localized()
        //        txtLanguage.localized()
        //        //txtCurrency.localized()
        //        btnContinue.localized()
        //        btnSaveChanges.localized()
        //        //btnSaveChangesCurrency.localized()
        
    }
}

extension AccountSettingVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageList.count + 1
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //        let dic = countryList[row] as! NSDictionary
    //        let name = dic.object(forKey: "country_name") as! String
    //        let code = dic.object(forKey: "phone_code")as! String
    //        let str = name + " (\(code))"
    //        return str
    //    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == languagePickerView{
            if row > 0 {
                selectedLanguage = languageList[row - 1]
                let str = languageList[row - 1].languageName
                txtLanguage.text = str
                //change language
                //self.selectedLang = languageList[row].languageName
            }else{
                txtLanguage.text = ""//"Select Language"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        label.textAlignment = .center
        label.font = RobotoFont.regular(with: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        if pickerView == languagePickerView{
            let str = row == 0 ? "Select Language" : languageList[row - 1].languageName
            label.text = str
        }
        
        return label
    }
}

extension UILabel{
    func localized() {
        self.text = self.descriptiveName?.localized
    }
}

//extension UITextField{
//    func localized() {
//        //self.text = self.text?.localized
//        self.placeholder = self.placeholder?.localized
//    }
//}

extension UITextField{
    func localized() {
        //self.text = self.text?.localized
        self.placeholder = self.descriptiveName?.localized
    }
}

extension UIButton{
    func localized() {
        //self.titleLabel?.text =  self.titleLabel?.text?.localized
        self.setTitle(self.descriptiveName?.localized, for: .normal)
    }
}


//extension UIViewController{
//    static func localization(controll: UIView) {
//        if controll is SkyFloatingLabelTextField{
//            let controll = controll as! SkyFloatingLabelTextField
//            controll.placeholder = controll.placeholder?.localized
//        }
//        else if controll is UIButton{
//            let controll = controll as! UIButton
//            controll.setTitle(controll.currentTitle?.localized, for: .normal)
//        }
//    }
//
//}
