//
//  SubCategoryVC.swift
//  bemyrider
//
//  Created by admin on 8/19/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class SubCategoryVC: NewBaseViewController {
    static var storyboardInstance:SubCategoryVC? {
        return StoryBoard.main.instantiateViewController(withIdentifier: SubCategoryVC.identifier) as? SubCategoryVC
    }
    
    @IBOutlet weak var tblSubCategory: UITableView!{
        didSet{
            tblSubCategory.delegate = self
            tblSubCategory.dataSource = self
            tblSubCategory.register(CategoryCell.nib, forCellReuseIdentifier: CategoryCell.identifier)
        }
    }
    @IBOutlet weak var imgNoRecords: UIImageView!
    var subCategoryList = [Category]()
    var categoryId:String?
    var categoryTitle:String?
    var deliveryProvider:DeliveryProivderList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: categoryTitle ?? "", action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title: categoryTitle ?? "", isBack: true, rightButton: false)
        
        callSubcategory()
    }
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
        //sideMenuController?.hideLeftView(animated: true, completionHandler: nil)
    }
}
extension SubCategoryVC{
    func callSubcategory() {
        Modal.shared.getSubcategoryList(vc: self, param: ["category_id": categoryId ?? "","provider_id":deliveryProvider?.provider_id ?? ""]) { (dic) in
                self.subCategoryList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({Category(dictionary: $0 as! [String:Any])})
                self.tblSubCategory.reloadData()
            }
    }
}
extension SubCategoryVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            fatalError()
        }
        cell.cellData = subCategoryList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        subCategory = subCategoryList[indexPath.row].category_id
        
        let vc = CategoryDetaliVC.storyboardInstance!
        vc.subCategory = subCategoryList[indexPath.row]
        newDeliveryProvider = self.deliveryProvider
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
