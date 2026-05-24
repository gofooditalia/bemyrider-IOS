//
//  ChatVC.swift
//  TaskGator
//
//  Created by NCT 24 on 25/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices.UTType

extension Notification.Name {
    static let sendMessgae = Notification.Name("sendMessgae")
}

protocol ChatDelegate {
    func refreshMessageList()
}

class ChatVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:ChatVC? {
        return StoryBoard.messages.instantiateViewController(withIdentifier: ChatVC.identifier) as? ChatVC
    }
    
    @IBOutlet weak var imgNoRecords: UIImageView!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(ChatCell.nib, forCellReuseIdentifier: ChatCell.identifier)
            tableView.register(ChatReceiveCell.nib, forCellReuseIdentifier: ChatReceiveCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
    @IBOutlet weak var bgView: UIView!{
        didSet{
            bgView.setRadius(10)
        }
    }
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            textView.placeholder =  "Your message here".localized
//            textView.border(side: .all, color: Color.grey.deviderColor, borderWidth: 1.0)
        }
    }
    @IBOutlet weak var btnAttachement: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var messageStackView: UIStackView?
    
    var delegate:ChatDelegate?
    
    var msgList = [Message]()
    var messageObj: MessageCls?
    
    var param: [String:Any]?
    
    var selectedUserImage:UIImage?
    var pickedAttachmentName:String?
    var pickedFileData:Data?
    
    var service_name:String?
    
    var picker:UIImagePickerController!{
        didSet{
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
        }
    }
    
    @objc func getMsg(notification: Notification) {
        if (notification.object as! [String: Any])["isReceive"] as? Bool ?? false{
            callLoadConversationAPI()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Modal.sharedAppdelegate.isCustomerLogin{
            NotificationCenter.default.addObserver(self, selector: #selector(getMsg), name: .messageScreenCustomer, object: nil)
        }
        else{
            NotificationCenter.default.addObserver(self, selector: #selector(getMsg), name: .messageScreenProvider, object: nil)
        }
        
        self.imgNoRecords.isHidden = false
        self.messageStackView?.isHidden = true
                       
    
        setUpUI()
        callLoadConversationAPI()
        
        //MARK: Attchment code is here
        AttachmentHandler.shared.imagePickedBlock = { (image, imageName) in
            /* get your image here */
            self.pickedAttachmentName = imageName
            self.textView.isUserInteractionEnabled = false
            self.textView.text = ""
            self.textView.text = self.pickedAttachmentName
            self.textView.resetPlaceHolder()
            self.selectedUserImage = image
            
            let imageCropper = ImageCropper.storyboardInstance
            imageCropper.delegate = self
            imageCropper.image = image
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(imageCropper, animated: false, completion: nil)
            }
            
        }
        AttachmentHandler.shared.videoPickedBlock = {(url) in
            /* get your compressed video url here */
            let responseData = (url as URL).getDataAndFileNameBasedOnURL()
            print(responseData.fileName)
            self.pickedFileData = responseData.fileData
            self.pickedAttachmentName = responseData.fileName
            self.textView.isUserInteractionEnabled = false
            self.textView.text = ""
            self.textView.text = self.pickedAttachmentName
            self.textView.resetPlaceHolder()
        }
        AttachmentHandler.shared.filePickedBlock = {(filePath) in
            /* get your file path url here */
            let responseData = filePath.getDataAndFileNameBasedOnURL()
            print(responseData.fileName)
            self.pickedFileData = responseData.fileData
            self.pickedAttachmentName = responseData.fileName
            self.textView.isUserInteractionEnabled = false
            self.textView.text = ""
            self.textView.text = self.pickedAttachmentName
            self.textView.resetPlaceHolder()
        }
    }
    
    @IBAction func onClickAttachements(_ sender: UIButton) {
        //checkPhotoLibraryPermission()
        //addAttachmentClick()
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
        if !(textView.text.isBlank){
            callsendMsgAPI()
        }
        else{
            let alert = UIAlertController(title: "Error".localized, message: "Please enter message or attach files".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func addAttachmentClick()
    {
        let optionMenu = UIAlertController(title: nil, message: "Please choose a source type".localized, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera".localized, style: .default, handler:{
            (alert: UIAlertAction!) -> Void in
            let imagepicker = UIImagePickerController()
            imagepicker.delegate = self
            imagepicker.chooseImage(vc: self, isCaptureFromCamera: true, allowsEditing: false)
        })
        
        let libraryAction = UIAlertAction(title: "Photo & Video Library".localized, style: .default, handler:{
            (alert: UIAlertAction!) -> Void in
            let imagepicker = UIImagePickerController()
            imagepicker.delegate = self
            //imagepicker.chooseImage(vc: self, isCaptureFromCamera: false, allowsEditing: false)
            imagepicker.chooseImage(vc: self, isCaptureFromCamera: false, allowsEditing: false, allowToPickVideo: true)
        })
        
        let documentAction = UIAlertAction(title: "Document".localized, style: .default, handler:{
            (alert: UIAlertAction!) -> Void in
            self.documentPickerOpen()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler:{
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(documentAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}

//MARK: Custom function
extension ChatVC {
    
    //MARK: iCloud data pick
    func documentPickerOpen()
    {
        let supportAllow = [String(kUTTypePDF), String(kUTTypeText), String(kUTTypePlainText),]//String(kUTTypeImage)
        //        let importMenu = UIDocumentMenuViewController(documentTypes: supportAllow, in: .import)
        //        importMenu.delegate = self
        //        importMenu.modalPresentationStyle = .formSheet
        //        self.present(importMenu, animated: true, completion: nil)
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: supportAllow, in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
        /*
         importMenu.addOption(withTitle: "From Gallery", image: #imageLiteral(resourceName: "Gallery"), order: .first, handler: {
         print("From Gallery or Camera")
         //Common.shared.selectPhoto(delegate: self, viewControl: self)
         //Common.shared.selectVideo(delegate: self)
         })
         */
    }
    
    func setUpUI() {
        self.applyStatusbar(color: Color.Theme.purple)
        // isBack: false → no custom button → native iOS back arrow is shown automatically
        self.setupNavigationBar(title: (service_name != nil ? service_name! : "Messages"), isBack: false, rightButton: false)
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callLoadConversationAPI() {
        guard var param = self.param else { return }
        let nextPage = (messageObj?.pagination?.currentPage ?? 0) + 1
        param["page"] = nextPage
        if nextPage > 1 {
            param["last_message_id"] = self.msgList.last?.message_id
        }

        Task { [weak self] in
            guard let self = self else { return }
            do {
                // APIClient.post — no startLoader(), fully background
                let dic = try await APIClient.shared.post(EndPoint.getMessage, params: param)
                self.messageObj = MessageCls(dictionary: dic)
                if self.msgList.count > 0 {
                    self.msgList += self.messageObj!.conversationList
                } else {
                    self.msgList = self.messageObj!.conversationList
                }
                self.tableView.reloadData()
                self.imgNoRecords.isHidden = !self.msgList.isEmpty
                self.messageStackView?.isHidden = self.messageObj?.isactive.lowercased() == "du"
            } catch {
                // Fail silently — chat screen stays as-is
            }
        }
    }
    
    func scrollToLastRow() {
        if self.msgList.count > 0{
            let indexPath = IndexPath(row: self.msgList.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    
    func callsendMsgAPI() {
        guard let userId = UserData.shared.getUser()?.user_id else { return }

        var param: [String:Any] = [:]
        if msgList.count > 0 {
            param = [
                "user_id": userId,
                "service_id": messageObj!.service_id,
                "service_master_id": messageObj!.service_master_id,
                "message_text": textView.text!,
            ]
            if customerSide_ProviderDetails != nil || providerSide_ProviderDetails != nil {
                param["to_user_id"] = (Modal.sharedAppdelegate.isCustomerLogin ? customerSide_ProviderDetails!.provider_id : providerSide_ProviderDetails!.customer_id)
            } else {
                if msgList.first!.to_user != userId {
                    param["to_user_id"] = msgList.first!.to_user
                } else {
                    param["to_user_id"] = msgList.first!.from_user
                }
            }
        } else if let fatchedParam = self.param {
            param = [
                "user_id": userId,
                "to_user_id": fatchedParam["to_user_id"] as! String,
                "service_id": fatchedParam["service_id"] as? String ?? "",
                "service_master_id": fatchedParam["service_master_id"] as! String,
                "message_text": textView.text!,
            ]
        }

        guard !param.isEmpty else { return }

        // Capture attachment state before clearing UI
        let image = selectedUserImage
        let attachmentName = pickedAttachmentName
        let fileData = pickedFileData

        // --- Optimistic insert: show message immediately ---
        let optimisticMsg = Message(dictionary: [
            "from_user": userId,
            "message_text": textView.text ?? "",
            "to_user": param["to_user_id"] as? String ?? "",
            "appAttUrl": attachmentName ?? "",
            "created_date": "",
            "isRead": "0",
            "message_id": "",
            "msgType": ""
        ])
        msgList.insert(optimisticMsg, at: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        tableView.endUpdates()
        imgNoRecords.isHidden = true

        textView.text = nil
        textView.placeholder = "Type a message here".localized
        textView.isUserInteractionEnabled = true
        selectedUserImage = nil
        pickedAttachmentName = nil
        pickedFileData = nil

        if image == nil && fileData == nil {
            // Text-only: fire-and-forget via APIClient — zero blocking overlay, user can navigate freely.
            // Do NOT call delegate?.refreshMessageList() — MessagesView.onAppear handles refresh on return.
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let msgData = try await APIClient.shared.sendTextMessage(params: param)
                    let message = Message(dictionary: msgData)
                    if !self.msgList.isEmpty {
                        self.msgList[0] = message
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                } catch {
                    // On failure: remove the optimistic message and show error
                    if !self.msgList.isEmpty {
                        self.msgList.removeFirst()
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                        self.tableView.endUpdates()
                    }
                    let alert = UIAlertController(title: "Errore", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .destructive))
                    self.present(alert, animated: true)
                }
            }
        } else {
            // Image/file upload: loader is correct (real upload in progress)
            Modal.shared.sendMessage(vc: self, param: param, postImage: image, attachmentName: attachmentName, fileData: fileData, failer: { [weak self] _ in
                guard let self = self, !self.msgList.isEmpty else { return }
                self.msgList.removeFirst()
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                self.tableView.endUpdates()
            }) { [weak self] dic in
                guard let self = self else { return }
                let message = Message(dictionary: ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data))
                if !self.msgList.isEmpty {
                    self.msgList[0] = message
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
                self.delegate?.refreshMessageList()
            }
        }
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
    
    func openGallary(){
        picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
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
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        reloadMoreData(indexPath: indexPath)
        if msgList[indexPath.row].from_user == UserData.shared.getUser()!.user_id {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatReceiveCell.identifier) as? ChatReceiveCell else {
                fatalError("Cell can't be dequeue")
            }
            cell.messageObj = self.messageObj
            cell.chatCellData = msgList[indexPath.row]
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier) as? ChatCell else {
                fatalError("Cell can't be dequeue")
            }
            cell.messageObj = self.messageObj
            cell.chatCellData = msgList[indexPath.row]
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgList.count
    }
    
    
    func reloadMoreData(indexPath: IndexPath) {
        if msgList.count > 0 {
        if msgList.count - 1 == indexPath.row &&
            (messageObj!.pagination!.currentPage < messageObj!.pagination!.total_pages) {
            self.callLoadConversationAPI()
        }
        }
    }
}

extension ChatVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /*
         //https://www.ioscreator.com/tutorials/take-video-tutorial-ios8-swift
         let mediaType:AnyObject? = info[UIImagePickerControllerMediaType] as AnyObject
         
         if let type:AnyObject = mediaType {
         if type is String {
         let stringType = type as! String
         if stringType == kUTTypeMovie as String {
         let urlOfVideo = info[UIImagePickerControllerMediaURL] as? URL
         if let videoURL = urlOfVideo {
         //TODO: remove below line
         _ = videoURL.getThumbnailFromVideo()
         // 2
         //                        assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(url,
         //                                                                         completionBlock: {(url: NSURL!, error: NSError!) in
         //                                                                            if let theError = error{
         //                                                                                println("Error saving video = \(theError)")
         //                                                                            }
         //                                                                            else {
         //                                                                                println("no errors happened")
         //                                                                            }
         //                        })
         }
         }
         }
         }
         */
        
        //1
        var selectedImage: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        //2
        if let _ = selectedImage {
            pickedAttachmentName = picker.getPickedFileName(info: info)
            textView.isUserInteractionEnabled = false
            textView.text = ""
            textView.text = pickedAttachmentName
            textView.resetPlaceHolder()
            self.selectedUserImage = selectedImage
        }
        else{
            print("Something went wrong")
        }
        //3
        //dismiss(animated: true, completion: nil)
        dismiss(animated: false) {
            if let selectedImages = selectedImage {
                let imageCropper = ImageCropper.storyboardInstance
                imageCropper.delegate = self
                imageCropper.image = selectedImages
                self.present(imageCropper, animated: false, completion: nil)
            }
        }
    }
}

//MARK: ImageCropper Class
extension ChatVC: ImageCropperDelegate{
    
    func didCropImage(originalImage: UIImage, cropImage: UIImage) {
        
        self.selectedUserImage = cropImage.resizedImageWith(targetSize: CGSize(width: 800, height: 800))  ?? cropImage
    }
    
    func didCancel() {
        print("Cancel Crop Image")
        self.selectedUserImage = nil
        self.textView.text = ""
    }
}


//MARK: Doucment Picker
extension ChatVC : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileURL = url as URL
        print("The Url is : \(fileURL)")
        let fileNameWithoutExtension = fileURL.pathExtension//deletingPathExtension().lastPathComponent
        print("fileNameWithoutExtension: \(fileNameWithoutExtension)")
        do {
            let data = try Data(contentsOf: fileURL)
            print("data=\(data)")
            let fileName = fileURL.lastPathComponent
            //let pickedData = data
            print(fileName)
            //isAttachement = true
            //            postFilesNames.append(fileName)
            //            postFileData.append(data)
            //
            //            //self.images.append(img!)
            //            //print("ImageSelected: \(self.images.count)")
            //            //TODO: call image upload API
            //            self.sendAttachments()
            
        }
        catch {/* error handling here */}
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("we cancelled")
        dismiss(animated: true, completion: nil)
    }
    
}
