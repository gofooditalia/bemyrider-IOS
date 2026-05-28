//
//  NotificationCell.swift
//  bemyrider
//
//  Created by NCT 24 on 23/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: Color.grey.lightDeviderColor)
        }
    }
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var mainView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
//                self.mainView.border(side: .all, color: UIColor(red: 228/255.0, green: 233.0/255.0, blue: 234.0/255.0, alpha: 1.0), borderWidth: 1.0)
                self.mainView.setRadius(10, borderWidth: 1.0, color: UIColor(red: 228/255.0, green: 233.0/255.0, blue: 234.0/255.0, alpha: 1.0))
            }
        }
    }
    
    var cellData: NotificationCls.NotificationList? {
        didSet{
            loadUI()
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
    
    func loadUI() {
        if let cellData = self.cellData{
            imgUser.downLoadImage(url: cellData.image)
            lblUserName.text = cellData.user_name
            lblDate.text = cellData.notification_date
            lblMessage.text = cellData.message
        }
        else{
            lblUserName.text = ""
            lblDate.text =  ""
            lblMessage.text =  ""
        }
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        
    }
    
    
}
