//
//  RaiseDisputeVC.swift
//  TaskGator
//
//  Created by NCT 24 on 26/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

protocol RaiseDisputeProtocol {
    func raiseDisputeComplete(isSuccess: Bool)
}

class RaiseDisputeVC: UIViewController {
    
    //MARK: Properties
    static var storyboardInstance:RaiseDisputeVC? {
        return StoryBoard.popUp.instantiateViewController(withIdentifier: RaiseDisputeVC.identifier) as? RaiseDisputeVC
    }
    
    var delegate:RaiseDisputeProtocol?
    var serviceRequestId: String?
    
    @IBOutlet weak var lblRaiseDispute: UILabel!
    @IBOutlet weak var txtSubject: RobotoRegular14TextField!
    @IBOutlet weak var txtDescription: RobotoRegular14TextField!
    @IBOutlet weak var viewContainerControls: UIView!
    @IBOutlet weak var blackLayerView: UIView!
    @IBOutlet weak var containerView: UIView!{
        didSet{
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(onClickBlackLayer))
            containerView.addGestureRecognizer(tapGest)
        }
    }
    @IBOutlet weak var btnSubmit: UIButton!
    @IBAction func onClickSubmit(_ sender: UIButton) {
        if isValidated(){
            callRaisedDisputeAPI()
        }
    }
    
    //    MARK: ViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blackLayerView.sendSubview(toBack: containerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        lblRaiseDispute.text = "Raise Dispute".localized
        txtSubject.placeholder = "Subject*".localized
        txtDescription.placeholder = "Description*".localized
        btnSubmit.setTitle("SUBMIT".localized, for: .normal)
    }
}

//Mark: Custom functions
extension RaiseDisputeVC{
    
    func callRaisedDisputeAPI() {
        let param = ["service_request_id":serviceRequestId!,
                     "title":txtSubject.text!,
                     "message":txtDescription.text!,
                     "user_id":UserData.shared.getUser()!.user_id]
        Modal.shared.raisedDispute(vc: self, param: param) { (dic) in
            print(dic)
            if let delegate = self.delegate{
                delegate.raiseDisputeComplete(isSuccess: true)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func onClickBlackLayer(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    func isValidated() -> Bool {
        var ErrorMsg = ""
        if (txtSubject.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter subject".localized
        }
        else if (txtDescription.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter description".localized
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
