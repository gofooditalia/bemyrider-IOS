//
//  Util.swift
//  Classifieds
//
//  Created by NCrypted Technologies on 13/07/18.
//  Copyright © 2018 NCrypted Technologies. All rights reserved.

import UIKit
import Photos
import Alamofire
import UserNotifications


var viewForLoader = UIView()

class Util {
    class func alertView(vc: UIViewController, title : String, message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    class func hideProgressHUD(in view: UIView) {
        for subUIView: UIView in view.subviews {
            if subUIView == viewForLoader {
                subUIView.removeFromSuperview()
            }
        }
    }
    
    class func showUpgradeBox(vc:UIViewController?,storeUrl:String){
        let alert = UIAlertController(title: "New version available", message: "Please download new version in order to use services fluently.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Update Now", style: .default, handler:{ (action) in
                // Open Store Url
            if let url = URL(string: storeUrl){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (action) in
                // Open Store Url
        }))
        
        if let vc = vc {
        vc.present(alert, animated: true, completion: nil)
        }
    }
    
    class func giveShadowEffect(to view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 1.5
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.borderColor = UIColor(red: 154.0 / 255.0, green: 154.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0).cgColor
        view.layer.borderWidth = 0
    }
    
    class func checkPhotoLibraryPermission() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return true
        case .denied, .restricted :
            return false
        case .notDetermined:
            return false
        case .limited:
        return true

        }
      
    }
    
    class func isNetworkReachable() -> Bool {
        
        return (NetworkReachabilityManager()?.isReachable)!
    }
    
    
    
    
    
    
    class func showErrorAlertForPhotoLibrary() -> UIAlertController{
        let alert = UIAlertController(title: "Access permission!", message: "This app requires access to the photo library.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        return alert
    }
    
    /*class func isConnectedToInternet() -> Bool {
     return NetworkReachabilityManager()!.isReachable
     }*/
    
    class func showMessageResult(vc: UIViewController, message: String?) {
        if(message != nil) {
            Util.alertView(vc: vc, title: "", message: message!)
        } else {
            Util.alertView(vc:vc, title: "", message: "Something is wrong.")
        }
    }
    
    class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height : size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x : 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func parseDouble(string: String) -> Double {
        return (NumberFormatter().number(from: string)?.doubleValue)!
    }
    
    class func parseInt(string: String) -> Int {
        return (NumberFormatter().number(from: string)?.intValue)!
    }
    
    class func showConfirmationAlert(vc: UIViewController, title: String, message : String, completion:@escaping (Bool) -> Void) {
        
        let confirmAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            completion(true)
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            completion(false)
        }))
        
        vc.present(confirmAlert, animated: true, completion: nil)
    }
    
    class func convertDate(date:String, inputFormate : String, outputFormate: String) -> String{
        guard date != "" else  {
            return ""
        }
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = inputFormate
        dateFormator.locale = Locale.init(identifier: "en")
        let dateObj = dateFormator.date(from: date)
        dateFormator.dateFormat = outputFormate
        return dateFormator.string(from: dateObj!)
    }
    
    class func compareDates(dateFormate: String, firstDate: String, secondDate: String) -> String {
        guard dateFormate != "", firstDate != "", secondDate != "" else {
            return "-1"
        }
        
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = dateFormate
        let firstDate = dateFormator.date(from: firstDate)
        let secondDate = dateFormator.date(from: secondDate)
        if(firstDate! == secondDate!) {
            return "e"
        } else if(firstDate! > secondDate!) {
            return "gt"
        } else if(firstDate! < secondDate!) {
            return "lt"
        }
        
        return "-1"
    }
    
    class func localToUTC(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
    
    class func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.calendar = NSCalendar.current
        
        dateFormatter.dateFormat = "yyyy-MM-dd | h:mm a"
        
        return dateFormatter.string(from: dt!)
    }
    
    class func isValidDate(dateString: String) -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let _ = dateFormatterGet.date(from: dateString) {
            //date parsing succeeded, if you need to do additional logic, replace _ with some variable name i.e date
            return true
        } else {
            // Invalid date
            return false
        }
    }
    
    class func showLocalNotification(title:String = "TaskGator",body:String,userInfo:[String:Any]){
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = title
        content.userInfo = userInfo
        content.sound = UNNotificationSound.default()
        
        let date = Date(timeIntervalSinceNow: 2)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Local Notification", content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        //                let userActions = "User Actions"
        //            let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        //            let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        //            let category = UNNotificationCategory(identifier: userActions, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
        //
        //            center.setNotificationCategories([category])
        
    }
    
    class func getImageFileSize(image:UIImage) -> String {
        if let data = UIImageJPEGRepresentation(image, 0.0){
            // print("There were \(String(describing: data.count)) bytes")
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
            bcf.countStyle = .file
            let string = bcf.string(fromByteCount: Int64(data.count))
            // print("formatted result: \(string)")
            
            return string
        }
        else{
            return "0.0 MB"
        }
    }
}

func describe<T>(_ value: Optional<T>) -> String {
    switch value {
    case .some(let wrapped):
        return String(describing: wrapped)
    case .none:
        return "(null)"
    }
}

