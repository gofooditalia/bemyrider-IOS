//
//  infoPageListVC.swift
//  bemyrider
//
//  Created by admin on 2/25/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit
import SafariServices

class infoPageListVC: NewBaseViewController {

//    MARK : Properties
    
    static var storyboardInstance:infoPageListVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: infoPageListVC.identifier) as? infoPageListVC
    }
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.tableFooterView = UIView()
            tableView.backgroundColor = .clear
        }
    }
    
    var infoPageList = [infoData]()
    
//    MARK:- API Calling
    
    func callInfoPageList() {
        Modal.shared.getcmsList(vc: self,param: [:]) { (dic) in
            print(dic)
            self.infoPageList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({ infoData(dictionary: $0 as! [String:Any]) })
            self.tableView.reloadData()
        }
    }
    
//    MARK: - ViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callInfoPageList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpUI()
    }
}

//MARK: Custom function
extension infoPageListVC {
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Info".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: "Info".localized, isBack: true, rightButton: false)
        
        
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        //sideMenuController?.showLeftView(animated: true, completionHandler: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: TableView Method

extension infoPageListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell")!
        cell.textLabel?.text = infoPageList[indexPath.row].pageTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoPageList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = infoPageDetailVC.storyboardInstance
        controller?.urlString = infoPageList[indexPath.row].pageUrl
        controller?.navTitle = infoPageList[indexPath.row].pageTitle
        self.navigationController?.pushViewController(controller!, animated: true)
    }
}
