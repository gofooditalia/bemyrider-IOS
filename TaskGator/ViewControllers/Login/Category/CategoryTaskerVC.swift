//
//  CategoryTaskerVC.swift
//  TaskGator
//
//  Created by admin on 8/19/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

class CategoryTaskerVC: UIViewController {

    static var storyboardInstance:CategoryTaskerVC? {
        return StoryBoard.main.instantiateViewController(withIdentifier: CategoryTaskerVC.identifier) as? CategoryTaskerVC
    }
    
    @IBOutlet weak var tblTasker: UITableView!{
        didSet{
            tblTasker.delegate = self
            tblTasker.dataSource = self
            tblTasker.register(CategoryTaskersCell.nib, forCellReuseIdentifier: CategoryTaskersCell.identifier)
            tblTasker.tableFooterView = UIView()
        }
    }
    var tasker = [PopularTasker]()
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTasker()
        // Do any additional setup after loading the view.
    }
}
//MARK: - API Calling

extension CategoryTaskerVC{
    func categoryTasker(){
        let param:[String:Any] = [
            "subcategory_id":subCategory ?? "",
            "user_id":UserData.shared.getUser()!.user_id
        ]
        Modal.shared.popularTask(vc: self, param: param) { (dic) in
            print(dic)
            self.tasker = ResponseKey.fatchData(res: dic, valueOf: .data).ary.map({PopularTasker(dictionary: $0 as! [String:Any])})
            self.tblTasker.reloadData()
        }
    }
}
extension CategoryTaskerVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasker.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTaskersCell.identifier, for: indexPath) as? CategoryTaskersCell else {
            fatalError()
        }
        cell.cellData = tasker[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CustomerSideProviderProfileVC.storyboardInstance
        vc?.providerId = tasker[indexPath.row].userid
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
}
