//
//  StripeCheckoutVC.swift
//  bemyrider
//
//

import UIKit
import Stripe
import MOLH

class StripeCheckoutVC: NewBaseViewController {
    
    static var storyboardInstance:StripeCheckoutVC {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: StripeCheckoutVC.identifier) as! StripeCheckoutVC
    }
    
    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        cardTextField.delegate = self
        cardTextField.postalCodeEntryEnabled = false
        return cardTextField
    }()
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var lblConstTotalAmount: UILabel!
    @IBOutlet weak var lblAmountToCharge: UILabel!
    @IBOutlet weak var lblDate: UILabel!{
        didSet{
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.locale = .autoupdatingCurrent
            dateFormatterGet.dateFormat = "MMM dd, yyyy"
            lblDate.text = dateFormatterGet.string(from: Date())
        }
    }
    
    @IBOutlet weak var lblConstPrice: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblConstFees: UILabel!
    @IBOutlet weak var lblFees: UILabel!
    
    
    @IBOutlet weak var payBtn: GreenButton!
    
    var paymentIntentClientSecret: String?
    var total_amount_to_charge:String?
    var booking_amount:String?
    var total_fees:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let total_amount_to_charge_full = total_amount_to_charge,
              let bookingPrice = booking_amount,
              let fees = total_fees else {
            self.navigationController?.popViewController(animated: true)
            return;
        }
        
        self.setupNavigationBar(title: "Payment".localized, isBack: true, rightButton: false)
        mainStackView.addArrangedSubview(cardTextField)
        
        // Setup Live server key up on release
        STPAPIClient.shared.publishableKey =  Domain.Stripe_Publishable_Live_Key // Domain.Stripe_Publishable_Test_Key
        
        lblAmountToCharge.text = "\(UserData.shared.currency)\(total_amount_to_charge_full)"
        lblPrice.text = "\(UserData.shared.currency)\(bookingPrice)"
        lblFees.text = "\(UserData.shared.currency)\(fees)"
        
        lblConstPrice.text = "Price".localized
        lblConstFees.text = "Fees".localized
        lblConstTotalAmount.text = "Total Amount".localized
        
        // Do any additional setup after loading the view.
    }
    
    
    override func didTapBackButton(sender: AnyObject) {
        self.alert(title: "", message: "Are you sure you want to cancel this payment?".localized , actions: ["No".localized,"Yes".localized], style: [.default,.cancel], completion: { (action) in
            if action == 1 {
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    @IBAction func onClickPay(_ sender: Any) {
        self.payBy3dSecureIntent()
    }
    
    
    @objc func payBy3dSecureIntent() {
        
        
        guard let paymentIntentClientSecret = paymentIntentClientSecret else {
            return;
        }
        self.cardTextField.resignFirstResponder()
        self.sharedAppdelegate.startLoader()
        
        guard let cardParams = cardTextField.paymentMethodParams.card else { return }
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        let paymentHandler = STPPaymentHandler.shared()
        paymentHandler.confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
            switch (status) {
            case .failed:
                Modal.sharedAppdelegate.stoapLoader()
                DispatchQueue.main.async {
                    self.alert(title: "Payment failed", message: error?.localizedDescription ?? "") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
                break
            case .canceled:
                Modal.sharedAppdelegate.stoapLoader()
                DispatchQueue.main.async {
                    self.alert(title: "Payment canceled", message: error?.localizedDescription ?? "") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                break
            case .succeeded:
                // Acknowledge api
                if let paymentMethodId = paymentIntent?.paymentMethodId, let stripeId = paymentIntent?.stripeId, let amount = paymentIntent?.amount {
                    self.acknowledge(payment_instant_id: stripeId, payment_id: paymentMethodId, total_amount_to_charge: amount)
                }else{
                    DispatchQueue.main.async {
                        self.alert(title: "", message: "Payment is being processed, please wait a few minutes or contact admin.", actions: ["OK","Contact Admin?"]) { index in
                            if index == 0 {
                                self.navigationController?.popViewController(animated: true)
                                
                            }else{
                                let controller = ContactUsVC.storyboardInstance!
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    }
                }
                break
            @unknown default:
                fatalError()
                break
            }
        }
    }
    
    func acknowledge(payment_instant_id:String,payment_id:String,total_amount_to_charge:Int){
        let param:dictionary = [
            "payment_instant_id":payment_instant_id,
            "payment_id":payment_id,
            "amount":total_amount_to_charge,
            "user_id":UserData.shared.getUser()!.user_id,
            "service_id":customerSide_ProviderDetails!.service_request_id,
        ]
        
        Modal.shared.serviceRequestBookWithStripe(vc: self, param: param, failer: { (message) in
            Modal.sharedAppdelegate.stoapLoader()
            self.alert(title: "", message: message ) {
                self.navigationController?.popViewController(animated: true)
            }
        }) { (dic) in
            print(dic)
            self.sharedAppdelegate.stoapLoader()
            let message = ResponseKey.fetchDataInString(res: dic, valueOf: "message")
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            self.alert(title: "", message: message.isEmpty ? "You have booked service successfully" : message) {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
    }
    
    
}

extension StripeCheckoutVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }
        
        return String(data: theJSONData, encoding: .ascii)
    }
}

extension StripeCheckoutVC:STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.isValid{
            payBtn.alpha = 1.0
            payBtn.isUserInteractionEnabled = true
        }else{
            payBtn.alpha = 0.5
            payBtn.isUserInteractionEnabled = false
        }
    }
}
