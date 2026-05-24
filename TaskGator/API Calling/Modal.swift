//
//  Modal.swift
//  APICalling
//
//  Created by Nirav Sapariya.
//  Copyright © 2018 NCrypted. All rights reserved.
//

import UIKit

enum Domain {
   
    //Dev Server
//        static let main = "https://gotasker.ncryptedprojects.com/ws/"
//        static let local = "https://gotasker.ncryptedprojects.com/ws/"
//        static let downloadInvoice = "https://gotasker.ncryptedprojects.com/"
    
//    Live Server
    static let main = "https://bemyrider.it/ws/"
    static let local = "https://bemyrider.it/ws/"
    static let downloadInvoice = "https://bemyrider.it/"
    
        //https://stripe.com/docs/keys
        // Key is loaded from Info.plist → injected via xcconfig (not hardcoded in source)
        static let Stripe_Publishable_Live_Key: String = {
            guard let key = Bundle.main.object(forInfoDictionaryKey: "StripePublishableKey") as? String, !key.isEmpty else {
                fatalError("StripePublishableKey not set in xcconfig / Info.plist")
            }
            return key
        }()
    
    
    static func getPayPalUrl(amount: String, deposit_commission:String?, service_id:String?) -> String{
        if let deposit_commission = deposit_commission, let service_id = service_id{
            return "\(Domain.main)payment-nct/paypal-button.php?user_id=\(UserData.shared.getUser()!.user_id)&amount=\(amount)&deposit_commission=\(deposit_commission)&action=hire_service&service_id=\(service_id)"
        }
        else{
            return "\(Domain.main)payment-nct/paypal-button.php?user_id=\(UserData.shared.getUser()!.user_id)&amount=\(amount)"
        }
    }
}

enum EndPoint {
    static let getCountryCode = "profile/countrycodelist"
    static let afterSocialLogin = "profile/afterSocialLogin"
    static let login = "profile/login"
    static let register = "profile/register"
    static let profile = "profile/"
    static let walletDetail = "profile/walletdetails/"
    static let redeemRequest = "finance/sendredeemrequest"
    static let getService = "services/customerservices"
    static let getMessageListing = "messages/getmessagelist"
    static let getMessage = "messages/getmessage"
    static let sendMessage = "messages/sendmessage"
    static let disputeListing = "disputes/getmydisputelist"
    static let forgotPassword = "profile/forgotpassword"
    static let categoryList = "services/categorylist"
    static let subcategoryList = "services/subcategorylist"
    static let serviceList = "services/servicelist"
    static let getCountry = "location/getCountry"
    static let getStateList = "location/getStates"
    static let getCityList = "location/getCitys"
    static let getNotificationList = "profile/getnotificationlist"
    static let getNotificationListing = "notifications/getNotifications"
    static let getLanguages = "language/getlanguages"
    static let getcmsList = "cms/getcmslist"
    static let getCmsDetails = "cms/getcmsdetails"
    static let depositHistory = "finance/deposithistory"
    static let redeemHistory = "finance/redeemhistory"
    static let paymentHistory = "finance/paymenthistory"
    static let minmaxPrice = "services/minmaxprice"
    static let updateavAvailablestatus = "profile/updateavailablestatus"
    static let providerList = "services/providerlist"
    static let likeDislikeServices = "services/likedislikeservices"
    static let providerServiceDetail = "services/providerservicedetail"
    static let sendServiceRequest = "services/send_service_request"
    static let inviteHistory = "services/invitehistory"
    static let inviteFriends = "messages/invite"
    static let contactus = "messages/contactus"
    static let resendMail = "profile/resend-activation"
    static let socialLogin = "profile/sociallogin"
    static let logout = "profile/logout"
    static let editprofile = "profile/editprofile"
    static let providerReviews = "services/providerreviews"
    static let financialInfo = "finance/financialinfo"
    static let providerServices = "services/providerservices"
    static let addServices = "services/addservices"
    static let updatenotification = "profile/updatenotification"
    static let feedback = "messages/feedback"
    static let changepassword = "profile/changepassword"
    static let getDisputelist = "disputes/getdisputelist"
    static let getDisputedetails = "disputes/getdisputedetails"
    static let escalateToAdmin = "disputes/escalatetoadmin"
    static let acceptDispute = "disputes/acceptdispute"
    static let sendDisputeMessage = "disputes/senddisputemessage"
    static let getFavoriteService = "services/getfavoriteservice"
    static let serviceRequestBookNow = "finance/servicerequestpayment"
    static let cancelService = "services/cancelservice"
    static let acceptService = "services/acceptservice"
    static let addProviderReview = "services/addproviderreview"
    static let bulkInvoices = "bulk-invoices"
    static let downloadInvoice = "\(Domain.downloadInvoice)download-invoice/"
    static let acceptProposal = "services/acceptproposal"
    static let sendProposal = "services/sendproposal"
    static let providerTasks = "services/providertasks" //like customer services
    static let extendService = "services/extendservice"
    static let payForExtendService = "services/extendservicepayment"
    static let raisedDispute = "disputes/raisedispute"
    static let deleteServices = "services/deleteservices"
    static let deleteMedia = "services/deletemedia"
    static let acceptExtendservice = "services/acceptextendservice"
    static let socialSignUp = "profile/socialsignup"
    static let popularservice = "services/popularservice"
    static let populartasker = "services/populartasker"
    static let deactiveuser = "profile/deactiveuser"
    static let transectionhistory = "services/transectionhistory"
    static let providerservice = "services/providerservice"
    static let flagUser = "profile/flag_user"
    static let getSiteSettingDataIos = "other/getSiteSettingDataIos"
    
    
    //new
    static let getSmallProviders = "services/small"
    static let getMediumProviders = "services/medium"
    static let getLargeProviders = "services/large"
    static let homeProviderServiceDetail = "services/homeproviderservicedetail"
    static let stripeConnect = "profile/stripe_connect"
    static let serviceRequestBookStripe = "finance/successpayment"

}

typealias failureBlock = (String) -> Void
typealias successBlock = ([String:Any]) -> Void
typealias failResponseBlock = ([String:Any],String) -> Void

class Modal {
    static let shared = Modal()
    
//    static var sharedAppdelegate:AppDelegate {
//        get{
//            return UIApplication.shared.delegate as! AppDelegate
//        }
//    }
//
    static var realDelegate: AppDelegate?

    static var sharedAppdelegate: AppDelegate {
        if Thread.isMainThread{
            return UIApplication.shared.delegate as! AppDelegate;
        }
        
        let dg = DispatchGroup()
        dg.enter()
        DispatchQueue.main.async{
            realDelegate = UIApplication.shared.delegate as? AppDelegate;
            dg.leave()
        }
        dg.wait()
        return realDelegate!
    }
    
    static func addLanguageId(param: dictionary) -> dictionary{
        var param = param
        //if !param.isEmpty{
            param["lId"] = UserData.shared.languageID
        //}
        return param
    }
    
    func socialSignUp(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.socialSignUp, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    
    func acceptExtendservice(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.acceptExtendservice, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func deleteMedia(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.deleteMedia, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func deleteService(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.deleteServices, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func raisedDispute(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.raisedDispute, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func payForextEndService(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.payForExtendService, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func extendService(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.extendService, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    
    func providerTasks(vc:UIViewController, param: dictionary, isLoader:Bool = true, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.providerTasks, parameter: param, isLoader: isLoader) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    
    func acceptProposal(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.acceptProposal, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func sendProposal(vc:UIViewController?, param: dictionary, failer:failResponseBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.sendProposal, parameter: param, isLoader: true) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.dic ?? [:],responce.message ?? "")
            }
        }
    }
    
    func addProviderReview(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.addProviderReview, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func downloadInvoice(vc:UIViewController, serviceRequestId:String, failer:failureBlock? = nil, success:@escaping successBlock ){
        let paramConst:[String:Any] = [
            //lId:1
            "user_id":UserData.shared.getUser()!.user_id,
            "user_type":UserData.shared.getUser()!.user_type,
            "request_type":InvoiceKey.request_type,
            "invoice":InvoiceKey.invoice,
            "service_start_time":InvoiceKey.service_start_time,
            "service_end_time":InvoiceKey.service_end_time,
            "booking_id":InvoiceKey.booking_id,
            "booking_details":InvoiceKey.booking_details,
            "booking_amount":InvoiceKey.booking_amount,
            "admin_fees":InvoiceKey.admin_fees,
            "payment_type":InvoiceKey.payment_type,
            "total_payable_amount":InvoiceKey.total_payable_amount,
            "total_receivable_amount":InvoiceKey.total_receivable_amount,
            "wallet":InvoiceKey.wallet,
            "cash":InvoiceKey.cash,
            "complete":InvoiceKey.complete
        ]
        //param.forEach({ paramConst[$0.0] = $0.1; print("\($0.0):\($0.1)") })
        let url = EndPoint.downloadInvoice + serviceRequestId
        let param = Modal.addLanguageId(param: paramConst)
        WebRequester.shared.requests(url: url, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }

    /// Download bulk invoices for a period as a ZIP file
    /// - Parameters:
    ///   - vc: View controller for loader display
    ///   - period: "last_week", "last_month", or "custom"
    ///   - dateFrom: Start date in "YYYY-MM-DD" format (required if period is "custom")
    ///   - dateTo: End date in "YYYY-MM-DD" format (required if period is "custom")
    ///   - failer: Failure callback
    ///   - success: Success callback with response containing file_name (ZIP URL) and count
    func downloadBulkInvoices(vc: UIViewController, period: String, dateFrom: String? = nil, dateTo: String? = nil, failer: failureBlock? = nil, success: @escaping successBlock) {
        var param: [String: Any] = [
            "user_id": UserData.shared.getUser()!.user_id,
            "user_type": UserData.shared.getUser()!.user_type,
            "period": period
        ]

        if period == "custom", let from = dateFrom, let to = dateTo {
            param["date_from"] = from
            param["date_to"] = to
        }

        // Timeout esteso a 120 secondi come specificato nella PRD
        WebRequester.shared.requests(url: Domain.main + EndPoint.bulkInvoices, parameter: param, timeout: 120) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            } else {
                failer?(responce.message!)
            }
        }
    }
    
    func acceptService(vc:UIViewController?, param: dictionary, failer:failResponseBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.acceptService, parameter: param,isLoader: false) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.dic ?? [:],responce.message ?? "")
                
            }
        }
    }
    
    func cancelService(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){

        WebRequester.shared.requests(url: Domain.main + EndPoint.cancelService, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message ?? "")
            }
        }
    }
    
    func serviceRequestBookNow(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.serviceRequestBookNow, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func sendMessage(vc:UIViewController, param: dictionary, postImage: UIImage?, attachmentName:String?, fileData: Data?, failer:failureBlock? = nil, success:@escaping successBlock ){
        let param = Modal.addLanguageId(param: param)
        if let fileData = fileData{
            WebRequester.shared.requestsWithFileData(url: Domain.main + EndPoint.sendMessage, parameter: param, withFileData: fileData, withFileName: attachmentName!, withParamName: "attachment") { (result) in
                let responce = self.checkResponce(vc: vc, result: result)
                if responce.isSuccess {
                    success(responce.dic!)
                }
                else {
                    failer?(responce.message!)
                }
            }
        }
        else{
            WebRequester.shared.requestsWithImage(url: Domain.main + EndPoint.sendMessage, parameter: param, withPostImage: postImage, withPostImageName: attachmentName, withParamName: "attachment") { (result) in
                let responce = self.checkResponce(vc: vc, result: result)
                if responce.isSuccess {
                    success(responce.dic!)
                }
                else {
                    failer?(responce.message!)
                }
            }
        }
    }
    
    func getFavoriteService(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.getFavoriteService, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func sendDisputeMessage(vc:UIViewController, param: dictionary, postImage: UIImage?, imageName:String?, failer:failureBlock? = nil, success:@escaping successBlock ){
        let param = Modal.addLanguageId(param: param)
        WebRequester.shared.requestsWithImage(url: Domain.main + EndPoint.sendDisputeMessage, parameter: param, withPostImage: postImage, withPostImageName: imageName, withParamName: "user_img") { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func acceptDispute(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.acceptDispute, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func escalatetoadmin(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.escalateToAdmin, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getDisputedetails(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.getDisputedetails, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getDisputelist(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.getDisputelist, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func changePassword(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.changepassword, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func sendFeedBack(vc:UIViewController, param: dictionary, postImage: UIImage?, imageName:String?, failer:failureBlock? = nil, success:@escaping successBlock ){
        let param = Modal.addLanguageId(param: param)
        WebRequester.shared.requestsWithImage(url: Domain.main + EndPoint.feedback, parameter: param, withPostImage: postImage, withPostImageName: imageName, withParamName: "user_img") { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func updateNotificationSettings(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.updatenotification, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func addMyServices(vc:UIViewController?, param: dictionary, withPostImageAry postImgsAry:[UIImage] = [UIImage](), withPostImageNameAry imgNameAry:[String] = [String](), failer:failureBlock? = nil, success:@escaping successBlock ){
        /*
        WebRequester.shared.requests(url: Domin.main + EndPoint.addServices, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
        */
        let param = Modal.addLanguageId(param: param)
        WebRequester.shared.requestsWithImage(url: Domain.main + EndPoint.addServices, parameter: param, withPostImage: nil, withPostImageName: nil, withPostImageAry: postImgsAry, withPostImageNameAry: imgNameAry, withParamName: "service_image") { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
        
    }
    
    func getProviderServices(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.providerServices, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getFinancialInfo(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.financialInfo, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func providerReviews(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.providerReviews, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }

    func editProfile(vc:UIViewController, param: dictionary, postImage: UIImage?, imageName:String?,signImg: UIImage?, signImgName:String = "", failer:failureBlock? = nil, success:@escaping successBlock ){
//        WebRequester.shared.requests(url: Domin.main + EndPoint.editprofile, parameter: param) { (result) in
//            let responce = self.checkResponce(vc: vc, result: result)
//            if responce.isSuccess {
//                success(responce.dic!)
//            }
//            else {
//                failer?(responce.message!)
//            }
//        }
          let param = Modal.addLanguageId(param: param)
        WebRequester.shared.requestsWithImage(url: Domain.main + EndPoint.editprofile, parameter: param, withPostImage: postImage, withPostImageName: imageName, withParamName: "profile_pic",signImage:signImg, signImageName: signImgName,signParamName:"signature_img") { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func logOut(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.logout, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func socialLogin(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
//        first_name
//        last_name
//        login_type
//        social_id
//        email
        WebRequester.shared.requests(url: Domain.main + EndPoint.socialLogin, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func resendActivationMail(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //email, lId
        WebRequester.shared.requests(url: Domain.main + EndPoint.resendMail, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func contactus(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //user_id, email, message, firstName, lastName
        WebRequester.shared.requests(url: Domain.main + EndPoint.contactus, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    
    func inviteFriends(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.inviteFriends, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func inviteHistory(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.inviteHistory, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func sendServiceRequest(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.sendServiceRequest, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func providerServiceDetail(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.providerServiceDetail, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func likeDislikeServices(vc:UIViewController, param: dictionary, isLoader:Bool = true, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.likeDislikeServices, parameter: param, isLoader: isLoader) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func providerList(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.providerList, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func updateavAvailablestatus(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.updateavAvailablestatus, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func minmaxPrice(vc:UIViewController, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.minmaxPrice) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func paymentHistory(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.paymentHistory, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }

    func providerSidePaymentHistory(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.transectionhistory, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    func redeemHistory(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.redeemHistory, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func depositHistory(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success: @escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.depositHistory, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getCmsDetails(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.getCmsDetails, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getcmsList(vc:UIViewController,param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.getcmsList, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getLanguages(vc:UIViewController, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.getLanguages) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getNotificationList(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.getNotificationList, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getNotificationListing(vc:UIViewController, param: dictionary, isLoader:Bool = false, failer:failureBlock? = nil, success:@escaping successBlock ){
        if isLoader {
            Modal.sharedAppdelegate.startLoader()
        }
        WebRequester.shared.requests(url: Domain.main + EndPoint.getNotificationListing, parameter: param, isLoader: isLoader) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    
    func getCountryList(vc:UIViewController, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.getCountry) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getServiceList(vc:UIViewController?, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.serviceList, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }

    func getSubcategoryList(vc:UIViewController?, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.subcategoryList, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }

    func getCatagoryList(vc:UIViewController?, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.categoryList, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getForgotPassword(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.forgotPassword, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getDisputeListing(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.disputeListing, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getMessage(vc:UIViewController?, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.getMessage, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getMessageListing(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.getMessageListing, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getService(vc:UIViewController, param: dictionary, isLoader:Bool = true, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        //history / ongoing / past
        WebRequester.shared.requests(url: Domain.main + EndPoint.getService, parameter: param, isLoader: isLoader) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getCountryCode(vc:UIViewController,param: dictionary, failer:failureBlock? = nil, success:@escaping([Country])->Void ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.getCountryCode, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                let data = ResponseKey.fatchData(res: responce.dic!, valueOf: .data).ary
                success(data.map({Country(Data: $0 as! [String:Any])}))
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func login(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        var param = param
        param["device_type"] = "i"
        param["device_token"] = UserData.shared.deviceToken
        WebRequester.shared.requests(url: Domain.main + EndPoint.login, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func autoLogin(param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        var param = param
        param["device_type"] = "i"
        param["device_token"] = UserData.shared.deviceToken
        WebRequester.shared.requests(url: Domain.main + EndPoint.login, parameter: param, isLoader: false) { (result) in
            let responce = self.checkResponce(vc: nil, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func autoLoginAfterSocial(email: String, failer:failureBlock? = nil, success:@escaping successBlock ){
        let param = [
        "email":email,
        "device_type" : "i",
        "device_token" : UserData.shared.deviceToken        ]
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.afterSocialLogin, parameter: param, isLoader: false) { (result) in
            let responce = self.checkResponce(vc: nil, result: result)
            
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func signUp(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        var param = param
        param["device_type"] = "i"
        param["device_token"] = UserData.shared.deviceToken
        WebRequester.shared.requests(url: Domain.main + EndPoint.register, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getUserProfile(vc:UIViewController?, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.profile, parameter: param,isLoader: false) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getWalletDetails(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.walletDetail, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                print("Wallet Details Response:", responce.dic!)
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func redeemRequest(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.redeemRequest, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    func popularService(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.popularservice, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    func popularTask(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.populartasker, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    func deactive(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.deactiveuser, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    func getProviderServiceData(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.providerservice, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func flagUser(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        //Modal.sharedAppdelegate.startLoader()
        WebRequester.shared.requests(url: Domain.main + EndPoint.flagUser, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getSiteSettings(vc:UIViewController?, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
           //Modal.sharedAppdelegate.startLoader()
           WebRequester.shared.requests(url: Domain.main + EndPoint.getSiteSettingDataIos, parameter: param) { (result) in
               let responce = self.checkResponce(vc: vc, result: result)
               if responce.isSuccess {
                   success(responce.dic!)
               }
               else {
                   failer?(responce.message!)
               }
           }
       }
    
    func deliveryProviderList(vc:UIViewController, param: dictionary,isLoader:Bool = false, action:String,failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + action, parameter: param, isLoader: isLoader) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    func updateNotification(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.updatenotification, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func autoSaveNotificationSettings() {
        guard let user = UserData.shared.getUser(), user.user_id != "0" else { return }
        let param = ["user_id": user.user_id]
        getNotificationList(vc: UIViewController(), param: param, failer: { (errString) in
            print("Auto save notifications fetch failed: \(errString)")
        }, success: { (dic) in
            let notificationList = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({NotificationData(dictionary: $0 as! [String:Any])})
            var updateParam = ["user_id": user.user_id]
            for val in notificationList {
                updateParam[val.id] = (val.checked == "false" ? "n" : "y")
            }
            if notificationList.count > 0 {
                self.updateNotification(vc: UIViewController(), param: updateParam, failer: { (errorMsg) in
                    print("Auto save notifications failed: \(errorMsg)")
                }, success: { (response) in
                    print("Auto save notifications success: \(response)")
                })
            }
        })
    }
}


extension Modal{
    
    private func checkResponce(vc: UIViewController?, result: Result<Any>) -> (isSuccess:Bool, dic:dictionary? ,message:String?) {
        Modal.sharedAppdelegate.stoapLoader()
        switch result {
        case .success(let val):
            guard let dic = val as? dictionary else {
                print("Response is not a dictionary: \(val)")
                return (isSuccess: false, dic: nil, message: "Risposta non valida dal server")
            }
            if dic[keys.status.rawValue] as? Bool ?? false{
                return (isSuccess: true, dic: dic, message: nil)
            }else{
                guard let message = dic[keys.message.rawValue] as? String else { //server side respose false
                    print("Status is false but can't get error message")
                    return (isSuccess: false, dic: nil, message: nil)
                }
                if let vc = vc{
                    vc.alert(title: "", message: message)
                }
                return (isSuccess: false, dic: dic, message: message)
            }
        case .failure(let error):
            let strErr = error.localizedDescription
            if strErr == "The Internet connection appears to be offline." {//strErr == "Could not connect to the server." ||
                if let vc = vc{
//                    vc.alert(title: "", message: strErr, actions: ["Cancel","Settings"], completion: { (flag) in
//                        if flag == 1{ //Settings
//                            vc.open(scheme:UIApplicationOpenSettingsURLString)
//                        }
//                        else{ //== 0 Cancel
//                        }
//                    })
                }
            }
            return (isSuccess: false, dic: nil, message: strErr)
        }
    }
    
    func homeProviderServiceDetail(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.homeProviderServiceDetail, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func getStripeConnectUrl(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        WebRequester.shared.requests(url: Domain.main + EndPoint.stripeConnect, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
    func serviceRequestBookWithStripe(vc:UIViewController, param: dictionary, failer:failureBlock? = nil, success:@escaping successBlock ){
        
        WebRequester.shared.requests(url: Domain.main + EndPoint.serviceRequestBookStripe, parameter: param) { (result) in
            let responce = self.checkResponce(vc: vc, result: result)
            if responce.isSuccess {
                success(responce.dic!)
            }
            else {
                failer?(responce.message!)
            }
        }
    }
    
}

