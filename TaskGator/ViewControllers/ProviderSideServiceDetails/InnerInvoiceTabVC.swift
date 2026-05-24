//
//  InnerInvoiceTabVC.swift
//  TaskGator
//
//  Created by NCT 24 on 14/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class InnerInvoiceTabVC: UIViewController {

    //MARK: Properties
    static var storyboardInstance:InnerInvoiceTabVC? {
        return StoryBoard.providerSideServiceDetails.instantiateViewController(withIdentifier: InnerInvoiceTabVC.identifier) as? InnerInvoiceTabVC
    }
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblRatingForMe: UILabel!
    @IBOutlet weak var lblPaymentPref: UILabel!
    @IBOutlet weak var lblValCategory: UILabel!
    @IBOutlet weak var lblValPrice: UILabel!
    @IBOutlet weak var lblValRatingForMe: UILabel!
    @IBOutlet weak var lblStar: UILabel!
    @IBOutlet weak var lblValPaymentPref: UILabel!
    @IBOutlet weak var imgStar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func loadData() {
        if let providerSide_ProviderDetails = providerSide_ProviderDetails{
            lblValCategory.text = providerSide_ProviderDetails.category_name
            lblValPrice.text = "\(UserData.shared.currency) \(providerSide_ProviderDetails.booking_amount)"
            let paymentMode = providerSide_ProviderDetails.payment_mode.capitalizingFirstLetter()
            lblValPaymentPref.text = paymentMode.localized
            lblValRatingForMe.text = (providerSide_ProviderDetails.review.isEmpty ? "No Review" : providerSide_ProviderDetails.review )
            lblStar.text = providerSide_ProviderDetails.rating.isEmpty ? "0.0" : providerSide_ProviderDetails.rating
        }
    }
    
    func setLang(){
        lblCategory.text = "Category".localized
        lblPrice.text = "Rate".localized
        lblPaymentPref.text = "Payment Preference".localized
        lblRatingForMe.text = "Rating For Me".localized
    }
}
