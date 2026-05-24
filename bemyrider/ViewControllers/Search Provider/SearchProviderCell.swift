//
//  SearchProviderCell.swift
//  bemyrider
//
//  Created by NCT 24 on 25/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class SearchProviderCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: Color.grey.lightDeviderColor)
        }
    }
    @IBOutlet weak var lblProviderName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var mainView: UIView!
    /*{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self._containerView.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
            }
        }
    }*/
    
    @IBOutlet weak var btnHeart: UIButton!
    @IBOutlet weak var lblRating: UILabel!
    
    var indexPath:IndexPath?
    var cellData:ProviderListCls.ProviderList? {
        didSet {
            self.loadCellData()
        }
    }
    
    func loadCellData() {
        if let celldata = self.cellData {
            imgUser.downLoadImage(url: celldata.provider_image)
            lblProviderName.text = celldata.provider_name
            lblAddress.text = celldata.address
            lblDetail.text = celldata.service_description
            lblRating.text = celldata.avg_rating
            btnHeart.setImage((self.cellData!.favorite_id > "0" ? #imageLiteral(resourceName: "heartBig") : #imageLiteral(resourceName: "heart1Big") ), for: .normal)
            //print(self.cellData!.favorite_id)
        }
        else{
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgUser.image = #imageLiteral(resourceName: "small-Image-Place-Holder")
        lblProviderName.text = ""
        lblAddress.text = ""
        lblDetail.text = ""
        lblRating.text = "0"
        btnHeart.setImage(#imageLiteral(resourceName: "heart1Big"), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func onClickFavorite(_ sender: UIButton) {
        //0 = add to favourite, 1 = remove from favourite
        if let vc = self.viewController as? SearachProviderVC, cellData != nil {
            Modal.shared.likeDislikeServices(vc: vc, param: ["service_id":cellData!.provider_service_id, "fvrt_val": (cellData!.favorite_id > "0" ? "1" : "0"), "user_id": UserData.shared.getUser()!.user_id]) { (dic) in
                print(dic)
                let data = vc.providerList[self.indexPath!.row]
                data.favorite_id = (self.cellData!.favorite_id > "0" ? "0" : "1")
                self.btnHeart.setImage((self.cellData!.favorite_id > "0" ? #imageLiteral(resourceName: "heart1Big") : #imageLiteral(resourceName: "heartBig")), for: .normal)
                vc.tableView.reloadRows(at: [self.indexPath!], with: .none)
            }
        }
    }
}
