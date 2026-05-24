//
//  MyWalletVC.swift
//  bemyrider
//
//  Created by NCT 24 on 21/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class MyWalletVC: NewBaseViewController {

    //MARK: Properties

    static var storyboardInstance:MyWalletVC {
        return StoryBoard.wallet.instantiateViewController(withIdentifier: MyWalletVC.identifier) as! MyWalletVC
    }
    
    @IBOutlet weak var lblCreadit: UILabel!
    @IBOutlet weak var lblCreditAmount: UILabel!
    @IBOutlet weak var lblCreditMsg: UILabel!
    @IBOutlet weak var lblHold: UILabel!
    @IBOutlet weak var lblHoldAmount: UILabel!
    @IBOutlet weak var lblHoldMsg: UILabel!
    @IBOutlet weak var lblDeposite: UILabel!
    @IBOutlet weak var btnDepostite: UIButton!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.estimatedRowHeight = 90
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.isScrollEnabled = false
            tableView.separatorStyle = .none
            tableView.register(MyWalletCell.nib, forCellReuseIdentifier: MyWalletCell.identifier)
        }
    }
    @IBOutlet weak var constraintTabliViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var creditView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
               // self.creditView.border(side: .bottom, color: Color.grey.deviderColor, borderWidth: 1.0)
            }
        }
    }
    @IBOutlet weak var holdView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                //self.holdView.border(side: .bottom, color: Color.grey.deviderColor, borderWidth: 1.0)
            }
        }
    }
    @IBOutlet weak var depositView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
               // self.depositView.border(side: .bottom, color: Color.grey.deviderColor, borderWidth: 1.0)
            }
        }
    }
    
    @IBOutlet weak var redeemView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                self.redeemView.shadow(Offset:  CGSize(width: 0, height: 1), redius: 0, opacity: 0.12, color: .black)
            }
        }
    }
    
    var depositeHistoryList:[DepositHistoryList] = []
    var creditAmount:String?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
        callInitialAPIs()
    }
    
    func setLang() {
        lblCreadit.text = "My Wallet".localized
//        lblCreditMsg.text = "Credits can be used for making new projects, and that can be redeem anytime.".localized
        lblHold.text = "Hold".localized
//        lblHoldMsg.text = "Credits of ongoing projects, and that can be given to provider after task completion.".localized
//        lblDeposite.text = "Deposit History".localized
        btnDepostite.setTitle("DEPOSIT FUND".localized, for: .normal)
    }
    
    @IBAction func onClickDepositFund(_ sender: UIButton) {
        let nextVC = DepositeFundVC.storyboardInstance!
        nextVC.creditAmount = creditAmount ?? "0.0"
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

//MARK: Custom function
extension MyWalletVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "My Wallet".localized, action: #selector(onClickMenu(_:)))
        self.setupNavigationBar(title: "My Wallet".localized, isBack: true, rightButton: false)
        self.lblCreditAmount.text = ""
        self.lblHoldAmount.text = ""
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callInitialAPIs(){
        let requestGroup =  DispatchGroup()
        //Need as many of these statements as you have Alamofire.requests
        requestGroup.enter()
        requestGroup.enter()
        
        //callMyWallletAPI
        Modal.shared.getWalletDetails(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id]) { (dic) in
            let obj = MyWallet(dictionary: ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data))
            self.creditAmount = obj.wallet_amount
            self.lblCreditAmount.text = "\(UserData.shared.currency)" + obj.wallet_amount
            self.lblHoldAmount.text =  "\(UserData.shared.currency)" + obj.hold_amount
            print("callMyWallletAPI done, \(obj.wallet_amount)")
            requestGroup.leave()
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
//                self.creditView.border(side: .bottom, color: Color.grey.deviderColor, borderWidth: 1.0)
//                self.holdView.border(side: .bottom, color: Color.grey.deviderColor, borderWidth: 1.0)
//                self.depositView.border(side: .bottom, color: Color.grey.deviderColor, borderWidth: 1.0)
//            }
        }
        
        //callDepositeHistoryAPI
        Modal.shared.depositHistory(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id]) { (dic) in
            print(dic)
            self.depositeHistoryList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({DepositHistoryList(dictionary: $0 as! [String:Any])})
            self.tableView.reloadData()
            self.autoDynamicHeight()
            print("callDepositeHistoryAPI done")
            requestGroup.leave()
        }
        
        //This only gets executed once all the above are done
        requestGroup.notify(queue: DispatchQueue.main, execute: {
            // Hide HUD, refresh data, etc.
            print("DEBUG: all Done")
            
        })
        
    }
    
    func callMyWallletAPI() {
        Modal.shared.getWalletDetails(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id]) { (dic) in
            let obj = MyWallet(dictionary: ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data))
            self.lblCreditAmount.text = obj.wallet_amount
            self.lblHoldAmount.text = obj.hold_amount
        }
    }
    
    func callDepositeHistoryAPI() {
        Modal.shared.depositHistory(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id]) { (dic) in
            print(dic)
            self.depositeHistoryList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({DepositHistoryList(dictionary: $0 as! [String:Any])})
            self.tableView.reloadData()
            self.autoDynamicHeight()
        }
    }
}

extension MyWalletVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyWalletCell.identifier, for: indexPath) as? MyWalletCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.isProviderWallet = (UserData.shared.getUser()!.user_type == "p" ? true : false)
        cell.lblDate.text = "Date".localized
        cell.lblAmount.text = "Amount".localized
        cell.depositeData = depositeHistoryList[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return depositeHistoryList.count
    }
    
    func autoDynamicHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.constraintTabliViewHeight.constant =  CGFloat(self.depositeHistoryList.count * 90)
            self.tableView.updateConstraintsIfNeeded()
//            self.tableView.contentSize.height > 1 ? self.tableView.contentSize.height : 1
            self.tableView.layoutIfNeeded()
        }
    }
    
}

