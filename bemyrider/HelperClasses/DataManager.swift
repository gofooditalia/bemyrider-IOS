    //
    //  DataManager.swift
    //  bemyrider
    //
    //  Created by Nirav Sapariya on 19/05/18.
    //  Copyright © 2018 NMS. All rights reserved.
    //
    
    import UIKit
    
    class User: NSObject {
        
        //    "user_id": "81",
        //    "first_name": "Me",
        //    "last_name": "Ns",
        //    "user_name": "Me Ns",
        //    "user_type": "c",
        //    "email_id": "ns@mailinator.com",
        //    "country_code_id": "91"
        
        private let keys = ["user_id","first_name","last_name","user_name","user_type","email_id","country_code_id","currency_sign","profile_img","address",/*"mobileverify","city_shipping",
             "state_shipping","postal_code","address"*/]
        
        @objc var user_id = ""
        @objc var first_name = ""
        @objc var last_name = ""
        @objc var user_name = ""
        @objc var user_type = ""
        @objc var email_id = ""
        @objc var country_code_id = ""
        @objc var currency_sign = ""
        @objc var  profile_img = ""
        @objc var  address = ""
        
        //Additional
        @objc var  certified_email = ""
        @objc var  company_name = ""
        @objc var  contact_number = ""
        @objc var  isUserActive = ""
        @objc var  latitude = ""
        @objc var  longitude = ""
        @objc var  receipt_code = ""
        @objc var  tax_id = ""
        @objc var  vat = ""

        //    @objc var mobileverify = ""
        //    @objc var city_shipping = ""
        //    @objc var state_shipping = ""
        //    @objc var postal_code = ""
        //    @objc var address = ""
        //    @objc var isProvider = false
        
        override init() {
            super.init()
        }
        
        init(dic:[String:Any]) {
            super.init()
            self.user_id = dic["user_id"] as? String ?? ""
            self.first_name = dic["first_name"] as? String ?? dic["firstName"] as? String ?? ""
            self.last_name = dic["last_name"] as? String ?? dic["lastName"] as? String ?? ""
            self.user_name = dic["user_name"] as? String ?? ""
            self.user_type = dic["user_type"] as? String ?? ""
            self.email_id = dic["email_id"] as? String ?? ""
            self.country_code_id = dic["country_code_id"] as? String ?? ""
            self.currency_sign = dic["currency_sign"] as? String ?? "€"
            self.profile_img = dic["profile_img"] as? String ?? ""
            self.address = dic["address"] as? String ?? ""
            
            self.certified_email = dic["certified_email"] as? String ?? ""
            self.company_name = dic["company_name"] as? String ?? ""
            self.contact_number = dic["contact_number"] as? String ?? ""
            self.isUserActive = dic["isUserActive"] as? String ?? ""
            self.latitude = dic["latitude"] as? String ?? ""
            self.longitude = dic["longitude"] as? String ?? ""
            self.receipt_code = dic["receipt_code"] as? String ?? ""
            self.tax_id = dic["tax_id"] as? String ?? ""
            self.vat = dic["vat"] as? String ?? ""
            
            UserData.shared.setCurrency(currency: self.currency_sign)
            
            //        self.mobileverify = dic["mobileverify"] as? String ?? ""
            //        self.city_shipping = dic["city_shipping"] as? String ?? ""
            //        self.state_shipping = dic["state_shipping"] as? String ?? ""
            //        self.postal_code = dic["postal_code"] as? String ?? ""
            //        self.address = dic["address"] as? String ?? ""
            //        self.isProvider = ( (dic["user_type"] as? String ?? "") == "p" ? true : false )
        }
        
        init(userData dic:[String:Any]) {
            super.init()
            self.setValuesForKeys(dic)
            //self.isProvider = ( (dic["user_type"] as? String ?? "") == "p" ? true : false )
        }
        
        //This variable use for Convert Any Class type object into Dictionary type (Class properties become a Key in Dictionry and same for values also)
        var dictionary:[String:Any] {
            return self.dictionaryWithValues(forKeys: keys)
        }
        
    }
    
    
    class ServiceList: NSObject{
        
        private let keys = ["service_id", "category_id","sub_category_id","service_name","service_img","service_img_url","service_type","isactive","createdUser","createdDate","total"]
        
        @objc var service_id = ""
        @objc var provider_service_id = ""
        @objc var provider_id = ""
        @objc var category_id = ""
        @objc var sub_category_id = ""
        @objc var service_name = ""
        @objc var service_img = ""
        @objc var service_img_url = ""
        @objc var service_type = ""
        @objc var isactive = ""
        @objc var createdUser = ""
        @objc var createdDate = ""
        @objc var total : String = ""
        
        override init() {
            super.init()
        }
        
        init(dic:[String:Any]) {
            super.init()
            service_id = dic["service_id"] as? String ?? ""
            category_id = dic["category_id"] as? String ?? ""
            provider_service_id = dic["provider_service_id"] as? String ?? ""
            provider_id = dic["provider_id"] as? String ?? ""
            sub_category_id = dic["sub_category_id"] as? String ?? ""
            service_name = dic["service_name"] as? String ?? ""
            service_img = dic["service_img"] as? String ?? ""
            service_img_url = dic["service_img_url"] as? String ?? ""
            service_type = dic["service_type"] as? String ?? ""
            isactive = dic["isactive"] as? String ?? ""
            createdUser = dic["createdUser"] as? String ?? ""
            createdDate = dic["createdDate"] as? String ?? ""
            total = dic["total"] as? String ?? ""
        }
        
        init(dictionary:[String:Any]) {
            super.init()
            self.setValuesForKeys(dictionary)
        }
        
        var dictionary:[String:Any] {
            return self.dictionaryWithValues(forKeys: keys)
        }
        
    }
    
    class ProviderServiceDetail: NSObject{
        
        class MediaData: NSObject{
            
            private let keys = ["media_id", "media_url","media_name"]
            
            @objc var media_id = ""
            @objc var media_url = ""
            @objc var media_name = ""
            @objc var media_image = UIImage()
            
            override init() {
                super.init()
            }
            
            init(dic:[String:Any]) {
                super.init()
                media_id = "\(dic["media_id"] ?? "")"
                media_url = dic["media_url"] as? String ?? ""
                media_name = dic["media_name"] as? String ?? ""
                media_image = dic["media_image"] as? UIImage ?? UIImage()
            }
            
            init(dictionary:[String:Any]) {
                super.init()
                self.setValuesForKeys(dictionary)
            }
            
            var dictionary:[String:Any] {
                return self.dictionaryWithValues(forKeys: keys)
            }
            
        }
        
        class ReviewData: NSObject{
            
            private let keys = ["review_id", "created_user","rating","review","service_request_id","user_name","profile_img","created_date"]
            
            @objc var review_id = ""
            @objc var created_user = ""
            @objc var rating = ""
            @objc var review = ""
            @objc var service_request_id = ""
            @objc var user_name = ""
            @objc var profile_img = ""
            @objc var created_date = ""
            
            override init() {
                super.init()
            }
            
            init(dic:[String:Any]) {
                super.init()
                review_id = dic["review_id"] as? String ?? ""
                created_user = dic["created_user"] as? String ?? ""
                rating = dic["rating"] as? String ?? ""
                review = dic["review"] as? String ?? ""
                service_request_id = dic["service_request_id"] as? String ?? ""
                user_name = dic["user_name"] as? String ?? ""
                profile_img = dic["profile_img"] as? String ?? ""
                created_date = dic["created_date"] as? String ?? ""
            }
            
            init(dictionary:[String:Any]) {
                super.init()
                self.setValuesForKeys(dictionary)
            }
            
            var dictionary:[String:Any] {
                return self.dictionaryWithValues(forKeys: keys)
            }
            
        }
        
        private let keys = ["id","service_id","provider_service_id","provider_id", "category_id","subcategory_id","price","duration","_description","createdUser","user_name","first_name","last_name","about_me","email","contact_number","country_code","service_name","total_service","total_favorite","avg_rating","category_name","sub_category_name","provider_service_image","service_master_type","hours","provider_service_hours","provider_commission","payment_preference","start_time","end_time","service_description","service_status","service_status_dis","service_address","isFavorite","isReviewGiven","service_latitude","service_longitude","admin_fees","booking_hours","provider_image","customer_commission_amount","customer_commission","booking_amt","service_booking_id","customer_address","extend_service_data","proposal_service_data","request_type","delivery_type","total_fees"]
    
    @objc var id = ""
        @objc var service_id = ""
        @objc var provider_service_id = ""
        @objc var provider_id = ""

        @objc var category_id = ""
        @objc var subcategory_id = ""
        @objc var price = ""
        @objc var duration = ""
        @objc var _description = ""
        @objc var createdUser = ""
        @objc var user_name = ""
        @objc var first_name = ""
        @objc var last_name = ""
        @objc var about_me = ""
        @objc var email = ""
        @objc var contact_number = ""
        @objc var country_code = ""
        @objc var service_name = ""
        @objc var total_service = ""
        @objc var total_favorite = ""
        @objc var avg_rating = ""
        @objc var category_name = ""
        @objc var sub_category_name = ""
        @objc var provider_service_image = ""
        @objc var service_master_type = ""
        @objc var hours = ""
        @objc var provider_service_hours = ""
        @objc var provider_commission = ""
        @objc var media_data = [ProviderServiceDetail.MediaData]()
        @objc var review_data = [ProviderServiceDetail.ReviewData]()
        
        @objc var payment_preference = ""
        @objc var start_time = ""
        @objc var end_time = ""
        @objc var service_description = ""
        @objc var service_status = ""
        @objc var service_status_dis = ""
        @objc var service_address = ""
        @objc var isFavorite = ""
        @objc var isReviewGiven = ""
        @objc var service_latitude = ""
        @objc var service_longitude = ""
        @objc var admin_fees = 0.0
        @objc var provider_name = ""
        @objc var booking_hours = ""
        @objc var provider_image = ""
        @objc var customer_commission_amount = ""
        @objc var customer_commission = ""
        @objc var booking_amt = ""
        @objc var service_booking_id = ""
        @objc var customer_address = ""
        @objc var isactive = "y"
        @objc var request_type = ""
        @objc var delivery_type = ""
        @objc var total_fees = ""

        @objc var available_days_list = ""
        @objc var available_time_end = ""
        @objc var available_time_start = ""

        var extend_service_data = [ExtendServiceData]()
        var proposal_service_data = [ProposalServiceData]()
        
        override init() {
            super.init()
        }
        
        init(dic:[String:Any]) {
            super.init()
            id = "\(dic["id"] ?? "")"
            service_id = "\(dic["service_id"] ?? "")"
            let rawPsId = "\(dic["provider_service_id"] ?? "")"
            provider_service_id = rawPsId.isEmpty ? id : rawPsId
            provider_id = "\(dic["provider_id"] ?? "")"
            category_id = "\(dic["category_id"] ?? "")"
            subcategory_id = "\(dic["subcategory_id"] ?? "")"
            service_name = dic["service_name"] as? String ?? ""
            price = "\(dic["price"] ?? "")"
            duration = dic["duration"] as? String ?? ""
            _description = (dic["description"] as? String ?? "").removingPercentEncodingSafe()
            createdUser = dic["createdUser"] as? String ?? ""
            user_name = dic["user_name"] as? String ?? ""
            first_name = dic["first_name"] as? String ?? ""
            last_name = dic["last_name"] as? String ?? ""
            provider_name = first_name + " " + last_name
            about_me = (dic["about_me"] as? String ?? "").removingPercentEncodingSafe()
            email = dic["email"] as? String ?? ""
            contact_number = dic["contact_number"] as? String ?? ""
            country_code = dic["country_code"] as? String ?? ""
            createdUser = dic["createdUser"] as? String ?? ""
            total_service = dic["total_service"] as? String ?? ""
            total_favorite = dic["total_favorite"] as? String ?? ""
            avg_rating = String(dic["avg_rating"] as? Double ?? 0)
            category_name = dic["category_name"] as? String ?? ""
            sub_category_name = dic["sub_category_name"] as? String ?? ""
            provider_service_image = dic["provider_service_image"] as? String ?? ""
            service_master_type = dic["service_master_type"] as? String ?? ""
            hours = dic["hours"] as? String ?? ""
            provider_service_hours = dic["provider_service_hours"] as? String ?? ""
            provider_commission = dic["provider_commission"] as? String ?? ""
            payment_preference = dic["payment_preference"] as? String ?? ""
            start_time = dic["start_time"] as? String ?? ""
            end_time = dic["end_time"] as? String ?? ""
            service_description = (dic["service_description"] as? String ?? "").removingPercentEncodingSafe()
            service_status = dic["service_status"] as? String ?? ""
            service_status_dis = dic["service_status_dis"] as? String ?? ""
            service_address = dic["service_address"] as? String ?? ""
            isFavorite = dic["isFavorite"] as? String ?? ""
            isReviewGiven = dic["isReviewGiven"] as? String ?? ""
            service_latitude = dic["service_latitude"] as? String ?? ""
            service_longitude = dic["service_longitude"] as? String ?? ""
            admin_fees = dic["admin_fees"] as? Double ?? 0.0
            booking_hours = dic["booking_hours"] as? String ?? ""
            provider_image = dic["provider_image"] as? String ?? ""
            customer_commission_amount = dic["customer_commission_amount"] as? String ?? ""
            customer_commission = dic["customer_commission"] as? String ?? ""
            booking_amt = dic["booking_amt"] as? String ?? ""
            service_booking_id = dic["service_booking_id"] as? String ?? ""
            customer_address = dic["customer_address"] as? String ?? ""
            extend_service_data = (dic["extend_service_data"] as? [Any] ?? [Any]()).map({ExtendServiceData(dictionary: $0 as! [String:Any])})
            proposal_service_data = (dic["proposal_service_data"] as? [Any] ?? [Any]()).map({ProposalServiceData(dictionary: $0 as! [String:Any])})
            isactive = dic["isactive"] as? String ?? ""
            
            delivery_type = dic["delivery_type"] as? String ?? ""
            request_type = dic["request_type"] as? String ?? ""
            total_fees = dic["total_fees"] as? String ?? ""

            available_days_list = dic["available_days_list"] as? String ?? ""
            available_time_end = dic["available_time_end"] as? String ?? ""
            available_time_start = dic["available_time_start"] as? String ?? ""

            media_data = (dic["media_data"] as? [[String: Any]] ?? []).map { MediaData(dic: $0) }
            review_data = (dic["review_data"] as? [[String: Any]] ?? []).map { ReviewData(dic: $0) }

        }
        
        //    init(dictionary:[String:Any]) {
        //        super.init()
        //        self.setValuesForKeys(dictionary)
        //    }
        
        var dictionary:[String:Any] {
            return self.dictionaryWithValues(forKeys: keys)
        }
        
    }
    
    class InviteFriends: NSObject{
        
        private let keys = ["email", "status","credit_earn","invite_date"]
        
        @objc var email = ""
        @objc var status = ""
        @objc var credit_earn = ""
        @objc var invite_date = ""
        
        override init() {
            super.init()
        }
        
        init(dic:[String:Any]) {
            super.init()
            email = dic["email"] as? String ?? ""
            status = dic["status"] as? String ?? ""
            credit_earn = dic["credit_earn"] as? String ?? ""
            invite_date = dic["invite_date"] as? String ?? ""
        }
        init(dictionary:[String:Any]) {
            super.init()
            self.setValuesForKeys(dictionary)
        }
        
        var dictionary:[String:Any] {
            return self.dictionaryWithValues(forKeys: keys)
        }
    }
    
    class UserSocialData {
        //    var first_name : String = ""
        //    var last_name : String = ""
        //    var login_type : String = ""
        //    var email : String = ""
        //
        //
        //    required public init?(dictionary: [String:Any]) {
        //        first_name = dictionary["first_name"] as? String ?? ""
        //        last_name = dictionary["last_name"] as? String ?? ""
        //        login_type = dictionary["login_type"] as? String ?? ""
        //        email = dictionary["email"] as? String ?? ""
        //    }
        var first_name : String = ""
        var last_name : String = ""
        var user_type : String = ""
        var email_id : String = ""
        var user_id : String = ""
        var user_name : String = ""
        var country_code_id : String = ""
        var currency_sign : String = ""
        
        required public init?(dictionary: [String:Any]) {
            first_name = dictionary["first_name"] as? String ?? ""
            last_name = dictionary["last_name"] as? String ?? ""
            user_type = dictionary["user_type"] as? String ?? ""
            email_id = dictionary["email_id"] as? String ?? ""
            user_id = dictionary["user_id"] as? String ?? ""
            user_name = dictionary["user_name"] as? String ?? ""
            country_code_id = dictionary["country_code_id"] as? String ?? ""
            currency_sign = dictionary["currency_sign"] as? String ?? ""
        }
    }
    
    //class MyWallet {
    //
    //    var wallet_amount : String = ""
    //    var hold_amount : String = ""
    //    var redeem_requested_amount : String = ""
    //    var wallet_amount_usd : String = ""
    //    var address : String = ""
    //    var city_shipping : String = ""
    //    var state_shipping : String = ""
    //    var postal_code : String = ""
    //    var pAYTABS_MERCHANT_EMAIL : String = ""
    //    var pAYTABS_SECRET_KEY : String = ""
    //
    //    required public init?(dictionary: [String:Any]) {
    //        wallet_amount = dictionary["wallet_amount"] as? String ?? ""
    //        hold_amount = dictionary["hold_amount"] as? String ?? ""
    //        redeem_requested_amount = dictionary["redeem_requested_amount"] as? String ?? ""
    //        wallet_amount_usd = dictionary["wallet_amount_usd"] as? String ?? ""
    //        address = dictionary["address"] as? String ?? ""
    //        city_shipping = dictionary["city_shipping"] as? String ?? ""
    //        state_shipping = dictionary["state_shipping"] as? String ?? ""
    //        postal_code = dictionary["postal_code"] as? String ?? ""
    //        pAYTABS_MERCHANT_EMAIL = dictionary["PAYTABS_MERCHANT_EMAIL"] as? String ?? ""
    //        pAYTABS_SECRET_KEY = dictionary["PAYTABS_SECRET_KEY"] as? String ?? ""
    //    }
    //
    //    func dictionaryRepresentation() -> [String:Any] {
    //        var dictionary:[String:Any] = [:]
    //        dictionary["wallet_amount"] = self.wallet_amount
    //        dictionary["hold_amount"] = self.hold_amount
    //        dictionary["redeem_requested_amount"] = self.redeem_requested_amount
    //        dictionary["wallet_amount_usd"] = self.wallet_amount_usd
    //        dictionary["address"] = self.address
    //        dictionary["city_shipping"] = self.city_shipping
    //        dictionary["state_shipping"] = self.state_shipping
    //        dictionary["postal_code"] = self.postal_code
    //        dictionary["PAYTABS_MERCHANT_EMAIL"] = self.pAYTABS_MERCHANT_EMAIL
    //        dictionary["PAYTABS_SECRET_KEY"] = self.pAYTABS_SECRET_KEY
    //        return dictionary
    //    }
    //
    //}
    
    class UserProfile {
        var id : String = ""
        var user_name : String = ""
        var firstName : String = ""
        var lastName : String = ""
        var email : String = ""
        var user_type : String = ""
        var user_type_title : String = ""
        var contact_number : String = ""
        var profile_img : String = ""
        var description : String = ""
        var address : String = ""
        var landmark : String = ""
        var available_days : String = ""
        var available_days_list : String = ""
        var available_time_start : String = ""
        var available_time_end : String = ""
        var gmail_id : String = ""
        var fb_id : String = ""
        var linkedin_id : String = ""
        var positive_rating : String = ""
        var star_rating : Double? = 0.0
        var task_assigned : String = ""
        var total_review : String = ""
        var email_mask : String = ""
        var contact_mask : String = ""
        var latitude : String = ""
        var longitude : String = ""
        var country_code : String = ""
        var payment_mode : String = ""
        var paypal_email : String = ""
        var is_available : String = ""
        var total_service:String = ""
        var is_flag:String = ""
        
        var small_delivery:String = ""
        var medium_delivery:String = ""
        var large_delivery:String = ""

        var certified_email:String = ""
        var receipt_code:String = ""
        var tax_id:String = ""
        var vat:String = ""
        var company_name:String = ""
        
        var city_of_birth:String = ""
        var city_of_company:String = ""
        var city_of_residence:String = ""
        var residential_address:String = ""
        var date_of_birth:String = ""

        var signature_img_url:String = ""

        
        required public init?(dictionary: [String:Any]) {
            
            id = dictionary["id"] as? String ?? ""
            user_name = dictionary["user_name"] as? String ?? ""
            firstName = dictionary["firstName"] as? String ?? dictionary["first_name"] as? String ?? ""
            lastName = dictionary["lastName"] as? String ?? dictionary["last_name"] as? String ?? ""
            email = dictionary["email"] as? String ?? ""
            user_type = dictionary["user_type"] as? String ?? ""
            user_type_title = dictionary["user_type_title"] as? String ?? ""
            contact_number = dictionary["contact_number"] as? String ?? ""
            profile_img = dictionary["profile_img"] as? String ?? ""
            description = (dictionary["description"] as? String ?? "").removingPercentEncodingSafe()
            address = dictionary["address"] as? String ?? ""
            landmark = dictionary["landmark"] as? String ?? ""
            available_days = dictionary["available_days"] as? String ?? ""
            available_days_list = dictionary["available_days_list"] as? String ?? ""
            available_time_start = (dictionary["available_time_start"] as? String ?? "")
            available_time_end = dictionary["available_time_end"] as? String ?? ""
            gmail_id = dictionary["gmail_id"] as? String ?? ""
            fb_id = dictionary["fb_id"] as? String ?? ""
            linkedin_id = dictionary["linkedin_id"] as? String ?? ""
            positive_rating = dictionary["positive_rating"] as? String ?? ""
            star_rating = dictionary["star_rating"] as? Double ?? 0.0
            task_assigned = dictionary["task_assigned"] as? String ?? ""
            total_review = dictionary["total_review"] as? String ?? ""
            email_mask = dictionary["email_mask"] as? String ?? ""
            contact_mask = dictionary["contact_mask"] as? String ?? ""
            latitude = dictionary["latitude"] as? String ?? ""
            longitude = dictionary["longitude"] as? String ?? ""
            country_code = dictionary["country_code"] as? String ?? ""
            payment_mode = dictionary["payment_mode"] as? String ?? ""
            paypal_email = dictionary["paypal_email"] as? String ?? ""
            is_available = dictionary["is_available"] as? String ?? ""
            total_service = dictionary["total_service"] as? String ?? ""
            is_flag = dictionary["is_flag"] as? String ?? ""
            
            small_delivery = dictionary["small_delivery"] as? String ?? ""
            medium_delivery = dictionary["medium_delivery"] as? String ?? ""
            large_delivery = dictionary["large_delivery"] as? String ?? ""

            certified_email = dictionary["certified_email"] as? String ?? ""
            receipt_code = dictionary["receipt_code"] as? String ?? ""
            tax_id = dictionary["tax_id"] as? String ?? ""
            vat = dictionary["vat"] as? String ?? ""
            company_name = dictionary["company_name"] as? String ?? ""
            
            
            city_of_birth = dictionary["city_of_birth"] as? String ?? ""
            city_of_company = dictionary["city_of_company"] as? String ?? ""
            city_of_residence = dictionary["city_of_residence"] as? String ?? ""
            residential_address = dictionary["residential_address"] as? String ?? ""
            date_of_birth = dictionary["date_of_birth"] as? String ?? ""
            signature_img_url = dictionary["signature_img_url"] as? String ?? ""

            available_time_start.setNotAvailable()
            description.setNotAvailable()
            available_days_list.setNotAvailable()
            address.setNotAvailable()
            
        }
        
        
        var dictionaryRepresentation: [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.id, forKey: "id")
            dictionary.setValue(self.user_name, forKey: "user_name")
            dictionary.setValue(self.firstName, forKey: "firstName")
            dictionary.setValue(self.lastName, forKey: "lastName")
            dictionary.setValue(self.email, forKey: "email")
            dictionary.setValue(self.user_type, forKey: "user_type")
            dictionary.setValue(self.user_type_title, forKey: "user_type_title")
            dictionary.setValue(self.contact_number, forKey: "contact_number")
            dictionary.setValue(self.profile_img, forKey: "profile_img")
            dictionary.setValue(self.description, forKey: "description")
            dictionary.setValue(self.address, forKey: "address")
            dictionary.setValue(self.landmark, forKey: "landmark")
            dictionary.setValue(self.available_days, forKey: "available_days")
            dictionary.setValue(self.available_days_list, forKey: "available_days_list")
            dictionary.setValue(self.available_time_start, forKey: "available_time_start")
            dictionary.setValue(self.available_time_end, forKey: "available_time_end")
            dictionary.setValue(self.gmail_id, forKey: "gmail_id")
            dictionary.setValue(self.fb_id, forKey: "fb_id")
            dictionary.setValue(self.linkedin_id, forKey: "linkedin_id")
            dictionary.setValue(self.positive_rating, forKey: "positive_rating")
            dictionary.setValue(self.star_rating, forKey: "star_rating")
            dictionary.setValue(self.task_assigned, forKey: "task_assigned")
            dictionary.setValue(self.total_review, forKey: "total_review")
            dictionary.setValue(self.email_mask, forKey: "email_mask")
            dictionary.setValue(self.contact_mask, forKey: "contact_mask")
            dictionary.setValue(self.latitude, forKey: "latitude")
            dictionary.setValue(self.longitude, forKey: "longitude")
            dictionary.setValue(self.country_code, forKey: "country_code")
            dictionary.setValue(self.payment_mode, forKey: "payment_mode")
            dictionary.setValue(self.paypal_email, forKey: "paypal_email")
            dictionary.setValue(self.is_available, forKey: "is_available")
            dictionary.setValue(self.is_flag, forKey: "is_flag")
            
            return dictionary as! [String:Any]
        }
        
    }
    
    struct Country{
        
        var id : String
        var country_name : String
        var country_code : String
        
        init(Data:[String:Any]) {
            self.id = Data["id"] as? String ?? ""
            self.country_name = Data["country_name"] as? String ?? ""
            self.country_code = Data["country_code"] as? String ?? ""
        }
        
        var dictionaryRepresentation: [String:Any] {
            var dictionary:[String:Any] = [:]
            dictionary["id"] = self.id
            dictionary["country_name"] = self.country_name
            dictionary["country_code"] = self.country_code
            return dictionary
        }
        
    }
    
    class MessageListCls {
        
        var usersList: [MessageList] = [MessageList]()
        var pagination: Pagination?
        
        required init(dictionary: [String:Any]) {
            print("MessageListCls init:", dictionary)
            usersList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["list"] as! [Any]).map({MessageList(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
        }
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 1
            var currentPage : Int = 1
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 1
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
    }
    
    class MessageList {
        var message_id : String = ""
        var service_id : String = ""
        var service_master_id : String = ""
        var message_text : String = ""
        var isRead : String = ""
        var createdDate : String = ""
        var service_name : String = ""
        var to_user : String = ""
        var to_user_name : String = ""
        var to_user_email : String = ""
        var to_user_type : String = ""
        var to_profile_img : String = ""
        var appAttUrl : String = ""
        
        
        required init(dictionary: [String:Any]) {
            message_id = dictionary["message_id"] as? String ?? ""
            service_id = dictionary["service_id"] as? String ?? ""
            service_master_id = dictionary["service_master_id"] as? String ?? ""
            message_text = (dictionary["message_text"] as? String ?? "").removingPercentEncodingSafe()
            isRead = dictionary["isRead"] as? String ?? ""
            createdDate = dictionary["createdDate"] as? String ?? ""
            service_name = (dictionary["service_name"] as? String ?? "").removingPercentEncodingSafe()
            to_user = dictionary["to_user"] as? String ?? ""
            to_user_name = dictionary["to_user_name"] as? String ?? ""
            to_user_email = dictionary["to_user_email"] as? String ?? ""
            to_user_type = dictionary["to_user_type"] as? String ?? ""
            to_profile_img = dictionary["to_profile_img"] as? String ?? ""
            appAttUrl = dictionary["appAttUrl"] as? String ?? ""
        }
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.message_id, forKey: "message_id")
            dictionary.setValue(self.service_id, forKey: "service_id")
            dictionary.setValue(self.service_master_id, forKey: "service_master_id")
            dictionary.setValue(self.message_text, forKey: "message_text")
            dictionary.setValue(self.isRead, forKey: "isRead")
            dictionary.setValue(self.createdDate, forKey: "createdDate")
            dictionary.setValue(self.service_name, forKey: "service_name")
            dictionary.setValue(self.to_user, forKey: "to_user")
            dictionary.setValue(self.to_user_name, forKey: "to_user_name")
            dictionary.setValue(self.to_user_email, forKey: "to_user_email")
            dictionary.setValue(self.to_user_type, forKey: "to_user_type")
            dictionary.setValue(self.to_profile_img, forKey: "to_profile_img")
            dictionary.setValue(self.appAttUrl, forKey: "appAttUrl")
            
            return dictionary as! [String:Any]
        }
        
    }
    
    class MessageCls {
        
        var conversationList: [Message] = [Message]()
        var pagination: Pagination?
        var isactive:String = "y"
        var my_profile_img:String = ""
        var my_user_email:String = ""
        var my_user_name:String = ""
        var my_user_type:String = ""
        var ser_active:String = ""
        var service_id:String = ""
        var service_master_id:String = ""
        var service_name:String = ""
        var to_profile_img:String = ""
        var to_user_email:String = ""
        var to_user_name:String = ""
        var to_user_type:String = ""
        var user_id:String = ""
        
        
        required init(dictionary: [String:Any]) {
            print("MessageCls init:", dictionary)
            conversationList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["message_list"] as! [Any]).map({Message(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
            
            isactive = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["isactive"] as? String ?? "y"
            my_profile_img = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["my_profile_img"] as? String ?? "y"
            my_user_email = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["my_user_email"] as? String ?? ""
            my_user_name = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["my_user_name"] as? String ?? ""
            my_user_type = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["my_user_type"] as? String ?? ""
            ser_active = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["ser_active"] as? String ?? ""
            service_id = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_id"] as? String ?? ""
            service_master_id = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_master_id"] as? String ?? ""
            service_name = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_name"] as? String ?? ""
            to_profile_img = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["to_profile_img"] as? String ?? ""
            to_user_email = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["to_user_email"] as? String ?? ""
            to_user_name = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["to_user_name"] as? String ?? ""
            to_user_type = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["to_user_type"] as? String ?? ""
            user_id = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["user_id"] as? String ?? ""
        }
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 0
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 0
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
    }
    
    class Message {
        var appAttUrl : String = ""
        var created_date : String = ""
        var from_user : String = ""
        var isRead : String = ""
        var message_id : String = ""
        var message_text : String = ""
        var msgType : String = ""
        var to_user : String = ""
        
        
        required init(dictionary: [String:Any]) {
            
            appAttUrl = dictionary["appAttUrl"] as? String ?? ""
            created_date = dictionary["created_date"] as? String ?? ""
            from_user = dictionary["from_user"] as? String ?? ""
            isRead = dictionary["isRead"] as? String ?? ""
            message_id = dictionary["message_id"] as? String ?? ""
            message_text = (dictionary["message_text"] as? String ?? "").removingPercentEncodingSafe()
            msgType = dictionary["msgType"] as? String ?? ""
            to_user = dictionary["to_user"] as? String ?? ""

        }


        /**
         Returns the dictionary representation for the current instance.

         - returns: Dictionary.
         */
        public func dictionaryRepresentation() -> [String:Any] {

            let dictionary = NSMutableDictionary()

            dictionary.setValue(self.appAttUrl, forKey: "appAttUrl")
            dictionary.setValue(self.created_date, forKey: "created_date")
            dictionary.setValue(self.from_user, forKey: "from_user")
            dictionary.setValue(self.isRead, forKey: "isRead")
            
            dictionary.setValue(self.message_id, forKey: "message_id")
            dictionary.setValue(self.message_text, forKey: "message_text")
            dictionary.setValue(self.msgType, forKey: "msgType")
            dictionary.setValue(self.to_user, forKey: "to_user")
            
            
            return dictionary as! [String:Any]
        }
        
    }
    
    class ReviewCls {
        
        var pagination: Pagination?
        var reviewList: [Review] = []

               required init(dictionary: [String:Any]) {
                   print("ReviewCls init:", dictionary)
                   reviewList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["review_list"] as! [Any]).map({Review(dictionary: $0 as! [String:Any])})
                   pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
               }
        
        class Pagination {
               var total_records : Int = 0
               var total_pages : Int = 0
               var currentPage : Int = 0
               
               required init(dictionary: [String:Any]) {
                   total_records = dictionary["total_records"] as? Int ?? 0
                   total_pages = dictionary["total_pages"] as? Int ?? 0
                   currentPage = dictionary["currentPage"] as? Int ?? 0
               }
               
               func dictionaryRepresentation() -> [String:Any] {
                   let dictionary = NSMutableDictionary()
                   dictionary.setValue(self.total_records, forKey: "total_records")
                   dictionary.setValue(self.total_pages, forKey: "total_pages")
                   dictionary.setValue(self.currentPage, forKey: "currentPage")
                   return dictionary as! [String:Any]
               }
           }
        
    }
    
    class Review {
        var review_id : String = ""
        var user_name : String = ""
        var created_user : String = ""
        var address : String = ""
        var provider_service_id : String = ""
        var service_master_id : String = ""
        var user_image : String = ""
        var provider_email : String = ""
        var service_name : String = ""
        var category_name : String = ""
        var sub_category_name : String = ""
        var review_rating : String = ""
        var review_desc : String = ""
        var review_date : String = ""
        var isactive: String = "y"
        
        
        required public init(dictionary: [String:Any]) {
            review_id = dictionary["review_id"] as? String ?? ""
            user_name = dictionary["user_name"] as? String ?? ""
            created_user = dictionary["created_user"] as? String ?? ""
            address = dictionary["address"] as? String ?? ""
            provider_service_id = dictionary["provider_service_id"] as? String ?? ""
            service_master_id = dictionary["service_master_id"] as? String ?? ""
            user_image = dictionary["user_image"] as? String ?? ""
            provider_email = dictionary["provider_email"] as? String ?? ""
            service_name = dictionary["service_name"] as? String ?? ""
            category_name = dictionary["category_name"] as? String ?? ""
            sub_category_name = dictionary["sub_category_name"] as? String ?? ""
            review_rating = dictionary["review_rating"] as? String ?? ""
            review_desc = dictionary["review_desc"] as? String ?? ""
            review_date = dictionary["review_date"] as? String ?? ""
            isactive = dictionary["isactive"] as? String ?? "y"
        }
        
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        public func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.review_id, forKey: "review_id")
            dictionary.setValue(self.user_name, forKey: "user_name")
            dictionary.setValue(self.created_user, forKey: "created_user")
            dictionary.setValue(self.address, forKey: "address")
            dictionary.setValue(self.provider_service_id, forKey: "provider_service_id")
            dictionary.setValue(self.service_master_id, forKey: "service_master_id")
            dictionary.setValue(self.user_image, forKey: "user_image")
            dictionary.setValue(self.provider_email, forKey: "provider_email")
            dictionary.setValue(self.service_name, forKey: "service_name")
            dictionary.setValue(self.category_name, forKey: "category_name")
            dictionary.setValue(self.sub_category_name, forKey: "sub_category_name")
            dictionary.setValue(self.review_rating, forKey: "review_rating")
            dictionary.setValue(self.review_desc, forKey: "review_desc")
            dictionary.setValue(self.review_date, forKey: "review_date")
            
            return dictionary as! [String:Any]
        }
        
    }
    
    
    class FinancialInfo {
        var total_completed_service : Int = 0
        var total_earned : String = ""
        var total_commission : String = ""
        var total_net_earned : String = ""
        
        
        required init(dictionary: [String:Any]) {
            //        total_completed_service = String(dictionary["total_completed_service"] as? Double ?? 0.0)
            //        total_earned = dictionary["total_earned"] as? String ?? ""
            //        total_commission = String(dictionary["total_commission"] as? Double ?? 0.0)
            //        total_net_earned = String(dictionary["total_net_earned"] as? Double ?? 0.0)
            total_completed_service = dictionary["total_completed_service"] as? Int ?? 0
            total_earned = dictionary["total_earned"] as? String ?? "0"
            total_commission = dictionary["total_commission"] as? String ?? "0"
            total_net_earned = dictionary["total_net_earned"] as? String ?? "0"
        }
        
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        public func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.total_completed_service, forKey: "total_completed_service")
            dictionary.setValue(self.total_earned, forKey: "total_earned")
            dictionary.setValue(self.total_commission, forKey: "total_commission")
            dictionary.setValue(self.total_net_earned, forKey: "total_net_earned")
            
            return dictionary as! [String:Any]
        }
        
    }
    
    class ProviderServiceCls {
        var serviceList: [ProviderService] = [ProviderService]()
               var pagination: Pagination?
               
               required init(dictionary: [String:Any]) {
                   print("ProviderServiceCls init:", dictionary)
                   serviceList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_list"] as! [Any]).map({ProviderService(dictionary: $0 as! [String:Any])})
                   pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
               }
               
        class Pagination {
                   var total_records : Int = 0
                   var total_pages : Int = 0
                   var currentPage : Int = 0
                   
                   required init(dictionary: [String:Any]) {
                       total_records = dictionary["total_records"] as? Int ?? 0
                       total_pages = dictionary["total_pages"] as? Int ?? 0
                       currentPage = dictionary["currentPage"] as? Int ?? 0
                   }
                   
                   func dictionaryRepresentation() -> [String:Any] {
                       let dictionary = NSMutableDictionary()
                       dictionary.setValue(self.total_records, forKey: "total_records")
                       dictionary.setValue(self.total_pages, forKey: "total_pages")
                       dictionary.setValue(self.currentPage, forKey: "currentPage")
                       return dictionary as! [String:Any]
                   }
               }
    }
    
    class ProviderService {
        var provider_service_id : String = ""
        var service_name : String = ""
        var service_id : String = ""
        var price : String = ""
        var duration : String = ""
        var description : String = ""
        var service_description : String = ""
        var user_type : String = ""
        var address : String = ""
        var user_id : String = ""
        var category_id : String = ""
        var category_name : String = ""
        var subcategory_id : String = ""
        var subcategory_name : String = ""
        var service_type : String = ""
        var service_image : String = ""
        
        
        required init(dictionary: [String:Any]) {

            provider_service_id = "\(dictionary["provider_service_id"] ?? "")"
            service_name = dictionary["service_name"] as? String ?? ""
            service_id = "\(dictionary["service_id"] ?? "")"
            price = "\(dictionary["price"] ?? "")"
            duration = dictionary["duration"] as? String ?? ""
            description = (dictionary["description"] as? String ?? "").removingPercentEncodingSafe()
            service_description = (dictionary["service_description"] as? String ?? "").removingPercentEncodingSafe()
            user_type = dictionary["user_type"] as? String ?? ""
            address = dictionary["address"] as? String ?? ""
            user_id = "\(dictionary["user_id"] ?? "")"
            category_id = "\(dictionary["category_id"] ?? "")"
            category_name = dictionary["category_name"] as? String ?? ""
            subcategory_id = "\(dictionary["subcategory_id"] ?? "")"
            subcategory_name = dictionary["subcategory_name"] as? String ?? ""
            service_type = dictionary["service_type"] as? String ?? ""
            service_image = dictionary["service_image"] as? String ?? ""
        }
        
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.provider_service_id, forKey: "provider_service_id")
            dictionary.setValue(self.service_name, forKey: "service_name")
            dictionary.setValue(self.service_id, forKey: "service_id")
            dictionary.setValue(self.price, forKey: "price")
            dictionary.setValue(self.duration, forKey: "duration")
            dictionary.setValue(self.description, forKey: "description")
            dictionary.setValue(self.service_description, forKey: "service_description")
            dictionary.setValue(self.user_type, forKey: "user_type")
            dictionary.setValue(self.address, forKey: "address")
            dictionary.setValue(self.user_id, forKey: "user_id")
            dictionary.setValue(self.category_id, forKey: "category_id")
            dictionary.setValue(self.category_name, forKey: "category_name")
            dictionary.setValue(self.subcategory_id, forKey: "subcategory_id")
            dictionary.setValue(self.subcategory_name, forKey: "subcategory_name")
            dictionary.setValue(self.service_type, forKey: "service_type")
            dictionary.setValue(self.service_image, forKey: "service_image")
            
            return dictionary as! [String:Any]
        }
        
    }
    
    class Category {
        var category_id : String = ""
        var category_name : String = ""
        var category_small_banner : String = ""
        var category_banner_img : String = ""
        var description : String = ""
        var isFeatured : String = ""
        var small_banner_url : String = ""
        var banner_url : String = ""
        
        required init(dictionary: [String:Any]) {
            
            category_id = dictionary["category_id"] as? String ?? ""
            category_name = dictionary["category_name"] as? String ?? ""
            category_small_banner = dictionary["category_small_banner"] as? String ?? ""
            category_banner_img = dictionary["category_banner_img"] as? String ?? ""
            description = (dictionary["description"] as? String ?? "").removingPercentEncodingSafe()
            isFeatured = dictionary["isFeatured"] as? String ?? ""
            small_banner_url = dictionary["small_banner_url"] as? String ?? ""
            banner_url = dictionary["banner_url"] as? String ?? ""
        }
        
        /**
         Returns the dictionary representation for the current instance.
         - returns: Dictionary.
         */
        func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.category_id, forKey: "category_id")
            dictionary.setValue(self.category_name, forKey: "category_name")
            dictionary.setValue(self.category_small_banner, forKey: "category_small_banner")
            dictionary.setValue(self.category_banner_img, forKey: "category_banner_img")
            dictionary.setValue(self.description, forKey: "description")
            dictionary.setValue(self.isFeatured, forKey: "isFeatured")
            dictionary.setValue(self.small_banner_url, forKey: "small_banner_url")
            dictionary.setValue(self.banner_url, forKey: "banner_url")
            
            return dictionary as! [String:Any]
        }
        
    }
    
    //TODO: Crash issue
    class NotificationCls{
        var notificationList: [NotificationList] = [NotificationList]()
        var pagination: Pagination?
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            notificationList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["notificationList"] as! [Any]).map({NotificationList(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
        }
        
        class NotificationList {
            var user_name : String = ""
            var image : String = ""
            var user_type : String = ""
            var notification_date : String = ""
            var message : String = ""
            var service_request_id:String = ""
            var provider_service_id:String = ""
            var notification_type:String = ""
            var isactive:String = ""
            var customer_id:Int = 0
            var dispute_id:Int = 0
            var notification_constant:String = ""
            var provider_id:String = ""
            var service_id:String = ""
            var service_status:String = ""
            
            
            
            required init(dictionary: [String:Any]) {
                user_name = dictionary["user_name"] as? String ?? ""
                image = dictionary["image"] as? String ?? ""
                user_type = dictionary["user_type"] as? String ?? ""
                notification_date = dictionary["notification_date"] as? String ?? ""
                message = dictionary["message"] as? String ?? ""
                service_request_id = dictionary["service_request_id"] as? String ?? ""
                provider_service_id = dictionary["provider_service_id"] as? String ?? ""
                notification_type = dictionary["notification_type"] as? String ?? ""
                isactive = dictionary["isactive"] as? String ?? "y"
                
                customer_id = dictionary["customer_id"] as? Int ?? 0
                dispute_id = dictionary["dispute_id"] as? Int ?? 0
                notification_constant = dictionary["notification_constant"] as? String ?? "y"
                provider_id = dictionary["provider_id"] as? String ?? "y"
                service_id = dictionary["service_id"] as? String ?? "y"
                service_status = dictionary["service_status"] as? String ?? "y"
                
                
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.user_name, forKey: "user_name")
                dictionary.setValue(self.image, forKey: "image")
                dictionary.setValue(self.user_type, forKey: "user_type")
                dictionary.setValue(self.notification_date, forKey: "notification_date")
                dictionary.setValue(self.message, forKey: "message")
                dictionary.setValue(self.service_request_id, forKey: "service_request_id")
                dictionary.setValue(self.provider_service_id, forKey: "provider_service_id")
                dictionary.setValue(self.notification_type, forKey: "notification_type")
                dictionary.setValue(self.isactive, forKey: "isactive")
                dictionary.setValue(self.customer_id, forKey: "customer_id")
                dictionary.setValue(self.dispute_id, forKey: "dispute_id")
                dictionary.setValue(self.notification_constant, forKey: "notification_constant")
                dictionary.setValue(self.provider_id, forKey: "provider_id")
                dictionary.setValue(self.service_id, forKey: "service_id")
                dictionary.setValue(self.service_status, forKey: "service_status")
                return dictionary as! [String:Any]
            }
        }
        
        class Pagination {
                   var total_records : Int = 0
                   var total_pages : Int = 0
                   var currentPage : Int = 0
                   
                   required init(dictionary: [String:Any]) {
                       total_records = dictionary["total_records"] as? Int ?? 0
                       total_pages = dictionary["total_pages"] as? Int ?? 0
                       currentPage = dictionary["currentPage"] as? Int ?? 0
                   }
                   
                   func dictionaryRepresentation() -> [String:Any] {
                       let dictionary = NSMutableDictionary()
                       dictionary.setValue(self.total_records, forKey: "total_records")
                       dictionary.setValue(self.total_pages, forKey: "total_pages")
                       dictionary.setValue(self.currentPage, forKey: "currentPage")
                       return dictionary as! [String:Any]
                   }
               }
        
       
    }
    
    class NotificationData {
        var id : String = ""
        var title : String = ""
        var checked : String = ""
        
        required init(dictionary: [String:Any]) {
            id = dictionary["id"] as? String ?? ""
            title = dictionary["title"] as? String ?? ""
            checked = dictionary["checked"] as? String ?? ""
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.id, forKey: "id")
            dictionary.setValue(self.title, forKey: "title")
            dictionary.setValue(self.checked, forKey: "checked")
            return dictionary as! [String:Any]
        }
    }
    
    class ServerLanguage {
        var id : String = ""
        var languageName : String = ""
        var default_lan : String = ""
        
        required init(dictionary: [String:Any]) {
            id = dictionary["id"] as? String ?? ""
            languageName = (dictionary["languageName"] as? String ?? "").capitalized
            default_lan = dictionary["default_lan"] as? String ?? ""
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.id, forKey: "id")
            dictionary.setValue(self.languageName, forKey: "languageName")
            dictionary.setValue(self.default_lan, forKey: "default_lan")
            return dictionary as! [String:Any]
        }
    }
    
    class infoData {
        var id : String = ""
        var pageTitle : String = ""
        var pageUrl : String = ""
        
        required init(dictionary: [String:Any]) {
            id = dictionary["id"] as? String ?? ""
            pageTitle = (dictionary["page_title"] as? String ?? "").capitalized
            pageUrl = dictionary["url"] as? String ?? ""
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.id, forKey: "id")
            dictionary.setValue(self.pageTitle, forKey: "page_title")
            dictionary.setValue(self.pageUrl, forKey: "url")
            return dictionary as! [String:Any]
        }
    }
    
    class DisputeCls {
        
        var disputeList: [Dispute] = [Dispute]()
        var pagination: Pagination?
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            disputeList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["dispute_list"] as! [Any]).map({Dispute(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
        }
        
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 0
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 0
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
    }
    
    class Dispute {
        var dispute_id : String = ""
        var customer_id : String = ""
        var provider_id : String = ""
        var dispute_title : String = ""
        var status : String = ""
        var created_user : String = ""
        var createdDate : String = ""
        var service_id : String = ""
        var service_request_id : String = ""
        var customer_firstname : String = ""
        var customer_lastname : String = ""
        var customer_img : String = ""
        var provider_firstname : String = ""
        var provider_lastname : String = ""
        var provider_img : String = ""
        var service_name : String = ""
        var dispute_message : String = ""
        var dispute_message_date : String = ""
        
        required init(dictionary: [String:Any]) {
            
            dispute_id = dictionary["dispute_id"] as? String ?? ""
            customer_id = dictionary["customer_id"] as? String ?? ""
            provider_id = dictionary["provider_id"] as? String ?? ""
            dispute_title = dictionary["dispute_title"] as? String ?? ""
            status = dictionary["status"] as? String ?? ""
            created_user = dictionary["created_user"] as? String ?? ""
            createdDate = dictionary["createdDate"] as? String ?? ""
            service_id = dictionary["service_id"] as? String ?? ""
            service_request_id = dictionary["service_request_id"] as? String ?? ""
            customer_firstname = dictionary["customer_firstname"] as? String ?? ""
            customer_lastname = dictionary["customer_lastname"] as? String ?? ""
            customer_img = dictionary["customer_img"] as? String ?? ""
            provider_firstname = dictionary["provider_firstname"] as? String ?? ""
            provider_lastname = dictionary["provider_lastname"] as? String ?? ""
            provider_img = dictionary["provider_img"] as? String ?? ""
            service_name = dictionary["service_name"] as? String ?? ""
            dispute_message = dictionary["dispute_message"] as? String ?? ""
            dispute_message_date = dictionary["dispute_message_date"] as? String ?? ""
        }
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.dispute_id, forKey: "dispute_id")
            dictionary.setValue(self.customer_id, forKey: "customer_id")
            dictionary.setValue(self.provider_id, forKey: "provider_id")
            dictionary.setValue(self.dispute_title, forKey: "dispute_title")
            dictionary.setValue(self.status, forKey: "status")
            dictionary.setValue(self.created_user, forKey: "created_user")
            dictionary.setValue(self.createdDate, forKey: "createdDate")
            dictionary.setValue(self.service_id, forKey: "service_id")
            dictionary.setValue(self.service_request_id, forKey: "service_request_id")
            dictionary.setValue(self.customer_firstname, forKey: "customer_firstname")
            dictionary.setValue(self.customer_lastname, forKey: "customer_lastname")
            dictionary.setValue(self.customer_img, forKey: "customer_img")
            dictionary.setValue(self.provider_firstname, forKey: "provider_firstname")
            dictionary.setValue(self.provider_lastname, forKey: "provider_lastname")
            dictionary.setValue(self.provider_img, forKey: "provider_img")
            dictionary.setValue(self.service_name, forKey: "service_name")
            dictionary.setValue(self.dispute_message, forKey: "dispute_message")
            dictionary.setValue(self.dispute_message_date, forKey: "dispute_message_date")
            
            return dictionary as! [String:Any]
        }
    }
    
    class DisputeMsgCls {
        
        var disputeMsgList: [DisputeMsg] = [DisputeMsg]()
        var pagination: Pagination?
        
        var dispute_id : String = ""
        var customer_id : String = ""
        var provider_id : String = ""
        var dispute_title : String = ""
        var status : String = ""
        var customer_firstname : String = ""
        var customer_lastname : String = ""
        var customer_image : String = ""
        var provider_firstname : String = ""
        var provider_lastname : String = ""
        var provider_image : String = ""
        var service_status : String = ""
        var escalate_admin : String = ""
        var cust_active : String = ""
        var pro_active : String = ""
        var dispute_create_userid : String = ""
        var service_request_id : String = ""
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            disputeMsgList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["message_list"] as! [Any]).map({DisputeMsg(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
            
            dispute_id = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["dispute_id"] as? String ?? ""
            customer_id = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["customer_id"] as? String ?? customer_id
            provider_id = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["provider_id"] as? String ?? ""
            dispute_title = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["dispute_title"] as? String ?? ""
            status = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["status"] as? String ?? ""
            customer_firstname = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["customer_firstname"] as? String ?? ""
            customer_lastname = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["customer_lastname"] as? String ?? ""
            customer_image = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["customer_image"] as? String ?? ""
            provider_firstname = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["provider_firstname"] as? String ?? ""
            provider_lastname = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["provider_lastname"] as? String ?? ""
            provider_image = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["provider_image"] as? String ?? ""
            service_status = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_status"] as? String ?? ""
            escalate_admin = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["escalate_admin"] as? String ?? ""
            cust_active = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["cust_active"] as? String ?? ""
            pro_active = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pro_active"] as? String ?? ""
            dispute_create_userid = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["dispute_create_userid"] as? String ?? ""
            service_request_id = ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_request_id"] as? String ?? ""

        }
        
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 0
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 0
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
    }
    
    class DisputeMsg {
        var message_id : String = ""
        var dispute_message : String = ""
        var created_user : String = ""
        var created_user_type : String = ""
        var createdDate : String = ""
        var appAttUrl : String = ""
        var downloadUrl : String = ""
        
        required init(dictionary: [String:Any]) {
            
            message_id = dictionary["message_id"] as? String ?? ""
            dispute_message = dictionary["dispute_message"] as? String ?? ""
            created_user = dictionary["created_user"] as? String ?? ""
            created_user_type = dictionary["created_user_type"] as? String ?? ""
            createdDate = dictionary["createdDate"] as? String ?? ""
            appAttUrl = dictionary["appAttUrl"] as? String ?? ""
            downloadUrl = dictionary["downloadUrl"] as? String ?? ""
        }
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.message_id, forKey: "message_id")
            dictionary.setValue(self.dispute_message, forKey: "dispute_message")
            dictionary.setValue(self.created_user, forKey: "created_user")
            dictionary.setValue(self.created_user_type, forKey: "created_user_type")
            dictionary.setValue(self.createdDate, forKey: "createdDate")
            dictionary.setValue(self.appAttUrl, forKey: "appAttUrl")
            dictionary.setValue(self.downloadUrl, forKey: "downloadUrl")
            
            return dictionary as! [String:Any]
        }
    }
    
    class RedeemHistory {
        
        var requested_amount : String = ""
        var admin_fees : String = ""
        var requested_date : String = ""
        var redeemed_amount : String = ""
        var redeemed_date : String = ""
        
        required init(dictionary: [String:Any]) {
            requested_amount = dictionary["requested_amount"] as? String ?? ""
            admin_fees = dictionary["admin_fees"] as? String ?? ""
            requested_date = dictionary["requested_date"] as? String ?? ""
            redeemed_amount = dictionary["redeemed_amount"] as? String ?? ""
            redeemed_date = dictionary["redeemed_date"] as? String ?? ""
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.requested_amount, forKey: "requested_amount")
            dictionary.setValue(self.admin_fees, forKey: "admin_fees")
            dictionary.setValue(self.requested_date, forKey: "requested_date")
            dictionary.setValue(self.redeemed_amount, forKey: "redeemed_amount")
            dictionary.setValue(self.redeemed_date, forKey: "redeemed_date")
            return dictionary as! [String:Any]
        }
    }
    
    class MyWallet {
        
        var wallet_amount : String = ""
        var hold_amount : String = ""
        var redeem_requested_amount : String = ""
        
        required init(dictionary: [String:Any]) {
            wallet_amount = dictionary["wallet_amount"] as? String ?? ""
            hold_amount = dictionary["hold_amount"] as? String ?? ""
            redeem_requested_amount = dictionary["redeem_requested_amount"] as? String ?? ""
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.wallet_amount, forKey: "wallet_amount")
            dictionary.setValue(self.hold_amount, forKey: "hold_amount")
            dictionary.setValue(self.redeem_requested_amount, forKey: "redeem_requested_amount")
            return dictionary as! [String:Any]
        }
    }
    
    
    class FavoriteServiceCls{
        
        var pagination: Pagination?
        var favoriteList:[FavoriteService] = [FavoriteService]()
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            favoriteList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["services"] as! [Any]).map({FavoriteService(dict: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
        }
        
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 1
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 1
                currentPage = dictionary["currentPage"] as? Int ?? 1
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
        
        
    }
    
    class FavoriteService: Identifiable  {
        var id : String = ""
        var provider_service_id : String = ""
        var service_name : String = ""
        var category_name : String = ""
        var subcategory : String = ""
        var provider_name : String = ""
        var profile_img : String = ""
        var provider_id : String = ""
        var address : String = ""
        var description : String = ""
        var service_type : String = ""
        var service_master_id : String = ""
        var price : String = ""
        
        var delivery_type : String = ""
        var large_delivery : String = ""
        var medium_delivery : String = ""
        var small_delivery : String = ""
        var request_type : String = ""

        required init(dict: [String:Any]) {
            id = dict["id"] as? String ?? ""
            provider_service_id = dict["provider_service_id"] as? String ?? ""
            service_name = dict["service_name"] as? String ?? ""
            category_name = dict["category_name"] as? String ?? ""
            subcategory = dict["subcategory"] as? String ?? ""
            provider_name = dict["provider_name"] as? String ?? ""
            profile_img = dict["profile_img"] as? String ?? ""
            provider_id = dict["provider_id"] as? String ?? ""
            address = dict["address"] as? String ?? ""
            description = dict["description"] as? String ?? ""
            service_type = dict["service_type"] as? String ?? ""
            service_master_id = dict["service_master_id"] as? String ?? ""
            price = dict["price"] as? String ?? ""
            
            delivery_type = dict["delivery_type"] as? String ?? ""
            large_delivery = dict["large_delivery"] as? String ?? ""
            medium_delivery = dict["medium_delivery"] as? String ?? ""
            small_delivery = dict["small_delivery"] as? String ?? ""
            request_type = dict["request_type"] as? String ?? ""
            delivery_type = dict["delivery_type"] as? String ?? ""

        }
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.id, forKey: "id")
            dictionary.setValue(self.provider_service_id, forKey: "provider_service_id")
            dictionary.setValue(self.service_name, forKey: "service_name")
            dictionary.setValue(self.category_name, forKey: "category_name")
            dictionary.setValue(self.subcategory, forKey: "subcategory")
            dictionary.setValue(self.provider_name, forKey: "provider_name")
            dictionary.setValue(self.profile_img, forKey: "profile_img")
            dictionary.setValue(self.provider_id, forKey: "provider_id")
            dictionary.setValue(self.address, forKey: "address")
            dictionary.setValue(self.description, forKey: "description")
            dictionary.setValue(self.service_type, forKey: "service_type")
            dictionary.setValue(self.service_master_id, forKey: "service_master_id")
            dictionary.setValue(self.price, forKey: "price")
            
            return dictionary as! [String:Any]
        }
        
    }
    
    class ExtendServiceData {
        public var extend_id : String = ""
        public var booking_start_time : String = ""
        public var booking_end_time : String = ""
        public var extend_hours : String = ""
        public var booking_amt : String = ""
        public var serviceStatus : String = ""
        
        required init(dictionary: [String:Any]) {
            
            extend_id = dictionary["extend_id"] as? String ?? ""
            booking_start_time = dictionary["booking_start_time"] as? String ?? ""
            booking_end_time = dictionary["booking_end_time"] as? String ?? ""
            extend_hours = dictionary["extend_hours"] as? String ?? ""
            booking_amt = dictionary["booking_amt"] as? String ?? ""
            serviceStatus = dictionary["serviceStatus"] as? String ?? ""
        }
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        public func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.extend_id, forKey: "extend_id")
            dictionary.setValue(self.booking_start_time, forKey: "booking_start_time")
            dictionary.setValue(self.booking_end_time, forKey: "booking_end_time")
            dictionary.setValue(self.extend_hours, forKey: "extend_hours")
            dictionary.setValue(self.booking_amt, forKey: "booking_amt")
            dictionary.setValue(self.serviceStatus, forKey: "serviceStatus")
            
            return dictionary as! [String:Any]
        }
    }
    
    class ProposalServiceData {
        public var id : String = ""
        public var hours : String = ""
        public var message : String = ""
        public var status : String = ""
        public var created_by : String = ""
        
        required init(dictionary: [String:Any]) {
            
            id = dictionary["id"] as? String ?? ""
            hours = dictionary["hours"] as? String ?? ""
            message = dictionary["message"] as? String ?? ""
            status = dictionary["status"] as? String ?? ""
            created_by = dictionary["created_by"] as? String ?? ""
        }
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: Dictionary.
         */
        public func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.id, forKey: "id")
            dictionary.setValue(self.hours, forKey: "hours")
            dictionary.setValue(self.message, forKey: "message")
            dictionary.setValue(self.status, forKey: "status")
            dictionary.setValue(self.created_by, forKey: "created_by")
            
            return dictionary as! [String:Any]
        }
    }
    
    class CustomerServicesCls{
        
        var customerServicesList: [CustomerServices] = [CustomerServices]()
        var pagination: Pagination?
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            customerServicesList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_list"] as! [Any]).map({CustomerServices(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
        }
        
        class CustomerServices {
            var service_request_id : String = ""
            var provider_service_id : String = ""
            var service_id : String = ""
            var service_booking_id : String = ""
            var booking_hours : String = ""
            var booking_amount : String = ""
            var customer_commission : String = ""
            var customer_commission_amount : String = ""
            var service_status : String = ""
            var service_name : String = ""
            var category_name : String = ""
            var sub_category_name : String = ""
            var description : String = ""
            var service_price : String = ""
            var address : String = ""
            var service_type : String = ""
            var booking_start_time : String = ""
            var booking_end_time : String = ""
            var booking_details : String = ""
            var booking_date : String = ""
            var provider_id : String = ""
            var provider_fname : String = ""
            var provider_lname : String = ""
            var provide_name: String = ""
            var booking_address : String = ""
            var customer_address : String = ""
            var provider_image : String = ""
            var total_reviews : String = ""
            var total_my_reviews : String = ""
            var payment_mode : String = ""
            var extend_service_data  = [ExtendServiceData]()
            var proposal_service_data = [ProposalServiceData]()
            var service_address = ""
            var service_latitude = ""
            var service_longitude = ""
            var service_status_dis = ""
            var delivery_type : String = ""

            required init(dictionary: [String:Any]) {
                
                service_request_id = dictionary["service_request_id"] as? String ?? ""
                provider_service_id = dictionary["provider_service_id"] as? String ?? ""
                service_id = dictionary["service_id"] as? String ?? ""
                service_booking_id = dictionary["service_booking_id"] as? String ?? ""
                booking_hours = dictionary["booking_hours"] as? String ?? ""
                booking_amount = dictionary["booking_amount"] as? String ?? ""
                customer_commission = dictionary["customer_commission"] as? String ?? "0"
                customer_commission_amount = String(dictionary["customer_commission_amount"] as? Double ?? 0)
                service_status = dictionary["service_status"] as? String ?? ""
                service_name = dictionary["service_name"] as? String ?? ""
                category_name = dictionary["category_name"] as? String ?? ""
                sub_category_name = dictionary["sub_category_name"] as? String ?? ""
                description = (dictionary["description"] as? String ?? "").removingPercentEncodingSafe()
                service_price = dictionary["service_price"] as? String ?? ""
                address = dictionary["address"] as? String ?? ""
                service_type = dictionary["service_type"] as? String ?? ""
                booking_start_time = dictionary["booking_start_time"] as? String ?? ""
                booking_end_time = dictionary["booking_end_time"] as? String ?? ""
                booking_details = dictionary["booking_details"] as? String ?? ""
                booking_date = dictionary["booking_date"] as? String ?? ""
                provider_id = dictionary["provider_id"] as? String ?? ""
                provider_fname = dictionary["provider_fname"] as? String ?? ""
                provider_lname = dictionary["provider_lname"] as? String ?? ""
                provide_name = provider_fname + " " + provider_lname
                booking_address = dictionary["booking_address"] as? String ?? ""
                customer_address = dictionary["customer_address"] as? String ?? ""
                provider_image = dictionary["provider_image"] as? String ?? ""
                total_reviews = dictionary["total_reviews"] as? String ?? ""
                total_my_reviews = dictionary["total_my_reviews"] as? String ?? ""
                payment_mode = dictionary["payment_mode"] as? String ?? ""
                service_status_dis = dictionary["service_status_dis"] as? String ?? ""
                delivery_type = dictionary["delivery_type"] as? String ?? ""

                if (dictionary["extend_service_data"] != nil) {
                    extend_service_data = (dictionary["extend_service_data"] as! [Any]).map({ ExtendServiceData(dictionary: $0 as! [String:Any]) })
                }
                if (dictionary["proposal_service_data"] != nil) {
                    proposal_service_data = (dictionary["proposal_service_data"] as! [Any]).map({ ProposalServiceData(dictionary: $0 as! [String:Any]) })
                }
            }
            
            /**
             Returns the dictionary representation for the current instance.
             
             - returns: NSDictionary.
             */
            func dictionaryRepresentation() -> [String:Any] {
                
                let dictionary = NSMutableDictionary()
                
                dictionary.setValue(self.service_request_id, forKey: "service_request_id")
                dictionary.setValue(self.provider_service_id, forKey: "provider_service_id")
                dictionary.setValue(self.service_id, forKey: "service_id")
                dictionary.setValue(self.service_booking_id, forKey: "service_booking_id")
                dictionary.setValue(self.booking_hours, forKey: "booking_hours")
                dictionary.setValue(self.booking_amount, forKey: "booking_amount")
                dictionary.setValue(self.customer_commission, forKey: "customer_commission")
                dictionary.setValue(self.customer_commission_amount, forKey: "customer_commission_amount")
                dictionary.setValue(self.service_status, forKey: "service_status")
                dictionary.setValue(self.service_name, forKey: "service_name")
                dictionary.setValue(self.category_name, forKey: "category_name")
                dictionary.setValue(self.sub_category_name, forKey: "sub_category_name")
                dictionary.setValue(self.description, forKey: "description")
                dictionary.setValue(self.service_price, forKey: "service_price")
                dictionary.setValue(self.address, forKey: "address")
                dictionary.setValue(self.service_type, forKey: "service_type")
                dictionary.setValue(self.booking_start_time, forKey: "booking_start_time")
                dictionary.setValue(self.booking_end_time, forKey: "booking_end_time")
                dictionary.setValue(self.booking_details, forKey: "booking_details")
                dictionary.setValue(self.booking_date, forKey: "booking_date")
                dictionary.setValue(self.provider_id, forKey: "provider_id")
                dictionary.setValue(self.provider_fname, forKey: "provider_fname")
                dictionary.setValue(self.provider_lname, forKey: "provider_lname")
                dictionary.setValue(self.booking_address, forKey: "booking_address")
                dictionary.setValue(self.customer_address, forKey: "customer_address")
                dictionary.setValue(self.provider_image, forKey: "provider_image")
                dictionary.setValue(self.total_reviews, forKey: "total_reviews")
                dictionary.setValue(self.total_my_reviews, forKey: "total_my_reviews")
                dictionary.setValue(self.payment_mode, forKey: "payment_mode")
                dictionary.setValue(self.extend_service_data, forKey: "extend_service_data")
                dictionary.setValue(self.proposal_service_data, forKey: "proposal_service_data")
                dictionary.setValue(self.service_status_dis, forKey: "service_status_dis")
                
                return dictionary as! [String:Any]
            }
        }
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 0
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 0
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
    }
    
    class DepositHistory{
        
        var historyList: [DepositHistoryList] = [DepositHistoryList]()
        var pagination: Pagination?
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            historyList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["transection_list"] as? [Any] ?? []).map({DepositHistoryList(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
        }
        
        
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 0
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 0
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
    }
    
    class DepositHistoryList {
        var amount : String = ""
        var admin_fees : String = ""
        var date : String = ""
        var transaction_id : String = ""
        
        
        required init(dictionary: [String:Any]) {
            
            amount = dictionary["amount"] as? String ?? ""
            admin_fees = dictionary["admin_fees"] as? String ?? ""
            date = dictionary["date"] as? String ?? ""
            transaction_id = dictionary["transaction_id"] as? String ?? ""
            
        }
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: NSDictionary.
         */
        func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            
            dictionary.setValue(self.amount, forKey: "amount")
            dictionary.setValue(self.admin_fees, forKey: "admin_fees")
            dictionary.setValue(self.date, forKey: "date")
            dictionary.setValue(self.transaction_id, forKey: "transaction_id")
            
            
            return dictionary as! [String:Any]
        }
    }
    
    
    class UserLoginData {
        var password : String = ""
        var email : String = ""
        
        required init(dictionary: [String:Any]) {
            password = dictionary["password"] as? String ?? ""
            email = dictionary["email"] as? String ?? ""
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.password, forKey: "password")
            dictionary.setValue(self.email, forKey: "email")
            return dictionary as! [String:Any]
        }
    }
    
    class PopularService {
        var service_id : String = ""
        var category_id : String = ""
        var sub_category_id : String = ""
        var service_name : String = ""
        var service_img : String = ""
        var service_img_url : String = ""
        var service_type : String = ""
        var isactive : String = ""
        var createdUser : String = ""
        var createdDate : String = ""
        var total : String = ""
        
        required init(dictionary: [String:Any]) {
            service_id = dictionary["service_id"] as? String ?? ""
            category_id = dictionary["category_id"] as? String ?? ""
            sub_category_id = dictionary["sub_category_id"] as? String ?? ""
            service_name = dictionary["service_name"] as? String ?? ""
            service_img = dictionary["service_img"] as? String ?? ""
            service_img_url = dictionary["service_img_url"] as? String ?? ""
            service_type = dictionary["service_type"] as? String ?? ""
            isactive = dictionary["isactive"] as? String ?? ""
            createdUser = dictionary["createdUser"] as? String ?? ""
            createdDate = dictionary["createdDate"] as? String ?? ""
            total = dictionary["total"] as? String ?? ""
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.service_id, forKey: "service_id")
            dictionary.setValue(self.category_id, forKey: "category_id")
            dictionary.setValue(self.sub_category_id, forKey: "sub_category_id")
            dictionary.setValue(self.service_name, forKey: "service_name")
            dictionary.setValue(self.service_img, forKey: "service_img")
            dictionary.setValue(self.service_img_url, forKey: "service_img_url")
            dictionary.setValue(self.service_type, forKey: "service_type")
            dictionary.setValue(self.isactive, forKey: "isactive")
            dictionary.setValue(self.createdUser, forKey: "createdUser")
            dictionary.setValue(self.createdDate, forKey: "createdDate")
            dictionary.setValue(self.total, forKey: "total")
            return dictionary as! [String:Any]
        }
    }
    
    class PopularTasker{
        var userimg : String = ""
        var username : String = ""
        var userid : String = ""
        var service : String = ""
        var provider : String = ""
        var category_id : String = ""
        var latitude : String = ""
        var longitude : String = ""
        var sub_category_id : String = ""
        
        required init(dictionary: [String:Any]) {
            userimg = dictionary["userimg"] as? String ?? ""
            username = dictionary["username"] as? String ?? ""
            userid = dictionary["userid"] as? String ?? ""
            service = dictionary["service"] as? String ?? ""
            provider = dictionary["provider"] as? String ?? ""
            category_id = dictionary["category_id"] as? String ?? ""
            latitude = dictionary["latitude"] as? String ?? ""
            longitude = dictionary["longitude"] as? String ?? ""
            sub_category_id = dictionary["sub_category_id"] as? String ?? ""
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.userimg, forKey: "userimg")
            dictionary.setValue(self.username, forKey: "username")
            dictionary.setValue(self.userid, forKey: "userid")
            dictionary.setValue(self.service, forKey: "service")
            dictionary.setValue(self.provider, forKey: "provider")
            dictionary.setValue(self.category_id, forKey: "category_id")
            dictionary.setValue(self.latitude, forKey: "latitude")
            dictionary.setValue(self.longitude, forKey: "longitude")
            dictionary.setValue(self.sub_category_id, forKey: "sub_category_id")
            return dictionary as! [String:Any]
        }
    }
    
    class PaymentHistory{
        var transection_list:[TransactionList] = [TransactionList]()
        var pagination :Pagination?
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            transection_list = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["transection_list"] as! [Any]).map({TransactionList(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as? [String:Any]  ?? [:]))
        }
        
        class TransactionList{
            var profile_image:String = ""
            var username:String = ""
            var servicename:String = ""
            var category:String = ""
            var subcategory:String = ""
            var address:String = ""
            var transection_id:String = ""
            var recived_amount:String = ""
            var completion_date:String = ""
            var per_hour:String = ""
            var totel_hours:String = ""
            var status:String = ""
            var per_hour_title:String = ""
            var per_hour_class:String = ""
            var isactive:String = ""
            
            required init(dictionary: [String:Any]) {
                profile_image = dictionary["profile_image"] as? String ?? ""
                username = dictionary["username"] as? String ?? ""
                servicename = dictionary["servicename"] as? String ?? ""
                category = dictionary["category"] as? String ?? ""
                subcategory = dictionary["subcategory"] as? String ?? ""
                address = dictionary["address"] as? String ?? ""
                transection_id = dictionary["transection_id"] as? String ?? ""
                recived_amount = dictionary["recived_amount"] as? String ?? ""
                completion_date = dictionary["completion_date"] as? String ?? ""
                per_hour = dictionary["per_hour"] as? String ?? ""
                totel_hours = dictionary["totel_hours"] as? String ?? ""
                status = dictionary["status"] as? String ?? ""
                per_hour_title = dictionary["per_hour_title"] as? String ?? ""
                per_hour_class = dictionary["per_hour_class"] as? String ?? ""
                isactive = dictionary["isactive"] as? String ?? ""
                
            }
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.profile_image, forKey: "profile_image")
                dictionary.setValue(self.username, forKey: "username")
                dictionary.setValue(self.servicename, forKey: "servicename")
                dictionary.setValue(self.category, forKey: "category")
                dictionary.setValue(self.subcategory, forKey: "subcategory")
                dictionary.setValue(self.address, forKey: "address")
                dictionary.setValue(self.transection_id, forKey: "transection_id")
                dictionary.setValue(self.recived_amount, forKey: "recived_amount")
                dictionary.setValue(self.completion_date, forKey: "completion_date")
                dictionary.setValue(self.per_hour, forKey: "per_hour")
                dictionary.setValue(self.totel_hours, forKey: "totel_hours")
                dictionary.setValue(self.status, forKey: "status")
                dictionary.setValue(self.per_hour_title, forKey: "per_hour_title")
                dictionary.setValue(self.per_hour_class, forKey: "per_hour_class")
                dictionary.setValue(self.isactive, forKey: "isactive")
                return dictionary as! [String:Any]
            }
        }
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 0
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 0
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
    }
    class ProviderServices {
        
        var service_request_id:String = ""
        var provider_service_id:String = ""
        var service_id:String = ""
        var service_booking_id:String = ""
        var service_name:String = ""
        var address:String = ""
        var service_status:String = ""
        var service_status_dis:String = ""
        var category_name:String = ""
        var sub_category_name:String = ""
        var description:String = ""
        var service_price:String = ""
        var service_type:String = ""
        var booking_start_time:String = ""
        var booking_end_time:String = ""
        var booking_details:String = ""
        var booking_date:String = ""
        var booking_amount:String = ""
        var provider_commission_amount:String = ""
        var provider_id:String = ""
        var customer_id:String = ""
        var customer_fname:String = ""
        var customer_lname:String = ""
        var customer_name:String = ""
        var customer_email:String = ""
        var customer_contact_number:String = ""
        var country_code:String = ""
        var rating:String = ""
        var review:String = ""
        var booking_address:String = ""
        var provider_address:String = ""
        var payment_mode:String = ""
        var customer_image:String = ""
        var total_proposal:String = ""
        var extend_service_data  = [ProviderServicesCls.ExtendServiceData]()
        var proposal_service_data = [ProviderServicesCls.ProposalServiceData]()
        var service_address:String = ""
        var service_latitude:String = ""
        var service_longitude:String = ""
        var isactive:String = ""
        
        var available_days_list:String = ""
        var available_time_start:String = ""
        var available_time_end:String = ""

        var request_type:String = ""
        var delivery_type:String = ""
        
        required init(dictionary: [String:Any]) {
            
            service_request_id = dictionary["service_request_id"] as? String ?? ""
            provider_service_id = dictionary["provider_service_id"] as? String ?? ""
            service_id = dictionary["service_id"] as? String ?? ""
            service_booking_id = dictionary["service_booking_id"] as? String ?? ""
            service_name = dictionary["service_name"] as? String ?? ""
            address = dictionary["address"] as? String ?? ""
            service_status = dictionary["service_status"] as? String ?? ""
            category_name = dictionary["category_name"] as? String ?? ""
            sub_category_name = dictionary["sub_category_name"] as? String ?? ""
            description = (dictionary["description"] as? String ?? "").removingPercentEncodingSafe()
            service_price = dictionary["service_price"] as? String ?? ""
            service_type = dictionary["service_type"] as? String ?? ""
            booking_start_time = dictionary["booking_start_time"] as? String ?? ""
            booking_end_time = dictionary["booking_end_time"] as? String ?? ""
            booking_details = dictionary["booking_details"] as? String ?? ""
            booking_date = dictionary["booking_date"] as? String ?? ""
            booking_amount = dictionary["booking_amount"] as? String ?? ""
            provider_commission_amount = String(dictionary["provider_commission_amount"] as? Double ?? 0)
            provider_id = dictionary["provider_id"] as? String ?? ""
            customer_id = dictionary["customer_id"] as? String ?? ""
            customer_fname = dictionary["customer_fname"] as? String ?? ""
            customer_lname = dictionary["customer_lname"] as? String ?? ""
            customer_name = customer_fname + " " + customer_lname
            customer_email = dictionary["customer_email"] as? String ?? ""
            customer_contact_number = dictionary["customer_contact_number"] as? String ?? "0"
            country_code = dictionary["country_code"] as? String ?? ""
            rating = dictionary["rating"] as? String ?? ""
            review = dictionary["review"] as? String ?? ""
            booking_address = dictionary["booking_address"] as? String ?? ""
            provider_address = dictionary["provider_address"] as? String ?? ""
            payment_mode = dictionary["payment_mode"] as? String ?? ""
            customer_image = dictionary["customer_image"] as? String ?? ""
            total_proposal = String(dictionary["total_proposal"] as? Int ?? 0)
            service_address = dictionary["service_address"] as? String ?? ""
            service_latitude = dictionary["service_latitude"] as? String ?? ""
            service_longitude = dictionary["service_longitude"] as? String ?? ""
            isactive = dictionary["isactive"] as? String ?? "y"
            service_status_dis = dictionary["service_status_dis"] as? String ?? ""
            
            available_days_list = dictionary["available_days_list"] as? String ?? ""
            available_time_start = dictionary["available_time_start"] as? String ?? ""
            available_time_end = dictionary["available_time_end"] as? String ?? ""

            request_type = dictionary["request_type"] as? String ?? ""
            delivery_type = dictionary["delivery_type"] as? String ?? ""

            if (dictionary["extend_service_data"] != nil) {
                extend_service_data = (dictionary["extend_service_data"] as! [Any]).map({ ProviderServicesCls.ExtendServiceData(dictionary: $0 as! [String:Any]) })
            }
            if (dictionary["proposal_service_data"] != nil) {
                proposal_service_data = (dictionary["proposal_service_data"] as! [Any]).map({ ProviderServicesCls.ProposalServiceData(dictionary: $0 as! [String:Any]) })
            }
        }
        
        /**
         Returns the dictionary representation for the current instance.
         
         - returns: NSDictionary.
         */
        func dictionaryRepresentation() -> [String:Any] {
            
            let dictionary = NSMutableDictionary()
            /*
             dictionary.setValue(self.service_request_id, forKey: "service_request_id")
             dictionary.setValue(self.provider_service_id, forKey: "provider_service_id")
             dictionary.setValue(self.service_id, forKey: "service_id")
             dictionary.setValue(self.service_booking_id, forKey: "service_booking_id")
             //            dictionary.setValue(self.booking_hours, forKey: "booking_hours")
             dictionary.setValue(self.booking_amount, forKey: "booking_amount")
             //            dictionary.setValue(self.customer_commission, forKey: "customer_commission")
             //            dictionary.setValue(self.customer_commission_amount, forKey: "customer_commission_amount")
             dictionary.setValue(self.service_status, forKey: "service_status")
             dictionary.setValue(self.service_name, forKey: "service_name")
             dictionary.setValue(self.category_name, forKey: "category_name")
             dictionary.setValue(self.sub_category_name, forKey: "sub_category_name")
             dictionary.setValue(self.description, forKey: "description")
             dictionary.setValue(self.service_price, forKey: "service_price")
             dictionary.setValue(self.address, forKey: "address")
             dictionary.setValue(self.service_type, forKey: "service_type")
             dictionary.setValue(self.booking_start_time, forKey: "booking_start_time")
             dictionary.setValue(self.booking_end_time, forKey: "booking_end_time")
             dictionary.setValue(self.booking_details, forKey: "booking_details")
             dictionary.setValue(self.booking_date, forKey: "booking_date")
             dictionary.setValue(self.provider_id, forKey: "provider_id")
             //            dictionary.setValue(self.provider_fname, forKey: "provider_fname")
             //            dictionary.setValue(self.provider_lname, forKey: "provider_lname")
             dictionary.setValue(self.booking_address, forKey: "booking_address")
             //            dictionary.setValue(self.customer_address, forKey: "customer_address")
             //            dictionary.setValue(self.provider_image, forKey: "provider_image")
             //            dictionary.setValue(self.total_reviews, forKey: "total_reviews")
             //            dictionary.setValue(self.total_my_reviews, forKey: "total_my_reviews")
             dictionary.setValue(self.payment_mode, forKey: "payment_mode")
             dictionary.setValue(self.extend_service_data, forKey: "extend_service_data")
             dictionary.setValue(self.proposal_service_data, forKey: "proposal_service_data")
             
             */
            return dictionary as! [String:Any]
        }
    }
    
    class ProviderServicesCls{
        
        var providerServicesList: [ProviderServices] = [ProviderServices]()
        var pagination: Pagination?
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            providerServicesList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_list"] as! [Any]).map({ProviderServices(dictionary: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
        }
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 0
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 0
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
        
        class ExtendServiceData {
            public var extend_id : String = ""
            public var booking_start_time : String = ""
            public var booking_end_time : String = ""
            public var extend_hours : String = ""
            public var booking_amount : String = ""
            public var extend_status : String = ""
            
            required init(dictionary: [String:Any]) {
                
                extend_id = dictionary["extend_id"] as? String ?? ""
                booking_start_time = dictionary["booking_start_time"] as? String ?? ""
                booking_end_time = dictionary["booking_end_time"] as? String ?? ""
                extend_hours = dictionary["extend_hours"] as? String ?? ""
                booking_amount = dictionary["booking_amount"] as? String ?? ""
                extend_status = dictionary["extend_status"] as? String ?? ""
            }
            
            /**
             Returns the dictionary representation for the current instance.
             
             - returns: Dictionary.
             */
            public func dictionaryRepresentation() -> [String:Any] {
                
                let dictionary = NSMutableDictionary()
                
                dictionary.setValue(self.extend_id, forKey: "extend_id")
                dictionary.setValue(self.booking_start_time, forKey: "booking_start_time")
                dictionary.setValue(self.booking_end_time, forKey: "booking_end_time")
                dictionary.setValue(self.extend_hours, forKey: "extend_hours")
                dictionary.setValue(self.booking_amount, forKey: "booking_amount")
                dictionary.setValue(self.extend_status, forKey: "extend_status")
                
                return dictionary as! [String:Any]
            }
        }
        
        class ProposalServiceData {
            public var proposal_id : String = ""
            public var status : String = ""
            public var created_by : String = ""
            public var message : String = ""
            public var hours : String = ""
            
            required init(dictionary: [String:Any]) {
                
                proposal_id = dictionary["proposal_id"] as? String ?? ""
                hours = dictionary["hours"] as? String ?? ""
                message = dictionary["message"] as? String ?? ""
                status = dictionary["status"] as? String ?? ""
                created_by = dictionary["created_by"] as? String ?? ""
            }
            
            /**
             Returns the dictionary representation for the current instance.
             
             - returns: Dictionary.
             */
            public func dictionaryRepresentation() -> [String:Any] {
                
                let dictionary = NSMutableDictionary()
                
                dictionary.setValue(self.proposal_id, forKey: "proposal_id")
                dictionary.setValue(self.hours, forKey: "hours")
                dictionary.setValue(self.message, forKey: "message")
                dictionary.setValue(self.status, forKey: "status")
                dictionary.setValue(self.created_by, forKey: "created_by")
                
                return dictionary as! [String:Any]
            }
        }
    }
    
    class ProviderServicesList{
        
        var providerServices: ProviderServices = ProviderServices(dictionary: [:])
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            providerServices = ProviderServices(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)))
        }
        
        //        class ProviderServices {
        //
        //            var service_request_id:String = ""
        //            var provider_service_id:String = ""
        //            var service_id:String = ""
        //            var service_booking_id:String = ""
        //            var service_name:String = ""
        //            var address:String = ""
        //            var service_status:String = ""
        //            var category_name:String = ""
        //            var sub_category_name:String = ""
        //            var description:String = ""
        //            var service_price:String = ""
        //            var service_type:String = ""
        //            var booking_start_time:String = ""
        //            var booking_end_time:String = ""
        //            var booking_details:String = ""
        //            var booking_date:String = ""
        //            var booking_amount:String = ""
        //            var provider_commission_amount:String = ""
        //            var provider_id:String = ""
        //            var customer_id:String = ""
        //            var customer_fname:String = ""
        //            var customer_lname:String = ""
        //            var customer_name:String = ""
        //            var customer_email:String = ""
        //            var customer_contact_number:String = ""
        //            var country_code:String = ""
        //            var rating:String = ""
        //            var review:String = ""
        //            var booking_address:String = ""
        //            var provider_address:String = ""
        //            var payment_mode:String = ""
        //            var customer_image:String = ""
        //            var total_proposal:String = ""
        //
        //            var extend_service_data  = [ProviderServicesCls.ExtendServiceData]()
        //            var proposal_service_data = [ProviderServicesCls.ProposalServiceData]()
        //
        //
        //            required init(dictionary: [String:Any]) {
        //
        //                service_request_id = dictionary["service_request_id"] as? String ?? ""
        //                provider_service_id = dictionary["provider_service_id"] as? String ?? ""
        //                service_id = dictionary["service_id"] as? String ?? ""
        //                service_booking_id = dictionary["service_booking_id"] as? String ?? ""
        //                service_name = dictionary["service_name"] as? String ?? ""
        //                address = dictionary["address"] as? String ?? ""
        //                service_status = dictionary["service_status"] as? String ?? ""
        //                category_name = dictionary["category_name"] as? String ?? ""
        //                sub_category_name = dictionary["sub_category_name"] as? String ?? ""
        //                description = dictionary["description"] as? String ?? ""
        //                service_price = dictionary["service_price"] as? String ?? ""
        //                service_type = dictionary["service_type"] as? String ?? ""
        //                booking_start_time = dictionary["booking_start_time"] as? String ?? ""
        //                booking_end_time = dictionary["booking_end_time"] as? String ?? ""
        //                booking_details = dictionary["booking_details"] as? String ?? ""
        //                booking_date = dictionary["booking_date"] as? String ?? ""
        //                booking_amount = dictionary["booking_amount"] as? String ?? ""
        //                provider_commission_amount = String(dictionary["provider_commission_amount"] as? Double ?? 0)
        //                provider_id = dictionary["provider_id"] as? String ?? ""
        //                customer_id = dictionary["customer_id"] as? String ?? ""
        //                customer_fname = dictionary["customer_fname"] as? String ?? ""
        //                customer_lname = dictionary["customer_lname"] as? String ?? ""
        //                customer_name = customer_fname + " " + customer_lname
        //                customer_email = dictionary["customer_email"] as? String ?? ""
        //                customer_contact_number = dictionary["customer_contact_number"] as? String ?? "0"
        //                country_code = dictionary["country_code"] as? String ?? ""
        //                rating = String(dictionary["rating"] as? Double ?? 0)
        //                review = dictionary["review"] as? String ?? ""
        //                booking_address = dictionary["booking_address"] as? String ?? ""
        //                provider_address = dictionary["provider_address"] as? String ?? ""
        //                payment_mode = dictionary["payment_mode"] as? String ?? ""
        //                customer_image = dictionary["customer_image"] as? String ?? ""
        //                total_proposal = String(dictionary["total_proposal"] as? Int ?? 0)
        //                payment_mode = dictionary["payment_mode"] as? String ?? ""
        //
        //                if (dictionary["extend_service_data"] != nil) {
        //                    extend_service_data = (dictionary["extend_service_data"] as! [Any]).map({ ProviderServicesCls.ExtendServiceData(dictionary: $0 as! [String:Any]) })
        //                }
        //                if (dictionary["proposal_service_data"] != nil) {
        //                    proposal_service_data = (dictionary["proposal_service_data"] as! [Any]).map({ ProviderServicesCls.ProposalServiceData(dictionary: $0 as! [String:Any]) })
        //
        //                }
        //            }
        //
        //
        //            /**
        //             Returns the dictionary representation for the current instance.
        //
        //             - returns: NSDictionary.
        //             */
        //            func dictionaryRepresentation() -> [String:Any] {
        //
        //                let dictionary = NSMutableDictionary()
        //                /*
        //                 dictionary.setValue(self.service_request_id, forKey: "service_request_id")
        //                 dictionary.setValue(self.provider_service_id, forKey: "provider_service_id")
        //                 dictionary.setValue(self.service_id, forKey: "service_id")
        //                 dictionary.setValue(self.service_booking_id, forKey: "service_booking_id")
        //                 //            dictionary.setValue(self.booking_hours, forKey: "booking_hours")
        //                 dictionary.setValue(self.booking_amount, forKey: "booking_amount")
        //                 //            dictionary.setValue(self.customer_commission, forKey: "customer_commission")
        //                 //            dictionary.setValue(self.customer_commission_amount, forKey: "customer_commission_amount")
        //                 dictionary.setValue(self.service_status, forKey: "service_status")
        //                 dictionary.setValue(self.service_name, forKey: "service_name")
        //                 dictionary.setValue(self.category_name, forKey: "category_name")
        //                 dictionary.setValue(self.sub_category_name, forKey: "sub_category_name")
        //                 dictionary.setValue(self.description, forKey: "description")
        //                 dictionary.setValue(self.service_price, forKey: "service_price")
        //                 dictionary.setValue(self.address, forKey: "address")
        //                 dictionary.setValue(self.service_type, forKey: "service_type")
        //                 dictionary.setValue(self.booking_start_time, forKey: "booking_start_time")
        //                 dictionary.setValue(self.booking_end_time, forKey: "booking_end_time")
        //                 dictionary.setValue(self.booking_details, forKey: "booking_details")
        //                 dictionary.setValue(self.booking_date, forKey: "booking_date")
        //                 dictionary.setValue(self.provider_id, forKey: "provider_id")
        //                 //            dictionary.setValue(self.provider_fname, forKey: "provider_fname")
        //                 //            dictionary.setValue(self.provider_lname, forKey: "provider_lname")
        //                 dictionary.setValue(self.booking_address, forKey: "booking_address")
        //                 //            dictionary.setValue(self.customer_address, forKey: "customer_address")
        //                 //            dictionary.setValue(self.provider_image, forKey: "provider_image")
        //                 //            dictionary.setValue(self.total_reviews, forKey: "total_reviews")
        //                 //            dictionary.setValue(self.total_my_reviews, forKey: "total_my_reviews")
        //                 dictionary.setValue(self.payment_mode, forKey: "payment_mode")
        //                 dictionary.setValue(self.extend_service_data, forKey: "extend_service_data")
        //                 dictionary.setValue(self.proposal_service_data, forKey: "proposal_service_data")
        //
        //                 */
        //                return dictionary as! [String:Any]
        //            }
        //
        //        }
        
        class ExtendServiceData {
            public var extend_id : String = ""
            public var booking_start_time : String = ""
            public var booking_end_time : String = ""
            public var extend_hours : String = ""
            public var booking_amount : String = ""
            public var extend_status : String = ""
            
            required init(dictionary: [String:Any]) {
                
                extend_id = dictionary["extend_id"] as? String ?? ""
                booking_start_time = dictionary["booking_start_time"] as? String ?? ""
                booking_end_time = dictionary["booking_end_time"] as? String ?? ""
                extend_hours = dictionary["extend_hours"] as? String ?? ""
                booking_amount = dictionary["booking_amount"] as? String ?? ""
                extend_status = dictionary["extend_status"] as? String ?? ""
            }
            
            /**
             Returns the dictionary representation for the current instance.
             
             - returns: Dictionary.
             */
            public func dictionaryRepresentation() -> [String:Any] {
                
                let dictionary = NSMutableDictionary()
                
                dictionary.setValue(self.extend_id, forKey: "extend_id")
                dictionary.setValue(self.booking_start_time, forKey: "booking_start_time")
                dictionary.setValue(self.booking_end_time, forKey: "booking_end_time")
                dictionary.setValue(self.extend_hours, forKey: "extend_hours")
                dictionary.setValue(self.booking_amount, forKey: "booking_amount")
                dictionary.setValue(self.extend_status, forKey: "extend_status")
                
                return dictionary as! [String:Any]
            }
            
        }
        
        class ProposalServiceData {
            public var proposal_id : String = ""
            public var status : String = ""
            public var created_by : String = ""
            public var message : String = ""
            public var hours : String = ""
            
            required init(dictionary: [String:Any]) {
                
                proposal_id = dictionary["proposal_id"] as? String ?? ""
                hours = dictionary["hours"] as? String ?? ""
                message = dictionary["message"] as? String ?? ""
                status = dictionary["status"] as? String ?? ""
                created_by = dictionary["created_by"] as? String ?? ""
            }
            
            /**
             Returns the dictionary representation for the current instance.
             
             - returns: Dictionary.
             */
            public func dictionaryRepresentation() -> [String:Any] {
                
                let dictionary = NSMutableDictionary()
                
                dictionary.setValue(self.proposal_id, forKey: "proposal_id")
                dictionary.setValue(self.hours, forKey: "hours")
                dictionary.setValue(self.message, forKey: "message")
                dictionary.setValue(self.status, forKey: "status")
                dictionary.setValue(self.created_by, forKey: "created_by")
                
                return dictionary as! [String:Any]
            }
        }
    }
    
    class ProviderListCls{
        
        var providerList: [ProviderList] = [ProviderList]()
        var pagination: Pagination?
        
        required init(dictionary: [String:Any]) {
            print(dictionary)
            providerList = (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["service_list"] as! [Any]).map({ProviderListCls.ProviderList(dic: $0 as! [String:Any])})
            pagination = Pagination(dictionary: (ResponseKey.fatchDataAsDictionary(res: dictionary, valueOf: .data)["pagination"] as! [String:Any]))
        }
        
        class Pagination {
            var total_records : Int = 0
            var total_pages : Int = 0
            var currentPage : Int = 0
            
            required init(dictionary: [String:Any]) {
                total_records = dictionary["total_records"] as? Int ?? 0
                total_pages = dictionary["total_pages"] as? Int ?? 0
                currentPage = dictionary["currentPage"] as? Int ?? 0
            }
            
            func dictionaryRepresentation() -> [String:Any] {
                let dictionary = NSMutableDictionary()
                dictionary.setValue(self.total_records, forKey: "total_records")
                dictionary.setValue(self.total_pages, forKey: "total_pages")
                dictionary.setValue(self.currentPage, forKey: "currentPage")
                return dictionary as! [String:Any]
            }
        }
        
        class ProviderList: NSObject{
            
            private let keys = ["provider_service_id", "total_records","service_id","provider_id","category_id","subcategory_id","price","duration","service_description","avg_rating","user_type", "provider_first_name", "provider_last_name", "address", "favorite_id", "service_type", "provider_image","total_reviews",]
            
            @objc var provider_service_id = ""
            @objc var total_records = 0
            @objc var total_reviews = 0
            @objc var service_id = ""
            @objc var provider_id = ""
            @objc var category_id = ""
            @objc var subcategory_id = ""
            @objc var price = ""
            @objc var duration = ""
            @objc var service_description = ""
            @objc var avg_rating = ""
            @objc var user_type = ""
            @objc var provider_first_name = ""
            @objc var provider_last_name = ""
            @objc var provider_name = ""
            @objc var address = ""
            @objc var favorite_id = ""
            @objc var service_type = ""
            @objc var provider_image = ""
            //@objc var payment_mode = ""
            
            override init() {
                super.init()
            }
            
            init(dic:[String:Any]) {
                super.init()
                provider_service_id = dic["provider_service_id"] as? String ?? ""
                total_records = dic["total_records"] as? Int ?? 0
                service_id = dic["service_id"] as? String ?? ""
                provider_id = dic["provider_id"] as? String ?? ""
                category_id = dic["category_id"] as? String ?? ""
                subcategory_id = dic["subcategory_id"] as? String ?? ""
                price = dic["price"] as? String ?? ""
                duration = dic["duration"] as? String ?? ""
                service_description = (dic["service_description"] as? String ?? "").removingPercentEncodingSafe()
                avg_rating = dic["avg_rating"] as? String ?? ""
                user_type = dic["user_type"] as? String ?? ""
                provider_first_name = dic["provider_first_name"] as? String ?? ""
                provider_last_name = dic["provider_last_name"] as? String ?? ""
                provider_name = dic["provider_name"] as? String ?? ""
                if provider_name.isEmpty{
                    provider_name = provider_first_name + " " + provider_last_name
                }
                address = dic["address"] as? String ?? ""
                favorite_id = dic["favorite_id"] as? String ?? ""
                service_type = dic["service_type"] as? String ?? ""
                provider_image = dic["provider_image"] as? String ?? ""
                total_reviews = dic["total_reviews"]  as? Int ?? 0

                //payment_mode = dic["payment_mode"] as? String ?? ""
            }
            
            init(dictionary:[String:Any]) {
                super.init()
                self.setValuesForKeys(dictionary)
            }
            
            var dictionary:[String:Any] {
                return self.dictionaryWithValues(forKeys: keys)
            }
        }
    }
    


class DeliveryProviderModal {
//    var currentPage: Int = 1
//    var totalRecords: Int
//    var totalPages: Int
//    var limit: String
//    var is_next_record_avl: String
    
    var providerList: [DeliveryProivderList]
    var pagination: Pagination?
    
    
    required public init(dictionary: [String : Any]) {
        let  paginationData = dictionary["pagination"] as? [String:Any] ?? [:]
        //        currentPage = ResponseHandler.fetchDataInInteger(res: pagination, valueOf: "start")
        pagination = Pagination(dictionary: paginationData)
//        totalRecords = ResponseKey.fetchDataInInteger(res: paginationData, valueOf: "totalrecords")
//        totalPages = ResponseKey.fetchDataInInteger(res: paginationData, valueOf: "total_page")
//        limit = ResponseKey.fetchDataInString(res: paginationData, valueOf: "limit")
//        is_next_record_avl = ResponseKey.fetchDataInString(res: paginationData, valueOf: "is_next_record_avl")
        
        if let data = dictionary["provider_list"] as? [Any] {
            self.providerList = data.map({ DeliveryProivderList(dictionary: $0 as! [String: Any]) })
        }else {
            self.providerList = []
        }
    }
    
    
    class Pagination {
        var total_records : Int = 0
        var total_pages : Int = 0
        var currentPage : Int = 0
        
        required init(dictionary: [String:Any]) {
            total_records = dictionary["total_records"] as? Int ?? 0
            total_pages = dictionary["total_pages"] as? Int ?? 1
            currentPage = dictionary["currentPage"] as? Int ?? 1
        }
        
        func dictionaryRepresentation() -> [String:Any] {
            let dictionary = NSMutableDictionary()
            dictionary.setValue(self.total_records, forKey: "total_records")
            dictionary.setValue(self.total_pages, forKey: "total_pages")
            dictionary.setValue(self.currentPage, forKey: "currentPage")
            return dictionary as! [String:Any]
        }
    }
    
    
}

class DeliveryProivderList {
    var address: String
    var avg_rating: String
    var large_delivery: String
    var medium_delivery: String
    var small_delivery: String
    var provider_first_name: String
    var provider_image: String
    var provider_last_name: String
    var provider_id: String
    var total_ratting: String
    var total_records: Int
    var total_reviews: Int
    var hour_rate: String

    
    
      
    required public init(dictionary: [String : Any]) {
        address = dictionary["address"] as? String ?? ""
        avg_rating = dictionary["avg_rating"] as? String ?? ""
        large_delivery = dictionary["large_delivery"] as? String ?? ""
        medium_delivery = dictionary["medium_delivery"] as? String ?? ""
        small_delivery = dictionary["small_delivery"] as? String ?? ""
        provider_first_name = dictionary["provider_first_name"] as? String ?? ""
        provider_image = dictionary["provider_image"] as? String ?? ""
        provider_last_name = dictionary["provider_last_name"] as? String ?? ""
        provider_id = dictionary["provider_id"] as? String ?? ""
        total_ratting = dictionary["total_ratting"] as? String ?? ""
        total_records = dictionary["total_records"] as? Int ?? 0
        total_reviews = dictionary["total_reviews"] as? Int ?? 0
        hour_rate = dictionary["hour_rate"] as? String ?? "6"

    }
}
