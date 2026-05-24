//
//  innerGalleryTabVC.swift
//  TaskGator
//
//  Created by NCT 24 on 03/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class innerGalleryTabVC: UIViewController {

    @IBOutlet weak var imgNoRecords: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(innerGalleryTabCell.nib, forCellWithReuseIdentifier: innerGalleryTabCell.identifier)
        }
    }
    
    var mediaData = [ProviderServiceDetail.MediaData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mediaData = providerServiceDetail!.media_data
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mediaData = providerServiceDetail!.media_data
        collectionView.reloadData()
        if mediaData.count == 0{
            imgNoRecords.isHidden = false
        }else{
            imgNoRecords.isHidden = true
        }
    }
}


extension innerGalleryTabVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: innerGalleryTabCell.identifier, for: indexPath) as? innerGalleryTabCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.cellData = mediaData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    //MARK: UICollectionViewDelegateFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(collectionView.frame.size.width / 2 - 15 ), height: CGFloat(collectionView.frame.size.width / 2 - 15 ))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}
