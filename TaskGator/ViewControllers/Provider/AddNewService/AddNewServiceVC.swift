//
//  AddNewServiceVC.swift
//  TaskGator
//
//  Created by NCT 24 on 30/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Photos



class AddNewServiceVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:AddNewServiceVC? {
        return StoryBoard.provider.instantiateViewController(withIdentifier: AddNewServiceVC.identifier) as? AddNewServiceVC
    }
    
    var categoryList = [Category]()
    var subCategoryList = [Category]()
    var serviceList = [ServiceList]()
    var hoursList = [String]()
    var arrImages = [ProviderServiceDetail.MediaData]()
    var selectedCategory: Category?
    var selectedSubCategory: Category?
    var selectedService: ServiceList?
    var selectedHours: String?
    
    //New data
    //var serviceDescription: String?
    var serviceType : String?
    var servicePrice : String?
    var pickedImage:UIImage?
    var pickedImageName:String?
    var isEdit : Bool?
    
    var pickedImageAry = [UIImage](){
        didSet{
            //self.collectionView.reloadData()
            //self.setAutoHeight()
        }
    }
    var pickedImageNameAry = [String]()
    let categoryPickerView = UIPickerView()
    @IBOutlet weak var txtCategory: RightViewArrowTextField!{
        didSet{
            categoryPickerView.delegate = self
            txtCategory.inputView = categoryPickerView
            txtCategory.delegate = self
            txtCategory.rightViewImage = #imageLiteral(resourceName: "downArrow")
            txtCategory.setPlaceHolderColor(color: Color.Black.theam)
        }
    }
    
    let subCategoryPickerView = UIPickerView()
    @IBOutlet weak var txtSubCategory: RightViewArrowTextField!{
        didSet{
            subCategoryPickerView.delegate = self
            txtSubCategory.inputView = subCategoryPickerView
            txtSubCategory.delegate = self
            txtSubCategory.rightViewImage = #imageLiteral(resourceName: "downArrow")
            txtSubCategory.setPlaceHolderColor(color: Color.Black.theam)
        }
    }
    
    let servicePickerView = UIPickerView()
    @IBOutlet weak var txtService: RightViewArrowTextField!{
        didSet{
            servicePickerView.delegate = self
            txtService.inputView = servicePickerView
            txtService.delegate = self
            txtService.rightViewImage = #imageLiteral(resourceName: "downArrow")
            txtService.setPlaceHolderColor(color: Color.Black.theam)
        }
    }
    
    let hoursPickerView = UIPickerView()
    @IBOutlet weak var txtHours: RightViewArrowTextField!{
        didSet{
            hoursPickerView.delegate = self
            txtHours.inputView = hoursPickerView
            txtHours.delegate = self
            txtHours.rightViewImage = #imageLiteral(resourceName: "downArrow")
            txtHours.setPlaceHolderColor(color: Color.Black.theam)
            txtHours.isHidden = true
        }
    }
    
    @IBOutlet weak var btnSubmit: GreenButton!
    @IBOutlet weak var txtPrice: RobotoRegular14TextField!{
        didSet{
            txtPrice.delegate = self
            txtPrice.maxLength = 4
        }
    }
    @IBOutlet weak var txtUploadImg: RightViewArrowTextField!{
        didSet{
            txtUploadImg.isUserInteractionEnabled = false
            txtUploadImg.leftViewImage = #imageLiteral(resourceName: "uploadIco")

        }
    }
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            //textView.border(side: .bottom, color: Color.grey.light, borderWidth: 2.0)
            textView.placeholder = "Vehicle Model and Equipment*".localized
            (textView.viewWithTag(100) as! UILabel?)?.textColor = Color.Black.theam
            DispatchQueue.main.async {
                self.textView.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
            }
        }
    }
    @IBOutlet weak var btnUpload: UIButton!
    
    var picker:UIImagePickerController!{
        didSet{
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.isScrollEnabled = false
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(AddNewServiceImageCell.nib, forCellWithReuseIdentifier: AddNewServiceImageCell.identifier)
        }
    }
    
    @IBOutlet weak var constCollectioViewHeight: NSLayoutConstraint!
    
    func setLang() {
        
        if let _ = providerServiceDetail, let _ = providerService{
            btnSubmit.setTitle("SUBMIT".localized, for: .normal)
            txtUploadImg.placeholder = "Upload Image".localized
            
        }
        else{
            txtCategory.placeholder = "Select Category*".localized
            txtSubCategory.placeholder = "Select SubCategory*".localized
            txtService.placeholder = "Select Service*".localized
            txtHours.placeholder = "Select Hours*".localized
            txtPrice.placeholder = "Enter Price*".localized
            txtUploadImg.placeholder = "Upload Image".localized
            btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
        setUpUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Pre loaded images
        if isEdit == true {
            if let media_data = providerServiceDetail?.media_data, media_data.count != 0 {
                arrImages = media_data
                collectionView.reloadData()
                self.setAutoHeight()
            }
        }
        
        callCategoryAPI()
        //hoursList fillUp
        for i in 1...2{
            hoursList.append("\(i)")
        }
    }
    
//    func setLang(){
//        txtCategory.placeholder = "\(localizedString(key: "Select Category"))*"
//        txtSubCategory.placeholder = "\(localizedString(key: "Select Subcategory"))*"
//        txtService.placeholder = "\(localizedString(key: "Select Service"))*"
//        txtHours.placeholder = "\(localizedString(key: "Select Hours"))*"
//        if isEdit == true{
//            if providerServiceDetail?.service_master_type == "fixed" {
//                txtPrice.placeholder = "\(localizedString(key: "Select Price(HRK)/fixed"))*"
//            }else{
//                txtPrice.placeholder = "\(localizedString(key: "Select Price(HRK)/hourly"))*"
//            }
//        }else{
//            txtPrice.placeholder = "\(localizedString(key: "Select Price(HRK)"))*"
//        }
//        txtUploadImg.placeholder = "\(localizedString(key: "Upload Image"))*"
//        btnSubmit.setTitle(localizedString(key: "SUBMIT"), for: .normal)
//    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        if isValidated() {
            callAddService()
        }
    }
    
    @IBAction func onClickUploadPhoto(_ sender: UIButton) {
        print("onClickUploadPhoto")
        pickImage()
    }
}

//MARK: Custom function
extension AddNewServiceVC {
    
    func setUpUI() {
        if isEdit == true {
//            setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Edit Service".uppercased().localized.capitalized, action: #selector(onClickMenu(_:)))
            self.applyStatusbar(color: Color.Theme.purple)
                 self.setupNavigationBar(title: "Edit Service".uppercased().localized.capitalized, isBack: true, rightButton: false)
            
            if let providerServiceDetail = providerServiceDetail, let providerService = providerService{
                txtPrice.text = providerServiceDetail.price //servicePrice
                //textView.text = serviceDescription
                //textView.resetPlaceHolder()
                txtCategory.text = providerServiceDetail.category_name
                txtSubCategory.text = providerServiceDetail.sub_category_name
                txtService.text = providerServiceDetail.service_name
                textView.text = providerServiceDetail._description
                textView.resetPlaceHolder()
                //TODO: set visibility of hours textField
                self.txtHours.isHidden = (providerService.service_type == "hourly" ? true : false)
                if !self.txtHours.isHidden{
                    txtHours.text = "\(providerServiceDetail.provider_service_hours) Hour"
                    selectedHours = providerServiceDetail.provider_service_hours
                }
            }
        }else{
//            setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Add New Service".localized, action: #selector(onClickMenu(_:)))
            self.applyStatusbar(color: Color.Theme.purple)
                 self.setupNavigationBar(title:  "Add New Service".localized, isBack: true, rightButton: false)
        }
//        txtHours.text = "Can't Estimate"
//        selectedHours = "Can't Estimate"
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func setAutoHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.constCollectioViewHeight.constant = self.collectionView.contentSize.height
            self.collectionView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    func isValidated() -> Bool {
        var ErrorMsg = ""
        if (txtCategory.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! { //selectedCategory == nil //(txtCategory.text?.isEmpty)! {
            ErrorMsg = "Please select Category".localized
        }
        else if (txtSubCategory.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! { //selectedSubCategory == nil //(txtSubCategory.text?.isEmpty)! {
            ErrorMsg = "Please select SubCategory".localized
        }
        else if (txtService.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! { //selectedService == nil //(txtService.text?.isEmpty)! {
            ErrorMsg = "Please select Service".localized
        }
        else if (txtHours.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! , !(txtHours.isHidden) {
            ErrorMsg = "Please select hours".localized
        }
        else if (txtPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter Price".localized
        }
        else if (textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter Vehicle Model and Equipment".localized
        }
        if ErrorMsg != "" {
            let alert = UIAlertController(title: "Error".localized, message: ErrorMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
    
    func callCategoryAPI() {
        Modal.shared.getCatagoryList(vc: self, param: [:]) { (dic) in
            self.categoryList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({Category(dictionary: $0 as! [String:Any])})
            self.categoryList.sort{
                $0.category_name < $1.category_name
            }
            self.categoryPickerView.reloadAllComponents()
            
            if self.isEdit == false || self.isEdit == nil{
                //Auto selection
                if self.categoryList.count > 0{
                   // self.selectedCategory = self.categoryList.first!
//                    self.txtCategory.text = self.selectedCategory!.category_name
                }
            }
            self.callSubcategory()
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
                self.txtSubCategory.text = ""

                //Auto selection
                if self.isEdit == false || self.isEdit == nil {
                    if self.subCategoryList.count > 0{
                       // self.selectedSubCategory = self.subCategoryList.first!
//                        self.txtSubCategory.text = self.selectedSubCategory!.category_name
                    }
                }
                self.callServiceList()
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
                self.txtService.text = ""

                //Auto selection
                if self.isEdit == false || self.isEdit == nil{
                    if self.serviceList.count > 0{
                       // self.selectedService = self.serviceList.first!
//                        self.txtService.text = self.selectedService!.service_name
                        
                        if let selectedservice = self.selectedService{
                            self.txtHours.isHidden = (selectedservice.service_type == "hourly" ? true : false)
                            print(selectedservice.service_type)
                        }
                    }
                }
            }
        }
    }
    
    func callAddService() {
        //provider_service_id //for edit service
        
        var param: [String:Any]
        if isEdit == true {
            if txtCategory.text == providerServiceDetail?.category_name {
                param = ["provider_service_id" : providerService!.provider_service_id,
                         "user_id": UserData.shared.getUser()!.user_id,
                         "service_id": providerServiceDetail!.service_id,
                         "category_id":providerServiceDetail!.category_id,
                         "subcategory_id":providerServiceDetail!.subcategory_id,
                         //"hours":selectedHours ?? "0",
                         "price":txtPrice.text!,
                         "description":textView.text!,
                         ]
            }else{
                param = ["provider_service_id" : providerService!.provider_service_id,
                         "user_id": UserData.shared.getUser()!.user_id,
                         "service_id": selectedService!.service_id,
                         "category_id":selectedCategory!.category_id,
                         "subcategory_id":selectedSubCategory!.category_id,
                         //"hours":selectedHours ?? "0",
                         "price":txtPrice.text!,
                         "description":textView.text!,
                         ]
                
                if !self.txtHours.isHidden{
                //if let selectedservice = selectedService, selectedservice.service_type == "hourly"{
                    param["hours"] = selectedHours ?? "0"
                }
                
            }
        }else{
            param = [
                "user_id": UserData.shared.getUser()!.user_id,
                "service_id": selectedService!.service_id,
                "category_id":selectedCategory!.category_id,
                "subcategory_id":selectedSubCategory!.category_id,
                //"hours":selectedHours ?? "0",
                "price":txtPrice.text!,
                "description":textView.text!,
                
                ]
            
            if !self.txtHours.isHidden{
            //if let selectedservice = selectedService, selectedservice.service_type == "hourly"{
                param["hours"] = selectedHours ?? "0"
            }
        }
        Modal.shared.addMyServices(vc: self, param: param, withPostImageAry: pickedImageAry, withPostImageNameAry: pickedImageNameAry) { (dic) in
            print(dic)
            NotificationCenter.default.post(name: .isAddService, object: ["isAddService":true] as [String:Any])
            self.navigationController?.popViewController(animated: true)
            //let nextVC = MyServiceVC.storyboardInstance!
            //self.navigationController?.pushViewController(nextVC, animated: false)
        }
    }
    
    func openSettingForGivePermissionCamera() {
        self.alert(title: "", message: "Camera access required for capturing photos!".localized, actions: ["Cancel".localized,"Settings".localized], completion: { (flag) in
            if flag == 1{ //Setting
                self.open(scheme:UIApplicationOpenSettingsURLString)
            }
            else{//Cancel
            }
        })
    }
    
    func checkCamera() {
        //https://stackoverflow.com/questions/27646107/how-to-check-if-the-user-gave-permission-to-use-the-camera
        //https://stackoverflow.com/questions/27646107/how-to-check-if-the-user-gave-permission-to-use-the-camera/27646311
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            openCamera() // Do your stuff here i.e. callCameraMethod()
        case .denied, .restricted:
            openSettingForGivePermissionCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    self.openCamera()
                } else {
                    //access denied
                    self.openSettingForGivePermissionCamera()
                }
            })
        }
    }
    
    func checkCameraPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            openCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    self.openCamera()
                } else {
                    //access denied
                    self.alert(title: "", message: "Camera access required for capturing photos!".localized, actions: ["Cancel".localized,"Settings".localized], completion: { (flag) in
                        if flag == 1{ //Setting
                            self.open(scheme:UIApplicationOpenSettingsURLString)
                        }
                        else{//Cancel
                        }
                    })
                }
            })
        }
    }
    
    func openCamera()  {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.picker = UIImagePickerController()
            self.picker.delegate = self
            self.picker.sourceType = .camera
            self.picker.allowsEditing = true
            self.present(self.picker, animated: true, completion: nil)
        }
        else{
            self.alert(title: "Alert".localized, message: "Camera is not available in this device".localized)
        }
    }
    
    func pickImage() {
        let captureAction = UIAlertAction(title: "Capture".localized, style: .default, handler: { (action) -> Void in
            print("Capture Button Pressed")
            self.checkCamera() //checkCameraPermission()
        })
        let selectImageFromGalleryAction = UIAlertAction(title: "From Gallery".localized, style: .default, handler: { (action) -> Void in
            print("Select Image From Gallery Button Pressed")
            self.picker = UIImagePickerController()
            self.picker.openGallery(vc: self)
        })
        showActionSheetWithTitle(title: "Select Image".localized, actions: [captureAction, selectImageFromGalleryAction])
    }
    
    func showActionSheetWithTitle(title:String, actions:[UIAlertAction]) {
        let actionSheet = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
        for action in actions {
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        
        //For iPad display actionsheet
        actionSheet.popoverPresentationController?.sourceRect = btnUpload.frame
        actionSheet.popoverPresentationController?.sourceView = self.view
        self.present(actionSheet, animated: true, completion: nil)
    }
    
}

extension AddNewServiceVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //1
        var selectedImage: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage]   as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        //2
        if let selectedImage = selectedImage {
            pickedImageName = picker.getPickedFileName(info: info) ?? "image.jpeg"
            //txtUploadImg.text = pickedImageName
            
            //TODO: If ImageCropper Used then comment below line
            //self.pickedImage = selectedImage
            
            if let imageSizeInfo = selectedImage.getFileSize() {
                print("\(imageSizeInfo), \(type(of: imageSizeInfo))") // 5.9 MB, String
                if imageSizeInfo > 2.0 {
                    self.pickedImageAry.append(selectedImage.resized(withPercentage: 0.3)!)
                }else{
                    self.pickedImageAry.append(selectedImage)
                }
            }else{
                self.pickedImageAry.append(selectedImage)
            }
            
            self.pickedImageNameAry.append(pickedImageName!)
            if isEdit  == true {
                var dict:[String:Any] = [:]
                dict["media_image"] = selectedImage
                dict["media_name"] = pickedImageName
                let objAry = ProviderServiceDetail.MediaData(dic: dict)
                arrImages.append(objAry)
            }
            self.collectionView.reloadData()
            self.setAutoHeight()
        }
        else{
            print("Something went wrong")
        }
        //3
        //dismiss(animated: true, completion: nil)
        dismiss(animated: false) {
            
            /*
             if let selectedImages = selectedImage {
             let imageCropper = ImageCropper.storyboardInstance
             imageCropper.delegate = self
             imageCropper.image = selectedImages
             self.present(imageCropper, animated: false, completion: nil)
             }
             */
        }
    }
}

//MARK: ImageCropper Class
extension AddNewServiceVC: ImageCropperDelegate{
    
    func didCropImage(originalImage: UIImage, cropImage: UIImage) {
        self.pickedImage = cropImage
    }
    
    func didCancel() {
        print("Cancel Crop Image")
    }
    
}

extension AddNewServiceVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtCategory || textField == txtSubCategory || textField == txtService || textField == txtHours{
            return false
        }
        else if textField == txtPrice {
            
            let inverseSet = CharacterSet(charactersIn:".0123456789").inverted
            let components = string.components(separatedBy: inverseSet)
            let _ = components.joined(separator: "")

                       
            if (textField.text?.contains("."))!, string.contains(".") {
               return false
            }else if string.contains(".") {
                return true
            }
            
            else if string == "" && txtPrice.text!.count > 0 {
                return true
            }
            else if  let textFieldString = textField.text, let range = Range(range, in: textFieldString)  {
                let newString = textFieldString.replacingCharacters(in: range, with: string)
                if let price = Double(newString)  , price >= 1.0 && price <= 12.5  {
                    return true
                }else{
                    return false
                }
            }
            else{
                return false
            }
        }
        else {
            return true
        }
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == self.tfYear || textField == self.tfMonths {
//            guard let textFieldString = textField.text, let range = Range(range, in: textFieldString) else {
//                return false
//            }
//            let newString = textFieldString.replacingCharacters(in: range, with: string)
//            if newString.isEmpty {
//                textField.text = "0"
//                return false
//            }else if textField.text == "0" {
//                textField.text = string
//                return false
//            }else if textField == self.tfMonths {
//                //let months = Int(self.tfMonths.text) ?? 0
//                if (Int(newString) ?? 0) > 11 {
//                    return false
//                }
//
//                return true
//            }
//        }
//
//        return true
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtCategory {
            callSubcategory()
        }
        else if textField == txtSubCategory{
            callServiceList()
        }
        else if textField == txtService{
            if let selectedservice = selectedService{
                txtHours.isHidden = (selectedservice.service_type == "hourly" ? true : false)
                print(selectedservice.service_type)
            }
        }
    }
    
}

extension AddNewServiceVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        else if pickerView == hoursPickerView{
            return hoursList.count + 1
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPickerView{
            if categoryList.count > 0{
                if row > 0{
                    selectedCategory = categoryList[row - 1]
                    let str = categoryList[row - 1].category_name
                    txtCategory.text = str
                    if self.isEdit == false || self.isEdit == nil{
                        callSubcategory()
                    }
                }else{
                    txtCategory.text = ""//"Select Category"
                }
            }
        }
        else if pickerView == subCategoryPickerView{
           
                if subCategoryList.count > 0{
                     if row > 0{
                    selectedSubCategory = subCategoryList[row - 1]
                    let str = subCategoryList[row - 1].category_name
                    txtSubCategory.text = str
                    if self.isEdit == false || self.isEdit == nil{
                        callServiceList()
                    }
                }else{
                    txtSubCategory.text = ""//"Select SubCategory"
                }
            }
        }
        else if pickerView == servicePickerView{
            if serviceList.count > 0{
                if row > 0{
                    selectedService = serviceList[row - 1]
                    let str = serviceList[row - 1].service_name
                    txtService.text = str
                }else{
                    txtService.text = ""//"Select Service Name"
                }
            }
        }
        else if pickerView == hoursPickerView{
            if hoursList.count > 0{
                if row > 0 {
                    selectedHours = hoursList[row - 1]
                    if row == 1 {
                        let str = "\(hoursList[row - 1]) \("Hour".localized)"
                        txtHours.text = str
                    }else{
                        let str = "\(hoursList[row - 1]) \("Hours".localized)"
                        txtHours.text = str
                    }
                }else{
                    txtHours.text = ""//"Service Houre"
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
            let str = row == 0 ? "Select Category*".localized : categoryList[row - 1].category_name
            label.text = str
        }
        else if pickerView == subCategoryPickerView{
            let str =  row == 0 ? "Select SubCategory*".localized : subCategoryList[row - 1].category_name
            label.text = str
        }
        else if pickerView == servicePickerView{
            let str = row == 0 ? "Select Service*".localized : serviceList[row - 1].service_name
            label.text = str
        }
        else if pickerView == hoursPickerView{
            if row == 0 {
                label.text = "Select Hours".localized
            }else if row == 1 {
                label.text = "\(hoursList[row - 1]) \("Hour".localized)"
            }else{
                label.text = "\(hoursList[row - 1]) \("Hours".localized)"
            }
        }
        else{
        }
        return label
    }
}


extension AddNewServiceVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  ( isEdit  == true ? arrImages.count : pickedImageAry.count )
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddNewServiceImageCell.identifier, for: indexPath) as? AddNewServiceImageCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.indexPath = indexPath
        if isEdit  == true {
            if arrImages[indexPath.row].media_id.isEmpty {
                cell.imgUser.image = arrImages[indexPath.row].media_image
            }else{
                cell.imgUser.downLoadImage(url: arrImages[indexPath.row].media_url)
            }
        }else{
            cell.imgUser.image = pickedImageAry[indexPath.row]
        }
        if isEdit == true {
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(onClickDelte(_:)), for: .touchUpInside)
            
        }
        return cell
    }
    
    @objc func onClickDelte(_ sender: UIButton) {
        if pickedImageAry.count != 0 {
            self.pickedImageAry.remove(object: self.arrImages[sender.tag].media_image)
        }
        if arrImages[sender.tag].media_id != "" {
            let param = [
                "media_id" : arrImages[sender.tag].media_id,
                "user_id" : UserData.shared.getUser()!.user_id
            ]
            Modal.shared.deleteMedia(vc: self, param: param) { (dic) in
                let dltObj = self.arrImages.remove(at: sender.tag)
                //delete from galleryTab image
                providerServiceDetail?.media_data.remove(object: dltObj)
                self.collectionView.reloadData()
                //TODO: raise notification
                NotificationCenter.default.post(name: .isAddService, object: ["isAddService":true] as [String:Any])
                //self.navigationController?.popViewController(animated: true)
            }
        }else{
            self.arrImages.remove(at: sender.tag)
            self.collectionView.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    //MARK: UICollectionViewDelegateFlowLayout Methos
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(UIScreen.main.bounds.width / 4 ), height: CGFloat((CGFloat(UIScreen.main.bounds.width / 4 ))))
    }
}





extension UIImage {
    func getFileSizeInfo(allowedUnits: ByteCountFormatter.Units = .useMB,
                         countStyle: ByteCountFormatter.CountStyle = .file) -> String? {
        // https://developer.apple.com/documentation/foundation/bytecountformatter
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.countStyle = countStyle
        return getSizeInfo(formatter: formatter)
    }

    func getFileSize(allowedUnits: ByteCountFormatter.Units = .useMB,
                     countStyle: ByteCountFormatter.CountStyle = .memory) -> Double? {
        guard let num = getFileSizeInfo(allowedUnits: allowedUnits, countStyle: countStyle)?.getNumbers().first else { return nil }
        return Double(truncating: num)
    }

    func getSizeInfo(formatter: ByteCountFormatter, compressionQuality: CGFloat = 1.0) -> String? {
        guard let imageData = UIImageJPEGRepresentation(self, compressionQuality) else { return nil }
        return formatter.string(fromByteCount: Int64(imageData.count))
    }
   
}

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resizedTo1MB() -> UIImage? {
        guard let imageData = UIImagePNGRepresentation(self) else { return nil }
        let megaByte = 1000.0

        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB

        while imageSizeKB > megaByte { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
            let imageData = UIImagePNGRepresentation(resizedImage) else { return nil }

            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        }

        return resizingImage
    }
}


extension String {
    func getNumbers() -> [NSNumber] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let charset = CharacterSet.init(charactersIn: " ,.")
        return matches(for: "[+-]?([0-9]+([., ][0-9]*)*|[.][0-9]+)").compactMap { string in
            return formatter.number(from: string.trimmingCharacters(in: charset))
        }
    }

    // https://stackoverflow.com/a/54900097/4488252
    func matches(for regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: self) else { return nil }
            return String(self[range])
        }
    }
}
