//
//  AttachmentHandler.swift
//

import Foundation
import UIKit
import MobileCoreServices.UTType
import AVFoundation
import Photos


let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

extension UIImagePickerController{
    
    func getPickedNewFileName(info: [String:Any]) -> String? {
        if #available(iOS 11.0, *) {
            if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
                if let fileName = (asset.value(forKey: "filename")) as? String {
                    print("\(fileName)")
                    return fileName
                }
                else{return nil}
            }
            else{return nil}
        } else {
            // Fallback on earlier versions
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                if let asset = result.firstObject {
                    print(asset.value(forKey: "filename")!)
                    return asset.value(forKey: "filename") as? String ?? ""
                }
                else{return nil}
            }
            else{return nil}
        }
        
    }
    
}


/*
 AttachmentHandler.shared.imagePickedBlock = { [weak self]  (image, fileName) in
 guard let self = self else{ return }
 /* get your image here */
 }
 AttachmentHandler.shared.videoPickedBlock = { [weak self] (url) in
 guard let self = self else{ return }
 /* get your compressed video url here */
 }
 AttachmentHandler.shared.filePickedBlock = { [weak self] (filePath) in
 guard let self = self else{ return }
 /* get your file path url here */
 }
 */


class AttachmentHandler: NSObject {
    static let shared = AttachmentHandler()
    fileprivate var currentVC: UIViewController?
    
    //MARK: - Internal Properties
    var imagePickedBlock: ((UIImage, String) -> Void)?
    var videoPickedBlock: ((NSURL) -> Void)?
    var filePickedBlock: ((URL) -> Void)?
    var isFromCamera = false
    
    private enum AttachmentType: String{
        case camera, video, photoLibrary
    }
    
    //MARK: - Constants
    fileprivate struct Constants {
        static var actionFileTypeHeading : String { return "Add a File".localized }
        static var actionFileTypeDescription : String { return  "Choose a filetype to add...".localized }
        static var actionSelectImage : String { return  "Select Image".localized }
        static var camera : String { return  "Camera".localized }
        static var phoneLibrary : String { return  "Phone Library".localized }
        static var video : String { return  "Video".localized }
        static var file : String { return  "File".localized }
        static var alert : String { return  "Alert".localized }
        static var ok : String { return  "OK".localized }
        
        static var alertForPhotoLibraryMessage : String { return  "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access.".localized }
        
        static var alertForCameraAccessMessage : String { return  "App does not have access to your camera. To enable access, tap settings and turn on Camera.".localized }
        
        static var alertForVideoLibraryMessage : String { return  "App does not have access to your video. To enable access, tap settings and turn on Video Library Access.".localized }
        
        static var alertForNoCamera : String { return  "Camera is not available in this device".localized }
        static var alertForNotSupportPhotoLib : String { return  "Photo library is not available in this device".localized }
        
        static var settingsBtnTitle : String { return  "Settings".localized }
        static var cancelBtnTitle : String { return  "Cancel".localized }
        
    }
    
    //MARK: - showAttachmentActionSheet
    
    
    // This function is used to show the attachment sheet for image, photo.
    func showAttachmentActionSheetForImage(vc: UIViewController, isCaptureFromCamera:Bool = true) {
        self.currentVC = vc
        let actionSheet = UIAlertController(title: Constants.actionFileTypeHeading, message: Constants.actionFileTypeDescription, preferredStyle: .actionSheet)
        
        if isCaptureFromCamera{
            actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
                self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!)
        }))
        actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
        
        if let popup = actionSheet.popoverPresentationController {
            popup.sourceRect = CGRect(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT, width: 0, height: 0)
            popup.sourceView = self.currentVC?.view
        }
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    
    // This function is used to show the attachment sheet for image, video, photo and file.
    func showAttachmentActionSheet(vc: UIViewController) {
        self.currentVC = vc
        let actionSheet = UIAlertController(title: Constants.actionFileTypeHeading, message: Constants.actionFileTypeDescription, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
        }))
        
        actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!)
        }))
        
        actionSheet.addAction(UIAlertAction(title: Constants.video, style: .default, handler: { (action) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .video, vc: self.currentVC!)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: Constants.file, style: .default, handler: { (action) -> Void in
            self.documentPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
        
        
        if let popup = actionSheet.popoverPresentationController {
            popup.sourceRect = CGRect(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT, width: 0, height: 0)
            popup.sourceView = currentVC?.view
        }
        
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    func showPhotoAttachmentActionSheet(vc: UIViewController) {
        self.currentVC = vc
        let actionSheet = UIAlertController(title: Constants.actionSelectImage, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
        }))
        
        actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!)
        }))
    
        
        actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
        
        
        if let popup = actionSheet.popoverPresentationController {
            popup.sourceRect = CGRect(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT, width: 0, height: 0)
            popup.sourceView = currentVC?.view
        }
        
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Authorisation Status
    // This is used to check the authorisation status whether user gives access to import the image, photo library, video.
    // if the user gives access, then we can import the data safely
    // if not show them alert to access from settings.
    private func authorisationStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController){
        self.currentVC = vc
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized , .limited :
            if attachmentTypeEnum == AttachmentType.camera{
                openCamera()
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary{
                photoLibrary()
            }
            if attachmentTypeEnum == AttachmentType.video{
                videoLibrary()
            }
        case .denied:
            print("permission denied")
            self.addAlertForSettings(attachmentTypeEnum)
        case .notDetermined:
            print("Permission Not Determined")
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized{
                    // photo library access given
                    print("access given")
                    if attachmentTypeEnum == AttachmentType.camera{
                        self.openCamera()
                    }
                    if attachmentTypeEnum == AttachmentType.photoLibrary{
                        self.photoLibrary()
                    }
                    if attachmentTypeEnum == AttachmentType.video{
                        self.videoLibrary()
                    }
                }else{
                    print("restriced manually")
                    self.addAlertForSettings(attachmentTypeEnum)
                }
            })
        case .restricted:
            print("permission restricted")
            self.addAlertForSettings(attachmentTypeEnum)
        }
    }
    
    
    //MARK: - CAMERA PICKER
    //This function is used to open camera from the iphone and
    private func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            DispatchQueue.main.async {
                
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                self.isFromCamera = true
                myPickerController.sourceType = .camera
                self.currentVC?.present(myPickerController, animated: true, completion: nil)
            }
        }else{
            let actionSheet = UIAlertController(title: Constants.alert, message: Constants.alertForNoCamera, preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: { (action) -> Void in
                //self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
            }))
            DispatchQueue.main.async {
                self.currentVC?.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: - PHOTO PICKER
    private func photoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            DispatchQueue.main.async {
                
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                self.isFromCamera = false
                myPickerController.sourceType = .photoLibrary
                self.currentVC?.present(myPickerController, animated: true, completion: nil)
            }
        }else{
            let actionSheet = UIAlertController(title: Constants.alert, message: Constants.alertForNotSupportPhotoLib, preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: { (action) -> Void in
                //self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
            }))
            DispatchQueue.main.async {
                
                self.currentVC?.present(actionSheet, animated: true, completion: nil)
                
            }
        }
    }
    
    //MARK: - VIDEO PICKER
    private func videoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            DispatchQueue.main.async {
                
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                myPickerController.sourceType = .photoLibrary
                myPickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
                
                self.currentVC?.present(myPickerController, animated: true, completion: nil)
            }
        }else{
            let actionSheet = UIAlertController(title: Constants.alert, message: Constants.alertForNotSupportPhotoLib, preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: { (action) -> Void in
                //self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
            }))
            DispatchQueue.main.async {
                
                self.currentVC?.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - FILE PICKER
    private func documentPicker(){
        let supportAllow = [String(kUTTypePDF), String(kUTTypeText), String(kUTTypePlainText),  String(kUTTypeZipArchive)]//String(kUTTypeImage),String(kUTTypeText), String(kUTTypePlainText)
        let importMenu = UIDocumentPickerViewController(documentTypes: supportAllow, in: .import)
        //let importMenu = UIDocumentMenuViewController(documentTypes: supportAllow, in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        DispatchQueue.main.async {
            
            self.currentVC?.present(importMenu, animated: true, completion: nil)
        }
    }
    
    //MARK: - SETTINGS ALERT
    private func addAlertForSettings(_ attachmentTypeEnum: AttachmentType){
        var alertTitle: String = ""
        if attachmentTypeEnum == AttachmentType.camera{
            alertTitle = Constants.alertForCameraAccessMessage
        }
        if attachmentTypeEnum == AttachmentType.photoLibrary{
            alertTitle = Constants.alertForPhotoLibraryMessage
        }
        if attachmentTypeEnum == AttachmentType.video{
            alertTitle = Constants.alertForVideoLibraryMessage
        }
        
        let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: Constants.settingsBtnTitle, style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    let success = UIApplication.shared.openURL(url as URL)
                    print("Open \(url): \(success)")
                }
            }
        }
        let cancelAction = UIAlertAction(title: Constants.cancelBtnTitle, style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(cancelAction)
        cameraUnavailableAlertController .addAction(settingsAction)
        DispatchQueue.main.async {
            
            self.currentVC?.present(cameraUnavailableAlertController , animated: true, completion: nil)
        }
    }
}

//MARK: - IMAGE PICKER DELEGATE
// This is responsible for image picker interface to access image, video and then responsibel for canceling the picker
extension AttachmentHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.currentVC?.dismiss(animated: true, completion: nil)
    }
    
    
    func imageSelected(imageName: String?, image: UIImage) {
        if self.isFromCamera {
            self.imagePickedBlock?(self.imageOrientation(image) ?? image, imageName ?? "image.jpg")
        } else {
            self.imagePickedBlock?(image, imageName ?? "image.jpg")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            let pickedImageName = picker.getPickedNewFileName(info: info)
            //self.imagePickedBlock?(image, pickedImageName ?? "image.jpg")
            self.imageSelected(imageName: pickedImageName, image: image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let pickedImageName = picker.getPickedNewFileName(info: info)
            //self.imagePickedBlock?(image, pickedImageName ?? "image.jpg")
            self.imageSelected(imageName: pickedImageName, image: image)
        } else{
            print("Something went wrong in  image")
        }
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL{
            print("videourl: ", videoUrl)
            //trying compression of video
            let data = NSData(contentsOf: videoUrl as URL)!
            print("File size before compression: \(Double(data.length / 1048576)) mb")
            compressWithSessionStatusFunc(videoUrl)
        }
        else{
            print("Something went wrong in  video")
        }
        
        self.currentVC?.dismiss(animated: true, completion: nil)
    }
    
    
    func imageOrientation(_ src:UIImage) -> UIImage? {
        if src.imageOrientation == UIImage.Orientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        if let cgimg:CGImage = ctx.makeImage() {
            return UIImage(cgImage: cgimg)
        }
        
        return src
    }
    
    
    //MARK: Video Compressing technique
    fileprivate func compressWithSessionStatusFunc(_ videoUrl: NSURL) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
        compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                DispatchQueue.main.async {
                    self.videoPickedBlock?(compressedURL as NSURL)
                }
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    }
    
    // Now compression is happening with medium quality, we can change when ever it is needed
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}

//MARK: - FILE IMPORT DELEGATE
extension AttachmentHandler: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url", url)
        self.filePickedBlock?(url)
    }
    
    //    Method to handle cancel action.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.currentVC?.dismiss(animated: true, completion: nil)
    }
    
}
