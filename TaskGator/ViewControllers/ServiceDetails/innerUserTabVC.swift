//
//  innerUserTabVC.swift
//  TaskGator
//
//  Created by NCT 24 on 03/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import MessageUI

class innerUserTabVC: UIViewController {

    //MARK: Properties
    
    static var storyboardInstance:innerUserTabVC? {
        return StoryBoard.serviceProviderDetail.instantiateViewController(withIdentifier: innerUserTabVC.identifier) as? innerUserTabVC
    }
    
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblValServiceDesc: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblContactNum: UILabel!{
        didSet{
            lblContactNum.underline()
            lblContactNum.isUserInteractionEnabled = true
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(onClickPhoneNumber(_:)))
            lblContactNum.addGestureRecognizer(tapGest)
        }
    }
    @IBOutlet weak var lblEmail: UILabel!{
        didSet{
            lblEmail.underline()
            lblEmail.isUserInteractionEnabled = true
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(onClickEmail(_:)))
            lblEmail.addGestureRecognizer(tapGest)
        }
    }
    @IBOutlet weak var stackViewContact: UIStackView!
    @IBOutlet weak var stackViewEmail: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        lblServiceDesc.text = "Service Description".localized
        lblContact.text = "Contact".localized
    }
}
extension innerUserTabVC{
    func loadUI()  {
        lblValServiceDesc.text = providerServiceDetail?.about_me
        if providerServiceDetail != nil && providerServiceDetail?.isactive.lowercased() == "du" {
            lblContactNum.text = providerServiceDetail?.contact_number
            lblEmail.text = providerServiceDetail?.email
            lblEmail.underline()
            lblContactNum.underline()
            lblContact.isHidden = false
            stackViewContact.isHidden = false
            stackViewEmail.isHidden = false
        }else{
            lblContact.isHidden = true  
            stackViewContact.isHidden = true
            stackViewEmail.isHidden = true
        }
    }
    
    @objc func onClickEmail(_ sender: UITapGestureRecognizer){
        sendEmail(emails: [(sender.view as! UILabel).text!])
    }
    
    @objc func onClickPhoneNumber(_ sender: UITapGestureRecognizer){
        self.callOn(PhoneNumber: (sender.view as! UILabel).text!)
    }
}

//MARK: mail compose delegate
extension innerUserTabVC: MFMailComposeViewControllerDelegate{
    
    func sendEmail(emails:[String]) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(emails)
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
            self.alert(title: "Error".localized, message: "Can't send mail".localized)
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Cancelled")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        case .failed:
            print("failed")
        }
        controller.dismiss(animated: true)
    }
}

