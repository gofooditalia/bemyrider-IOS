//
//  ReviewCell.swift
//  TaskGator
//
//  Created by NCT 24 on 16/06/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import Cosmos

class ReviewCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: Color.grey.lightDeviderColor)
        }
    }
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblServiceType: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var mainView: UIView!{
        didSet{
            //DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            //    self._containerView.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
            //}
        }
    }
    @IBOutlet weak var cosmosStarView: CosmosView!{
        didSet{
            cosmosStarView.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    var cellData: Review? {
        didSet{
            self.loadUI()
        }
    }
    
    
    func loadUI() {
        if let cellData = self.cellData {
            imgUser.downLoadImage(url: cellData.user_image)
            lblCustomerName.text = cellData.user_name
            lblServiceType.text = cellData.service_name
            lblReview.text = cellData.review_desc
            lblDate.text = cellData.review_date
            lblLocation.text = cellData.address
            cosmosStarView.rating = Double(cellData.review_rating) ?? 0.0
        }
        else{
            lblCustomerName.text = ""
            lblServiceType.text = ""
            lblReview.text = ""
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
