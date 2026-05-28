//
//  AppDelegate.swift
//  bemyrider
//
//  Created by Nirav Sapariya on 04/04/18.
//  Copyright © 2018 NMS. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import MOLH
import Alamofire
import AlamofireImage
import GooglePlaces
import GoogleSignIn
import FacebookCore
import FacebookLogin
import NotificationBannerSwift
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appIsStarting:Bool = false
    var notification = NotificationManager(notification: [:])
    var isCustomerLogin = false
    var tempDict : [String: Any]?
    var noti_data : [String : Any]?
    var pendingRiderDeepLink: String? // rider providerId da aprire dopo rootToHome
    var networkReachabilityManager  = NetworkReachabilityManager()

    var bundleId:String {
        get{
            return Bundle.main.bundleIdentifier ?? "com.test.api"
        }
    }
    
    var banner = StatusBarNotificationBanner(title: "No Internet Connection", style: .danger)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 1. Configurazioni UI immediate (sincrone)
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        GMSPlacesClient.provideAPIKey(Google.placeId)
        
        // 2. Configura URLCache per immagini e API
        let cache = URLCache(
            memoryCapacity: 50_000_000,
            diskCapacity: 200_000_000,
            diskPath: "image_cache"
        )
        URLCache.shared = cache
        
        // 3. Launch UI (prioritaria)
        launchApp()
        
        // 4. Auto login (differito)
        if let userData = UserData.shared.getUser(), userData.user_id != "0" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.processAutoLogin(launchOptions: launchOptions)
            }
        }
        
        // 5. Connectivity check in background
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.checkInternetConnectivity()
        }
        
        // 6. Registrazione notifiche differita
        DispatchQueue.main.async {
            self.registerRemoteNotification(application)
        }
        
        return true
    }
    
    private func processAutoLogin(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let launchOptions = launchOptions, let notificationData = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String : Any] {
            self.noti_data = notificationData
            appIsStarting = true
            self.notification = NotificationManager(notification: notificationData)
        }

        // Universal Link passato nelle launch options (es. apertura da WhatsApp cold start)
        if let activityDict = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any],
           let activity = activityDict["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity,
           activity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = activity.webpageURL {
            print("🔗 [launchOptions] Universal Link trovato: \(url)")
            _ = handleRiderDeepLink(url: url)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.appIsStarting = false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.appIsStarting = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: .reloadPicker, object: [:])
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.appIsStarting = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    
    func updateIconBadge() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.count
            }
        }
    }
}

//Custom functions
extension AppDelegate{
    
    
    private func registerRemoteNotification(_ application: UIApplication) {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.alert, .sound]) { (granted, error) in
            print(error?.localizedDescription ?? "")
            // Enable or disable features based on authorization.
        }
        center.delegate = self
        application.registerForRemoteNotifications()
        
    }
    
    //MARK:- Other Functions
    func launchApp(){
        
        // Default Italian langauge convert
        if UserData.shared.languageID.isEmpty {
            UserData.shared.setLanguage(language: "Italian")
            UserData.shared.setLanguageID(languageID: "4")
            MOLH.setLanguageTo(MuliLangShortHand.it.rawValue)
        }
        
        let splashVC = SplashVC.storyboardInstance
        let nav = UINavigationController(rootViewController: splashVC)
        nav.navigationBar.isHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func rootToHome(isFirstLogin:Bool = false){
        let newRoot: UIViewController
        if UserData.shared.getUserLoginData() == nil {
            let signupVC = SignUpHostingVC()
            newRoot = UINavigationController(rootViewController: signupVC)
        }else{
            newRoot = getTabBar()
        }

        guard let window = self.window else { return }

        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: {
            window.rootViewController = newRoot
        }, completion: nil)
        window.makeKeyAndVisible()

        // Consuma il deep link pendente (es. cold start da Universal Link)
        if let riderId = pendingRiderDeepLink,
           let tabBar = newRoot as? UITabBarController,
           let rootNav = tabBar.selectedViewController as? UINavigationController {
            pendingRiderDeepLink = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.navigateToProviderProfile(providerId: riderId, rootNav: rootNav)
            }
        }
    }
    
    func rootToLogin(){
        let tabBarVC = getTabBar(isLoginSelected: true)

        guard let window = self.window else { return }

        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarVC
        }, completion: nil)
        window.makeKeyAndVisible()
        tabBarVC.selectedIndex = 2
    }
    
    func getTabBar(isLoginSelected: Bool = false) -> AnimatedTabBarController {
        let tabBarController = AnimatedTabBarController()
        
        tabBarController.tabBar.backgroundColor = UIColor.white
        tabBarController.tabBar.barTintColor = UIColor.white
        tabBarController.hidesBottomBarWhenPushed = true
        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBarController.tabBar.layer.shadowRadius = 3
        tabBarController.tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.12
        if let _ = UserData.shared.getUserLoginData(),let user = UserData.shared.getUser(), user.user_type == "c" {
            Modal.sharedAppdelegate.isCustomerLogin = true
            
            let v1 = HomeHostingVC()
            let v2 = FavouritesHostingVC()
            let v3 = ServiceRequestHostingVC()
            let v4 = MessagesHostingVC()
            let v5 = MenuHostingVC()
            
            v1.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "searchBlack"), selectedImage: UIImage(named: "searchBlack"))
            v2.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ic_favourite"), selectedImage: UIImage(named: "ic_favourite"))
            v3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "serviceIcoMenu"), selectedImage: UIImage(named: "serviceIcoMenu"))
            v4.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "emailIco"), selectedImage: UIImage(named: "emailIco"))
            v5.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabMenuIcon"), selectedImage: UIImage(named: "tabMenuIcon"))
            
            let n1 = InteractivePopNavigationController.init(rootViewController: v1)
            let n2 = InteractivePopNavigationController.init(rootViewController: v2)
            let n3 = InteractivePopNavigationController.init(rootViewController: v3)
            let n4 = InteractivePopNavigationController.init(rootViewController: v4)
            let n5 = InteractivePopNavigationController.init(rootViewController: v5)
            
            tabBarController.viewControllers = [n1, n2, n3, n4, n5]
        }else if let _ = UserData.shared.getUserLoginData(),let user = UserData.shared.getUser(), user.user_type == "p" {
            Modal.sharedAppdelegate.isCustomerLogin = false
            let v1 = ServiceRequestHostingVC()
            let v2 = MessagesHostingVC()
            let v3 = ProviderProfileHostingVC()
            let v5 = MenuHostingVC()

            v1.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabHomeIcon"), selectedImage: UIImage(named: "tabHomeIcon"))
            v2.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "emailIco"), selectedImage: UIImage(named: "emailIco"))
            v3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabProfileIcon"), selectedImage: UIImage(named: "tabProfileIcon"))
            v5.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabMenuIcon"), selectedImage: UIImage(named: "tabMenuIcon"))

            let n1 = InteractivePopNavigationController.init(rootViewController: v1)
            let n2 = InteractivePopNavigationController.init(rootViewController: v2)
            let n3 = InteractivePopNavigationController.init(rootViewController: v3)
            let n5 = InteractivePopNavigationController.init(rootViewController: v5)
            tabBarController.viewControllers = [n1, n2, n3, n5]

        }else{
            // without login
            let signupVC = SignUpHostingVC()
            signupVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabMenuIcon"), selectedImage: UIImage(named: "tabMenuIcon"))
            let n1 = InteractivePopNavigationController.init(rootViewController: signupVC)
            tabBarController.viewControllers = [n1]
        }
        
        return tabBarController
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            defaults.synchronize()
            print("App launched first time")
            return false
        }
    }
    
    func callAutoLogin(failer:@escaping() -> () , success:@escaping() -> ()) {
        if let userData = UserData.shared.getUserLoginData(){
            Modal.shared.autoLogin(param: ["email": userData.email, "password": userData.password], failer: { (err) in
                if err != "The Internet connection appears to be offline." || err != "Could not connect to the server."{
                    UserData.shared.logoutUser()
                    failer()
                }
            }) { (dic) in
                print("AutoLogin response:", dic)
                let data = ResponseKey.fatchData(res: dic, valueOf: .data).dic
                _ = UserData.shared.setUser(dic: data)
                if let isUserActive = data["isUserActive"] as? String {
                    if isUserActive.lowercased() == "d" {
                        failer()
                        return
                    }
                }
                Modal.shared.autoSaveNotificationSettings()
                success()
            }
        }
    }
}

//MARK: FB & Google Login
extension AppDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:] ) -> Bool {
        print("🔗 [openURL] url=\(url.absoluteString)")
        let stripeHandled = StripeAPI.handleURLCallback(with: url)
        if stripeHandled {
            return true
        }

        // Deep link: bemyrider://rider?id=XXX
        if url.scheme == "bemyrider" {
            return handleRiderDeepLink(url: url)
        }

        if url.absoluteString.hasPrefix("com.googleusercontent.apps") {
            return GIDSignIn.sharedInstance.handle(url)
        }
        else if (url.scheme?.hasPrefix("fb"))!{
            return ApplicationDelegate.shared.application(application, open: url, options: options)
        }
        return false
    }
    
    // This method handles opening universal link URLs (for example, "https://example.com/stripe_ios_callback")
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool  {
        print("🔗 [continueUserActivity] activityType=\(userActivity.activityType) url=\(userActivity.webpageURL?.absoluteString ?? "nil")")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                if stripeHandled {
                    return true
                }
                // Deep link: bemyrider.it/rider?id=XXX
                if handleRiderDeepLink(url: url) {
                    return true
                }
            }
        }
        return false
    }
}

//MARK: Deep Link — Rider Profile
extension AppDelegate {

    @discardableResult
    func handleRiderDeepLink(url: URL) -> Bool {
        print("🔗 [DeepLink] handleRiderDeepLink: \(url)")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        let path = components?.path ?? ""
        print("🔗 [DeepLink] path='\(path)' host='\(url.host ?? "nil")'")
        guard path.contains("rider") || url.host == "rider" else {
            print("🔗 [DeepLink] ❌ path guard failed")
            return false
        }

        guard let riderId = components?.queryItems?.first(where: { $0.name == "id" })?.value,
              !riderId.isEmpty else {
            print("🔗 [DeepLink] ❌ riderId non trovato. queryItems=\(components?.queryItems ?? [])")
            return false
        }
        print("🔗 [DeepLink] ✅ riderId=\(riderId)")

        let rootVC = window?.rootViewController
        print("🔗 [DeepLink] rootVC=\(type(of: rootVC as AnyObject)) user=\(UserData.shared.getUser()?.user_id ?? "nil")")

        if let tabBar = rootVC as? UITabBarController,
           let rootNav = tabBar.selectedViewController as? UINavigationController,
           UserData.shared.getUser() != nil {
            print("🔗 [DeepLink] tab bar pronta → navigating now")
            navigateToProviderProfile(providerId: riderId, rootNav: rootNav)
        } else {
            print("🔗 [DeepLink] tab bar NON pronta → salvo pending")
            pendingRiderDeepLink = riderId
        }
        return true
    }

    private func navigateToProviderProfile(providerId: String, rootNav: UINavigationController? = nil) {
        guard UserData.shared.getUser() != nil else {
            print("🔗 [DeepLink] ❌ navigateToProviderProfile: user nil")
            return
        }
        print("🔗 [DeepLink] post notifica openRiderProfile providerId=\(providerId)")
        // Switcha al tab Home (tab 0) e posta la notifica — HomeHostingVC fa il push
        if let tabBar = window?.rootViewController as? UITabBarController {
            tabBar.selectedIndex = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .openRiderProfile,
                object: nil,
                userInfo: ["providerId": providerId]
            )
        }
    }
}

//MARK: Remotenotification
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("deviceTokenString:", deviceTokenString)
        UserData.shared.setDeviceToken(deviceToken: deviceTokenString)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }

    func processNotification(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.notification.userInfo.keys.count > 0  {
                
                if self.notification.actionType == .userDeactive {
                    if Util.isNetworkReachable() {
                        self.logout()
                    }else{
                        self.logoutLocally()
                    }
                }
                else if self.notification.actionType == .message {
                    if let _ = UserData.shared.getUserLoginData(),let user = UserData.shared.getUser() {
                        if let tabBar = self.window?.rootViewController as? UITabBarController {
                            tabBar.selectedIndex = user.user_type == "c" ? 3 : 1
                        }
                    }
                }
                else if self.notification.actionType == .serviceRequest {
                    if let tabBar = self.window?.rootViewController as? UITabBarController {
                        tabBar.selectedIndex = 0
                        self.rootToHome()
                    }
                }
                else if self.notification.actionType == .disputeList {
                    let tabController = Modal.sharedAppdelegate.window?.rootViewController as? UITabBarController
                    let navigation =  tabController?.viewControllers?.first as?  InteractivePopNavigationController
                    navigation?.pushViewController(DisputeListVC.storyboardInstance!, animated: true)
                }
                else if self.notification.actionType == .displayCustomerReview {
                    let serviceDetailVC = CustomerSideServiceDetailHostingVC()
                    serviceDetailVC.providerServiceId = self.notification.providerServiceId
                    serviceDetailVC.serviceRequestId = self.notification.serviceRequestId
                    serviceDetailVC.hidesBottomBarWhenPushed = true
                    let tabController = Modal.sharedAppdelegate.window?.rootViewController as? UITabBarController
                    let navigation =  tabController?.viewControllers?.first as?  InteractivePopNavigationController
                    navigation?.pushViewController(serviceDetailVC, animated: true)
                }
                else if self.notification.actionType == .displayProviderReview {
                    let tabController = Modal.sharedAppdelegate.window?.rootViewController as? UITabBarController
                    let navigation =  tabController?.viewControllers?.first as?  InteractivePopNavigationController
                    navigation?.pushViewController(ReviewList.storyboardInstance!, animated: true)
                }
                self.notification = NotificationManager(notification: [:])
            }
        }
    }
    
    func logoutLocally(){
        UserData.shared.logoutUser()
        Modal.sharedAppdelegate.rootToHome()
    }

    func logout() {
        let param = ["user_id":UserData.shared.getUser()!.user_id, "device_token": UserData.shared.deviceToken]

        if var topController = self.window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            Modal.shared.logOut(vc: topController, param: param, failer: { (message) in
                print(message)
            }) { (dic) in
                UserData.shared.logoutUser()
                Modal.sharedAppdelegate.rootToHome()
            }
        }
    }
}

extension Notification.Name {
    static let messageScreenCustomer = Notification.Name("messageScreenCustomer")
    static let messageScreenProvider = Notification.Name("messageScreenProvider")
    static let customerMyTask = Notification.Name("customerMyTask")
    static let providerMyTask = Notification.Name("providerMyTask")
    static let isAddService = Notification.Name("isAddService")
    static let openRiderProfile = Notification.Name("openRiderProfile") // deep link rider
}

extension AppDelegate {
    // MARK: - Modern Loader

    func startLoader(loaderText: String = "") {
        guard let window = self.window else { return }
        // Remove any existing loader SYNCHRONOUSLY to avoid race conditions
        // (hideLoader uses animation, which can leave orphan views with the same tag)
        while let existing = window.viewWithTag(420123) {
            existing.layer.removeAllAnimations()
            existing.removeFromSuperview()
        }
        
        // Container with blur effect
        let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        container.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        container.center = window.center
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        container.tag = 420123
        container.alpha = 0

        // Custom animated loader circles
        let loaderContainer = UIView()
        container.contentView.addSubview(loaderContainer)
        loaderContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loaderContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            loaderContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            loaderContainer.widthAnchor.constraint(equalToConstant: 40),
            loaderContainer.heightAnchor.constraint(equalToConstant: 10)
        ])

        // Create three animated circles
        let dotColor = UIColor(red: 62/255, green: 62/255, blue: 112/255, alpha: 1)
        let circles = (0..<3).map { index -> UIView in
            let circle = UIView()
            circle.backgroundColor = dotColor
            circle.layer.cornerRadius = 5
            loaderContainer.addSubview(circle)
            circle.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: 10),
                circle.heightAnchor.constraint(equalToConstant: 10),
                circle.centerYAnchor.constraint(equalTo: loaderContainer.centerYAnchor)
            ])
            
            if index == 0 {
                circle.leadingAnchor.constraint(equalTo: loaderContainer.leadingAnchor).isActive = true
            } else if index == 1 {
                circle.centerXAnchor.constraint(equalTo: loaderContainer.centerXAnchor).isActive = true
            } else {
                circle.trailingAnchor.constraint(equalTo: loaderContainer.trailingAnchor).isActive = true
            }
            
            // Pulsing animation
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.15,
                options: [.repeat, .autoreverse],
                animations: {
                    circle.alpha = 0.3
                    circle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                }
            )
            
            return circle
        }
        
        // Message label
        if !loaderText.isEmpty {
            let label = UILabel()
            label.text = loaderText
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            container.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: loaderContainer.bottomAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
            ])
        }
        
        window.addSubview(container)
        
        // Scale in animation
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            container.transform = .identity
            container.alpha = 1
        }
    }

    func stoapLoader() {
        hideLoader()
    }
    
    private func hideLoader() {
        guard let window = self.window else { return }
        // Remove ALL loader views (handles orphans from race conditions)
        while let container = window.viewWithTag(420123) {
            container.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2, animations: {
                container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                container.alpha = 0
            }) { _ in
                container.removeFromSuperview()
            }
            // Break tag link immediately so viewWithTag won't find it again
            container.tag = 0
        }
    }
    
    func checkInternetConnectivity(){
        guard let networkReachabilityManager = self.networkReachabilityManager else { return }
        networkReachabilityManager.startListening { [weak self] networkStatus in
            guard let self = self else { return }
            switch networkStatus {
            case .notReachable:
                DispatchQueue.main.async {
                    self.banner = StatusBarNotificationBanner(title: "No Internet Connection", style: .danger)
                    self.banner.autoDismiss = false
                    self.banner.show()
                }
            case .unknown, .reachable(.ethernetOrWiFi), .reachable(.cellular):
                DispatchQueue.main.async {
                    self.banner.dismiss()
                }
            }
        }
    }
    
    
}

extension AppDelegate:UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
                print("Handling notifications with the Local Notification Identifier")
            }
        
        let state = UIApplication.shared.applicationState
        let userInfo = response.notification.request.content.userInfo
        
        print("Notification userInfo:", userInfo)
        
        if let data = userInfo as? [String:Any] {
            self.notification = NotificationManager(notification: data)
            self.processNotification()
        }

        if state == .active {
            self.processNotification()
        }

        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        if  let apsData = userInfo["aps"] as? [String: Any] {
            if  let data = apsData["data"] as? [String: Any] {
                if let notificationType = data["notification_type"] as? String , notificationType == "userdeactive"{
                    if Util.isNetworkReachable() {
                        logout()
                    }else{
                        logoutLocally()
                    }
                    
                    completionHandler([.sound])
                }
            }
        }
        completionHandler([.banner, .sound])
    }
}

