//
//  PaymentManager.swift
//  MasterCleaner
//
//  Created by Nhuom Tang on 7/15/19.
//  Copyright © 2019 Nhuom Tang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAnalytics
import SwiftyStoreKit

class PaymentManager: NSObject {
    
    var isVerifyError = true
    static let shared = PaymentManager()

    func isPurchaseAdFree() -> Bool {
        return true
    }

    func isPurchase() -> Bool {
        return true
        
        /*if let time = UserDefaults.standard.value(forKey: "purchaseTime") as? TimeInterval {
            let timeInterval = Date().timeIntervalSince1970
            
            print("Qubee: Current time = ", timeInterval)
            print("Qubee: Expiry time = ", time)
            print("Qubee: difference = ", timeInterval - time)
        }*/
        
        let hasActiveSubscription = UserDefaults.standard.bool(forKey: "hasActiveSubscription")
        /*
         * In Most cases, this will decide users subscriptions
         * Since in the very beginning, we were using SwiftKit
         * So just keeping the Block after this check in case we are missing any scenario
         * I Dont think we should remove that block of code
         */
        if hasActiveSubscription {
            return true
        }
        
        if let time = UserDefaults.standard.value(forKey: "purchaseTime") as? TimeInterval {
            let timeInterval = Date().timeIntervalSince1970
            if timeInterval > time {
                let wasValidSubscriber = UserDefaults.standard.bool(forKey: "isValidSubscriberNow")
                
                if wasValidSubscriber {
                    UserDefaults.standard.set(false, forKey: "isValidSubscriberNow")
                    Analytics.logEvent("subscription_cancel", parameters: ["user_id": Utilities.getUDID()])
                }
                
                return false
            }
            
            return true
        }
        
        return false
    }
    
    func savePurchase(active: Bool, time: TimeInterval, isFromRestore: Bool, itemID: String){
        UserDefaults.standard.setValue(time, forKey: "purchaseTime")
        UserDefaults.standard.set(active, forKey: "hasActiveSubscription")
        
        if isPurchase() {
            // Saving user purchase to later reporting firebase event for cancellation
            UserDefaults.standard.set(true, forKey: "isValidSubscriberNow")
            
            if (isFromRestore == false) {
                Analytics.logEvent("subscription_purchase", parameters: ["user_id": Utilities.getUDID(), "item_id": itemID])
            }
        }
    }
        
    func verifyPurchase(completion: ((Bool) -> Void)? = nil) {
        var appleValidator = AppleReceiptValidator(service: .production, sharedSecret: PRODUCT_SHARED_SECRET)
        if iS_TEST{
            appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: PRODUCT_SHARED_SECRET)
        }
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { [weak self] result in
            switch result {
            case .success(let receipt):
                self?.isVerifyError = false
                let productIds = Set.init(PRODUCT_IDS)
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, _):
                    let timeInterval = expiryDate.timeIntervalSince1970
                    PaymentManager.shared.savePurchase(active: true, time: timeInterval, isFromRestore: false, itemID: "")
                    completion?(true)
                    
                    break
                case .expired(let expiryDate, _):
                    /*if let vc = UIApplication.shared.keyWindow?.rootViewController{
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
                        let str = dateFormatterPrint.string(from: expiryDate)
                        vc.showError(message: "Your purchase is expired since " + str)
                        let timeInterval = expiryDate.timeIntervalSince1970
                        PaymentManager.shared.savePurchase(time: timeInterval)
                    }*/
                    
                    let timeInterval = expiryDate.timeIntervalSince1970
                    PaymentManager.shared.savePurchase(active: false, time: timeInterval, isFromRestore: false, itemID: "")
                    completion?(false)
                    
                    break
                case .notPurchased:
                    print("not purchased")
                    completion?(false)
                }
                
                break
            case .error(let error):
                print(error.localizedDescription)
                
                completion?(false)
                self?.isVerifyError = true
                
                break
            }
        }
    }
}

