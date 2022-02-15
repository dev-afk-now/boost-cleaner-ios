//
//  AppDelegate.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/22/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import AVFoundation
import Firebase
import FirebaseCrashlytics
import EventKit
import Purchases
import Amplitude
import SDWebImagePhotosPlugin
import FBSDKCoreKit
import AppsFlyerLib
import Intents

//import AdSupport
//import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let content = UNMutableNotificationContent()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let abc = MediaComparatorService()
        abc.searchSimilar(images: [
            UIImage(named: "checkMark") ?? UIImage(),
            UIImage(named: "check_box") ?? UIImage(),
            UIImage(named: "checkMark") ?? UIImage()
        ])
        application.isIdleTimerDisabled = true

        let navBackgroundImage:UIImage! = UIImage(named: "")
        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, for: .default)
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().tintColor = hexStringToUIColor(hex: "#062549")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#062549")]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            UINavigationBar.appearance().titleTextAttributes =
                [NSAttributedString.Key.foregroundColor:  hexStringToUIColor(hex: "#062549"),
                 NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 35)!]
            UINavigationBar.appearance().isTranslucent = false
        } else {
            UINavigationBar.appearance().titleTextAttributes =
                [NSAttributedString.Key.foregroundColor:  hexStringToUIColor(hex: "#062549"),
                 NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 17)!]
            UINavigationBar.appearance().isTranslucent = false
        }
                
        //UserNotifications
        let action = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        let category = UNNotificationCategory(identifier: "myCategory", actions: [action], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
                
        do { // Background Music play handling
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
       // SDWebImageManager.shared.imageCache.deleteOldFiles(completionBlock: nil)
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        URLCache.shared.removeAllCachedResponses()
        SDImageCache.shared.config.maxDiskAge = 3600 * 24 * 7; // 1 week
        SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 20; //20 images
        SDImageCache.shared.config.shouldUseWeakMemoryCache = false; //Default True => Store images in RAM
        SDImageCache.shared.config.diskCacheReadingOptions = NSData.ReadingOptions.mappedIfSafe

        FirebaseApp.configure()
        AppSetting.sharedInstance.initialize()
        EventManager.shared.initialze()

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerPublicSDKKey
        AppsFlyerLib.shared().appleAppID = appid
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false
        
        let isFirstTime = UserDefaults.standard.bool(forKey: "isFirstTime")
        if  isFirstTime == true {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 120)
        }
        
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        // RevenueCat Cofig
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: rcPublicSDKKey)
        Purchases.shared.delegate = self
        Purchases.shared.collectDeviceIdentifiers()     // Automatically collect the $idfa, $idfv, and $ip values
        Purchases.shared.setAppsflyerID(AppsFlyerLib.shared().getAppsFlyerUID())    // Set the Appsflyer Id
        //Purchases.shared.allowSharingAppStoreAccount = true
        Purchases.shared.offerings  { (offerings, error) in
            if error != nil {
                print("failed to fetch offerings")
            } else {
                print("successfully fetched offerings")
            }
        }

        Utilities.identifyUserOnPurchase()
        
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey(amplitudeAPIKey)
        Amplitude.instance().setUserId(Utilities.getUDID(), startNewSession: true)
        /*Amplitude.instance().adSupportBlock = {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }*/
      
        //let isFirstTime = UserDefaults.standard.bool(forKey: "isFirstTime")
//        if  isFirstTime == true {
//            UserDefaults.standard.set(true, forKey: "showBadgeCount")
//            UIApplication.shared.applicationIconBadgeNumber = 0
//
//            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber)
//            showOnboardingsVC()
//        } else {
            showHomeVC()
        //}
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Start the SDK (start the IDFA timeout set above, for iOS 14 or later)
        AppsFlyerLib.shared().start()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        // Report Push Notification attribution data for re-engagements
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
    
    // Open Univerasal Links
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(" user info \(userInfo)")
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }

    // Open URI-scheme for iOS 9 and above
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
    // Reports app open from deep link for iOS 10 or later
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
//        if let _ = userActivity.interaction?.intent as? BatteryAnimationIntent {
//            delay(0.1) {
//                if let vc = UIApplication.getTopViewController(), !vc.isModal{
////                    let storyBoard = UIStoryboard.init(name: "Compression", bundle: nil)
////                    let batteryVC = storyBoard.instantiateViewController(withIdentifier: "BatteryAnimationVC") as! BatteryAnimationVC
////                    //                UIViewController.preventPageSheetPresentation
////                    vc.navigationController?.present(batteryVC, animated: false, completion: nil)
//                }
//            }
//        }
        return true
    }
    
//    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
//        if intent is BatteryAnimationIntent {
//            return BatteryAnimationHandler()
//        }
//    }
    
    func delay(_ delay:Double, closure: @escaping ()-> Void) {
        let delayTime = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: closure)
    }
    
    func showOnboardingsVC(){
//        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
//        let onboardingsVC = storyBoard.instantiateViewController(withIdentifier: "OnboardingsVC") as! OnboardingsVC
//        let nvc: UINavigationController = UINavigationController (rootViewController: onboardingsVC)
//        self.window?.rootViewController = nvc
//        self.window?.backgroundColor = .white
//        self.window?.makeKeyAndVisible()
    }
    
    
    func showHomeVC(){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let nvc: UINavigationController = UINavigationController (rootViewController: homeVC)
        self.window?.rootViewController = nvc
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PrivateVault")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
        
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    @objc func sendLaunch() {
        AppsFlyerLib.shared().start()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "remindLater" {
            let newDate = Date(timeInterval: 3600, since: Date())
            Utilities.scheduleNotification(at: newDate, delegate: self)
        }
    }
}

extension AppDelegate: PurchasesDelegate {
  
    func purchases(_ purchases: Purchases, shouldPurchasePromoProduct product: SKProduct, defermentBlock makeDeferredPurchase: @escaping RCDeferredPromotionalPurchaseBlock) {
        
        // Save the deferment block and call it later...
        //let defermentBlock = makeDeferredPurchase

        // ...or call it right away to proceed with the purchase
        makeDeferredPurchase { (transaction, purchaserInfo, error, cancelled) in

            if let info = purchaserInfo, let entitlement = info.entitlements.all["pro"] {
                if let latestExpirationDate = info.latestExpirationDate, (entitlement.isActive == true) {
                    let expireTime = latestExpirationDate.timeIntervalSince1970
                    PaymentManager.shared.savePurchase(active: true, time: expireTime, isFromRestore: false, itemID: product.localizedTitle)
                } else {
                    PaymentManager.shared.savePurchase(active: false, time: Date().timeIntervalSince1970, isFromRestore: false, itemID: product.localizedTitle)
                }
            } else {
                PaymentManager.shared.savePurchase(active: false, time: Date().timeIntervalSince1970, isFromRestore: false, itemID: product.localizedTitle)
            }
        }
    }
    
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        // handle any changes to purchaserInfo
    }
}

//MARK: AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        print("onConversionDataSuccess data:")
        
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                   let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
               is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
        
        // IMPORTANT!! - Don't forget to include the network user ID
        Purchases.addAttributionData(installData, from: .appsFlyer, forNetworkUserId: AppsFlyerLib.shared().getAppsFlyerUID())
    }
    
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}
