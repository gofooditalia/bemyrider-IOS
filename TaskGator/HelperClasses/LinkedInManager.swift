//
//  LinkedInManager.swift
//

import UIKit

fileprivate struct LinkedInfo {
    //Changable
    static let clientId = "86tz3hifyjat9i"
    static let clientSecret = "N7Xa2U4B7Hfu4CCZ"
    static let redirectURL = "https://gotasker.ncryptedprojects.com/includes-nct/linkedin/callback.php"
    
    //Don't change below variable
    static let state = "E3ZYKC1T6H2yP4z" //May be it's unused
    static let permission = ["r_emailaddress", "r_liteprofile"]
    static let requestURL_MemberProfilePicture = "https://api.linkedin.com/v2/me?projection=(id,localizedFirstName,localizedLastName,profilePicture(displayImage~:playableStreams))"
    static let requestURL_MemberEmailAddress = "https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))"
    
    //static let requestURL_MemberProfiles = "https://api.linkedin.com/v2/me"
    //static let url = "https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))"
    
}

/**
 
 LinkedInManager class user for linkedIn login
 
 - **Step 1: Create App on LinkedIn developer account**
 
 [Create App click here](https://developer.linkedin.com/docs/ref/v2/media-migration)
 
 [LinkedIn integration reference](https://docs.microsoft.com/en-us/linkedin/consumer/integrations/self-serve/sign-in-with-linkedin)
 
 
 
 - **Step 2: Setup App on LinkedIn Developer Account**
 
 - Your App -> Setting Tab -> Additional settings -> Domains:
 
 - Your App -> Auth Tab -> OAuth 2.0 Setting -> RedirectURLs - for example -> "https://www.google.com/"
 
 
 
 - **Step 3 : Add below code into Info.plist file**
 
 This step is option if you don't want to open LinkedIn app then this step is not required.
 
 
        <key>LSApplicationQueriesSchemes</key>
        <array>
            <string>linkedin</string>
            <string>linkedin-sdk2</string>
        </array>
 
 
 
 - **Step 4: Replace value of this variable as per app create on linkedIn developer portal**
 
        fileprivate struct LinkedInfo {
            static let clientId = "<REPLACE_ME>"
            static let clientSecret = "<REPLACE_ME>"
            static let redirectURL = "<REPLACE_ME>"
        }
 
 - **Step 5: Usage**
 
 
        @IBAction func onClickLinkedLogin(_ sender: Any) {
            LinkedInManager.shared.loginWithLinked(vc: self) { (userInfo, error) in
                print("Login in")
                if let userInfo = userInfo {
                    print("\n=======LinkedIn Login Info========")
                    print("id : \(userInfo.socialId)\nname : \(userInfo.firstName) \(userInfo.lastName)\nEmail - \(userInfo.email)\nprofile : \(userInfo.proFileURL)")
                    print("==================================\n")
                }
            }
        }
 
 */

class LinkedInManager: NSObject {
    static let shared = LinkedInManager()
    
    //create LinkedInSwiftHelper request
    private let linkedinHelper = LinkedinHelper(linkedInConfig: LinkedInConfig(linkedInKey: LinkedInfo.clientId, linkedInSecret: LinkedInfo.clientSecret, redirectURL: LinkedInfo.redirectURL, scope: LinkedInfo.permission))
    
    //success block
    typealias basicInfo = (socialId:String,firstName:String,lastName:String,email:String,proFileURL:String)
    typealias linkedInBasicInfo =  (basicInfo?,_ error:String?) -> Void
    //typealias successBlock = (_ id: String, _ firstName:String, _ lastName:String, _ email:String, _ proFileURL:String) -> ()
    
    //login function which is return success block
    //func loginWithLinked(completion: @escaping successBlock) {
    func loginWithLinked(vc : UIViewController, completion: @escaping linkedInBasicInfo) {
        
        //clear liinkedin cookies from browser
        clearCookieof(name: "linkedin")
        
        linkedinHelper.login(from: vc, loadingTitleString: "Loading", completion: { (token) in
            // Initialize a mutable URL request object.
            if let url = URL(string: LinkedInfo.requestURL_MemberProfilePicture) {
                var request = URLRequest(url: url)
                // Indicate that this is a GET request.
                request.httpMethod = "GET"
                // Add the access token as an HTTP header field.
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // Initialize a NSURLSession object.
                let session = URLSession(configuration: URLSessionConfiguration.default)
                
                // Make the request.
                let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    
                    if statusCode == 200 {
                        // Convert the received JSON data into a dictionary.
                        do {
                            let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                            
                            if let dataDictionary = dataDictionary as? [String :Any] {
                                let firstName = dataDictionary["localizedFirstName"] as? String ?? ""
                                let lastName = dataDictionary["localizedLastName"] as? String ?? ""
                                let linkedInId = dataDictionary["id"] as? String ?? ""
                                var profileURL = ""
                                if let profilePicture = dataDictionary["profilePicture"] as? [String:Any],
                                let displayImage = profilePicture["displayImage~"] as? [String:Any],
                                let elements = displayImage["elements"] as? [[String:Any]],
                                let elementLast = elements.last,
                                let identifiers = (elementLast["identifiers"] as? [[String:Any]])?.first,
                                let identifier = identifiers["identifier"] as? String{
                                    profileURL = identifier
                                }
                                self.getEmailId(token: token) { (success, email) in
                                    if success, let email = email {
                                        completion(basicInfo(linkedInId,firstName,lastName,email,profileURL),nil)
                                    } else {
                                        completion(nil, "Something is wrong.")
                                    }
                                }
                                
                            } else {
                                completion(nil, "Something is wrong.")
                            }
                        }
                        catch {
                            print("Could not convert JSON data into a dictionary.")
                        }
                    } else {
                        completion(nil, "Something is wrong.")
                    }
                }
                
                task.resume()
            }
            else {
                completion(nil, "Url is not found")
            }
            print("=======")
            print(token)
            print("==========")
            
        }, failure: { (error) in
            print(error.localizedDescription)
        }) {
            print("Cancel")
        }
    }
    
    //Get email id api call
    private func getEmailId(token : String, completion:@escaping(Bool, String?) -> Void) {
        
        // Initialize a mutable URL request object.
        if let url = URL(string: LinkedInfo.requestURL_MemberEmailAddress) {
            var request = URLRequest(url: url)
            // Indicate that this is a GET request.
            request.httpMethod = "GET"
            // Add the access token as an HTTP header field.
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Initialize a NSURLSession object.
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            // Make the request.
            let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                if statusCode == 200 {
                    // Convert the received JSON data into a dictionary.
                    do {
                        let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                        
                        if let dataDictionary = dataDictionary as? [String :Any], let elements = dataDictionary["elements"] as? [Any], elements.count > 0 {
                            if let dict = elements[0] as? [String: Any], let emailInfo = dict["handle~"] as? [String: Any], let email = emailInfo["emailAddress"] as? String {
                                completion(true, email)
                                return
                            }
                        }
                        completion(false, nil)
                        return
                    } catch {
                        print("Could not convert JSON data into a dictionary.")
                        completion(false, nil)
                        return
                    }
                }
                completion(false, nil)
            }
            
            task.resume()
        }
    }
    
    
    private func writeConsoleLine(_ log: String, file: String = #file, function: String = #function, line: Int = #line ) {
        DispatchQueue.main.async { () -> Void in
            #if DEVELOPMENT
            print("\(log) called from \(function) \(file):\(line)")
            #endif
        }
    }
    
    private func clearCookieof(name:String = "linkedin"){
        let cookieStorage: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieStorage.cookies {
            for cookie in cookies {
                print("cookie.domain:\(cookie.domain)")
                if cookie.domain.contains(name) {
                    cookieStorage.deleteCookie(cookie)
                }
            }
        }
    }
    
}


