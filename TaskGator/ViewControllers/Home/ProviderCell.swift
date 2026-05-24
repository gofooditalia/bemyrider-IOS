//
//  ProviderCell.swift
//  bemyrider
//
//

import UIKit

class ProviderCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var profileImgView: UIImageView!{
        didSet{
            profileImgView.setRadius()
        }
    }
    @IBOutlet weak var lblName: RobotoMedium14Label!
    @IBOutlet weak var lblRating: RobotoMedium14Label!
    @IBOutlet weak var lblLocation: RobotoLight12Label!
    @IBOutlet weak var lblHourRate: UILabel!
    
    var cellData:DeliveryProivderList?{
        didSet{
            loadData()
        }
    }
    func loadData(){
        if let celldata = cellData{
            lblName.text = celldata.provider_first_name + " " + celldata.provider_last_name
            lblRating.text = celldata.avg_rating
            lblLocation.text = celldata.address
            lblHourRate.text = "\(celldata.hour_rate)" //\(UserData.shared.currency)/h"
            profileImgView.downLoadImage(url: celldata.provider_image, placeHolderImage: #imageLiteral(resourceName: "small-Image-Place-Holder.png"))
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
