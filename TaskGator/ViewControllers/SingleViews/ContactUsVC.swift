//
//  ContactUsVC.swift
//  TaskGator
//
//  Created by NCT 24 on 11/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import AlamofireImage

class ContactUsVC: NewBaseViewController {

    //MARK: Properties
    static var storyboardInstance:ContactUsVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: ContactUsVC.identifier) as? ContactUsVC
    }
    
    @IBOutlet weak var txtFirstName: RobotoRegular14TextField!
    @IBOutlet weak var txtLastName: RobotoRegular14TextField!
    @IBOutlet weak var txtEmail: RobotoRegular14TextField!
    
    @IBOutlet weak var txtContryCode: RightViewArrowTextField!{
        didSet{
            txtContryCode.delegate = self
            txtContryCode.rightViewImage =  #imageLiteral(resourceName: "downArrow")
            countryPickerView.delegate = self
            txtContryCode.inputView = countryPickerView
        }
    }
    @IBOutlet weak var txtContactNum: RobotoRegular14TextField!{
        didSet{
            txtContactNum.delegate = self
        }
    }
    
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
//            textView.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
            textView.placeholder = "Enter Message*"
        }
    }
    
    @IBOutlet weak var btnSubmit: GreenButton!
    
    var countryList = [Country]()
    let dic = ["id": "105",
               "country_name": "Italy",
               "country_code": "+39"]
    var selectedCountry:Country!
    let countryPickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        getCountryCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    
    func getCountryCode() {
        Modal.shared.getCountryCode(vc: self,param:[:]) { (countryList) in
            self.countryList = countryList
            self.countryList.sort{
                $0.country_name < $1.country_name
            }
            self.countryPickerView.reloadAllComponents()
        }
    }
   
    func setLang(){
        txtEmail.placeholder = "Email ID*".localized
        txtLastName.placeholder = "Last Name*".localized
        txtFirstName.placeholder = "First Name*".localized
        btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        textView.placeholder = "Enter Message*".localized
        
        txtFirstName.text = UserData.shared.getUser()?.first_name
        txtLastName.text = UserData.shared.getUser()?.last_name
        txtEmail.text = UserData.shared.getUser()?.email_id
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        print("onClickSubmit")
        if isValidated() {
            callContactUsAPI()
        }
    }
    
    
    @IBAction func onClickCountryCodeBtn(_ sender: UIButton) {
        txtContryCode.becomeFirstResponder()
    }
    
}

//MARK: Custom function
extension ContactUsVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Contact Us".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: "Contact Us".localized, isBack: true, rightButton: false)
        selectedCountry = Country(Data: dic)
        if let user = UserData.shared.getUser() {
        txtFirstName.text = user.first_name
        txtLastName.text = user.last_name
        txtEmail.text = user.email_id
        txtContryCode.text = selectedCountry.country_code

        }
    }

    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callContactUsAPI() {
        Modal.shared.contactus(vc: self, param: ["user_id":UserData.shared.getUser()?.user_id ?? "", "email":txtEmail.text!, "message":textView.text!, "firstName":txtFirstName.text!, "lastName":txtLastName.text!, "country_code":self.txtContryCode.text!,"contact_number":txtContactNum.text!]) { (dic) in
            print(dic)
            self.textView.text = nil
            self.alert(title: "", message: ResponseKey.fatchData(res: dic, valueOf: .message).str){
                self.navigationController?.popViewController(animated: true)
            }

        }
    }
    
    func isValidated() -> Bool {
        var ErrorMsg = ""
        if (txtFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter a first name".localized
        }
        else if (txtLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter a Last name".localized
        }
        else if (txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter a email Id".localized
        }
        else if !(txtEmail.text?.isValidEmailId)! {
            ErrorMsg = "Email Id is not valid".localized
        }
        else if (txtContryCode.text?.isEmpty)! {
            ErrorMsg = "Please select a country code".localized
        }
        else if (txtContactNum.text?.isEmpty)! {
            ErrorMsg = "Please enter a contact number".localized
        }
        else if txtContactNum.text!.count < 10 {
                ErrorMsg = "Please enter contact number with minimum 10 digit".localized
        }
        else if (textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter a message".localized
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


extension ContactUsVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtContryCode{
            return false
        }
        else if textField == txtContactNum{
            let newLength: Int = textField.text!.count +    string.count - range.length
            
            return string.isStringContainsOnlyDigit && newLength <= 15
        }
        else {
            return true
        }
    }
}

extension ContactUsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  countryList.count
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //        let dic = countryList[row] as! NSDictionary
    //        let name = dic.object(forKey: "country_name") as! String
    //        let code = dic.object(forKey: "phone_code")as! String
    //        let str = name + " (\(code))"
    //        return str
    //    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if countryList.count > 0 {
                    selectedCountry = countryList[row]
                    let dic = countryList[row]
                    //let name = dic.country_name
                    let code = dic.country_code
                    let str = code
                    txtContryCode.text = str
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
        
            let dic = countryList[row]
            label.text = dic.country_code + " (\(dic.country_name))"
      
        
        return label
    }
}
