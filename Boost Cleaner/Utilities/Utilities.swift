//
//  Utilities.swift
//  Cleaner
//
//  Created by Qaiser Butt on 4/3/19.
//  Copyright © 2019 Rad Pony. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import Purchases
import SystemConfiguration
import MessageUI
import EzPopup

class Utilities {
    
    static func getUDID() -> String {
        if let vendor  = UIDevice.current.identifierForVendor {
            print("vendor.uuidString = ", vendor.uuidString)
            return vendor.uuidString
        }
        
        return ""
    }
    
    static func identifyUserOnPurchase() {
        Purchases.shared.logIn(Utilities.getUDID()) { purchaserInfo, created, error in
            if let e = error {
                print(e.localizedDescription)
                print("user not identified on purchase")
            } else {
                print("user identified on purchase")
            }
            
            Utilities.refreshSubscriptionStatus()
        }
    }
    
    static func refreshSubscriptionStatus() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            
            let isSubscribedInSwiftyStoreKit = PaymentManager.shared.isPurchase()
            let isSubscribedInRevenueCat = purchaserInfo?.entitlements.all["pro"]?.isActive == true
            if isSubscribedInRevenueCat { // User is already subscribed in RevenueCat
                if let expireTime = purchaserInfo?.latestExpirationDate?.timeIntervalSince1970 {
                    PaymentManager.shared.savePurchase(active: true, time: expireTime, isFromRestore: true, itemID: "")
                } else {
                    PaymentManager.shared.savePurchase(active: true, time: Date().timeIntervalSince1970, isFromRestore: true, itemID: "")
                }
            } else if isSubscribedInSwiftyStoreKit {
                Utilities.restoreOnRevenueCat()
            } else {
                PaymentManager.shared.savePurchase(active: false, time: Date().timeIntervalSince1970, isFromRestore: true, itemID: "")
            }
        }
    }
    
    static func restoreOnRevenueCat() {
        // User isn't subscribed in RevenueCat but is
        // in SwiftyStoreKit. Let's restore. This will
        // sync the user's receipt with RevenueCat
        Purchases.shared.restoreTransactions({ (info, err) in
            
            // info should contain updated PurchaserInfo
            // now check again if the user has an active entitlement
            let isSubscribedInRC = info?.entitlements.all["pro"]?.isActive == true
            if isSubscribedInRC {
                if let expireTime = info?.latestExpirationDate?.timeIntervalSince1970 {
                    PaymentManager.shared.savePurchase(active: true, time: expireTime, isFromRestore: true, itemID: "")
                } else {
                    PaymentManager.shared.savePurchase(active: true, time: Date().timeIntervalSince1970, isFromRestore: true, itemID: "")
                }
            } else {
                PaymentManager.shared.savePurchase(active: false, time: Date().timeIntervalSince1970, isFromRestore: true, itemID: "")
            }
        })
    }    
    
    static func scheduleNotification(at date: Date, delegate: UNUserNotificationCenterDelegate) {
        let date = Date(timeIntervalSinceNow: 86400)
        let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
        
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let content = UNMutableNotificationContent()
        
        content.title = "Boost Cleaner Reminder".localized
        
        if IS_IPAD {
            content.body = "It's been a long time since you've cleaned up your iPad!".localized
        } else {
            content.body = "It's been a long time since you've cleaned up your iPhone!".localized
        }
        
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.categoryIdentifier = "myCategory"
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = delegate
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    static func removeAllNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
        
    static func containsRatingEvent(event: ReviewPopupLocation) -> Bool {
        let events = EventManager.shared.ratingLocations
        if events.contains(event) {
            return true
        }
        return false
    }
    
    static func rateApp(controller: UIViewController, completion: ((Bool) -> Void)? = nil) {
        if EventManager.shared.askSupportLine == false {
//            if #available(iOS 14.0, *) {
//                if let scene = UIApplication.shared.currentScene {
//                    SKStoreReviewController.requestReview(in: scene)
//                }
//            } else {
            SKStoreReviewController.requestReview()
//            }
            
            if let callback = completion {
                callback(true)
            }
            
            return
        }
        
        let alertController = UIAlertController(title: EventManager.shared.ratePopupTitle, message: EventManager.shared.ratePopupMsg, preferredStyle: .alert)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "SFRounded-Bold", size: 21)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: EventManager.shared.ratePopupTitle, attributes: titleAttributes)
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let messageString = NSAttributedString(string: EventManager.shared.ratePopupMsg, attributes: messageAttributes)
        
        alertController.setValue(titleString, forKey: "attributedTitle")
        alertController.setValue(messageString, forKey: "attributedMessage")
        
        // let alertController = UIAlertController(title: EventManager.shared.ratePopupTitle,
        //                                                message: EventManager.shared.ratePopupMsg,
        //                                                preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Yes".localized, style: .default) { (action) in
            Utilities.writeReview()
            if let callback = completion {
                callback(true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "No".localized, style: .default) { (action) in
            let alertController = UIAlertController(title:  "Contact Us!".localized, message: "Would you like to contact App support?".localized, preferredStyle: .alert)
            let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "SFRounded-Bold", size: 21)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let titleString = NSAttributedString(string:  "Contact Us!".localized, attributes: titleAttributes)
            let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let messageString = NSAttributedString(string: "Would you like to contact App support?".localized, attributes: messageAttributes)
            alertController.setValue(titleString, forKey: "attributedTitle")
            alertController.setValue(messageString, forKey: "attributedMessage")
            
            let okAction = UIAlertAction(title: "Yes".localized, style: .default) { (action) in
                // Modify following variables with your text / recipient
                let recipientEmail = mailSupport.localized
                let subject = "Boost Cleaner feedback".localized
                let body = ""
                
                // Show default mail composer
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = controller as? MFMailComposeViewControllerDelegate
                    mail.setToRecipients([recipientEmail])
                    mail.setSubject(subject)
                    mail.setMessageBody(body, isHTML: false)
                    
                    controller.present(mail, animated: true)
                }
            }
            
            let cancelAction = UIAlertAction(title: "No".localized, style: .cancel) { (action) in
                if let callback = completion {
                    callback(true)
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            controller.present(alertController, animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func writeReview() {
        let productURL = "https://apps.apple.com/us/app/id" + appid
        if let url = URL(string: productURL) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "action", value: "write-review")]
            if let writeReviewURL = components?.url {
                UIApplication.shared.open(writeReviewURL)
            } else {
                SKStoreReviewController.requestReview()
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
    
    static func isIPhoneXSeriesDevice() -> Bool {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let deviceARatio = width / height
        var filename = false
        
        
        if deviceARatio >= 0.44 && deviceARatio <= 0.47 {
            filename = true
        }
        return filename
    }
    
    static func prepare(title: String, message: String, parentVC: UIViewController, okAction: (() -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Okay".localized, style: .default) { action in
            okAction?()
        }
        
        alertController.addAction(OKAction)
        parentVC.present(alertController, animated: true, completion: nil)
    }
    
    static var isAvailable: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    static func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let regAttrs = [NSAttributedString.Key.font : font]
        let attrs = [NSAttributedString.Key.font : font.bold()]
        let regularString = NSMutableAttributedString(string: string, attributes: regAttrs)
        let boldiString = NSMutableAttributedString(string: boldString, attributes:attrs)
        
        regularString.append(boldiString)
        
        return regularString
    }
    
    static func showPremium(parentController: UIViewController, isAppDelegate: Bool, isFromStore: Bool, iapEvent: InAppEventLocations) {}
    
    static func convertIntoDatabaseParam(iapLocation: InAppEventLocations) -> String? {
        switch iapLocation {
        case .afterOnboarding:
            return "afterOnboarding"
        case .onFastScan:
            return "onFastScan"
        case .onPhotoSimilarDelete:
            return "onPhotoSimilarDelete"
        case .onFastSimilarDelete:
            return "onFastSimilarDelete"
        case .onScreenshotsDelete:
            return "onScreenshotsDelete"
        case .onLiveDelete:
            return "onLiveDelete"
        case .onSelfieDelete:
            return "onSelfieDelete"
        case .onDuplicatesDelete:
            return "onDuplicatesDelete"
        case .onVideosSimilarDelete:
            return "onVideosSimilarDelete"
        case .onVideosDelete:
            return "onVideosDelete"
        case .onContactsDuplicateName:
            return "onContactsDuplicateName"
        case .onContactsDuplicatePhone:
            return "onContactsDuplicatePhone"
        case .onContactsDuplicateEmail:
            return "onContactsDuplicateEmail"
        case .onAdblocker:
            return "onAdblocker"
        case .onSettings:
            return "onSettings"
        case .onSpeedChecker:
            return "onSpeedCheker"
        case .onHome:
            return "onHome"
        default:
            return nil
        }
    }
    
    static func openAppSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    static func showAlert(title: String, message: String, parentController: UIViewController, delegate: AlterLocationContactDelegate) {
        let Alterloc = AlterLocationContact.instantiate()
        
        Alterloc?.headerTitle = title.localized
        Alterloc?.detailMessage = message.localized
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            guard let pickerVC = Alterloc else { return }
            pickerVC.delegate = delegate
            
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 500, popupHeight: 260)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            
            parentController.present(popupVC, animated: true, completion: nil)            
        } else {
            guard let pickerVC = Alterloc else { return }
            pickerVC.delegate = delegate
            
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 300, popupHeight: 160)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            
            parentController.present(popupVC, animated: true, completion: nil)
        }
    }
}


