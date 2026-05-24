//
//  MyWalletProvider.swift
//  bemyrider
//
//  Created by NCT 24 on 21/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class MyWalletProvider: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:MyWalletProvider? {
        return StoryBoard.wallet.instantiateViewController(withIdentifier: MyWalletProvider.identifier) as? MyWalletProvider
    }
    
    @IBOutlet weak var reedemHoldView: UIView!{
        didSet{
//            reedemHoldView.layer.shadowOffset = CGSize(width: 0, height: 0)
//            reedemHoldView.layer.shadowRadius = 3
//            reedemHoldView.layer.shadowColor = UIColor.black.cgColor
//            reedemHoldView.layer.shadowOpacity = 0.12
            reedemHoldView.shadow(Offset:  CGSize(width: 0, height: 1), redius: 0, opacity: 0.12, color: .black)
        }
    }
    @IBOutlet weak var lblCreadit: UILabel!
    @IBOutlet weak var lblCreditAmount: UILabel!
//    @IBOutlet weak var lblCreditMsg: UILabel!
    @IBOutlet weak var lblHold: UILabel!
    @IBOutlet weak var lblHoldAmount: UILabel!
//    @IBOutlet weak var lblHoldMsg: UILabel!
    @IBOutlet weak var lblRedeem: UILabel!
    @IBOutlet weak var lblRedeemAmount: UILabel!
//    @IBOutlet weak var lblRedeemMsg: UILabel!
    @IBOutlet weak var lblRedeemHistory: UILabel!
    @IBOutlet weak var btnDepostite: UIButton!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            //            tableView.tableFooterView = UIView()
            tableView.isScrollEnabled = false
            tableView.separatorStyle = .none
            tableView.register(MyWalletCell.nib, forCellReuseIdentifier: MyWalletCell.identifier)
        }
    }
    @IBOutlet weak var constraintTabliViewHeight: NSLayoutConstraint!
    @IBOutlet weak var innerContainerView: UIView!
    
    
    @IBOutlet weak var creditView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                //self.creditView.border(side: .bottom, color: Color.grey.deviderColor, borderWidth: 1.0)
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
                //self.depositView.border(side: .bottom, color: Color.grey.deviderColor, borderWidth: 1.0)
            }
        }
    }
    
    
    var redeemHistoryList = [RedeemHistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        callInitialAPIs()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        lblCreadit.text = "My Wallet".localized
//        lblCreditMsg.text = "Credits can be used for making new projects, and that can be redeem anytime.".localized
        lblHold.text = "Hold".localized
//        lblHoldMsg.text = "Credits of ongoing projects, and that can be given to provider after task completion.".localized
        lblRedeem.text = "Redeem Request".localized
//        lblRedeemMsg.text = "This is the balance which you have requested for redeem".localized
        lblRedeemHistory.text = "Redeem Request History".localized
        btnDepostite.setTitle("Redeem Request".localized.uppercased(), for: .normal)
    }
    
    @IBAction func onClickRedeemRequest(_ sender: UIButton) {
        callRedeemreqAPI()
    }
    
}

//MARK: Custom function
extension MyWalletProvider {
    
    func callInitialAPIs() {
        Task {
            do {
                let userId = UserData.shared.getUser()!.user_id
                async let walletTask = APIClient.shared.getWalletDetails(params: ["user_id": userId])
                async let historyTask = APIClient.shared.getRedeemHistory(params: ["user_id": userId])
                
                let walletDic = try await walletTask
                let obj = MyWallet(dictionary: ResponseKey.fatchDataAsDictionary(res: walletDic, valueOf: .data))
                
                let historyDic = try await historyTask
                
                await MainActor.run {
                    self.lblCreditAmount.text = UserData.shared.currency + obj.wallet_amount
                    self.lblHoldAmount.text = UserData.shared.currency + obj.hold_amount
                    self.lblRedeemAmount.text = UserData.shared.currency + obj.redeem_requested_amount
                    
                    self.redeemHistoryList = ResponseKey.fatchDataAsArray(res: historyDic, valueOf: .data).map({ RedeemHistory(dictionary: $0 as! [String:Any]) })
                    self.tableView.reloadData()
                    self.autoDynamicHeight()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func callMyWallletAPI() {
        Task {
            do {
                let userId = UserData.shared.getUser()!.user_id
                let dic = try await APIClient.shared.getWalletDetails(params: ["user_id": userId])
                await MainActor.run {
                    let obj = MyWallet(dictionary: ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data))
                    self.lblCreditAmount.text = obj.wallet_amount
                    self.lblHoldAmount.text = obj.hold_amount
                    self.lblRedeemAmount.text = obj.redeem_requested_amount
                    self.redeemHistoryAPI()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func callRedeemreqAPI() {
        Modal.sharedAppdelegate.startLoader()
        Task {
            do {
                let dic = try await APIClient.shared.redeemRequest(params: ["user_id": UserData.shared.getUser()!.user_id])
                await MainActor.run {
                    Modal.sharedAppdelegate.stoapLoader()
                    let message = ResponseKey.fatchDataAsString(res: dic, valueOf: .message)
                    self.alert(title: "Alert".localized, message: message, completion: {
                        self.redeemHistoryAPI()
                    })
                }
            } catch {
                await MainActor.run {
                    Modal.sharedAppdelegate.stoapLoader()
                    if let apiError = error as? APIError {
                        self.alert(title: "Alert".localized, message: apiError.message)
                    }
                }
            }
        }
    }
    
    func redeemHistoryAPI() {
        Task {
            do {
                let param = ["user_id": UserData.shared.getUser()!.user_id]
                let dic = try await APIClient.shared.getRedeemHistory(params: param)
                await MainActor.run {
                    self.redeemHistoryList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({ RedeemHistory(dictionary: $0 as! [String:Any]) })
                    self.tableView.reloadData()
                    self.autoDynamicHeight()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: false, btnTitle: "", navigationTitle: "My Wallet".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.lblCreditAmount.text = ""
        self.lblHoldAmount.text = ""
        self.lblRedeemAmount.text = ""
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func autoDynamicHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.constraintTabliViewHeight.constant = CGFloat(self.redeemHistoryList.count * 85) //self.tableView.contentSize.height
            //            self.view.layoutIfNeeded()
        }
        
    }
    
}

extension MyWalletProvider: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyWalletCell.identifier) as? MyWalletCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.isProviderWallet = (UserData.shared.getUser()!.user_type == "p" ? true : false)
        cell.cellData = redeemHistoryList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redeemHistoryList.count
    }
    
    
    
}


