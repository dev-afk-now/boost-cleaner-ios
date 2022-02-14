//
//  SceneDelegate.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/22/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import AppsFlyerLib

@available(iOS 13.0, *)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let content = UNMutableNotificationContent()

    var window: UIWindow?
        
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // Processing Universal Link from the killed state
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
        // Processing URI-scheme from the killed state
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        guard let _ = (scene as? UIWindowScene) else { return }
        
        AppSetting.sharedInstance.initialize()
         
//        let isFirstTime = UserDefaults.standard.bool(forKey: "isFirstTime")
//        if  isFirstTime == true {
//            UserDefaults.standard.set(true, forKey: "showBadgeCount")
//            UIApplication.shared.applicationIconBadgeNumber = 0
//
//            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber )
//            showOnboardingsVC()
//        } else {
            showHomeVC()
        //}
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
        
        AppsFlyerLib.shared().handleOpen(url, options: nil)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
//        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
//        if let _ = userActivity.interaction?.intent as? BatteryAnimationIntent {
////            guard (intent.playAnimation != nil) else {return}
//            delay(0.1) {
//                if let vc = UIApplication.getTopViewController(), !vc.isModal{
////                    let storyBoard = UIStoryboard.init(name: "Compression", bundle: nil)
////                    let batteryVC = storyBoard.instantiateViewController(withIdentifier: "BatteryAnimationVC") as! BatteryAnimationVC
////                    UIViewController.preventPageSheetPresentation
////                    vc.navigationController?.present(batteryVC, animated: false, completion: nil)
//                }
//            }
//        }
    }
    
    func delay(_ delay:Double, closure: @escaping ()-> Void) {
        let delayTime = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: closure)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.isIdleTimerDisabled = true
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
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

}

