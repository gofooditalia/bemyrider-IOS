//
//  ProposalPopUpVC.swift
//  bemyrider
//
//  Created by NCT 24 on 23/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

@objc protocol SendProposalProtocol {
    func sendProposalComplete(isSuccess: Bool)
    @objc optional func sendProposalStripeConnect()

}

class ProposalPopUpVC: UIViewController {
    
    //MARK: Properties
    static var storyboardInstance:ProposalPopUpVC? {
        return StoryBoard.popUp.instantiateViewController(withIdentifier: ProposalPopUpVC.identifier) as? ProposalPopUpVC
    }
    
    var delegate:SendProposalProtocol?
    var hoursList = [String]()
    var selectedHours: String?
    var proposalId: String? //Provider side pass txt_service_request_id
    
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
    @IBOutlet weak var txtMsg: SkyFloatingLabelTextField!
    
    
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
            callRejectProposalAPI()
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
        txtHours.placeholder = "Select hours*".localized
        txtMsg.placeholder = "Enter message here*".localized
        btnSend.setTitle("SEND".localized, for: .normal)
        btnCancel.setTitle("CANCEL".localized, for: .normal)
    }
}

//Mark: Custom functions
extension ProposalPopUpVC{
    
    @objc func onClickBlackLayer(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    func callRejectProposalAPI() {
        if let proposalId = proposalId{
            var param = [
                "sel_message_hour":selectedHours!,
                "txt_message":txtMsg.text!,
                "user_id":UserData.shared.getUser()!.user_id]
            if Modal.sharedAppdelegate.isCustomerLogin{
                param["txt_proposal_id"] = proposalId
            }
            else{
                param["txt_service_request_id"] = proposalId
            }
            
//            Modal.sharedAppdelegate.startLoader()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                Modal.shared.sendProposal(vc: nil, param: param, failer: { (dic,message) in
                        Modal.sharedAppdelegate.stoapLoader()
                    
                    NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)

                    if let type = dic["type"] as? String, type == "error" || message == "Please connect with stripe before accepting service" || message.lowercased() == "connettiti con stripe prima di accettare il servizio" {
                        self.alert(title: "", message: message, actions: ["OK","Connect Account?"]) { flag in
                            if flag == 1 {
                                
                                if let delegate = self.delegate{
                                    self.dismiss(animated: true, completion: nil)
                                    delegate.sendProposalStripeConnect?()
                                }
                            }
                        }
                    }else{
                        self.alert(title: "", message: message, actions: ["OK"]) { flag in
                        }
                    }
                }) { (dic) in
                    print(dic)
                    //self.navigationController?.popViewController(animated: true)
                    if let delegate = self.delegate{
                        delegate.sendProposalComplete(isSuccess: true)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            })


        }
    }
    
    
    func isValidated() -> Bool {
        var ErrorMsg = ""
        if (txtHours.text?.isEmpty)! || selectedHours == nil {
            ErrorMsg = "Please select hours".localized
        }
        else if (txtMsg.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please provide message".localized
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

//MARK: UIPickerView Delegate

extension ProposalPopUpVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
                if row > 0 {
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
                    selectedHours = nil
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

extension ProposalPopUpVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtHours{
            return false
        }
        else {
            return true
        }
    }
}
