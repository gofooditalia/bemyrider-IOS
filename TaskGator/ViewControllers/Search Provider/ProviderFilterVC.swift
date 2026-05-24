//
//  ProviderFilterVC.swift
//  TaskGator
//
//  Created by NCT 24 on 27/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import Cosmos
import SkyFloatingLabelTextField
// import RangeSeekSlider // Sostituito con RangeSliderView.swift
import GooglePlaces

 protocol ProviderFilterDelegate: AnyObject {
    func getFilterData(dic: [String:Any])
     func clearFilter()

}

class ProviderFilterVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:ProviderFilterVC? {
        return StoryBoard.searchProvider.instantiateViewController(withIdentifier: ProviderFilterVC.identifier) as? ProviderFilterVC
    }
    
    var latitude:String?
    var longitude:String?
    var minRange:String?
    var maxRange:String?
    var selectedDate:String?
    var starRating:String?
    var delegate: ProviderFilterDelegate?
    var paramList:[String:Any]!
    var selectedService:ServiceList?
    var searchAddrDic: [String: String] = [:]

    let categoryPickerView = UIPickerView()
    
    @IBOutlet weak var txtCategory: RightViewArrowTextField!{
        didSet{
            categoryPickerView.delegate = self
            txtCategory.inputView = categoryPickerView
            txtCategory.delegate = self
//            txtCategory.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "dropdown"))
            txtCategory.rightViewImage = #imageLiteral(resourceName: "dropdown")
//            txtCategory.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
//            txtCategory.setPlaceHolderColor(color: Color.Black.theam)
        }
    }
    
    let subCategoryPickerView = UIPickerView()
    @IBOutlet weak var txtSubCategory: RightViewArrowTextField!{
        didSet{
            subCategoryPickerView.delegate = self
            txtSubCategory.inputView = subCategoryPickerView
            txtSubCategory.delegate = self
            txtSubCategory.rightViewImage = #imageLiteral(resourceName: "dropdown")

//            txtSubCategory.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "dropdown"))
//            txtSubCategory.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
//            txtSubCategory.setPlaceHolderColor(color: Color.Black.theam)
        }
    }
    
    let servicePickerView = UIPickerView()
    @IBOutlet weak var txtService: RightViewArrowTextField!{
        didSet{
            servicePickerView.delegate = self
            txtService.inputView = servicePickerView
            txtService.delegate = self
//            txtService.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "dropdown"))
            txtService.rightViewImage = #imageLiteral(resourceName: "dropdown")

//            txtService.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
//            txtService.setPlaceHolderColor(color: Color.Black.theam)
        }
    }
    
    @IBOutlet weak var txtLocation: RightViewArrowTextField!{
        didSet{
//            txtLocation.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
//            txtLocation.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: UIImage(named: "map-white")?.withRenderingMode(.alwaysTemplate))
            txtLocation.rightViewImage = #imageLiteral(resourceName: "txt_location")
            txtLocation.delegate = self
        }
    }
    
    @IBOutlet weak var txtDate: RightViewArrowTextField!{
            didSet{
//                txtDate.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
                let pickerView =  UIDatePicker()
                pickerView.minimumDate = Date()
                pickerView.datePickerMode = .date
                if #available(iOS 13.4, *) {
                    pickerView.preferredDatePickerStyle = .wheels
                } else {
                    // Fallback on earlier versions
                }
                pickerView.addTarget(self, action: #selector(startTimeDiveChanged(_:)), for: .valueChanged)
                txtDate.inputView = pickerView
                txtDate.delegate = self
                txtDate.rightViewImage = #imageLiteral(resourceName: "dateIco")

//                txtDate.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "txt_calendar"))
            }
    }
    
    @IBOutlet weak var txtProviderName: RightViewArrowTextField!
    @IBOutlet weak var txtSearchKeyword: SkyFloatingLabelTextField!
    @IBOutlet weak var lblMinimumRating: UILabel!
    @IBOutlet weak var cosmosStarView: CosmosView!{
        didSet{
            cosmosStarView.didTouchCosmos = didTouchCosmos
            cosmosStarView.didFinishTouchingCosmos = didFinishTouchingCosmos
        }
    }
    
    @IBOutlet weak var lblRange: UILabel!
    
    @IBOutlet weak var btnApplyFilter: GreenButton!
    @IBOutlet weak var btnClearFilter: OrangeBorderButton!{
        didSet{
            btnClearFilter.border(side: .all, color: Color.Theme.purple, borderWidth: 1.0)
        }
    }
    
    // @IBOutlet fileprivate weak var rangeSlider: RangeSeekSlider! - RangeSeekSlider rimosso
    // Placeholder per il range slider (da implementare con UIKit custom se necessario)
    @IBOutlet weak var rangeSliderContainer: UIView!
    
    var rangeMinValue: Double = 0.0
    var rangeMaxValue: Double = 5010.0
    @IBOutlet weak var btnAsc: UIButton!
    @IBOutlet weak var btnDesc: UIButton!
    @IBOutlet weak var lblConstSort: UILabel!
    
    var categoryList = [Category]()
    var subCategoryList = [Category]()
    var serviceList = [ServiceList]()
    
    var selectedCategory: Category?
    var selectedSubCategory: Category?
    var sorting:String = ""
    
    @IBOutlet weak var lblSelectPrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        callCategoryAPI()
        callMinMaxRangeAPI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang(){
        txtCategory.placeholder = "Select Category*".localized
        txtSubCategory.placeholder = "Select Subcategory*".localized
        txtService.placeholder = "Select Service*".localized
        txtLocation.placeholder = "Location".localized
        txtDate.placeholder = "Select Date".localized
        txtProviderName.placeholder = "Courier Person Name".localized
        txtSearchKeyword.placeholder = "Search Keyword".localized
        lblMinimumRating.text = "Minimum Rating".localized
        lblSelectPrice.text = "Select Price".localized
        btnApplyFilter.setTitle("APPLY FILTER".localized, for: .normal)
        btnClearFilter.setTitle("CLEAR FILTER".localized, for: .normal)
        lblConstSort.text = "Sort".localized
    }
    
    @IBAction func onClickAsc(_ sender: UIButton) {
        btnAsc.setImage(#imageLiteral(resourceName: "checkedIco"), for: .normal)
        btnDesc.setImage(#imageLiteral(resourceName: "uncheckIco"), for: .normal)
        sorting = "asc"
    }
    
    @IBAction func onClickDesc(_ sender: UIButton) {
        btnDesc.setImage(#imageLiteral(resourceName: "checkedIco"), for: .normal)
        btnAsc.setImage(#imageLiteral(resourceName: "uncheckIco"), for: .normal)
        sorting = "desc"

    }
    
    
    @IBAction func onClickClearFIlter(_ sender: Any) {
        if let delegate = delegate{
            delegate.clearFilter()
        }
//        btnAsc.setImage(#imageLiteral(resourceName: "uncheckIco"), for: .normal)
//        btnDesc.setImage(#imageLiteral(resourceName: "uncheckIco"), for: .normal)

        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func onClickApplyFilter(_ sender: UIButton) {
        //"category_id", "subcategory_id", "search_provider_name", "search_keyword", "search_rating", "search_min_rate", "search_max_rate",
        //"search_service_date",
        let search_location = self.txtLocation.text ?? ""
        let _ = self.selectedCategory?.category_id ?? ""
        let _ = self.selectedService?.service_id ?? ""
        let _ = self.selectedSubCategory?.category_id ?? ""
        let _ = self.txtSearchKeyword.text ?? ""
        let search_provider_name = self.txtProviderName.text ?? ""
        
           
        let passDic = [
//            "category_id":category_id,
//            "subcategory_id": subcategory_id,
//            "service_id":service_id,
//            "search_provider_name": search_provider_name,
//            "search_keyword": search_keyword,'
            "search_keyword": search_provider_name,
            "search_rating": starRating ?? "",
//            "search_min_rate": minRange ?? "",
//            "search_max_rate": maxRange ?? "",
//            "search_service_date": selectedDate ?? "",
            "search_lat":latitude ?? "",
            "search_long":longitude ?? "",
            "search_location":search_location,
            "sort":sorting,
            ]
        if let latitude = latitude, !latitude.isEmpty, let longitude = longitude, !longitude.isEmpty{
            searchAddrDic = [
                "bookingLat":"\(latitude)",
                "bookingLong":"\(longitude)",
                "search_location":search_location,]
        }
        
        if let delegate = delegate{
            delegate.getFilterData(dic: passDic)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}

//MARK: Custom function
extension ProviderFilterVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Filter By".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: "Filter By".localized, isBack: true, rightButton: false)
        /*
        "search_lat":latitude!,
        "search_long":longitude!,
        "search_location":txtLocation.text!,]
        */
        
        latitude = paramList["search_lat"] as? String
        longitude = paramList["search_long"] as? String
        txtLocation.text = paramList["search_location"] as? String
        txtProviderName.text = paramList["search_keyword"] as? String
        
        
        starRating  = paramList["search_rating"] as? String
        if let doulbe  = Double(starRating ?? "0") {
            cosmosStarView.rating = doulbe

        }
        sorting = paramList["sort"] as? String ?? ""
        if sorting == "asc" {
            onClickAsc(btnAsc)
        }else if sorting == "desc" {
            onClickDesc(btnDesc)
        }
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
        //TODO: Notification fire
        
    }
    
    
    
    @objc func startTimeDiveChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd"
        formatter.dateStyle = .medium
        txtDate.text = formatter.string(from: sender.date)
        //timePicker.removeFromSuperview() // if you want to remove time picker
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd"
        selectedDate = formatter2.string(from: sender.date)
        print(selectedDate!)
    }
    
}

extension ProviderFilterVC{
    
    private func didTouchCosmos(_ rating: Double) {
        print(Float(rating))
        
    }
    
    private func didFinishTouchingCosmos(_ rating: Double) {
        print(Float(rating))
        starRating = "\(Float(rating))"
    }
    
    func callMinMaxRangeAPI() {
        Modal.shared.minmaxPrice(vc: self) { (dic) in
            /*
            "data": {
                "min_price": "1",
                "max_price": "5000",
                "min_duration": "",
                "max_duration": ""
            },
            */
            let rangeDic = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            self.minRange = rangeDic["min_price"] as? String ?? "0.0"
            self.maxRange = rangeDic["max_price"] as? String ?? "0.0"
            
            // rangeSlider rimosso - usa variabili locali
            self.rangeMinValue = Double(self.minRange!) ?? 0.0
            self.rangeMaxValue = Double(self.maxRange!) ?? 1000.0
            
            self.lblRange.text = "\(UserData.shared.currency)\(self.minRange!) - \(UserData.shared.currency)\(self.maxRange!)"
        }
    }
    
    func callCategoryAPI() {
        Modal.shared.getCatagoryList(vc: self,param: [:]) { (dic) in
            self.categoryList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({Category(dictionary: $0 as! [String:Any])})
            self.categoryList.sort{
                $0.category_name < $1.category_name
            }
            self.categoryPickerView.reloadAllComponents()
            
            //Auto selection
            if self.categoryList.count > 0{
                if let selectedService = self.selectedService{
                    let index = self.categoryList.index(where: { $0.category_id == selectedService.category_id })
                    if let i = index{
                        self.selectedCategory = self.categoryList[i]
                        self.txtCategory.text = self.selectedCategory!.category_name
                        self.callSubcategory()
                    }
                }
            }
        }
    }
    
    func callSubcategory() {
        if let selectedCategory = self.selectedCategory{
            Modal.shared.getSubcategoryList(vc: self, param: ["category_id": selectedCategory.category_id]) { (dic) in
                self.subCategoryList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({Category(dictionary: $0 as! [String:Any])})
                self.subCategoryList.sort{
                    $0.category_name < $1.category_name
                }
                self.subCategoryPickerView.reloadAllComponents()
                self.selectedSubCategory = nil
                self.txtSubCategory.text = nil
                
                //Auto selection
                if self.subCategoryList.count > 0{
                    self.selectedSubCategory = self.subCategoryList.first!
                    self.txtSubCategory.text = self.selectedSubCategory!.category_name
                    self.callServiceList()
                }
                
            }
        }
    }
    
    func callServiceList() {
        if let selectedSubCategory = self.selectedSubCategory{
            Modal.shared.getServiceList(vc: self, param: ["subcategory_id":selectedSubCategory.category_id]) { (dic) in
                self.serviceList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({ServiceList(dictionary: $0 as! [String:Any])})
                self.serviceList.sort{
                    $0.service_name < $1.service_name
                }
                self.servicePickerView.reloadAllComponents()
                self.selectedService = nil
                self.txtService.text = nil
                
                //Auto selection
                if self.serviceList.count > 0{
                    self.selectedService = self.serviceList.first!
                    self.txtService.text = self.selectedService!.service_name
                    //TODO: Change title for navigation bar
                    topTitle = self.selectedService!.service_name
                }
            }
        }
    }
}

// MARK: - RangeSeekSliderDelegate (rimosso)
// extension ProviderFilterVC: RangeSeekSliderDelegate {
//     func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
//         if slider === rangeSlider {
//             minRange = "\(minValue)"
//             maxRange = "\(maxValue)"
//             lblRange.text = "\(UserData.shared.currency)\(minRange!) - \(UserData.shared.currency)\(maxRange!)"
//         }
//     }
// }

extension ProviderFilterVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if txtLocation == textField {
            txtLocation.text = nil
            //https://developers.google.com/places/ios-api/
            //TODO: Display google place picker
            let ac = PlaceAutocompleteVC()
            ac.onPlaceSelected = { [weak self] (address: String, lat: Double, lng: Double) in
                self?.txtLocation.text = address
                self?.latitude  = "\(lat)"
                self?.longitude = "\(lng)"
            }
            present(UINavigationController(rootViewController: ac), animated: true)
            return false
        }
        else{
            return true
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if txtLocation == textField || textField == txtCategory || textField == txtSubCategory || textField == txtService {
            return false
        }
        else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtCategory {
            callSubcategory()
        }
        else if textField == txtSubCategory{
            callServiceList()
        }
        else if textField == txtService{
            if let selectedservice = selectedService{
                print(selectedservice.service_type)
            }
        }
    }
    
}

extension ProviderFilterVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPickerView{
            return categoryList.count + 1
        }
        else if pickerView == subCategoryPickerView{
            return subCategoryList.count + 1
        }
        else if pickerView == servicePickerView{
            return serviceList.count + 1
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPickerView{
            if categoryList.count > 0{
                if row > 0 {
                    selectedCategory = categoryList[row - 1]
                    let str = categoryList[row - 1].category_name
                    txtCategory.text = str
                }else{
                    txtCategory.text = ""//"Select Category"
                    txtSubCategory.text = ""
                    txtService.text = ""
                    selectedCategory = nil
                    selectedSubCategory = nil
                    selectedService = nil
                }
            }
        }
        else if pickerView == subCategoryPickerView{
            if subCategoryList.count > 0{
                if row > 0{
                    selectedSubCategory = subCategoryList[row - 1]
                    let str = subCategoryList[row - 1].category_name
                    txtSubCategory.text = str
                }else{
                    txtSubCategory.text = ""//"Select SubCategory"
                    txtService.text = ""
                    selectedSubCategory = nil
                    selectedService = nil
                }
            }
        }
        else if pickerView == servicePickerView{
            if serviceList.count > 0{
                if row > 0 {
                    selectedService = serviceList[row - 1]
                    let str = serviceList[row - 1].service_name
                    txtService.text = str
                    //TODO: Change title for navigation bar
                    topTitle = str
                }else{
                    txtService.text = ""//"Select Service"
                    selectedService = nil
                }
            }
        }
        else{
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        label.textAlignment = .center
        label.font = RobotoFont.regular(with: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        if pickerView == categoryPickerView{
            let str = row == 0 ? "Select Category" : categoryList[row - 1].category_name
            label.text = str
        }
        else if pickerView == subCategoryPickerView{
            let str = row == 0 ? "Select SubCategory" : subCategoryList[row - 1].category_name
            label.text = str
        }
        else if pickerView == servicePickerView{
            let str = row == 0 ? "Select Service" : serviceList[row - 1].service_name
            label.text = str
        }
        else{
        }
        return label
    }
}

