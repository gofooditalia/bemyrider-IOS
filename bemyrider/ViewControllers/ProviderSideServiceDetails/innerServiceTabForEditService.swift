//
//  innerServiceTabForEditService.swift
//  bemyrider
//
//  Created by NCT 24 on 30/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class innerServiceTabForEditService: UIViewController {

    //MARK: Properties

    static var storyboardInstance:innerServiceTabForEditService? {
        return StoryBoard.serviceProviderDetail.instantiateViewController(withIdentifier: innerServiceTabForEditService.identifier) as? innerServiceTabForEditService
    }

    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTotalService: UILabel!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblValCategory: UILabel!
    @IBOutlet weak var lblValPrice: UILabel!
    @IBOutlet weak var lblValTotalService: UILabel!
    @IBOutlet weak var lblValServiceDesc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        lblCategory.text = "Category".localized
        lblPrice.text = "Rate".localized
        lblTotalService.text = "Total service".localized
        lblServiceDesc.text = "Service Description".localized
    }
    
}
extension innerServiceTabForEditService{
    
    func loadUI()  {
        lblValCategory.text = providerServiceDetail?.category_name
//        if let service_master_type = providerServiceDetail?.service_master_type, service_master_type == "hourly" {
//            lblValPrice.text = "\(UserData.shared.currency)" + providerServiceDetail!.price + "/ hour"
//        }
//        else{
            lblValPrice.text = "\(UserData.shared.currency)" + providerServiceDetail!.price
//        }
        lblValTotalService.text = providerServiceDetail?.total_service
        lblValServiceDesc.text = providerServiceDetail?._description
    }
    
}


