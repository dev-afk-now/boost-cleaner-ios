//
//  UIAlertControllerExtension.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 08/09/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {

    /// This class method extened under UIAlertController which helps you to show UIAlertContol
    ///
    /// - Parameters:
    ///   - title: title for alert
    ///   - message: message for alert
    ///   - style: UIAlertContoller style (actionSheet / alert)
    ///   - buttons: number of button titles needs to add
    ///   - controller: contoller where UIAlertControl to be shown
    ///   - userAction: block which returns user intrected button title (string) to perform any action
    class func showVDAlertWith(title: String?, message: String?, style: UIAlertController.Style, buttons: [String], controller: UIViewController?, userAction: ((_ action: String) -> ())?) {
        let alertController =
            UIAlertController(title: title, message: message, preferredStyle: style)
        buttons.forEach
            { (buttonTitle) in
                if buttonTitle == "Delete" {
                    alertController.addAction(UIAlertAction(title: buttonTitle, style: .destructive, handler: { (action: UIAlertAction) in
                        userAction? (buttonTitle)
                    }))
                } else if buttonTitle == "Cancel" {
                    alertController.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: { (action: UIAlertAction) in
                        userAction? (buttonTitle)
                    }))
                } else if buttonTitle == "Remove member" {
                    alertController.addAction(UIAlertAction(title: buttonTitle, style: .destructive, handler: { (action: UIAlertAction) in
                        userAction? (buttonTitle)
                    }))
                } else if buttonTitle == "Remove Admin" {
                    alertController.addAction(UIAlertAction(title: buttonTitle, style: .destructive, handler: { (action: UIAlertAction) in
                        userAction? (buttonTitle)
                    }))
                } else if buttonTitle == "Remove Member from Studio Team" {
                    alertController.addAction(UIAlertAction(title: buttonTitle, style: .destructive, handler: { (action: UIAlertAction) in
                        userAction? (buttonTitle)
                    }))
                } else if buttonTitle == "Remove Member" {
                    alertController.addAction(UIAlertAction(title: buttonTitle, style: .destructive, handler: { (action: UIAlertAction) in
                        userAction? (buttonTitle)
                    }))
                } else {
                    alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action: UIAlertAction) in
                        userAction? (buttonTitle)
                    }))
                }
        }
        if let parentController = controller { DispatchQueue.main.async {
            parentController.present(alertController, animated: true, completion: nil)
            }
        }
    }

    
}

