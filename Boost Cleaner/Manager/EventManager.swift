//
//  EventManager.swift
//  Photo Roulette
//
//  Created by Bilal Nawaz on 30/12/2019.
//  Copyright © 2019 Bilal Nawaz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase
import FirebaseRemoteConfig

class EventManager {
    static let shared = EventManager()
    
    var remoteConfig: RemoteConfig? = nil
    var ratingLocations = [ReviewPopupLocation](arrayLiteral: ReviewPopupLocation.onBoarding)
    var inAppLocations = [InAppEventLocations](arrayLiteral:
                                                InAppEventLocations.afterOnboarding,
                                               InAppEventLocations.onFastScan,
                                               InAppEventLocations.onFastSimilarDelete,
                                               InAppEventLocations.onPhotoSimilarDelete,
                                               InAppEventLocations.onScreenshotsDelete,
                                               InAppEventLocations.onLiveDelete,
                                               InAppEventLocations.onSelfieDelete,
                                               InAppEventLocations.onDuplicatesDelete,
                                               InAppEventLocations.onVideosSimilarDelete,
                                               InAppEventLocations.onVideosDelete,
                                               InAppEventLocations.onContactsDuplicateName,
                                               InAppEventLocations.onContactsDuplicatePhone,
                                               InAppEventLocations.onContactsDuplicateEmail,
                                               InAppEventLocations.onAdblocker,
                                               InAppEventLocations.onSpeedChecker,
                                               InAppEventLocations.onSettings,
                                               InAppEventLocations.onHome,
                                               InAppEventLocations.onPhotoCompression)
    var inAppMainScreenText1 = "Try 3 days for free".localized
    var inAppMainScreenText2 = "3 days for free, then".localized
    var purchasePlanValue = "1"
    var continueText = "Try Free & Subscribe"
    var ratePopupTitle = "Having Fun?".localized
    var ratePopupMsg = "Are you enjoying the app?".localized
    var popUpHeadingStr = "Worry to be charged?".localized
    var popUpDescStr = "You won't be charged until 3-day free trial has ended, and only if you are still subscribed.".localized
    var subsScreenType = PurchaseScreenType.Eight
    var askSupportLine = false
    var dailyLimit = true
    var fireABTestEnabled = false
    
    func initialze() {
        fetchRemoteConfigs()
        fetchControlFlags()
    }
    
    func fetchRemoteConfigs() {
        let config = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        let configDefaults = ["premium_page" : "8" as NSObject,
                              "daily_limit" : "true" as NSObject,
                              "ask_Support" : "false" as NSObject,
                              "rate_popup_title" : "Having Fun?" as NSObject,
                              "continue_text" : "Try Free & Subscribe" as NSObject,
                              "rate_popup_message" : "Are you enjoying the app?".localized as NSObject,
                              "enable_firebase_ab_testing" : "true".localized as NSObject] as [String : NSObject]
        
        settings.minimumFetchInterval = 0
        
        remoteConfig = config
        remoteConfig?.configSettings = settings
        remoteConfig?.setDefaults(configDefaults)
        
        remoteConfig?.fetchAndActivate(completionHandler: { (status, error) in
            switch status {
            case .successFetchedFromRemote:
                print("sucess fetched from remote")
            case .successUsingPreFetchedData:
                print("sucess using pre-fetched data")
            case .error:
                print("error fetching")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            @unknown default:
                print("")
            }
            
            if let abTesting = self.configValue(key: "enable_firebase_ab_testing") {
                self.fireABTestEnabled = abTesting.boolValue
            }
            if let everythinglocked = self.configValue(key: "daily_limit") {
                self.dailyLimit = everythinglocked.boolValue
            }
            if let askSupport = self.configValue(key: "ask_Support") {
                self.askSupportLine = askSupport.boolValue
            }
            if let title = self.configValue(key: "continue_text"), let titleStr = title.stringValue {
                self.continueText = titleStr
            }
            if let title = self.configValue(key: "rate_popup_title"), let titleStr = title.stringValue {
                self.ratePopupTitle = titleStr
            }
            if let message = self.configValue(key: "rate_popup_message"), let messageStr = message.stringValue {
                self.ratePopupMsg = messageStr
            }
            if let premiumPage = self.configValue(key: "premium_page"), let premiumPageStr = premiumPage.stringValue {
                if premiumPageStr == "1" /*"7_days_trial_then_weekly_subscription"*/ {
                    self.subsScreenType = PurchaseScreenType.One
                } else if premiumPageStr == "2" /*"7_days_trial_then_monthly_subscription"*/ {
                    self.subsScreenType = PurchaseScreenType.Two
                } else if premiumPageStr == "3" /*"7_days_trial_then_annually_or_weekly_without_trial"*/ {
                    self.subsScreenType = PurchaseScreenType.Three
                } else if premiumPageStr == "4" /*"7_days_trial_then_annually_or_7_days_trial_then_monthly"*/ {
                    self.subsScreenType = PurchaseScreenType.Four
                } else if premiumPageStr == "5" /*"7_days_trial_then_weekly_subscription_or_weekly_without_trial"*/ {
                    self.subsScreenType = PurchaseScreenType.Five
                } else if premiumPageStr == "6" /*"yearly_or_monthly_lifetime_subscription"*/ {
                    self.subsScreenType = PurchaseScreenType.Six
                } else if premiumPageStr == "7" {
                    self.subsScreenType = PurchaseScreenType.Seven
                } else if premiumPageStr == "8" {
                    self.subsScreenType = PurchaseScreenType.Eight
                } else if premiumPageStr == "9" {
                    self.subsScreenType = PurchaseScreenType.Nine
                } else if premiumPageStr == "10" {
                    self.subsScreenType = PurchaseScreenType.Ten
                } else if premiumPageStr == "11" {
                    self.subsScreenType = PurchaseScreenType.Eleven
                } else if premiumPageStr == "12" {
                    self.subsScreenType = PurchaseScreenType.Twelve
                } else if premiumPageStr == "13" {
                    self.subsScreenType = PurchaseScreenType.Thirteen
                } else if premiumPageStr == "14" {
                    self.subsScreenType = PurchaseScreenType.Fourteen
                } else if premiumPageStr == "15" {
                    self.subsScreenType = PurchaseScreenType.Fifteen
                } else if premiumPageStr == "16" {
                    self.subsScreenType = PurchaseScreenType.Sixteen
                } else if premiumPageStr == "Friday991" {
                    self.subsScreenType = PurchaseScreenType.FridayOne
                } else if premiumPageStr == "Friday992" {
                    self.subsScreenType = PurchaseScreenType.FridayTwo
                } else if premiumPageStr == "Friday993" {
                    self.subsScreenType = PurchaseScreenType.FridayThree
                } else if premiumPageStr == "Charistmas994" {
                    self.subsScreenType = PurchaseScreenType.CharistmasOne
                } else if premiumPageStr == "Charistmas995" {
                    self.subsScreenType = PurchaseScreenType.CharistmasTwo
                } else if premiumPageStr == "Charistmas996" {
                    self.subsScreenType = PurchaseScreenType.CharistmasThree
                } else if premiumPageStr == "Friday997" {
                    self.subsScreenType = PurchaseScreenType.FridayFour
                } else if premiumPageStr == "Charistmas998" {
                    self.subsScreenType = PurchaseScreenType.CharistmasFour
                } else if premiumPageStr == "Halloween991" {
                    self.subsScreenType = PurchaseScreenType.Halloween1
                } else if premiumPageStr == "Halloween992" {
                    self.subsScreenType = PurchaseScreenType.Halloween2
                }
            }
        })
    }
    
    func fetchControlFlags() {
        let ref = Database.database().reference()
        
        ref.child("Flags").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: AnyObject] else {
                self.createRatingPopUpLocationFlag()
                self.createInAppEventFlags()
                self.createIAPText1()
                self.createIAPText2()
                self.createPurchasePlan()
                self.createPopupHeaderText()
                self.createPopupDescText()
                self.createSubscriptionCountsFlag()
                
                return
            }
            
            if let ratingStr = value["ratingPopUpLocation"] as? String {
                self.appendIAPRatings(ratingStr: ratingStr)
            } else {
                self.createRatingPopUpLocationFlag()
            }
            
            if let subEvents = value["inAppEvents"] as? String {
                self.appendIAPLocations(subEvents: subEvents)
            } else {
                self.createInAppEventFlags()
            }
            
            if let text1 = value["inAppMainScreenText1"] as? String {
                self.inAppMainScreenText1 = text1
            } else {
                self.createIAPText1()
            }
            
            if let text2 = value["inAppMainScreenText2"] as? String {
                self.inAppMainScreenText2 = text2
            } else {
                self.createIAPText2()
            }
            
            if let plan = value["purchasePlan"] as? String {
                self.purchasePlanValue = plan
            } else {
                self.createPurchasePlan()
            }
            
            if let heading = value["popupHeadingString"] as? String {
                self.popUpHeadingStr = heading
            } else {
                self.createPopupHeaderText()
            }
            
            if let description = value["popupDescriptionString"] as? String {
                self.popUpDescStr = description
            } else {
                self.createPopupDescText()
            }
            
            if let _ = value["SubscriptionCounts"] as? [String: String] {
                //print("SubscriptionCounts = ", counts)
            } else {
                self.createSubscriptionCountsFlag()
            }
        }
    }
    
    func appendIAPRatings(ratingStr: String) {
        let locations = ratingStr.components(separatedBy: [","])
        
        if locations.count > 0 {
            self.ratingLocations.removeAll()    //Clearing Default entries
        }
        for loc in locations {
            if var rating = Int(loc) {
                if rating < 1 || rating > 5 {
                    rating = 0
                }
                
                let location = ReviewPopupLocation(rawValue: rating) ?? ReviewPopupLocation.onBoarding
                self.ratingLocations.append(location)
                //print("Rating popUP App Locations Found\(self.ratingLocations)")
            }
        }
    }
    
    func appendIAPLocations(subEvents: String) {
        let inAppLocations = subEvents.components(separatedBy: [","])
        
        if inAppLocations.count > 0 {
            self.inAppLocations.removeAll()    //Clearing Default entries
        }
        
        for loc in inAppLocations {
            if var rating = Int(loc) {
                if rating < 1 || rating > 13 {
                    rating = 0
                }
                
                let location = InAppEventLocations(rawValue: rating) ?? InAppEventLocations.afterOnboarding
                self.inAppLocations.append(location)
                //print("In App Locations Found\(self.inAppLocations)")
            }
        }
    }
    
    //MARK:- Create Rating Flags
    func createRatingPopUpLocationFlag() {
        let ref = Database.database().reference()
        ref.child("Flags")
            .child("ratingPopUpLocation")
            .setValue("1") { (error, ref) in
                if let error = error {
                    print("Error while updating IsUpload Bool",error.localizedDescription)
                }
            }
    }
    
    //MARK:- Create Subscription Flags
    func createInAppEventFlags() {
        let ref = Database.database().reference()
        ref.child("Flags")
            .child("inAppEvents")
            .setValue("1") { (error, ref) in
                if let error = error {
                    print("Error while updating IsUpload Bool", error.localizedDescription)
                }
            }        
    }
    
    
    func createIAPText1() {
        let ref = Database.database().reference()
        ref.child("Flags")
            .child("inAppMainScreenText1")
            .setValue("Try 3 days for free".localized) { (error, ref) in
                if let error = error {
                    print("Error while updating InApp Text", error.localizedDescription)
                }
            }
    }
    
    func createIAPText2() {
        let ref = Database.database().reference()
        ref.child("Flags")
            .child("inAppMainScreenText2")
            .setValue("3 days for free, then") { (error, ref) in
                if let error = error {
                    print("Error while updating InApp Text", error.localizedDescription)
                }
            }
    }
    
    func createPurchasePlan(){
        let ref = Database.database().reference()
        ref.child("Flags")
            .child("purchasePlan")
            .setValue("1") { (error, ref) in
                if let error = error {
                    print("Error while updating InApp Text", error.localizedDescription)
                }
                
            }
    }
    
    func createPopupHeaderText(){
        let ref = Database.database().reference()
        ref.child("Flags")
            .child("popupHeadingString")
            .setValue("Worry to be charged?") { (error, ref) in
                if let error = error {
                    print("Error while updating InApp Text", error.localizedDescription)
                }
            }
    }
    
    func createPopupDescText() {
        let ref = Database.database().reference()
        ref.child("Flags")
            .child("popupDescriptionString")
            .setValue("You won't be charged untll 7 day free trial has ended, and only if you are still subscribed."){ (error, ref) in
                if let error = error {
                    print("Error while updating InApp Text", error.localizedDescription)
                }
                
            }
    }
    
    //MARK:- Create Subscription Counter Flags
    func createSubscriptionCountsFlag() {
        let ref = Database.database().reference()
        let values = ["afterOnboarding": "0", "onFastScan": "0", "onFastSimilarDelete": "0", "onPhotoSimilarDelete": "0",
                      "onScreenshotsDelete": "0", "onLiveDelete": "0", "onSelfieDelete": "0", "onDuplicatesDelete": "0",
                      "onVideosSimilarDelete": "0", "onVideosDelete": "0", "onContactsDuplicateName": "0", "onContactsDuplicatePhone": "0",
                      "onContactsDuplicateEmail": "0", "onAdblocker": "0", "onSettings": "0", "onSpeedCheker": "0", "onHome": "0"]
        ref.child("Flags")
            .child("SubscriptionCounts")
            .updateChildValues(values, withCompletionBlock: { (error, reference) in
                if let error = error {
                    print("Error while creating subscription counts", error.localizedDescription)
                }
            })
    }
    
    func incrementSubscribeCountAt(location loc: InAppEventLocations) {
        if let param = Utilities.convertIntoDatabaseParam(iapLocation: loc) {
            let ref = Database.database().reference()
            
            ref.child("Flags").child("SubscriptionCounts").observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                if let countString = value[param] as? String, let intValue = Int(countString) {
                    let newValue = intValue + 1
                    
                    ref.child("Flags")
                        .child("SubscriptionCounts")
                        .child(param)
                        .setValue("\(newValue)")
                }
            }
        }
    }
    
    func configValue(key: String) -> RemoteConfigValue? {
        if let config = self.remoteConfig {
            return config.configValue(forKey: key)
        }
        
        return nil
    }
}
