//
//  NotificationSettings.swift
//  TaskGator
//
//  Created by NCT 24 on 24/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class NotificationSettings: NewBaseViewController {

    //MARK: Properties

    static var storyboardInstance:NotificationSettings? {
        return StoryBoard.notification.instantiateViewController(withIdentifier: NotificationSettings.identifier) as? NotificationSettings
    }
    @IBOutlet weak var imgNoRecords: UIImageView!
    @IBOutlet weak var constraintTableviewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(NotificationSettingCell.nib, forCellReuseIdentifier: NotificationSettingCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var btnSaveChanges: UIButton!
    
    @IBAction func onClickSaveChange(_ sender: UIButton) {
        callUpdateNotifiacationAPI()
    }
    var notificationList = [NotificationData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        callNotificationListAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        btnSaveChanges.setTitle("SAVE CHANGE".localized, for: .normal)
        
    }
}

//MARK: Custom function
extension NotificationSettings {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Notifications".localized, action: #selector(onClickMenu(_:)))
        self.setupNavigationBar(title: "Notification Settings".localized, isBack: true,rightButton: false)

        
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callNotificationListAPI() {
        let param = ["user_id":UserData.shared.getUser()!.user_id]
        Modal.shared.getNotificationList(vc: self, param: param) { (dic) in
            print(dic)
            self.notificationList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({NotificationData(dictionary: $0 as! [String:Any])})
            self.tableView.reloadData()
            if self.notificationList.count == 0{
                self.imgNoRecords.isHidden = false
            }else{
                self.imgNoRecords.isHidden = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.constraintTableviewHeight.constant = self.tableView.contentSize.height + 40
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    func callUpdateNotifiacationAPI(){
        var param = ["user_id":UserData.shared.getUser()!.user_id]
        for val in notificationList{
            param[val.id] = (val.checked == "true" ? "y" : "n")
        }
        Modal.shared.updateNotification(vc: self, param: param) { message in
            self.alert(title: "", message: message) {
                
            }

        } success: { dic in
            let message  = ResponseKey.fatchDataAsString(res: dic, valueOf: .message)

            self.alert(title: "", message: message) {
                self.navigationController?.popViewController(animated: true)
            }

        }

   
    }
}

extension NotificationSettings: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingCell.identifier) as? NotificationSettingCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.indexPath = indexPath
        cell.cellData = notificationList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
}
