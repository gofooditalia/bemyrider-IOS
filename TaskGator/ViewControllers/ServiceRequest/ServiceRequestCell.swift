//
//  ServiceRequestCell.swift
//  TaskGator
//
//  Created by NCT 24 on 08/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class ServiceRequestCell: UITableViewCell {

    var cellData: CustomerServicesCls.CustomerServices?{
        didSet{
            loadUI()
        }
    }

    var cellDataOfProvide: ProviderServices?{
        didSet{
            loadProvideCellUI()
        }
    }

    func loadProvideCellUI() {
        if let cellDataOfProvide = cellDataOfProvide{
            imgUser.downLoadImage(url: cellDataOfProvide.customer_image)
            lblProviderName.text = cellDataOfProvide.customer_name
            lblMessage.text = cellDataOfProvide.service_name
            lblDate.text = cellDataOfProvide.booking_start_time
            lblAmnt.text = "\(UserData.shared.currency)\(cellDataOfProvide.booking_amount)"
            lblStatus.text = cellDataOfProvide.service_status_dis.capitalizingFirstLetter()
            lblStatus.text?.addSpaceTrainlingAndLeading(char: " ", spaceNum: 2)
            lblStatus.backgroundColor = StatusState.setStatusColor(status: cellDataOfProvide.service_status)
        }
        else{
            lblProviderName.text = ""
            lblMessage.text = ""
            lblDate.text = ""
            lblAmnt.text = ""
            lblStatus.text = ""
        }
    }

    func loadUI() {
        if let cellData = cellData{
            imgUser.downLoadImage(url: cellData.provider_image)
            lblProviderName.text = cellData.provider_fname + " " + cellData.provider_lname
            lblMessage.text = cellData.service_name
            lblDate.text = cellData.booking_start_time
            lblAmnt.text = "\(UserData.shared.currency)\(cellData.booking_amount)"
            lblStatus.text = cellData.service_status_dis.capitalizingFirstLetter()
            lblStatus.text?.addSpaceTrainlingAndLeading(char: " ", spaceNum: 2)
            lblStatus.backgroundColor = StatusState.setStatusColor(status: cellData.service_status)
        }
        else{
            lblProviderName.text = ""
            lblMessage.text = ""
            lblDate.text = ""
            lblAmnt.text = ""
            lblStatus.text = ""
        }
    }

    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: Color.grey.lightDeviderColor)
        }
    }
    @IBOutlet weak var lblProviderName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAmnt: UILabel!
    @IBOutlet weak var mainView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
