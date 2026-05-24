//
//  DepositAmountVC.swift
//  TaskGator
//
//  Created by NCT 24 on 14/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class DepositAmountVC: NewBaseViewController {

    //MARK: Properties
    static var storyboardInstance:DepositAmountVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: DepositAmountVC.identifier) as? DepositAmountVC
    }
    
    @IBOutlet weak var lblAvailBal: UILabel!
    @IBOutlet weak var lblValAvailBal: UILabel!
    @IBOutlet weak var lblServicePrice: UILabel!
    @IBOutlet weak var lblValServicePrice: UILabel!
    @IBOutlet weak var lblCommission: UILabel!
    
    @IBOutlet weak var txtAdminFees: RobotoRegular14TextField!{
        didSet{
            txtAdminFees.text = "0"
            txtAdminFees.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var txtDepositAmount: SkyFloatingLabelTextField!
    
    var depositeDic:[String:Any]?
    var serviceRequestDic:[String:Any]?
    var depositCommissionAsPerCalculation:String!
    
    @IBOutlet weak var btnPay: GreenButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("DepositAmountVC Destroy")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang(){
//        let cmtn = "5"; let adminFees = "10"
//        lblCommission.text = "\(cmtn)" + " % Deposite Commission ".localized + "\(adminFees)" + " % Admin Fees".localized
        if let depositeDic = depositeDic{
            let customer_commission = Double(depositeDic["customer_commission"] as? String ?? "0")!
            let deposit_commission = Double(depositeDic["deposit_commission"] as? String ?? "0")!
            lblCommission.text = "\(deposit_commission)" + " % Deposit Commission ".localized + "\(customer_commission)" + " % Admin Fees".localized
        }
        
        lblAvailBal.text = "Available Balance : ".localized
        lblServicePrice.text = "Service Price : ".localized
        txtAdminFees.placeholder = "Admin Fees".localized
        txtDepositAmount.placeholder = "Enter Deposit Amount".localized + "(\(UserData.shared.currency)" + "*)"
        btnPay.setTitle("PAYPAL".localized, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        loadUI()
        //Below line is for old payment. Now no more need
        NotificationCenter.default.addObserver(self, selector: #selector(paymentProcessDone(notification:)), name: .paymentProcessDone, object: nil)
    }
   
    @IBAction func onClickPay(_ sender: UIButton) {
        if let serviceRequestDic = serviceRequestDic{
            guard let vc = PayPalWebVC.storyboardInstance else {return}
            vc.amount = txtDepositAmount.text!
            vc.deposit_commission = depositCommissionAsPerCalculation
            vc.service_id = serviceRequestDic["service_id"] as? String
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

//MARK: Custom function
extension DepositAmountVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Deposit Fund".localized, action: #selector(onClickMenu(_:)))
        self.setupNavigationBar(title: "Deposit Fund".localized, isBack: true)
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
  
    func loadUI() {
        /*
         "customer_commission" = 10;
         "deposit_commission" = 5;
         
         "service_amount" = 200;
         "wallet_Amount" = 95;
         */
        if let depositeDic = depositeDic{
            txtDepositAmount.isUserInteractionEnabled = false
            txtAdminFees.isUserInteractionEnabled = false
            
            let customer_commission = Double(depositeDic["customer_commission"] as? String ?? "0")!
            let deposit_commission = Double(depositeDic["deposit_commission"] as? String ?? "0")!
            
            let service_amount = Double(depositeDic["service_amount"] as? String ?? "0")!
            let wallet_Amount = Double(depositeDic["wallet_Amount"] as? String ?? "0")!
            
            let adminFees = (service_amount * customer_commission)/100 //10% customer_commission
            let needToDepositeAmntInWallet = (wallet_Amount < service_amount ? (service_amount - wallet_Amount) : (wallet_Amount - service_amount))   + adminFees
            let depositeCommitionOnWallet = (needToDepositeAmntInWallet * deposit_commission) / 100
            
            let finalAdminFees = adminFees + depositeCommitionOnWallet
            let grandTotal = needToDepositeAmntInWallet + depositeCommitionOnWallet
            
            let walletRoundAmt = Double(round(100 * wallet_Amount)/100)
            let serviceRoundAmt = Double(round(100 * service_amount)/100)
            
            let finalAdminFeesRoundAmt = Double(round(100 * finalAdminFees)/100)
            let grandTotalRoundAmt = Double(round(100 * grandTotal)/100)
            depositCommissionAsPerCalculation = "\(Double(round(100 * depositeCommitionOnWallet)/100))"
            
            lblValAvailBal.text = "\(UserData.shared.currency) \(walletRoundAmt)"
            lblValServicePrice.text = "\(UserData.shared.currency) \(serviceRoundAmt)"
            
            txtAdminFees.text = "\(finalAdminFeesRoundAmt)"
            txtDepositAmount.text = "\(grandTotalRoundAmt)"
            
//            let depositeCommission = (deposit_commission * service_amount)/100
//            let customerCommission = (customer_commission * service_amount)/100
//            let adminFees = depositeCommission + customerCommission

        }
        
    }
}

extension DepositAmountVC{
    
    @objc func paymentProcessDone(notification: Notification) {
        if let data = (notification.object as? [String:Bool]), data.keys.contains("paymentDone") {
            if data["paymentDone"] ?? false{
                //As per new flow
                callSendServiceRequestAPI()
            }
            else{
                self.alert(title: "", message: "Payment fail!".localized) {
                    for control in (self.navigationController?.viewControllers)! {
                        if control is SearachProviderVC{
                            self.navigationController?.popToViewController(control, animated: false)
                            break
                        }
                    }
                }
            }
        }
    }
    
    func callSendServiceRequestAPI() {
        //As per new flow
        self.alert(title: "", message: "Service request send successfully".localized, completion: {
            for control in (self.navigationController?.viewControllers)! {
                if control is ServiceRequest{
                    self.navigationController?.popToViewController(control, animated: false)
                    break
                }
            }
        })
        
        //Old flow
//        if let serviceRequestDic = serviceRequestDic{
//            Modal.shared.sendServiceRequest(vc: self, param: serviceRequestDic) { (dic) in
//                self.alert(title: "", message: "Service request send successfully", completion: {
//                    for control in (self.navigationController?.viewControllers)! {
//                        if control is SearachProviderVC{
//                            self.navigationController?.popToViewController(control, animated: false)
//                            break
//                        }
//                    }
//                })
//            }
//        }
    }
    
}
