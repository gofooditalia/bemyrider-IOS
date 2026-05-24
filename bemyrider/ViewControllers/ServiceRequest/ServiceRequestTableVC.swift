//
//  ServiceRequestTableVC.swift
//  bemyrider
//
//  Created by NCT 24 on 08/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SwiftUI

class ServiceRequestTableVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(ServiceRequestCell.nib, forCellReuseIdentifier: ServiceRequestCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.allowsSelection = true
            tableView.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width*0.25, bottom: 0, right: 0)
            tableView.separatorColor = Color.grey.deviderColor
            //tableView.bounces = false
            //tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var searchKeyboardView: UIView!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                //                self.searchKeyboardView.border(side: .bottom, color: Color.green.theam, borderWidth: 2)
            })
        }
    }
    
    @IBOutlet weak var txtSearchKeyboard: RightViewArrowTextField!{
        didSet{
            txtSearchKeyboard.delegate = self
            txtSearchKeyboard.placeholder = "Search Keyword".localized
        }
    }
    @IBOutlet weak var searchHideView: UIView!
    
    
    
    var serviceList = [CustomerServicesCls.CustomerServices](){
        didSet{
            //serviceList
        }
    }
    var providerServiceList = [ProviderServices]()
    
    var customerServicesObj: CustomerServicesCls?
    var providerServicesObj: ProviderServicesCls?
    
    var refreshControl = UIRefreshControl()
    var refreshList:Bool = true
    
    @IBOutlet weak var imgNoRecord: UIImageView!
    
    @objc func getService(notification: Notification) {
        if (notification.object as! [String: Any])["isReceive"] as? Bool ?? false{
            if let _ = providerServicesObj{
                self.customerServicesObj = nil
                self.providerServicesObj = nil
                self.providerServiceList.removeAll()
                self.serviceList.removeAll()
                tableView.reloadData()
                imgNoRecord.isHidden = false
            }
            callAPI(index: selectedTab)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearchKeyboard.placeholder = "Search Keyword".localized
        if Modal.sharedAppdelegate.isCustomerLogin{
            NotificationCenter.default.addObserver(self, selector: #selector(getService), name: .customerMyTask, object: nil)
            self.searchHideView.isHidden = true
        }
        else{
            NotificationCenter.default.addObserver(self, selector: #selector(getService), name: .providerMyTask, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(taskReload), name: .reloadProviderTasks, object: nil)
        
        self.customerServicesObj = nil
        self.providerServicesObj = nil
        self.providerServiceList.removeAll()
        self.serviceList.removeAll()
        tableView.reloadData()
        imgNoRecord.isHidden = false
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    @objc func refresh() {
        // Code to refresh table view
        self.serviceList.removeAll()
        self.self.providerServiceList.removeAll()
        self.tableView.reloadData()
        self.customerServicesObj = nil
        self.providerServicesObj = nil
        callAPI(index: selectedTab)
        
    }
    
    @objc func taskReload(){
        refreshList = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Load from first")
        if refreshList {
            refreshList = false
            refresh()
        }
    }
    @IBAction func onClickSearch(_ sender: UIButton) {
        providerServiceList.removeAll()
        providerServicesObj?.pagination?.currentPage = 0
        callAPI(index: selectedTab)
    }
    
}

//MARK: Custom function
extension ServiceRequestTableVC{
    
    func callAPI(index:Int) {
        if index == 0 {
            getUpcomingService()
        }else if index == 1 {
            getOngoingService()
        }else if index == 2 {
            getPastService()
        }
    }
    
    @objc func menuChange(notification: Notification) {
        print("Notification catch for tab change")
        let data = notification.object as! [String: Any]
        guard let index = data["selectedMenu"] as? Int else { return }
        if index == 0 {
            getUpcomingService()
        }else if index == 1 {
            getOngoingService()
        }else if index == 2 {
            getPastService()
        }
    }
    
    
    func callGetServiceAPI(param: [String:Any]){
        let nextPage = (customerServicesObj?.pagination?.currentPage ?? 0 ) + 1
        print("nextPage: \(nextPage)")
        var param = param
        param["page"] = nextPage
        Modal.shared.getService(vc: self, param: param, isLoader: true/*!(nextPage > 1)*/) { (dic) in
            self.customerServicesObj = CustomerServicesCls(dictionary: dic)
            if self.serviceList.count > 0{
                self.serviceList += self.customerServicesObj!.customerServicesList
            }
            else{
                self.serviceList.removeAll()
                self.serviceList = self.customerServicesObj!.customerServicesList
            }
            print(self.serviceList.count)
            
            if self.serviceList.count != 0 {
                self.tableView.reloadData()
            }
            else{
                //TODO: No Data available
                print("No Data available")
            }
            self.imgNoRecord.isHidden = self.serviceList.count > 0
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func callGetProviderServiceAPI(param: [String:Any]){
        let nextPage = (providerServicesObj?.pagination?.currentPage ?? 0 ) + 1
        print("nextPage: \(nextPage)")
        var param = param
        param["page"] = nextPage
        
        Modal.shared.providerTasks(vc: self, param: param, isLoader: true/*!(nextPage > 1)*/) { (dic) in
            self.providerServicesObj = ProviderServicesCls(dictionary: dic)
            if self.providerServiceList.count > 0{
                self.providerServiceList += self.providerServicesObj!.providerServicesList
            }
            else{
                self.providerServiceList.removeAll()
                self.providerServiceList = self.providerServicesObj!.providerServicesList
            }
            print(self.providerServiceList.count)
            
            if self.providerServiceList.count <= 0 {
                //TODO: No Data available
                print("No Data available")
            }
            self.imgNoRecord.isHidden = self.providerServiceList.count > 0
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            
        }
    }
    
    func reloadMoreData() {
        if Modal.sharedAppdelegate.isCustomerLogin{
            if let customerServicesObj = customerServicesObj{
                if (customerServicesObj.pagination!.currentPage < customerServicesObj.pagination!.total_pages) {
                    self.callAPI(index: selectedTab)
                    print("call new page")
                }
            }
        }else{
            if let providerServicesObj = self.providerServicesObj{
                if (providerServicesObj.pagination!.currentPage < providerServicesObj.pagination!.total_pages) {
                    self.callAPI(index: selectedTab)
                    print("call new page")
                }
            }
        }
    }
    
    //history / ongoing / past
    func getOngoingService() {
        let param = [
            "user_id" : UserData.shared.getUser()!.user_id,
            "tab" : "ongoing",
            "keyword":txtSearchKeyboard.text ?? ""
        ]
        print("ongoing")
        if Modal.sharedAppdelegate.isCustomerLogin{
            callGetServiceAPI(param: param)
        }
        else{
            callGetProviderServiceAPI(param: param)
        }
    }
    
    func getPastService() {
        let param = [
            "user_id" : UserData.shared.getUser()!.user_id,
            "tab" : "past",
            "keyword":txtSearchKeyboard.text ?? ""
        ]
        print("past")
        if Modal.sharedAppdelegate.isCustomerLogin{
            callGetServiceAPI(param: param)
        }
        else{
            callGetProviderServiceAPI(param: param)
        }
    }
    
    func getUpcomingService() {
        let param = [
            "user_id" : UserData.shared.getUser()!.user_id,
            "tab" : "history",
            "keyword":txtSearchKeyboard.text ?? ""
        ]
        print("history")
        if Modal.sharedAppdelegate.isCustomerLogin{
            callGetServiceAPI(param: param)
        }
        else{
            callGetProviderServiceAPI(param: param)
        }
    }
    
    func callProviderServiceDetail(row:Int){
        if Modal.sharedAppdelegate.isCustomerLogin{
            topTitle = self.serviceList[row].service_name
            let nextVC = CustomerSideServiceDetailHostingVC()
            nextVC.providerServiceId = serviceList[row].provider_service_id
            nextVC.serviceRequestId = serviceList[row].service_request_id
            nextVC.customerItem = self.serviceList[row]
            nextVC.hidesBottomBarWhenPushed = true
            customerSide_ProviderDetails = self.serviceList[row]
            self.navigationController?.pushViewController(nextVC, animated: true)
            
        }else{//Provider side
            let nextVC = ProviderSideServiceDetailHostingVC()
            topTitle = self.providerServiceList[row].service_name
            providerSide_ProviderDetails = self.providerServiceList[row]
            nextVC.serviceRequestId = self.providerServiceList[row].service_request_id
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func redirectToProviderServiceDetail(row:Int){
        let nextVC = ProviderSideServiceDetailHostingVC()
        topTitle = self.providerServiceList[row].service_name
        providerSide_ProviderDetails = self.providerServiceList[row]
        nextVC.serviceRequestId = self.providerServiceList[row].service_request_id
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension ServiceRequestTableVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceRequestCell.identifier) as? ServiceRequestCell else {
            fatalError("Cell can't be dequeue")
        }
        if Modal.sharedAppdelegate.isCustomerLogin{
            cell.cellData = serviceList[indexPath.row]
        }
        else{
            cell.cellDataOfProvide = providerServiceList[indexPath.row]
        }
        //reloadMoreData(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  (Modal.sharedAppdelegate.isCustomerLogin ? serviceList.count : providerServiceList.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callProviderServiceDetail(row: indexPath.row)
        //        if Modal.sharedAppdelegate.isCustomerLogin{
        //            callProviderServiceDetail(row: indexPath.row)
        //        }
        //        else{
        //            redirectToProviderServiceDetail(row: indexPath.row)
        //        }
    }
}

extension ServiceRequestTableVC{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print("scrollView.bounds.maxY: \(scrollView.bounds.maxY), scrollView.contentSize.height:\(scrollView.contentSize.height)")
        if scrollView.bounds.maxY >= scrollView.contentSize.height {
            reloadMoreData()
        }
    }
}


extension ServiceRequestTableVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.customerServicesObj = nil
        self.providerServicesObj = nil
        self.providerServiceList.removeAll()
        self.serviceList.removeAll()
        tableView.reloadData()
        imgNoRecord.isHidden = false
        
        callAPI(index: selectedTab)
        return textField.resignFirstResponder()
    }
}
