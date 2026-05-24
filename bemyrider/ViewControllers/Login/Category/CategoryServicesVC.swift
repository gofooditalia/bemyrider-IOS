//
//  CategoryServicesVC.swift
//  bemyrider
//
//  Created by admin on 8/19/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

var subCategory:String?

class CategoryServicesVC: UIViewController {

    static var storyboardInstance:CategoryServicesVC? {
        return StoryBoard.main.instantiateViewController(withIdentifier: CategoryServicesVC.identifier) as? CategoryServicesVC
    }
    @IBOutlet weak var collectionViewService: UICollectionView!{
        didSet{
            collectionViewService.delegate = self
            collectionViewService.dataSource = self
            collectionViewService.register(CategoryServicesCell.nib, forCellWithReuseIdentifier: CategoryServicesCell.identifier)
        }
    }
    var services = [ServiceList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryServices()
    }
}

//MARK: - API Calling
extension CategoryServicesVC{
    func categoryServices(){
        let param:[String:Any] = [
            "sub_category_id":subCategory ?? "" ,  "provider_id":newDeliveryProvider?.provider_id ?? ""]
        Modal.shared.popularService(vc: self, param: param) { (dic) in
            self.services = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({ServiceList(dictionary: $0 as! [String:Any])})
            self.collectionViewService.reloadData()
        }
    }
}

//MARK: - CollactionView Methods

extension CategoryServicesVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryServicesCell.identifier, for: indexPath) as? CategoryServicesCell else {
            fatalError()
        }
        cell.opeView.backgroundColor = .random()
        cell.opeView.alpha = 0.5
        cell.cellData = services[indexPath.row]
       
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((collectionViewService.bounds.width - 8) / 2)
        return CGSize(width: width, height: width)
//        return CGSize(width: CGFloat(collectionView.frame.size.width / 2 - 8), height: CGFloat(collectionView.frame.size.width / 2 - 16 ))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _:[String:Any] = [
            "user_id":UserData.shared.getUser()!.user_id,
            "service_id":services[indexPath.row].service_id,
            "search_lat":"",
            "search_long":"",
            "search_location":""]
//        let nextVC = SearachProviderVC.storyboardInstance!
        topTitle = services[indexPath.row].service_name
//        nextVC.paramList = param
//        nextVC.selectedService = services[indexPath.row]
//        self.navigationController?.pushViewController(nextVC, animated: true)
        
        callProviderServiceDetail(service_id: services[indexPath.row].provider_service_id,provider_id:services[indexPath.row].provider_id)
    }
    
    func callProviderServiceDetail(service_id:String,provider_id:String){
        Modal.shared.providerServiceDetail(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id, "provider_service_id":service_id,"loginuser_id":UserData.shared.getUser()!.user_id,"provider_id":provider_id, "delivery_type": "", "request_type": "scheduled"]) { (dic) in
            print(dic)
            is_from_myservices = false
            let nextVC = ServiceDetailHostingVC()
            //TODO: Used to set for inner four services views
            providerServiceDetail = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
//            providerDetails = self.providerList[row]
            topTitle = providerServiceDetail?.service_name
            nextVC.provider_service_id = service_id
            nextVC.provider_id = provider_id
            nextVC.deliveryType = ""
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}
