//
//  AlertView.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/30/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import Foundation
import UIKit


class AlertView {
    
    class func prepare(title: String, message: String, okAction: (() -> ())?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black]
         let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.black]
         let messageString = NSAttributedString(string: message, attributes: messageAttributes)
        alertController.setValue(titleString, forKey: "attributedTitle")
        alertController.setValue(messageString, forKey: "attributedMessage")
        let OKAction = UIAlertAction(title: "Ok".localized, style: .default) { action in
            okAction?()
        }
        
        alertController.addAction(OKAction)
        
        return alertController
    }
    
    class func prepare(title: String, action1 title1: String, action2 title2: String?, message: String, actionOne: (() -> ())?, actionTwo: (() -> ())?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black]
         let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.black]
         let messageString = NSAttributedString(string: message, attributes: messageAttributes)
        alertController.setValue(titleString, forKey: "attributedTitle")
        alertController.setValue(messageString, forKey: "attributedMessage")
        
        let actionOne = UIAlertAction(title: title1, style: .default) { action in
            actionOne?()
        }
        
        alertController.addAction(actionOne)
        
        if let _ = title2 {
            let actionTwo = UIAlertAction(title: title2, style: .cancel) { action in
                actionTwo?()
            }
            
            alertController.addAction(actionTwo)
        }
        
        return alertController
    }
}
