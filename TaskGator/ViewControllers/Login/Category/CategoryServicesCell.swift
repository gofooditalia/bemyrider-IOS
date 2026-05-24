//
//  CategoryServicesCell.swift
//  TaskGator
//
//  Created by admin on 8/19/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class CategoryServicesCell: UICollectionViewCell {

    @IBOutlet weak var imgService: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var opeView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var cellData:ServiceList?{
        didSet{
            loadMoreData()
        }
    }
    func loadMoreData(){
        if let celldata = cellData{
            lblName.text = celldata.service_name
            imgService.downLoadImage(url: celldata.service_img_url, placeHolderImage: #imageLiteral(resourceName: "Image-Place-Holder"))
        }
    }
}
