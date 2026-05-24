//
//  LanuguageVC.swift
//  bemyrider
//
//  Created by NCrypted on 07/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import MOLH

class LanuguageVC: UIViewController {
    
    static var storyboardInstance:LanuguageVC? {
        return StoryBoard.main.instantiateViewController(withIdentifier: LanuguageVC.identifier) as? LanuguageVC
    }
    
    //    MARK: Properties
    
    var languageList = [ServerLanguage]()
    var selectedLanguage: ServerLanguage?
    var strId : String = ""
    let langaugePicker = UIPickerView()
    
    @IBOutlet weak var btnContinue: UIButton!{
        didSet{
            btnContinue.layer.borderColor = UIColor.white.cgColor //UIColor.init(hexString: "237902").cgColor
        }
    }
    @IBOutlet weak var txtLanguage: SkyFloatingLabelTextField!{
        didSet{
            langaugePicker.delegate = self
            txtLanguage.inputView = langaugePicker
            txtLanguage.delegate = self
            txtLanguage.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "dropdown-White"))
        }
    }
    
    //    MARK: API Calling
    
    func callLanguageList() {
        Modal.shared.getLanguages(vc: self) { (dic) in
            print(dic)
            self.languageList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({ ServerLanguage(dictionary: $0 as! [String:Any])})
            self.langaugePicker.reloadAllComponents()
            let index = self.languageList.index(where: { $0.default_lan.caseInsensitiveCompare(string: "y")})
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
    
    //    MARK: ViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        langaugePicker.selectedRow(inComponent: 0)
        callLanguageList()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        txtLanguage.placeholder = "Select Language*".localized
        btnContinue.setTitle("CONTINUE".localized, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickContinue(_ sender: UIButton) {
        if let selectedLanguage = self.selectedLanguage{
            UserData.shared.setLanguage(language: selectedLanguage.languageName.capitalized.trimmingCharacters(in: .whitespaces))
            UserData.shared.setLanguageID(languageID: selectedLanguage.id)
            if selectedLanguage.languageName.caseInsensitiveCompare(string: MuliLanguage.french.rawValue){
                MOLH.setLanguageTo(MuliLangShortHand.fr.rawValue)
            }
            else if selectedLanguage.languageName.caseInsensitiveCompare(string: MuliLanguage.portuguese.rawValue){
                MOLH.setLanguageTo(MuliLangShortHand.pt.rawValue)
            }
            else if selectedLanguage.languageName.caseInsensitiveCompare(string: MuliLanguage.italian.rawValue){
                MOLH.setLanguageTo(MuliLangShortHand.it.rawValue)
            }
            else{
                MOLH.setLanguageTo(MuliLangShortHand.en.rawValue)
            }
            MOLH.reset()
//            UserDefaults.standard.set(strId, forKey: "l_id")/
//            UserDefaults.standard.synchronize()
            //self.performSegue(withIdentifier: "segueLogin", sender: self)
            //self.navigationController?.pushViewController(LoginVC.storyboardInstance!, animated: true)
//            self.navigationController?.popToRootViewController(animated: false)
            Modal.sharedAppdelegate.rootToHome()
        }
        else{
            self.alert(title: "Error".localized, message: "Please select the app language".localized)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK: TextField Delegate

extension LanuguageVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtLanguage{
            return false
        }
        else {
            return true
        }
    }
}

//MARK: PickerView Delegate

extension LanuguageVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageList.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0{
            selectedLanguage = languageList[row - 1]
            let str = languageList[row - 1].languageName
            strId = languageList[row - 1].id
            txtLanguage.text = str
        }else{
            txtLanguage.text = ""//"Select Language"
            selectedLanguage = nil
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
        
        let str = row == 0 ? "Select Language*".localized : languageList[row - 1].languageName
        
        label.text = str
        
        return label
    }
}
