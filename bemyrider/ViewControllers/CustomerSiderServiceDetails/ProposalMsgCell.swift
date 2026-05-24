//
//  ProposalMsgCell.swift
//  bemyrider
//
//  Created by NCT 24 on 18/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

struct StatusState {
    
    enum StatusType:String{
        case completed = "completed"
        case expired = "expired"
        case pending = "pending"
        case onGoing = "ongoing"
        case rejected = "rejected"
        case accepted = "accepted"
        case hired = "hired"
        case cancelled = "cancelled"
        case dispute = "dispute"
        case closed = "closed"
        //send msg not visible
        //pending || accepted
        
    }
    
    static let colorGreen:UIColor = UIColor(red: 44/255, green: 198/255, blue: 102/255, alpha: 1.00)
    static let colorDarkGreen:UIColor = Color.green.theam
    static let colorLightBlue:UIColor = UIColor(red: 51/255, green: 122/255, blue: 183/255, alpha: 1.00)
    static let colorRed:UIColor = UIColor(red: 245/255, green: 20/255, blue: 20/255, alpha: 1.00)
    static let colorYellow:UIColor = UIColor(red: 240/255, green: 173/255, blue: 78/255, alpha: 1.00)
    static let colorBlue:UIColor = UIColor(red: 92/255, green: 107/255, blue: 192/255, alpha: 1.00)
    static let colorBlack:UIColor = Color.Black.primary
    static let colorGrey:UIColor = Color.grey.dark
    static let colorSkyBlue:UIColor = UIColor(red: 91/255, green: 192/255, blue: 222/255, alpha: 1.00)
    static let colorCofee:UIColor = Color.grey.dark
    static let colorRejectedGrey:UIColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1.00)
    static let colorClosedMaroom:UIColor = UIColor(red: 141/255, green: 110/255, blue: 99/255, alpha: 1.00)

    static func setStatusColor(status: String) -> UIColor {
        if status.caseInsensitiveCompare(string: StatusType.completed.rawValue) {
            return StatusState.colorGreen
        }else if status.caseInsensitiveCompare(string: StatusType.expired.rawValue) {
            return StatusState.colorBlack
        }
        else if status.caseInsensitiveCompare(string: StatusType.pending.rawValue) {
            return  StatusState.colorYellow
        }
        else if status.caseInsensitiveCompare(string: StatusType.onGoing.rawValue) {
            return  StatusState.colorBlue
        }
        else if status.caseInsensitiveCompare(string: StatusType.rejected.rawValue) {
            return  StatusState.colorRejectedGrey
        }
        else if status.caseInsensitiveCompare(string: StatusType.hired.rawValue) {
            return  StatusState.colorSkyBlue
        }
        else if status.caseInsensitiveCompare(string: StatusType.accepted.rawValue) {
            return  StatusState.colorLightBlue
        }
        else if status.caseInsensitiveCompare(string: StatusType.cancelled.rawValue) {
            return  StatusState.colorRed
        }
        else if status.caseInsensitiveCompare(string: StatusType.closed.rawValue) {
            return  StatusState.colorClosedMaroom
        }
            else if status.caseInsensitiveCompare(string: StatusType.dispute.rawValue) {
                return  StatusState.colorRed
            }
        else{
            return Color.green.theam
        }
    }
    
}

class ProposalMsgCell: UITableViewCell {
    
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    //ProposalServiceData
    
    var cellData: ProposalServiceData?{
        didSet{
            loadUI()
        }
    }
    
    var cellDataProviderSide: ProviderServicesCls.ProposalServiceData?{
        didSet{
            loadUIProviderSide()
        }
    }
    
    func loadUI() {
        if let cellData = cellData{
            lblStatus.text = nil
            if cellData.hours == "1" {
                lblHours.text = cellData.hours + " " + "Hour".localized

            }else{
                lblHours.text = cellData.hours + " " + "Hours".localized

            }
            
            //            lblHours.text = cellData.hours
            lblMsg.text = cellData.message
 
            lblStatus.text = cellData.status.capitalized + "    "
            lblStatus.backgroundColor = StatusState.setStatusColor(status: cellData.status)
            
        }
    }
    
    func loadUIProviderSide() {
        if let cellData = cellDataProviderSide{
            if cellData.hours == "1" {
                lblHours.text = cellData.hours + " " + "Hour".localized

            }else{
                lblHours.text = cellData.hours + " " + "Hours".localized

            }
//            lblHours.text = cellData.hours
            lblMsg.text = cellData.message
            
            lblStatus.text = cellData.status.capitalized + "    "
            lblStatus.backgroundColor = StatusState.setStatusColor(status: cellData.status)
            
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
