//
//  CategoryTaskersCell.swift
//  TaskGator
//
//  Created by admin on 8/20/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class CategoryTaskersCell: UITableViewCell {

    @IBOutlet weak var imgTasker: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDes: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var cellData:PopularTasker?{
        didSet{
            loadMoreData()
        }
    }
    func loadMoreData(){
        if let celldata = cellData{
            lblDes.text = celldata.service
            lblName.text = celldata.username
            imgTasker.downLoadImage(url: celldata.userimg, placeHolderImage: #imageLiteral(resourceName: "small-Image-Place-Holder"))
        }
    }
}
