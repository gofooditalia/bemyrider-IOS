//
//  DepositeFund.swift
//  TaskGator
//
//  Created by NCT 24 on 19/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class DepositeFundVC: NewBaseViewController {

    //MARK: Properties

    static var storyboardInstance:DepositeFundVC? {
        return StoryBoard.wallet.instantiateViewController(withIdentifier: DepositeFundVC.identifier) as? DepositeFundVC
    }
    
    @IBOutlet weak var txtAmount: RobotoRegular14TextField!{
        didSet{
            txtAmount.delegate = self
            txtAmount.keyboardType = .numberPad
        }
    }
    
    @IBOutlet weak var lblAvlBal: UILabel!
    @IBOutlet weak var lbl_AvlBal: UILabel!
    
    var creditAmount:String!
    
    @IBOutlet weak var btnPayPal: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        lbl_AvlBal.text = "Available Balance:".localized
        txtAmount.placeholder = "Enter Deposit Amount".localized + (" (\(UserData.shared.currency))*")
        btnPayPal.setTitle("PAYPAL".localized, for: .normal)
    }
    
    @IBAction func onClickPayPal(_ sender: UIButton) {
        if !((txtAmount.text?.isBlank)!)  {
            if ((txtAmount.text?.isValidAmount)!) {
            guard let vc = PayPalWebVC.storyboardInstance else {return}
            vc.amount = txtAmount.text!
            self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let alert = UIAlertController(title: "Error".localized, message: "Please enter valid amount".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
                present(alert, animated: true, completion: nil)
            }
            //        vc.modalPresentationStyle = .overCurrentContext
            //        vc.modalTransitionStyle = .crossDissolve
            //        present(vc, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Error".localized, message: "Please enter amount".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
}

//MARK: Custom function
extension DepositeFundVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Deposit Fund".localized, action: #selector(onClickMenu(_:)))
        self.setupNavigationBar(title: "Deposit Fund".localized, isBack: true)

        
        lblAvlBal.text = creditAmount
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension DepositeFundVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtAmount{
            let newLength: Int = textField.text!.count +    string.count - range.length
                                  
            return string.isStringContainsOnlyDigit && newLength <= 6
        }
        else {
            return true
        }
    }
    
}
