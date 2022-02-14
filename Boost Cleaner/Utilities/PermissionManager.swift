//
//  PermissionManager.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 21/09/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import UIKit
import Photos
import Contacts

enum Permission {
    case contactUsage
    case photoLibraryUsage
}

class PermissionManager {
    
    private init(){}
    public static let shared = PermissionManager()
    
    let PHOTO_LIBRARY_PERMISSION: String = "Require access to Photo library to proceed. Would you like to open settings and grant permission to photo library?"
    let PHOTO_LIBRARY_PERMISSION_LIMITED: String = "Require access to All Photos from Photo library to proceed. Would you like to open settings and grant permission to photo library?"
    let UNKNOWN_ERROR_OCCURED_FOR_PHOTO_LIBRARY: String = "Some unknown error occured, Please check your permission settings"
    let CONTACT_USAGE_ALERT: String = "Require access to Contact to proceed. Would you like to open Settings and grant permission to Contact?"
    let UNKNOWN_ERROR_OCCURED_FOR_CONTACTS: String = "Some unknown error occured, Please check your permission settings"
    
    
    func requestAccess(vc: UIViewController,
                       _ permission: Permission,
                       completionHandler: @escaping (_ accessGranted: Bool) -> Void){
        
        switch permission {
        
        case .contactUsage:
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized:
                completionHandler(true)
            case .denied:
                showSettingsAlert(controller: vc, msg: CONTACT_USAGE_ALERT, completionHandler)
            case .restricted, .notDetermined:
                CNContactStore.init().requestAccess(for: .contacts) { granted, error in
                    if granted {
                        completionHandler(true)
                    } else {
                        DispatchQueue.main.async {
                            self.showSettingsAlert(controller: vc, msg: self.CONTACT_USAGE_ALERT, completionHandler)
                        }
                    }
                }
            @unknown default:
                DispatchQueue.main.async {
                    let title = "Ok".localized
                    UIAlertController.showVDAlertWith(title: nil, message: self.UNKNOWN_ERROR_OCCURED_FOR_CONTACTS, style: .alert, buttons: [title], controller: vc, userAction: nil)
                }
            }
            break
            
            
        case .photoLibraryUsage:
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                completionHandler(true)
            case .denied:
                showSettingsAlert(controller: vc, msg: PHOTO_LIBRARY_PERMISSION, completionHandler)
            case .restricted, .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized{
                        completionHandler(true)
                    }else{
                        DispatchQueue.main.async {
                            self.showSettingsAlert(controller: vc, msg: self.PHOTO_LIBRARY_PERMISSION, completionHandler)
                        }
                    }
                }
            case .limited:
                DispatchQueue.main.async {
                    self.showSettingsAlert(controller: vc, msg: self.PHOTO_LIBRARY_PERMISSION_LIMITED, completionHandler)
                }
                //PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            @unknown default:
                DispatchQueue.main.async {
                    let title = "Ok"
                    UIAlertController.showVDAlertWith(title: nil, message: self.UNKNOWN_ERROR_OCCURED_FOR_PHOTO_LIBRARY, style: .alert, buttons: [title], controller: vc, userAction: nil)
                }
            }
            break
        }
    }
    
    
    
    private func showSettingsAlert(controller: UIViewController ,
                                   msg: String,
                                   _ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            completionHandler(false)
            
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl)
                    } else {
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })
        controller.present(alert, animated: true)
    }
}

