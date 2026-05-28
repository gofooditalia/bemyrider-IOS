//
//  CategoryCell.swift
//  bemyrider
//
//  Created by admin on 8/19/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCategoryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var cellData:Category?{
        didSet{
            loadData()
        }
    }
    func loadData(){
        if let celldata = cellData{
            lblCategoryName.text = celldata.category_name
            imgCategory.downLoadImage(url: celldata.banner_url, placeHolderImage: #imageLiteral(resourceName: "small-Image-Place-Holder.png"))
        }
    }
    
}
