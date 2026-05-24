//
//  innerStartTabCell.swift
//  bemyrider
//
//  Created by NCT 24 on 03/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class innerStartTabCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: Color.grey.lightDeviderColor)
        }
    }
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var mainView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
//                self.mainView.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
            }
        }
    }
    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    
    var cellData:ProviderServiceDetail.ReviewData? {
        didSet {
            self.loadCellData()
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

    func loadCellData() {
        if let celldata = self.cellData {
            imgUser.downLoadImage(url: celldata.profile_img)
            lblCustomerName.text = celldata.user_name
            lblDetail.text = celldata.review
            lblRating.text = celldata.rating
            lblDate.text = celldata.created_date
            
            //print(cellData?.dictionary)
        }
        else{
            lblCustomerName.text = ""
            lblDetail.text = ""
            lblRating.text = ""
            lblDate.text = ""
        }
    }
    
}
