//
//  FeedBackVC.swift
//  bemyrider
//
//  Created by NCT 24 on 11/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Photos

class FeedBackVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:FeedBackVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: FeedBackVC.identifier) as? FeedBackVC
    }
    
    var picker:UIImagePickerController!{
        didSet{
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
    }
    
    var selectedUserImage:UIImage?
    var pickedImageName:String?
    
    @IBOutlet weak var txtFirstName: RobotoRegular14TextField!
    @IBOutlet weak var txtLastName: RobotoRegular14TextField!
    @IBOutlet weak var txtEmail: RobotoRegular14TextField!
    @IBOutlet weak var txtUploadPhoto: RightViewArrowTextField!{
        didSet{
            txtUploadPhoto.isUserInteractionEnabled = false
            txtUploadPhoto.leftViewImage = #imageLiteral(resourceName: "uploadIco")
            
        }
    }
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            //            textView.border(side: .bottom, color: Color.grey.light, borderWidth: 2.0)
            textView.placeholder = "Enter Feedback*"
        }
    }
    @IBOutlet weak var btnSubmit: GreenButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang(){
        txtEmail.placeholder = "Email ID*".localized
        txtLastName.placeholder = "Last Name*".localized
        txtFirstName.placeholder = "First Name*".localized
        txtUploadPhoto.placeholder = "Upload your photo*".localized
        btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        textView.placeholder = "Enter Message*".localized
    }
    
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        print("onClickSubmit")
        if isValidated(){
            callFeedBackAPI()
        }
    }
    
    @IBAction func onClickUploadPhoto(_ sender: UIButton) {
        print("onClickUploadPhoto")
        //checkPhotoLibraryPermission()
        pickImage()
    }
    
}

//MARK: Custom function
extension FeedBackVC {
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Feedback".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title: "Feedback".localized, isBack: true, rightButton: false)
        
    }
    
    func setData()  {
        let user = UserData.shared.getUser()!
        txtFirstName.text = user.first_name
        txtLastName.text = user.last_name
        txtEmail.text = user.email_id
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callFeedBackAPI() {
        let user = UserData.shared.getUser()!
        let param = ["user_id":user.user_id,
                     "email":txtEmail.text!,
                     "message":textView.text!,
                     "firstName":txtFirstName.text!,
                     "lastName":txtLastName.text!]
        
        Modal.shared.sendFeedBack(vc: self, param: param, postImage: selectedUserImage, imageName: pickedImageName) { (dic) in
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func isValidated() -> Bool {
        var ErrorMsg = ""
        if (txtFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter a first name".localized
        }
        else if (txtLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter a last name".localized
        }
        else if (txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please enter a email".localized
        }
        else if !(txtEmail.text?.isValidEmailId)! {
            ErrorMsg = "Please enter a valid email id".localized
        }
        else if (txtUploadPhoto.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please attach the photo".localized
        }
        else if (textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please write feedback".localized
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
        actionSheet.popoverPresentationController?.sourceRect = txtUploadPhoto.frame
        actionSheet.popoverPresentationController?.sourceView = self.view
        DispatchQueue.main.async {
        self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func openGallary(){
        picker = UIImagePickerController()
        DispatchQueue.main.async {
            self.present(self.picker, animated: true, completion: nil)
        }
    }
    
    func openSettingForGivePermissionPhotos() {
        self.alert(title: "", message: "Photo Access Prohibited".localized, actions: ["Cancel".localized,"Settings".localized], completion: { (flag) in
            if flag == 1{ //Setting
                self.open(scheme:UIApplicationOpenSettingsURLString)
            }
            else{//Cancel
            }
        })
    }
    
    func checkPhotoLibraryPermission(){
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized , .limited:
            // Access has been granted.
            self.openGallary()
        case .denied, .restricted :
            // Access has been denied.
            // Restricted access - normally won't happen.
            openSettingForGivePermissionPhotos()
        case .notDetermined:
            // ask for permissions
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.openGallary()
                }
                else {
                    self.openSettingForGivePermissionPhotos()
                }
            })
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
                            DispatchQueue.main.async {
                                self.open(scheme:UIApplicationOpenSettingsURLString)
                            }
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
            DispatchQueue.main.async {
                self.present(self.picker, animated: true, completion: nil)
            }
        }
        else{
            self.alert(title: "Alert".localized, message: "Camera is not available in this device".localized)
        }
    }
}

extension FeedBackVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //1
        var selectedImage: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage]   as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        //2
        if let _ = selectedImage {
            pickedImageName = picker.getPickedFileName(info: info)
            if let name = picker.getPickedFileName(info: info){
                pickedImageName = name
            }else{
                pickedImageName = "Image_001.PNG"

            }
         
            txtUploadPhoto.text = pickedImageName
            self.selectedUserImage = selectedImage
        }
        else{
            print("Something went wrong")
        }
        //3
        //dismiss(animated: true, completion: nil)
        dismiss(animated: false) {
//            if let selectedImages = selectedImage {
//                let imageCropper = ImageCropper.storyboardInstance
//                imageCropper.delegate = self
//                imageCropper.image = selectedImages
//                DispatchQueue.main.async {
//                    self.present(imageCropper, animated: false, completion: nil)
//                }
//            }
        }
        
    }
}

//MARK: ImageCropper Class
extension FeedBackVC: ImageCropperDelegate{
    
    func didCropImage(originalImage: UIImage, cropImage: UIImage) {
        self.selectedUserImage = cropImage
    }
    
    func didCancel() {
        print("Cancel Crop Image")
    }
    
}

