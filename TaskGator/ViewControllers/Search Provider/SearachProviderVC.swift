//
//  SearachProviderVC.swift
//  TaskGator
//
//  Created by NCT 24 on 25/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

var topTitle: String?
var providerServiceDetail:ProviderServiceDetail?
var providerDetails:ProviderListCls.ProviderList?
var providerService:ProviderService?

class SearachProviderVC: BaseViewController {

    //MARK: Properties
    static var storyboardInstance:SearachProviderVC? {
        return StoryBoard.searchProvider.instantiateViewController(withIdentifier: SearachProviderVC.identifier) as? SearachProviderVC
    }
    
    var providerListObj: ProviderListCls?
    var providerList = [ProviderListCls.ProviderList]()
    var paramList:[String:Any]!
    var filterDic:[String:Any]?
    var selectedService:ServiceList?
    
    @IBOutlet weak var imgNoRecords: UIImageView!
    @IBOutlet weak var lblProvider: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(SearchProviderCell.nib, forCellReuseIdentifier: SearchProviderCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            //tableView.allowsSelection = false
        }
    }
    
    deinit {
        print("SearachProviderVC is Distroy")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callProviderListAPI()
        NotificationCenter.default.addObserver(self, selector: #selector(changeInProviderList(notification:)), name: .providerDisLike, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}

//MARK: Custom function
extension SearachProviderVC {
    
    @objc func changeInProviderList(notification: Notification) {
        if (notification.object as! [String:Bool])["isProviderDislike"] ?? false{
            callProviderListAPI()
        }
    }
    
    func setUpUI() {
        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: topTitle!, action: #selector(onClickMenu(_:)), isRightBtn: true, actionRight: #selector(onClickFilter(_:)),btnRightImg: #imageLiteral(resourceName: "ic_filter"))
        lblProvider.text = "\(providerList.count)" + " provider(s) Found".localized
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onClickFilter(_ sender: UIButton){
        let nextVC = SearchHostingVC()
        nextVC.delegate = self
        nextVC.paramList = paramList
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
        //self.present(nextVC, animated: true, completion: nil)
    }
    
    func callProviderServiceDetail(row:Int){
        Modal.shared.providerServiceDetail(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id, "provider_service_id":providerList[row].provider_service_id,"loginuser_id":UserData.shared.getUser()!.user_id, "provider_id": providerList[row].provider_id, "delivery_type": "", "request_type": "scheduled"]) { (dic) in
            print(dic)
            let nextVC = ServiceDetailHostingVC()
            providerServiceDetail = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            providerDetails = self.providerList[row]
            is_from_myservices = false
            nextVC.provider_service_id = self.providerList[row].provider_service_id
            nextVC.provider_id = self.providerList[row].provider_id
            nextVC.deliveryType = providerServiceDetail?.delivery_type ?? ""
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func callProviderListAPI() {
        //"page"
        /*
        let passDic = [
            "category_id":category_id,
            "subcategory_id": subcategory_id,
            "service_id":service_id,
            "search_provider_name": search_provider_name,
            "search_keyword": search_keyword,
            "search_rating": starRating ?? "",
            "search_min_rate": minRange ?? "",
            "search_max_rate": maxRange ?? "",
            "search_service_date": selectedDate ?? "",
            "search_lat":latitude ?? "",
            "search_lon":longitude ?? "",
            "search_location":search_location]
        */
        
        let nextPage = (providerListObj?.pagination?.currentPage ?? 0 ) + 1
        print("nextPage: \(nextPage)")
        paramList["page"] = nextPage
        
        if let filterDic = self.filterDic{
            print("New Added param:*********")
            for (key,val) in filterDic{
                if !((val as! String).isEmpty){
                    paramList[key] = val
                    print("[\(key): \(val)]")
                }
            }
        }
        guard let capturedParamList = paramList else { return }
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let dic = try await APIClient.shared.getProviderList(params: capturedParamList)
                await MainActor.run {
                    self.providerListObj = ProviderListCls(dictionary: dic)
                    if self.providerList.count > 0 {
                        self.providerList += self.providerListObj!.providerList
                    } else {
                        self.providerList.removeAll()
                        self.providerList = self.providerListObj!.providerList
                    }
                    self.lblProvider.text = "\(self.providerList.count) provider(s) Found"
                    self.tableView.reloadData()
                    self.imgNoRecords.isHidden = self.providerList.count != 0
                }
            } catch {
                print(error)
            }
        }
    }
}

extension SearachProviderVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchProviderCell.identifier) as? SearchProviderCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.indexPath = indexPath
        cell.cellData = providerList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callProviderServiceDetail(row: indexPath.row)
    }
    
    func reloadMoreData() {
        if let providerListObj = providerListObj{
            if (providerListObj.pagination!.currentPage < providerListObj.pagination!.total_pages) {
                callProviderListAPI()
                print("call new page")
            }
        }
    }
}

extension SearachProviderVC{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print("scrollView.bounds.maxY: \(scrollView.bounds.maxY), scrollView.contentSize.height:\(scrollView.contentSize.height)")
        if scrollView.bounds.maxY >= scrollView.contentSize.height {
            reloadMoreData()
        }
    }
}

extension SearachProviderVC: ProviderFilterDelegate{
    func getFilterData(dic: [String : Any]) {
        if !(dic.isEmpty){
            filterDic = dic
            //reset pagination
            filterDic!["page"] = "1"
            self.providerList.removeAll()
            callProviderListAPI()
        }
    }
    func clearFilter() {
        
    }
}

