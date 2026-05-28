//
//  RedeemedAmountVC.swift
//  bemyrider
//
//  Created by NCT 24 on 20/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class RedeemedAmountVC: UIViewController {

    //MARK: Properties

    
    static var storyboardInstance:RedeemedAmountVC? {
        return StoryBoard.popUp.instantiateViewController(withIdentifier: RedeemedAmountVC.identifier) as? RedeemedAmountVC
    }
    
    @IBOutlet weak var lblRequestedAmount: UILabel!
    @IBOutlet weak var lblAdminFees: UILabel!
    @IBOutlet weak var lblRequestedDate: UILabel!
    @IBOutlet weak var lblRedeemedAmount: UILabel!
    @IBOutlet weak var lblRedeemedDate: UILabel!
    @IBOutlet weak var blackLayerView: UIView!
    
    @IBOutlet weak var lbl_RequestedAmt: UILabel!
    @IBOutlet weak var lbl_AdminFees: UILabel!
    @IBOutlet weak var lbl_RequestedDate: UILabel!
    @IBOutlet weak var lbl_RedeemedAmnt: UILabel!
    @IBOutlet weak var lbl_RedeemedDate: UILabel!
    @IBOutlet weak var btnClose: GreenButton!
    
    var redeemHistoryData : RedeemHistory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRedeemHistoryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang(){
        lbl_RequestedAmt.text = "Requested Amount : ".localized
        lbl_AdminFees.text = "Admin Fees : ".localized
        lbl_RequestedDate.text = "Requested Date : ".localized
        lbl_RedeemedAmnt.text = "Redeemed Amount : ".localized
        lbl_RedeemedDate.text = "Redeemed Date : ".localized
        btnClose.setTitle("CLOSE".localized, for: .normal)
        
    }
    
    func setRedeemHistoryData() {
        if let redeemHistoryData = self.redeemHistoryData{
            lblRequestedAmount.text = redeemHistoryData.requested_amount
            lblAdminFees.text = redeemHistoryData.admin_fees
            lblRequestedDate.text = redeemHistoryData.requested_date
            lblRedeemedAmount.text = redeemHistoryData.redeemed_amount
            lblRedeemedDate.text = redeemHistoryData.redeemed_date
        }
    }
    
    @IBAction func onClickClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
