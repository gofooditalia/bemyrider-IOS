//
//  innerGalleryTabCell.swift
//  TaskGator
//
//  Created by NCT 24 on 03/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class innerGalleryTabCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    
    var cellData:ProviderServiceDetail.MediaData? {
        didSet {
            self.loadCellData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func loadCellData() {
        if let celldata = self.cellData {
           img.downLoadImage(url: celldata.media_url)
        }
        else{
            
        }
    }
    
}
