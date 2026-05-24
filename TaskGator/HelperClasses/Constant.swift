//
//  Constant.swift
//  chronicsouls
//
//  Created by Nirav Sapariya on 18/01/18.
//  Copyright © 2018 NMS. All rights reserved.
//

import UIKit
/*
user_id:56
lId:1
user_type:c
 
request_type:app
invoice:Invoice
service_start_time:Service Start Time
service_end_time:Service End Time
booking_id:Booking Id
booking_details:Booking Details
booking_amount:Booking Amount
admin_fees:Admin Fees
payment_type:Payment Type
total_payable_amount:Total Payable Amount
total_receivable_amount:Total Receivable Amount
wallet:Wallet
cash:Cash
complete:Completed
*/
struct InvoiceKey {
    static let request_type = "app"
    static let invoice = "Invoice"
    static let service_start_time = "Service Start Time"
    static let service_end_time = "Service End Time"
    static let booking_id = "Booking Id"
    static let booking_details = "Booking Details"
    static let booking_amount = "Booking Amount"
    static let admin_fees = "Admin Fees"
    static let payment_type = "Payment Type"
    static let total_payable_amount = "Total Payable Amount"
    static let total_receivable_amount = "Total Receivable Amount"
    static let wallet = "Wallet"
    static let cash = "Cash"
    static let complete = "Completed"
}

struct StoryBoard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static let home = UIStoryboard(name: "Home", bundle: nil)
    static let slideMenu = UIStoryboard(name: "SlideMenu", bundle: nil)
    static let singleViews = UIStoryboard(name: "SingleViews", bundle: nil)
    static let profiles = UIStoryboard(name: "Profiles", bundle: nil)
    static let popUp = UIStoryboard(name: "PopUp", bundle: nil)
    static let wallet = UIStoryboard(name: "Wallet", bundle: nil)
    static let messages = UIStoryboard(name: "Messages", bundle: nil)
    static let notification = UIStoryboard(name: "Notifications", bundle: nil)
    static let searchProvider = UIStoryboard(name: "SearchProvider", bundle: nil)
    static let provider = UIStoryboard(name: "Provider", bundle: nil)
    static let serviceProviderDetail  = UIStoryboard(name: "ServiceProviderDetail", bundle: nil)
    static let serviceRequest  = UIStoryboard(name: "ServiceRequest", bundle: nil)
    static let customerSideServiceDetails  = UIStoryboard(name: "CustomerSideServiceDetails", bundle: nil)
    static let providerSideServiceDetails  = UIStoryboard(name: "ProviderSideServiceDetails", bundle: nil)
    static let imageCropper  = UIStoryboard(name: "ImageCropper", bundle: nil)
    static let myServiceDetail = UIStoryboard(name: "MyServiceDetail", bundle: nil)
    static let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)

}

//var topSelectedMenu = 1

public enum Result<T> {
    case success(T)
    case failure(Error)
}

enum keys:String  {
    case status = "status"
    case message = "message"
    case data = "data"
}

struct ResponseKey{
    
    static func fatchDataAsDictionary(res: dictionary, valueOf key: keys) -> [String:Any] {
        if res[key.rawValue] as? [String:Any] != nil{
            print("Dictionary as a response")
            return res[key.rawValue] as! [String:Any]
        }
        else{
            if res[key.rawValue] as? [Any] != nil{
                print("Response is different: Array as a response")
                return [:]
            }
            else if res[key.rawValue] as? String != nil{
                print("Response is different: String as a response")
                return [:]
            }else{
                print("Response is different: Response type not a Dictionary nore Array or String")
                return [:]
            }
        }
    }
    
    static func fatchDataAsArray(res: dictionary, valueOf key: keys) -> [Any] {
        if res[key.rawValue] as? [Any] != nil{
            print("Array as a response")
            return res[key.rawValue] as! [Any]
        }
        else{
            if res[key.rawValue] as? [String:Any] != nil{
                print("Response is different: Dictionary as a response")
                return []
            }
            else if res[key.rawValue] as? String != nil{
                print("Response is different: String as a response")
                return []
            }else{
                print("Response is different: Response type not a Dictionary nore Array or String")
                return []
            }
        }
    }
    
    static func fatchDataAsString(res: dictionary, valueOf key: keys) -> String {
        if res[key.rawValue] as? String != nil{
            print("String as a response")
            return res[key.rawValue] as! String
        }
        else{
            if res[key.rawValue] as? [Any] != nil{
                print("Response is different: Array as a response")
                return ""
            }
            else if res[key.rawValue] as? [String:Any] != nil{
                print("Response is different: Dictionary as a response")
                return ""
            }else{
                print("Response is different: Response type not a Dictionary nore Array or String")
                return ""
            }
        }
    }
    
    static func fatchData(res: dictionary, valueOf key: keys) -> (dic: [String:Any], ary: [Any], str: String){
        if res[key.rawValue] as? [String:Any] != nil{
            print("Dictionary as a response")
            return (dic: res[key.rawValue] as! [String:Any], ary: [], str: "")
        }
        else if res[key.rawValue] as? [Any] != nil{
            print("Array as a response")
            return (dic: [:], ary: res[key.rawValue] as! [Any], str: "")
        }
        else if res[key.rawValue] as? String != nil{
            print("String as a response")
            return (dic: [:], ary: [], str: res[key.rawValue] as! String)
        }else{
            print("Response type not a Dictionary nore Array or String")
            return (dic: [:], ary:[], str: "")
        }
    }
    
    
    static func fetchDataInInteger(res: [String:Any], valueOf key: String) -> Int {
        if let value = res[key] as? String {
            return Int(value) ?? 0
        }else if let value = res[key] as? Int {
            return value
        }else {
            print("key value is neither in string nor integer")
            return 0
        }
    }
    
    static func fetchDataInDouble(res: [String:Any], valueOf key: String) -> Double {
        if let value = res[key] as? String {
            return Double(value) ?? 0.0
        }else if let value = res[key] as? Double {
            return value
        }else {
            print("key value is neither in string nor integer")
            return 0
        }
    }
    
    static func fetchDataInString(res: [String:Any], valueOf key: String) -> String {
        if let value = res[key] as? String {
            return value
        }else if let value = res[key] as? Int {
            return "\(value)"
        }else {
            print("key value is neither in string nor integer")
            return ""
        }
    }
}


