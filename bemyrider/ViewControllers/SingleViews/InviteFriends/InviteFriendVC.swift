//
//  InviteFriendVC.swift
//  bemyrider
//
//  Created by NCT 24 on 19/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class InviteFriendVC: NewBaseViewController {

    //MARK: Properties

    static var storyboardInstance:InviteFriendVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: InviteFriendVC.identifier) as? InviteFriendVC
    }
    
    
    var inviteFriendsList:[InviteFriends] = []
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(InviteFriendCell.nib, forCellReuseIdentifier: InviteFriendCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var btnInviteFriend: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callInviteFriendListAPI()
        setLang()
    }
    
    func setLang() {
        btnInviteFriend.setTitle("Invite Friend".localized, for: .normal)
        
    }
    
    @IBAction func onClickInviteFriend(_ sender: UIButton) {
        //self.navigationController?.pushViewController(SendInviteVC.storyboardInstance!, animated: true)
    }
    
}

//MARK: Custom function
extension InviteFriendVC {
    
    func callInviteFriendListAPI(){
        Modal.shared.inviteHistory(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id, "user_type": UserData.shared.getUser()!.user_type]) { (dic) in
            self.inviteFriendsList.removeAll()
            self.inviteFriendsList = ResponseKey.fatchData(res: dic, valueOf: .data).ary.map({InviteFriends(dic: $0 as! [String:Any])})
            self.tableView.reloadData()
            //print(ary[0].invite_date)
        }
    }
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Invite Friends".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: "Invite Friends".localized, isBack: true, rightButton: false)
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension InviteFriendVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InviteFriendCell.identifier) as? InviteFriendCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.cellData = inviteFriendsList[indexPath.row]
        cell.lblEmail.text = "Email".localized
        cell.lblStatus.text = "Status".localized
        cell.lblCreditEarned.text = "Credit Earned".localized
        cell.lblInviteDate.text = "Invite Date".localized
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inviteFriendsList.count
    }
    
    
}
