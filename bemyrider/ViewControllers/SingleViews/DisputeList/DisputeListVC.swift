//
//  DisputeListVC.swift
//  bemyrider
//
//  Created by NCT 24 on 10/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class DisputeListVC: NewBaseViewController {

    //MARK: Properties
    
    static var storyboardInstance:DisputeListVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: DisputeListVC.identifier) as? DisputeListVC
    }
    
    @IBOutlet weak var imgNoRecords: UIImageView!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(DisputeCell.nib, forCellReuseIdentifier: DisputeCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    
    deinit{
        print("DisputeListVC is Distroy")
        NotificationCenter.default.removeObserver(self)
    }
    
    var disputeList = [Dispute]()
    var disputeObj:DisputeCls?
    var refreshList:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
         NotificationCenter.default.addObserver(self, selector: #selector(disputeListChange(notification:)), name: .canCallDisputeList, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if refreshList {
            refreshList = false
            self.disputeList.removeAll()
            self.disputeObj = nil
            callDisputeList()
        }
    }

}

//MARK: Custom function
extension DisputeListVC {
    
    @objc func disputeListChange(notification: Notification) {
        if (notification.object as! [String: Any])["canCallDisputeList"] as? Bool ?? false{
            callDisputeList()
        }
    }
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Dispute List".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: "Resolution Center".localized, isBack: true, rightButton: false)
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callDisputeList() {
        let nextPage = (disputeObj?.pagination?.currentPage ?? 0 ) + 1
        print("nextPage: \(nextPage)")
        let param = ["user_id":UserData.shared.getUser()!.user_id,
                     "page": nextPage] as [String : Any]
        Modal.shared.getDisputelist(vc: self, param: param) { (dic) in
            print(dic)
           
            self.disputeObj = DisputeCls(dictionary: dic)
            if self.disputeList.count > 0{
                self.disputeList += self.disputeObj!.disputeList
            }
            else
            {
                self.disputeList = self.disputeObj!.disputeList
            }
            
            self.tableView.reloadData()
            if self.disputeList.count == 0{
                self.imgNoRecords.isHidden = false
            }else{
                self.imgNoRecords.isHidden = true
            }
        }
    }
    
}

extension DisputeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DisputeCell.identifier) as? DisputeCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.cellData = disputeList[indexPath.row]
        reloadMoreData(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return disputeList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = DisputeDetailVC.storyboardInstance!
        nextVC.disputeObj = disputeList[indexPath.row]
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func reloadMoreData(indexPath: IndexPath) {
        if disputeList.count > 0 {
           if disputeList.count - 1 == indexPath.row &&
               (disputeObj!.pagination!.currentPage < disputeObj!.pagination!.total_pages) {
               self.callDisputeList()
           }
       }
    }
}

extension DisputeListVC:DisputeDetailDelegate {
    func refreshDisputeList() {
        self.refreshList = true
    }
}

