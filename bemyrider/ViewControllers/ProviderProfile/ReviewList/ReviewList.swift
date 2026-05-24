//
//  ReviewList.swift
//  bemyrider
//
//  Created by NCT 24 on 16/06/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class ReviewList: NewBaseViewController {
    
    //MARK: Properties
    static var storyboardInstance:ReviewList? {
        return StoryBoard.profiles.instantiateViewController(withIdentifier: ReviewList.identifier) as? ReviewList
    }
    
    @IBOutlet weak var imgNoRecords: UIImageView!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(ReviewCell.nib, forCellReuseIdentifier: ReviewCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            //tableView.estimatedRowHeight = 65
            //tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    
    var reviewList = [Review]()
    var reviewObj: ReviewCls?
    
    var userId:String?
    var userType:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        callReviewAPI()
    }
    
    
}

//MARK: Custom function
extension ReviewList {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Review".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title: "Reviews".localized, isBack: true, rightButton: false)
        
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callReviewAPI() {
        let nextPage = (reviewObj?.pagination?.currentPage ?? 0 ) + 1
        
        let param:[String : Any] = ["user_id": userId ?? UserData.shared.getUser()!.user_id,
                                    "user_type": userType ?? UserData.shared.getUser()!.user_type,
                                    "page":nextPage]
        
        Modal.shared.providerReviews(vc: self, param: param) { (dic) in
            print(dic)
            
            self.reviewObj = ReviewCls(dictionary: dic)
            if self.reviewList.count > 0{
                self.reviewList += self.reviewObj!.reviewList
            }
            else
            {
                self.reviewList = self.reviewObj!.reviewList
            }
            
            self.tableView.reloadData()
            if self.reviewList.count == 0{
                self.imgNoRecords.isHidden = false
            }else{
                self.imgNoRecords.isHidden = true
            }
            
        }
    }
}

extension ReviewList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.identifier) as? ReviewCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.cellData = reviewList[indexPath.row]
        reloadMoreData(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reviewList[indexPath.row].isactive.lowercased() != "du" {
            let nextVc = CustomerProfileVC.storyboardInstance!
            nextVc.userType = self.userType
            nextVc.customerIdFromProviderSide = reviewList[indexPath.row].review_id
            nextVc.customerIdFromProviderSide = reviewList[indexPath.row].created_user
            self.navigationController?.pushViewController(nextVc, animated: true)
        }
    }
    
    func reloadMoreData(indexPath: IndexPath) {
        if reviewList.count > 0 {
            if reviewList.count - 1 == indexPath.row &&
                (reviewObj!.pagination!.currentPage < reviewObj!.pagination!.total_pages) {
                self.callReviewAPI()
            }
        }
    }
}
