//
//  FinancialInfoVC.swift
//  TaskGator
//
//  Created by NCT 24 on 30/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class FinancialInfoVC: NewBaseViewController {

    //MARK: Properties

    static var storyboardInstance:FinancialInfoVC? {
        return StoryBoard.provider.instantiateViewController(withIdentifier: FinancialInfoVC.identifier) as? FinancialInfoVC
    }
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var viewTotalEarned: UIView!{
        didSet{
            DispatchQueue.main.async {
                self.viewTotalEarned.setRadius(color: Color.Theme.extraLightGray)
            }
        }
    }
    @IBOutlet weak var viewCompletedService: UIView!{
        didSet{
            DispatchQueue.main.async {
                self.viewCompletedService.setRadius(color: Color.Theme.extraLightGray)
            }
        }
    }
    @IBOutlet weak var viewCommision: UIView!{
        didSet{
            DispatchQueue.main.async {
                self.viewCommision.setRadius(color:Color.Theme.extraLightGray)
            }
        }
    }
    @IBOutlet weak var viewNetEarned: UIView!{
        didSet{
            DispatchQueue.main.async {
                self.viewNetEarned.setRadius(color: Color.Theme.extraLightGray)
            }
        }
    }
    
    @IBOutlet weak var lblTotalEarned: UILabel!
    @IBOutlet weak var lblCompletedService: UILabel!
    @IBOutlet weak var lblCommision: UILabel!
    @IBOutlet weak var lblNetEarned: UILabel!
    @IBOutlet weak var lblTotalEarnedAmnt: UILabel!
    @IBOutlet weak var lblCompletedServiceAmnt: UILabel!
    @IBOutlet weak var lblCommisionAmnt: UILabel!
    @IBOutlet weak var lblNetEarnedAmnt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callFinancialInfo()
    }

    func setLang() {
        lblDescription.text = "Credits of ongoing projects, and that can be given to provider after task completion.".localized
        lblTotalEarned.text = "Total Earned".localized
        lblCompletedService.text = "Completed Services".localized
        lblCommision.text = "Commision".localized
        lblNetEarned.text = "Net Earned".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
        setUpUI()
    }
}

//MARK: Custom function
extension FinancialInfoVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Financial Information".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title: "Financial Information".localized, isBack: true, rightButton: false)
        
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callFinancialInfo() {
        self.lblTotalEarnedAmnt.text = ""
        self.lblCompletedServiceAmnt.text =  ""
        self.lblCommisionAmnt.text = ""
        self.lblNetEarnedAmnt.text = ""
        
        let param = ["user_id":UserData.shared.getUser()!.user_id]
        Modal.shared.getFinancialInfo(vc: self, param: param) { (dic) in
            let obj = FinancialInfo(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            print(obj.total_net_earned)
            self.lblTotalEarnedAmnt.text = "\(UserData.shared.currency)" + obj.total_earned
            self.lblCompletedServiceAmnt.text =  "\(obj.total_completed_service)"
            self.lblCommisionAmnt.text = "\(UserData.shared.currency)" + obj.total_commission
            self.lblNetEarnedAmnt.text = "\(UserData.shared.currency)" + obj.total_net_earned
        }
    }
}
