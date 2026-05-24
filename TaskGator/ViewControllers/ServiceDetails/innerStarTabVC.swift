//
//  innerStarTabVC.swift
//  TaskGator
//
//  Created by NCT 24 on 03/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class innerStarTabVC: UIViewController{
    
    var reviewData = [ProviderServiceDetail.ReviewData]()
    
    @IBOutlet weak var imgNoRecords: UIImageView!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(innerStartTabCell.nib, forCellReuseIdentifier: innerStartTabCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.allowsSelection = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewData = providerServiceDetail!.review_data
        if reviewData.count == 0 {
            imgNoRecords.isHidden = false
        }else{
            imgNoRecords.isHidden = true
        }
        tableView.reloadData()
    }
}

extension innerStarTabVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: innerStartTabCell.identifier) as? innerStartTabCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.cellData = reviewData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewData.count
    }
}

extension innerStarTabVC{
    func loadUI()  {
        
    }
}
