//
//  PaymentHistoryVC.swift
//  bemyrider
//
//  Created by NCT 24 on 27/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class PaymentHistoryVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:PaymentHistoryVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: PaymentHistoryVC.identifier) as? PaymentHistoryVC
    }
    @IBOutlet weak var imgNoRecords: UIImageView!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(MyWalletCell.nib, forCellReuseIdentifier: MyWalletCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var constraintTabliViewHeight: NSLayoutConstraint!
    
    var paymentHistoryList = [DepositHistoryList]()
    var depositHistoryObj:DepositHistory?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        paymentHistoryAPI()
        
    }
    
    
    
}

//MARK: Custom function
extension PaymentHistoryVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Payment History".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: "Payment History".localized, isBack: true, rightButton: false)
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func paymentHistoryAPI() {
        var param:[String:Any] = ["user_id":UserData.shared.getUser()!.user_id]
        let nextPage = (depositHistoryObj?.pagination?.currentPage ?? 0 ) + 1
        print("nextPage: \(nextPage)")
        param["page"] = nextPage
        Modal.shared.paymentHistory(vc: self, param: param) { (dic) in
            print(dic)
            self.depositHistoryObj = DepositHistory(dictionary: dic)
            if self.paymentHistoryList.count > 0{
                self.paymentHistoryList += self.depositHistoryObj!.historyList
            }
            else{
                self.paymentHistoryList.removeAll()
                self.paymentHistoryList = self.depositHistoryObj!.historyList
            }
            //self.autoDynamicHeight()
            if self.paymentHistoryList.count == 0{
                self.imgNoRecords.isHidden = false
            }else{
                self.imgNoRecords.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    
    func autoDynamicHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.constraintTabliViewHeight.constant = self.tableView.contentSize.height
            //self.view.layoutIfNeeded()
        }
    }
    
}

extension PaymentHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyWalletCell.identifier) as? MyWalletCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.isProviderWallet = (UserData.shared.getUser()!.user_type == "p" ? true : false)
        cell.depositeData = paymentHistoryList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paymentHistoryList.count
    }
    
    
}

extension PaymentHistoryVC{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print("scrollView.bounds.maxY: \(scrollView.bounds.maxY), scrollView.contentSize.height:\(scrollView.contentSize.height)")
        if scrollView.bounds.maxY >= scrollView.contentSize.height {
            reloadMoreData()
        }
    }
    
    func reloadMoreData() {
        if let depositHistoryObj = depositHistoryObj{
            if (depositHistoryObj.pagination!.currentPage < depositHistoryObj.pagination!.total_pages) {
                paymentHistoryAPI()
                print("call new page")
            }
        }
    }
}
