//
//  AddNewServiceImageCell.swift
//  bemyrider
//
//  Created by NCT 24 on 21/06/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class AddNewServiceImageCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var indexPath: IndexPath?
    
    @IBOutlet weak var bgView: UIView!{
        didSet{
//            bgView.setRadius()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.bgView.setRadius(self.bgView.frame.size.width/2, borderWidth: 1, color: UIColor(red: 198.0/255.0, green: 197.0/255.0, blue: 196.0/255.0, alpha: 1.0))
            }
        }
    }
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            self.imgUser.setRadius()
                        }
        }
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        if let parentVC = self.viewController as? AddNewServiceVC {
            if parentVC.isEdit == nil {
                parentVC.pickedImageAry.remove(at: self.indexPath!.row)
                parentVC.pickedImageNameAry.remove(at: self.indexPath!.row)
                parentVC.collectionView.reloadData()
            }
        }
    }
    
    
    //    var cellData:
    
    
}
