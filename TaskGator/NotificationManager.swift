//
//  NotificationManager.swift
//  BooknRide
//
//  Created by KASP on 10/01/18.
//  Copyright © 2018 NCrypted Technologies. All rights reserved.
//

import UIKit

enum RedirectAction {
    
    case none
    case message
    case serviceRequest
    case disputeList
    case displayCustomerReview
    case displayProviderReview
    case userDeactive
    
}

enum DeepLinkType{
    
    case data
    case notification
    
}

class NotificationManager {
    
    var deeplinkType:DeepLinkType = .data
    var actionType:RedirectAction = RedirectAction.none
    
    var userInfo:[String:Any] = [:]
    var title:String = ""
    var message:String = ""
    
    var notificationType:String?
    var userType:String?
    var providerServiceId:String?
    var serviceId:String?
    var serviceRequestId:String?
    var customerId:String?
    var disputeId:String?
    var notificationConstant:String?
    
    init(notification:[String:Any]) {
        self.userInfo = notification
        if  let apsData = notification["aps"] as? [String: Any] {
            if  let data = apsData["data"] as? [String: Any] {
                
                if let notificationType = data["notification_type"] as? String {
                    self.notificationType = notificationType
                }
                if let user_type = data["user_type"] as? String {
                    self.userType = user_type
                }
                if let provider_service_id = data["provider_service_id"] as? String {
                    self.providerServiceId = provider_service_id
                }
                if let service_id = data["service_id"] as? String {
                    self.serviceId = service_id
                }
                if let service_request_id = data["service_request_id"] as? String {
                    self.serviceRequestId = service_request_id
                }
                
                if let customer_id = data["customer_id"] as? String {
                    self.customerId = customer_id
                }
                
                if let dispute_id = data["dispute_id"] as? String {
                    self.disputeId = dispute_id
                }
                
                if let notification_constant = data["notification_constant"] as? String {
                    self.notificationConstant = notification_constant
                }
                
                self.title = data["title"] as? String ?? "New Service is requested"
                self.message = data["body"] as? String ?? ""

                //Setting Currency In Case of Changes From Server.
                if  let currency_sign = data["currency_sign"] as? String {
                    UserData.shared.setCurrency(currency: currency_sign)
                }
                
                if notificationType == "userdeactive"{
                    
                    self.actionType = .userDeactive
                    
                }else if notificationType == "m" && userType == "c"{
                    
                    self.actionType = .message
                    
                }else if notificationType == "s" && userType == "c"{
                    
                    //            NotificationCenter.default.post(name: .customerMyTask, object: ["isReceive":true] as [String:Any])
                    //                    self.redirectTo(viewController: ServiceRequest.storyboardInstance!, isRootView: true)
                    self.actionType = .serviceRequest
                    
                }else if notificationType == "m" && userType == "p"{
                    // for message screen provider
                    //            NotificationCenter.default.post(name: .messageScreenProvider, object: ["isReceive":true] as [String:Any])
                    //                    self.redirectTo(viewController: MessagesVC.storyboardInstance!, isRootView: true)
                    self.actionType = .message
                    
                }else if notificationType == "s" && userType == "p"{
                    // provider my task
                    //                        NotificationCenter.default.post(name: .providerMyTask, object: ["isReceive":true] as [String:Any])
                    //                    self.redirectTo(viewController: ServiceRequest.storyboardInstance!, isRootView: true)
                    self.actionType = .serviceRequest
                }
                else if notificationType == "d"{
                    // Dispute List Open
                    //                        NotificationCenter.default.post(name: .disputeList, object: ["isReceive":true] as [String:Any])
                    //                    self.redirectTo(viewController: DisputeListVC.storyboardInstance!, isRootView: true)
                    self.actionType = .disputeList
                    
                }else if notificationType == "r" && userType == "p"{
                    // Review List Open For Provider
                    //                        NotificationCenter.default.post(name: .reviewList, object: ["isReceive":true] as [String:Any])
                    //                    self.redirectTo(viewController: DisputeListVC.storyboardInstance!, isRootView: true)
                    self.actionType = .displayProviderReview
                }
                else if notificationType == "r" && userType == "c"{
                    self.actionType = .displayCustomerReview
                    
                }
            }
        }
    }
    
}
