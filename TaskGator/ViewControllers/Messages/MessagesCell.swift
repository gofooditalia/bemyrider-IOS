//
//  MessagesCell.swift
//  TaskGator
//
//  Created by NCT 24 on 23/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class MessagesCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: Color.grey.lightDeviderColor)
        }
    }
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var mainView: UIView!{
        didSet{
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
//                self._containerView.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
//            }
        }
    }
    
    var cellData: MessageList? {
        didSet{
            self.loadUI()
        }
    }
    
    
    func loadUI() {
        if let cellData = self.cellData {
            lblMessage.text = cellData.message_text.removingPercentEncodingSafe()
            lblCustomerName.text = cellData.to_user_name
            lblDate.text = cellData.createdDate
            imgUser.downLoadImage(url: cellData.to_profile_img)
            lblCategory.text = cellData.service_name
        }
        else{
            lblMessage.text = ""
            lblDate.text = ""
            lblCustomerName.text = ""
            lblCategory.text = ""

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblMessage.text = ""
        lblDate.text = ""
        lblCustomerName.text = ""
        lblCategory.text = ""

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
}
