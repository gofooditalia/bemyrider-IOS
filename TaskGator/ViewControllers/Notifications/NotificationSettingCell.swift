//
//  NotificationSettingCell.swift
//  TaskGator
//
//  Created by NCT 24 on 24/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class NotificationSettingCell: UITableViewCell {

    @IBOutlet weak var lblNotificationDetails: UILabel!{
        didSet{
            lblNotificationDetails.isUserInteractionEnabled = true
            lblNotificationDetails.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickSwitcUpdate)))
        }
    }
    
    @IBOutlet weak var btnSwitch: UIButton!{
        didSet{
            btnSwitch.setImage(#imageLiteral(resourceName: "uncheckIco"), for: .normal)
        }
    }
    
    var indexPath:IndexPath!
    
    var cellData: NotificationData? {
        didSet{
            loadUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func loadUI() {
        if let cellData = self.cellData{
            lblNotificationDetails.text = cellData.title
            btnSwitch.isSelected = (cellData.checked != "false")
        }
        else{
            lblNotificationDetails.text = ""
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @objc func onClickSwitcUpdate() {
        if let parentVC = self.viewController as? NotificationSettings {
            btnSwitch.isSelected = !btnSwitch.isSelected
            parentVC.notificationList[self.indexPath.row].checked = (btnSwitch.isSelected ? "true" : "false")
        }
    }
    
    @IBAction func onClickSwitch(_ sender: UIButton) {
        //sender.isSelected = !sender.isSelected
        
        if let parentVC = self.viewController as? NotificationSettings {
            sender.isSelected = !sender.isSelected
            parentVC.notificationList[self.indexPath.row].checked = (sender.isSelected ? "true" : "false")
        }
        
//        UIView.transition(with: sender as UIView, duration: 0.2, options: (sender.isSelected ? .transitionFlipFromRight : .transitionFlipFromLeft), animations: {
//            if let parentVC = self.viewController as? NotificationSettings {
//                sender.isSelected = !sender.isSelected
//                parentVC.notificationList[self.indexPath.row].checked = (sender.isSelected ? "true" : "false")
//            }
//        }, completion: nil)
    }

    
}
