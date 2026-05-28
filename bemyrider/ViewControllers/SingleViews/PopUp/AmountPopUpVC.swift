//
//  AmountPopUpVC.swift
//  bemyrider
//
//  Created by NCT 24 on 20/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class AmountPopUpVC: UIViewController {

    //MARK: Properties
    
    static var storyboardInstance:AmountPopUpVC? {
        return StoryBoard.popUp.instantiateViewController(withIdentifier: AmountPopUpVC.identifier) as? AmountPopUpVC
    }
    
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblAdminFees: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lbltranscationID: UILabel!
    @IBOutlet weak var blackLayerView: UIView!
    
    @IBOutlet weak var lblamount: UILabel!
    @IBOutlet weak var lbladmin: UILabel!
    @IBOutlet weak var lbldate: UILabel!
    @IBOutlet weak var lbltranscation: UILabel!
    @IBOutlet weak var btnClose: GreenButton!
    
    var depostiteHistoryData : DepositHistoryList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDepositeHistoryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang(){
        lblamount.text = "Amount : ".localized
        lbladmin.text = "Admin Fees : ".localized
        lbldate.text = "Date : ".localized
        lbltranscation.text = "Transcation ID : ".localized
        btnClose.setTitle("CLOSE".localized, for: .normal)
    }
    
    func setDepositeHistoryData() {
        if let depostiteHistoryData = self.depostiteHistoryData{
            lblAmount.text = depostiteHistoryData.amount
            lblAdminFees.text = depostiteHistoryData.admin_fees
            lblDate.text = depostiteHistoryData.date
            lbltranscationID.text = depostiteHistoryData.transaction_id
        }
    }
    
    @IBAction func onClickClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
//    func setRedeemHistoryData() {
//        
//    }
    
}
