//
//  DisputeCell.swift
//  bemyrider
//
//  Created by NCT 24 on 10/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class DisputeCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: Color.grey.lightDeviderColor)
        }
    }
    
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblProviderName: UILabel!
    @IBOutlet weak var lblDisputeTitle: UILabel!
    @IBOutlet weak var lblDisputeMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var mainView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.mainView.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
            }
        }
    }
    
    var cellData : Dispute?{
        didSet{
            loadData()
        }
    }
    
    func loadData() {
        if let cellData = cellData{
            if Modal.sharedAppdelegate.isCustomerLogin {
                imgUser.downLoadImage(url: cellData.provider_img)
                lblProviderName.text = cellData.provider_firstname + " " + cellData.provider_lastname
                
            }else{
                imgUser.downLoadImage(url: cellData.customer_img)
                lblProviderName.text = cellData.customer_firstname + " " + cellData.customer_lastname
            }
            
            lblDate.text = cellData.createdDate
            lblServiceName.text = cellData.service_name
            lblDisputeTitle.text = cellData.dispute_title
            lblDisputeMessage.text = cellData.dispute_message
        }
        else{
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
