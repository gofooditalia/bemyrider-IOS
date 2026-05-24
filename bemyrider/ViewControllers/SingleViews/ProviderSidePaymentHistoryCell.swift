//
//  ProviderSidePaymentHistoryCell.swift
//  bemyrider
//
//  Created by admin on 8/30/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class ProviderSidePaymentHistoryCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius()
        }
    }
    @IBOutlet weak var mainView: UIView!{
        didSet{
            self.mainView.setRadius(10, borderWidth: 1.0, color: UIColor(red: 228/255.0, green: 233.0/255.0, blue: 234.0/255.0, alpha: 1.0))
        }
    }
    
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblcategory: UILabel!
    @IBOutlet weak var lblSubCategory: UILabel!
    @IBOutlet weak var lblLocTransactionId: UILabel!
    @IBOutlet weak var lblTransactionId: UILabel!
    @IBOutlet weak var lblLocReceiveAmount: UILabel!
    @IBOutlet weak var lblReceiveAmount: UILabel!
    @IBOutlet weak var lblLocDateOfCompletion: UILabel!
    @IBOutlet weak var lblCompletion: UILabel!
    @IBOutlet weak var lblLocFixrate: UILabel!
    @IBOutlet weak var lblFixRate: UILabel!
    @IBOutlet weak var lblLocTotalWorkingHours: UILabel!
    @IBOutlet weak var lblTotalWorkingHours: UILabel!
    @IBOutlet weak var totalWorkingStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var cellData:PaymentHistory.TransactionList?{
        didSet{
            loadMoreData()
        }
    }
    func loadMoreData(){
        if let celldata = cellData{
            imgUser.downLoadImage(url: celldata.profile_image, placeHolderImage: #imageLiteral(resourceName: "small-Image-Place-Holder"))
            lblName.text = celldata.username
            lblStatus.text = celldata.status.capitalizingFirstLetter()
            lblStatus.text?.addSpaceTrainlingAndLeading(char: " ", spaceNum: 2)
            lblStatus.backgroundColor = StatusState.setStatusColor(status: celldata.status)
            
            lblcategory.text = ""//celldata.servicename
            lblSubCategory.text = "\(celldata.category.capitalized) > \(celldata.subcategory.capitalized)"
            lblTransactionId.text = celldata.transection_id
            lblReceiveAmount.text = celldata.recived_amount
            lblCompletion.text = celldata.completion_date
            lblFixRate.text = celldata.per_hour
            lblLocFixrate.text = celldata.per_hour_title
            lblTotalWorkingHours.text = celldata.totel_hours
            if celldata.per_hour_class == "hide"{
                totalWorkingStack.isHidden = true
            }else{
                totalWorkingStack.isHidden = false
            }
            
            if celldata.isactive.lowercased() == "du"{
                lblLocation.text = ""
                lblLocation.isHidden = true
            }else{
                lblLocation.text = celldata.address
                lblLocation.isHidden = false
            }
        }
    }
}
