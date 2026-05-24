//
//  CategoryVC.swift
//  bemyrider
//
//  Created by admin on 8/19/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class CategoryVC: NewBaseViewController {

    static var storyboardInstance:CategoryVC? {
        return StoryBoard.main.instantiateViewController(withIdentifier: CategoryVC.identifier) as? CategoryVC
    }
    
    @IBOutlet weak var tblCategory: UITableView!{
        didSet{
            tblCategory.delegate = self
            tblCategory.dataSource = self
            tblCategory.register(CategoryCell.nib, forCellReuseIdentifier: CategoryCell.identifier)
        }
    }
    @IBOutlet weak var imgNoRecords: UIImageView!
    
    var categoryList = [Category]()
    var deliveryProvider:DeliveryProivderList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = deliveryProvider else {
            self.navigationController?.popViewController(animated: true)
            return
        }

//        setUpNavigation(vc: self, isBackButton: true, navigationTitle: "Category".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title: "Category".localized, isBack: true, rightButton: false)
        
        
//        self.navigationController?.navigationBar.isHidden = false
//        self.setupNavigationBar(title: "Category".localized, isBack: true)
        callCategoryAPI()
        callVersionCheckAPI()
        // Open Notification in case of click on push when application launch
        self.sharedAppdelegate.processNotification()
        
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
//        sideMenuController?.showLeftView(animated: true)
        //sideMenuController?.hideLeftView(animated: true, completionHandler: nil)
    }
}

extension CategoryVC{
    func callCategoryAPI() {
        Modal.shared.getCatagoryList(vc: self, param: ["provider_id":self.deliveryProvider!.provider_id]) { message in
            if self.categoryList.count == 0 {
                self.imgNoRecords.isHidden = false
                self.tblCategory.isHidden = true
            }
        } success: { dic in
            self.imgNoRecords.isHidden = true
            self.tblCategory.isHidden = false
            self.categoryList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({Category(dictionary: $0 as! [String:Any])})
            self.tblCategory.reloadData()
        }
    }
    
    func callVersionCheckAPI(){
           Modal.shared.getSiteSettings(vc: self, param: [:], failer: { (message) in
               //  Error Handle
               print(message)
           }) { (dict) in
               // Data
               print(dict)
               let data = dict["data"] as? [String:Any] ?? [:]
               if let app_version = data["app_version"] as? String {
                   if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                       if let web = Double(app_version),let app =  Double(version), app < web {
                           // Show Alert
                           if let storeUrl = data["store_url"] as? String , storeUrl.contains(string: "apps.apple.com") {
                               Util.showUpgradeBox(vc: self, storeUrl: storeUrl)
                           }
                       }
                   }
               }
           }
       }
}

extension CategoryVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            fatalError()
        }
        cell.cellData = categoryList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SubCategoryVC.storyboardInstance
        vc?.categoryId = categoryList[indexPath.row].category_id
        vc?.categoryTitle = categoryList[indexPath.row].category_name
        vc?.deliveryProvider = self.deliveryProvider
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
