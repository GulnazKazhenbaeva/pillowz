//
//  AppDelegate.swift
//  Pillowz
//
//  Created by Samat on 24.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import Fabric
import Crashlytics
import OneSignal
import IQKeyboardManagerSwift
import GoogleSignIn
import FacebookCore
import GooglePlaces
import FirebaseDatabase


public typealias PushNotificationOpenedClosure = (_ payloadData:[String:Any]) -> Void

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {
    var tabbarController:MainTabBarController!
    var window: UIWindow?
    
    var locationManager:LocationManager!
    
    var newMessagesBadgeRef: DatabaseReference!
    var myRequestsClientBadgeRef: DatabaseReference!
    var myRequestsRealtorBadgeRef: DatabaseReference!
    
    var pushNotificationOpenedClosure:PushNotificationOpenedClosure!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager = LocationManager.shared
        
        var firebaseResourceFileName:String
        
        if Constants.isTesting {
            firebaseResourceFileName = "FirebaseTest-GoogleService-Info"
        } else {
            firebaseResourceFileName = "FirebaseProd-GoogleService-Info"
        }
        
        let filePath = Bundle.main.path(forResource: firebaseResourceFileName, ofType: "plist")
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
            else {
                assert(false, "Couldn't load config file")
        }
        FirebaseApp.configure(options: fileopts)
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "266714012309-dqop11irlalnq6rqn33iuhmvoh33a6tu.apps.googleusercontent.com"
        GMSServices.provideAPIKey(Constants.googleMapsAPIKey)
        GMSPlacesClient.provideAPIKey(Constants.googleMapsAPIKey)
        SVGeocoder.setGoogleMapsAPIKey(Constants.googleMapsAPIKey)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
                
        IQKeyboardManager.sharedManager().enable = true
        
        Fabric.with([Crashlytics.self])
        
        window = UIWindow(frame: Constants.screenFrame)
        window!.makeKeyAndVisible()
        
        tabbarController = MainTabBarController.shared
        tabbarController.view.backgroundColor = UIColor.white
        
        let tabbarNavigationController = UINavigationController(rootViewController: tabbarController)
        tabbarNavigationController.setNavigationBarHidden(true, animated: false)
        
        let rootViewController = UserDefaults.standard.bool(forKey: "tutorialLooked") ? tabbarNavigationController : TutorialViewController()
    
        window!.rootViewController = rootViewController
        
        configureNavigationBarDesign()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 10)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 10)!], for: .selected)

        configureBadges()
        configureOneSignal(launchOptions: launchOptions)
        displayFonts()
        UIFont.overrideInitialize()

        UILabel.appearance().font = UIFont(name: "OpenSans-Regular", size: 14)
        
        CategoriesHandler.sharedInstance.getCategories()
        CategoriesHandler.sharedInstance.getCountries()
        CategoriesHandler.sharedInstance.getLanguages()
        
        updateUserInfo()
        
        return true
    }
    
    func updateUserInfo() {
        if (User.isLoggedIn()) {
            AuthorizationAPIManager.getClientInfo { (userObject, error) in
                
            }
        }
    }
    
    func configureBadges() {
        if (User.shared.user_id == nil) {
            return
        }
        
        newMessagesBadgeRef = Database.database().reference().child("badges").child(String(User.shared.user_id!)).child("chat").child("total")
        
        newMessagesBadgeRef.observe(DataEventType.value, with: { (snapshot) in
            let newMessagesCount = snapshot.value as? NSNumber
            // ...
            if (newMessagesCount != nil) {
                BadgeView.messagesBadge.value = newMessagesCount!.intValue
            } else {
                BadgeView.messagesBadge.value = 0
            }
        })
        
        myRequestsClientBadgeRef = Database.database().reference().child("badges").child(String(User.shared.user_id!)).child("client").child("total")
        
        myRequestsClientBadgeRef.observe(DataEventType.value, with: { (snapshot) in
            let myRequestsClientCount = snapshot.value as? NSNumber
            // ...
            if (myRequestsClientCount != nil) {
                BadgeView.myRequestsClientBadge.value = myRequestsClientCount!.intValue
            } else {
                BadgeView.myRequestsClientBadge.value = 0
            }
        })
        
        myRequestsRealtorBadgeRef = Database.database().reference().child("badges").child(String(User.shared.user_id!)).child("realtor").child("total")
        
        myRequestsRealtorBadgeRef.observe(DataEventType.value, with: { (snapshot) in
            let myRequestsRealtorCount = snapshot.value as? NSNumber
            // ...
            if (myRequestsRealtorCount != nil) {
                BadgeView.myRequestsRealtorBadge.value = myRequestsRealtorCount!.intValue
                BadgeView.myRequestsRealtorTopTabBadge.value = myRequestsRealtorCount!.intValue
            } else {
                BadgeView.myRequestsRealtorBadge.value = 0
                BadgeView.myRequestsRealtorTopTabBadge.value = 0
            }
        })
        
        User.setupCurrentRoleBadges()
    }
    
    func configureNavigationBarDesign() {
        //changed
        //UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: Constants.paletteBlackColor, NSAttributedStringKey.font:UIFont.init(name: "OpenSans-SemiBold", size: 18)!]
//
//        UINavigationBar.appearance().isTranslucent = false
//
//        let barButtonItemAppearance = UIBarButtonItem.appearance()
//        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Constants.paletteVioletColor], for: .normal)
        
        UINavigationBar.appearance().barTintColor = Colors.mainVioletColor
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font:UIFont.init(name: "OpenSans-SemiBold", size: 18)!]
        UINavigationBar.appearance().isTranslucent = false
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        
        let backImage = UIImage(named: "backGrey")?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
    }
    
    func configureOneSignal(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppAlerts: true]
        
        pushNotificationOpenedClosure = { (payloadData) in
            let additionalData = payloadData
            
            if let requestId = additionalData["request_id"] as? Int {
                let vc = RequestOrOfferViewController()
                vc.requestId = requestId
                
                RequestUpdateFirebaseListener.shared.requestVC = vc
                RequestUpdateFirebaseListener.shared.requestId = requestId
                
                if let offerId = additionalData["offer_id"] as? Int {
                    vc.offerId = offerId
                }
                
                UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
            }
            
            if let room = additionalData["chat_id"] as? String {
                let vc = ChatViewController()
                vc.hidesBottomBarWhenPushed = true

                vc.room = room
                UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        let handleNotificationReceived: OSHandleNotificationReceivedBlock = { (notification) in
            //if client is in RequestsListViewController and new request comes - update
            if let payload = notification?.payload.additionalData["data"] as? [String:Any] {
                if let _ = payload["request_id"] as? Int {
                    let requestsVC = UIApplication.topViewController() as? RequestsListViewController
                    requestsVC?.page = 1
                    requestsVC?.loadNextPage()
                    
                    
                    let realtorRequestsVC = UIApplication.topViewController() as? RealtorRequestsViewController
                    realtorRequestsVC?.myRequestsVC.page = 0
                    realtorRequestsVC?.myRequestsVC.loadNextPage()
                }
                
                if let _ = payload["chat_id"] as? Int {
                    let chatsVC = UIApplication.topViewController() as? ChatsViewController
                    
                    chatsVC?.loadChats()
                }
            }
        }
        
        let handleNotificationAction: OSHandleNotificationActionBlock = { (notificationOpenedResult) in
            if notificationOpenedResult != nil {
                self.pushNotificationOpenedClosure(notificationOpenedResult!.notification.payload.additionalData as! [String : Any])
            }
        }
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: Constants.oneSignalKey, handleNotificationReceived: handleNotificationReceived, handleNotificationAction: handleNotificationAction, settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        OneSignal.add(self as OSSubscriptionObserver)
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        print("Subscribed for OneSignal push notifications!")
        print("\(stateChanges.to.userId)")
        print("\(stateChanges.to.pushToken)")
        
        if (stateChanges.to.userId != nil && stateChanges.to.userId != "") {
            AppDelegate.savePushPlayerId(stateChanges.to.userId!)
        }
        
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookHandler = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let googleHandler = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return facebookHandler
    }
    
    func displayFonts() {
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    class func savePushPlayerId(_ playerId:String) {
        UserDefaults.standard.set(playerId, forKey: Constants.pushPlayerIdStringKey)
    }
    
    class func getPushPlayerId() -> String {
        let pushToken = UserDefaults.standard.value(forKey: Constants.pushPlayerIdStringKey) as? String
        
        if (pushToken == nil) {
            return ""
        } else {
            return pushToken!
        }
    }
}


