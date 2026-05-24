//
//  UserData.swift
//  TaskGator
//
//  Created by Nirav Sapariya on 19/05/18.
//  Copyright © 2018 NMS. All rights reserved.
//

import UIKit

class UserData {
    static let shared = UserData()
    
    var notificationDict: [String: Any]?
    
    var isFirstTimeAppLaunch:Bool {
        return UserDefaults.standard.bool(forKey: "isFirstTimeAppLaunch")
    }
    
    func setisFirstTimeApp(launch:Bool) {
        UserDefaults.standard.set(launch, forKey: "isFirstTimeAppLaunch")
        UserDefaults.standard.synchronize()
    }

    /// Tracks the last completed onboarding step (0-based).
    /// -1 means no step completed yet. totalSteps means fully done.
    var onboardingCompletedStep: Int {
        let val = UserDefaults.standard.object(forKey: "onboardingCompletedStep") as? Int
        return val ?? -1
    }

    func setOnboardingCompletedStep(_ step: Int) {
        UserDefaults.standard.set(step, forKey: "onboardingCompletedStep")
        UserDefaults.standard.synchronize()
    }

    func resetOnboardingProgress() {
        UserDefaults.standard.removeObject(forKey: "onboardingCompletedStep")
        UserDefaults.standard.synchronize()
    }
    
    var language: String{
        return UserDefaults().object(forKey: "AppLanguage") as? String ?? ""
    }
    
    func setLanguage(language:String) {
        UserDefaults().set(language, forKey: "AppLanguage")
        UserDefaults().synchronize()
    }
    
    var currentLocaleIdentifier: String {
        let userLang = self.language
        if userLang.caseInsensitiveCompare(string: MuliLanguage.italian.rawValue) {
            return "it"
        } else if userLang.caseInsensitiveCompare(string: MuliLanguage.french.rawValue) {
            return "fr"
        } else if userLang.caseInsensitiveCompare(string: MuliLanguage.portuguese.rawValue) {
            return "pt-PT"
        } else if userLang.caseInsensitiveCompare(string: MuliLanguage.english.rawValue) {
            return "en"
        } else {
            return Bundle.main.preferredLocalizations.first ?? "en"
        }
    }
    
    var languageID: String{
        return UserDefaults().object(forKey: "AppLanguageID") as? String ?? ""
    }
    
    func setLanguageID(languageID:String) {
        UserDefaults().set(languageID, forKey: "AppLanguageID")
        UserDefaults().synchronize()
    }
    
    var currency: String{
        return UserDefaults().object(forKey: "currency") as? String ?? "€"
    }
    
    func setCurrency(currency:String) {
        UserDefaults().set(currency, forKey: "currency")
        UserDefaults().synchronize()
    }
    
    var isSocialLogin: Bool{
        return UserDefaults.standard.object(forKey: "loginViaSocial") as? Bool ?? false
       }
       
    func setSocialLogin(social:Bool) {
        UserDefaults.standard.set(social, forKey: "loginViaSocial")
        UserDefaults.standard.synchronize()
    }
    
    func setPaymentPref(deviceToken:String) {
        UserDefaults().set(deviceToken, forKey: "paymentPref")
        UserDefaults().synchronize()
    }
    
    var paymentPref: String {
        if (UserDefaults().object(forKey: "paymentPref") as? String ?? "") == "w" {
            return "Wallet"
        }
        else if (UserDefaults().object(forKey: "paymentPref") as? String ?? "") == "c" {
            return "Cash"
        }
        else{
            return "N/A"
        }
    }
    
    func setDeviceToken(deviceToken:String) {
        UserDefaults().set(deviceToken, forKey: "UserDeviceToken")
        UserDefaults().synchronize()
    }
    
    var deviceToken: String {
        return UserDefaults().object(forKey: "UserDeviceToken") as? String ?? "111222333444555"
    }
    
    func setUser(dic: [String:Any]) -> Bool {
        UserDefaults.standard.set(dic, forKey: "UserKey")
        return UserDefaults.standard.synchronize()
    }
    
    func getUser() -> User? {
        if let user = UserDefaults.standard.value(forKey: "UserKey") as? Dictionary<String,Any> {
            return User(dic: user)
        }
        return nil
    }
    
    func setUserLoginData(dic: [String:Any]) -> Bool {
        UserDefaults.standard.set(dic, forKey: "UserLoginData")
        return UserDefaults.standard.synchronize()
    }
    
    func getUserLoginData() -> UserLoginData? {
        if let user = UserDefaults.standard.value(forKey: "UserLoginData") as? Dictionary<String,Any> {
            return UserLoginData(dictionary: user)
        }
        return nil
    }
    
    func logoutUser(){
        if let bundle =  Bundle.main.bundleIdentifier{
//            UserDefaults.standard.removePersistentDomain(forName: bundle)
            // RemoteNotifications
            let app = UIApplication.shared
            app.registerForRemoteNotifications()
//            let userLanguage = UserData.shared.language
//            let userLanguageID = UserData.shared.languageID
//            let userCurrency = UserData.shared.currency
//
//            UserDefaults.standard.removePersistentDomain(forName: bundle)
//            // RemoteNotifications
//            UIApplication.shared.registerForRemoteNotifications()
//
//            UserData.shared.setLanguage(language: "")
//            UserData.shared.setLanguageID(languageID: "")
//            UserData.shared.setCurrency(currency: "")
            UserData.shared.setSocialLogin(social: false)
           _ = UserData.shared.setUserLoginData(dic: [:])
           _ = UserData.shared.setUser(dic: [:])
            UserDefaults.standard.removeObject(forKey: "UserLoginData")
            UserDefaults.standard.synchronize()
            UserData.shared.setisFirstTimeApp(launch: true)
            UserData.shared.resetOnboardingProgress()
        }
    }
    
    func removeStoredValues(key:String) -> Bool {
        UserDefaults.standard.removeObject(forKey: key)
        return UserDefaults.standard.synchronize()
    }
    
}

