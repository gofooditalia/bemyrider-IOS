//
//  ProviderSidePaymenyHistroyVC.swift
//  bemyrider
//
//  Created by admin on 8/30/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class ProviderSidePaymenyHistroyVC: NewBaseViewController {
    
    //MARK: Properties
    static var storyboardInstance:ProviderSidePaymenyHistroyVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: ProviderSidePaymenyHistroyVC.identifier) as? ProviderSidePaymenyHistroyVC
    }

    @IBOutlet weak var tblPaymentHistory: UITableView!{
        didSet{
            tblPaymentHistory.delegate = self
            tblPaymentHistory.dataSource = self
            tblPaymentHistory.tableFooterView = UIView()
            tblPaymentHistory.register(ProviderSidePaymentHistoryCell.nib, forCellReuseIdentifier: ProviderSidePaymentHistoryCell.identifier)
        }
    }
    @IBOutlet weak var imgNodataFound: UIImageView!
    var paymentHistory:PaymentHistory?
    var paymentHistoryList = [PaymentHistory.TransactionList]()
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Transaction History".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: "Payment History".localized, isBack: true, rightButton: false)
        transactionHistory()
    }
    @objc func onClickMenu(_ sender: UIButton){
            self.navigationController?.popViewController(animated: true)
    }
    func transactionHistory(){
        let nextPage = (paymentHistory?.pagination?.currentPage ?? 0 ) + 1
        let param:[String:Any] = [
            "user_id":UserData.shared.getUser()!.user_id,
            "page":nextPage        ]
        Modal.shared.providerSidePaymentHistory(vc: self, param: param) { (dic) in
            self.paymentHistory = PaymentHistory(dictionary: dic)
            if self.paymentHistoryList.count > 0{
                self.paymentHistoryList += self.paymentHistory!.transection_list
            }
            else{
                self.paymentHistoryList.removeAll()
                self.paymentHistoryList = self.paymentHistory!.transection_list
            }
            self.imgNodataFound.isHidden = self.paymentHistoryList.count == 0 ? false : true
            self.tblPaymentHistory.reloadData()
        }
    }
    func reloadMoreData() {
        if let paymentHistory = paymentHistory{
            if (paymentHistory.pagination!.currentPage < paymentHistory.pagination!.total_pages) {
                transactionHistory()
                print("call new page")
            }
        }
    }

}
extension ProviderSidePaymenyHistroyVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProviderSidePaymentHistoryCell.identifier, for: indexPath) as? ProviderSidePaymentHistoryCell else {
            fatalError()
        }
        cell.cellData = paymentHistoryList[indexPath.row]
        cell.lblLocTransactionId.text = "Transaction ID".localized
        cell.lblLocReceiveAmount.text = "Received Amount".localized
        cell.lblLocDateOfCompletion.text = "Date Of Completion".localized
        cell.lblLocTotalWorkingHours.text = "Total Working Hours".localized
        return cell
    }
}
extension ProviderSidePaymenyHistroyVC{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print("scrollView.bounds.maxY: \(scrollView.bounds.maxY), scrollView.contentSize.height:\(scrollView.contentSize.height)")
        if scrollView.bounds.maxY >= scrollView.contentSize.height {
            reloadMoreData()
        }
    }
}
