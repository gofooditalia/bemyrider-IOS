//
//  ExtendServicePopUp.swift
//  TaskGator
//
//  Created by NCT 24 on 26/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

protocol ExtendServiceProtocol {
    func sendExtendServiceComplete(isSuccess: Bool)
}

class ExtendServicePopUp: UIViewController {
    
    //MARK: Properties
    static var storyboardInstance:ExtendServicePopUp? {
        return StoryBoard.popUp.instantiateViewController(withIdentifier: ExtendServicePopUp.identifier) as? ExtendServicePopUp
    }
    
    var delegate:ExtendServiceProtocol?
    var hoursList = [String]()
    var selectedHours: String?
    var proposalId: String?
    
    @IBOutlet weak var viewContainerControls: UIView!
    @IBOutlet weak var blackLayerView: UIView!
    @IBOutlet weak var containerView: UIView!{
        didSet{
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(onClickBlackLayer))
            containerView.addGestureRecognizer(tapGest)
        }
    }
    
    let hoursPickerView = UIPickerView()
    @IBOutlet weak var txtHours: RightViewArrowTextField!{
        didSet{
            hoursPickerView.delegate = self
            txtHours.inputView = hoursPickerView
            txtHours.delegate = self
            txtHours.rightViewImage = #imageLiteral(resourceName: "dropdown")
//            txtHours.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "dropdown"))
//            txtHours.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
            txtHours.setPlaceHolderColor(color: Color.Black.theam)
        }
    }
    
    @IBOutlet weak var btnCancel: UIButton!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.btnCancel.border(side: .all, color: Color.green.theam, borderWidth: 1.0)
            }
        }
    }
    @IBOutlet weak var btnSend: UIButton!
    
    @IBAction func onClickSend(_ sender: UIButton) {
        if isValidated(){
            callExtendServiceAPI()
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //    MARK: ViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hoursList fillUp
        for i in 1...2{
            hoursList.append("\(i)")
        }
        blackLayerView.sendSubview(toBack: containerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        txtHours.placeholder = "Select hours to complete*".localized
        btnSend.setTitle("SEND".localized, for: .normal)
        btnCancel.setTitle("CANCEL".localized, for: .normal)
    }
}

//Mark: Custom functions
extension ExtendServicePopUp{
    
    func callExtendServiceAPI() {
        let param = [
            "txt_service_request_id":customerSide_ProviderDetails!.service_request_id,
            "sel_hours": selectedHours!]
        Modal.shared.extendService(vc: self, param: param) { (dic) in
            print(dic)
            if let delegate = self.delegate{
                delegate.sendExtendServiceComplete(isSuccess: true)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func onClickBlackLayer(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    func isValidated() -> Bool {
        var ErrorMsg = ""
        if (txtHours.text?.isEmpty)! || selectedHours == nil {
            ErrorMsg = "Please select hours".localized
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

//MARK: PickerView Delegate

extension ExtendServicePopUp: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == hoursPickerView{
            return hoursList.count + 1
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == hoursPickerView{
            if hoursList.count > 0{
                if row > 0{
                    selectedHours = hoursList[row - 1]
                    if row == 1 {
                        let str = "\(hoursList[row - 1]) \("Hour".localized)"
                        txtHours.text = str
                    }else{
                        let str = "\(hoursList[row - 1]) \("Hours".localized)"
                        txtHours.text = str
                    }
                }else{
                    txtHours.text = ""//"Select Hour"
                }
            }
        }
        else{
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
        
        if pickerView == hoursPickerView{
            if row == 0 {
                label.text = "Select Hours".localized
            }else if row == 1 {
                label.text = "\(hoursList[row - 1]) \("Hour".localized)"
            }else{
                label.text = "\(hoursList[row - 1]) \("Hours".localized)"
            }
        }
        else{
        }
        return label
    }
}

//MARK: UITextField Delegate

extension ExtendServicePopUp: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtHours{
            return false
        }
        else {
            return true
        }
    }
}
