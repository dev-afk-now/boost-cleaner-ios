//
//  HomeVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/23/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import CircleProgressView
import SystemServices
import SwiftyContacts
import Foundation
import Contacts
import CoreTelephony
import StoreKit
import Photos
import UserNotifications
import FirebaseCrashlytics
import AppTrackingTransparency
import FBSDKCoreKit

let notificationCenter = NotificationCenter.default

class HomeVC: UIViewController {
    
    @IBOutlet weak var lblHeadertitle: UILabel!
    @IBOutlet weak var lblFreeTitle: UILabel!
    @IBOutlet weak var lblMergeTitle: UILabel!
    @IBOutlet weak var lblFindTitle: UILabel!
    @IBOutlet weak var lblPrTitle: UILabel!
    @IBOutlet weak var lblCompresstitle: UILabel!
    
    @IBOutlet var permissionView: UIView!
    @IBOutlet weak var lblSpeedtab: UILabel!
    @IBOutlet weak var lblAdBlockTab: UILabel!
    @IBOutlet weak var lblCleanerTab: UILabel!
    @IBOutlet weak var lblBatteryTab: UILabel!
    
    @IBOutlet weak var lblCompressor: UILabel!
    
    @IBOutlet weak var btnFastCleaner: UIButton!
    @IBOutlet weak var lblstorageTitle: UILabel!
    @IBOutlet weak var lblContactTitle: UILabel!
    @IBOutlet weak var lblVideotitle: UILabel!
    @IBOutlet weak var lblPhotoTitle: UILabel!
    
    @IBOutlet weak var circleProgressView: CircleProgressView!
    @IBOutlet weak var proButton: UIButton!
    @IBOutlet weak var storageLabel: UILabel!
    @IBOutlet weak var allContactLabel: UILabel!
    @IBOutlet weak var allVideoLabel: UILabel!
    @IBOutlet weak var allImagesLabel: UILabel!
    @IBOutlet var totalstorageLabel: UILabel!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var openVaultIMV: UIImageView!
    @IBOutlet weak var permissionAlertBG: UIImageView!
    @IBOutlet weak var topConstraintsSettings: NSLayoutConstraint!
    @IBOutlet weak var topConstraintsPro: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintForNotesStackView: NSLayoutConstraint!
    @IBOutlet weak var topConstraintForLogo: NSLayoutConstraint!
    @IBOutlet weak var topConstraintForLogoText: NSLayoutConstraint!
    @IBOutlet var imgvSpeakerBack: UIImageView!
    
    @IBOutlet weak var imgWidgets: UIImageView!
    var timerflg = true
    var timerflgvideo = true
    let user = SharedData.sharedUserInfo
    
    var imagesAssetSize = 0.0
    var videosAssetSize = 0.0
    var allContactArray: [CNContact] = []
    var videos: PHFetchResult<PHAsset>?
    var images: PHFetchResult<PHAsset>?
    var total : Double = 0.0
    var free : Double = 0.0
    var initialising = true
    
    private func getLocalization(){
        lblCompressor.text = "COMPRESS".localized
        lblBatteryTab.text = lblBatteryTab.text?.capitalized.localized.uppercased()
        lblSpeedtab.text = lblSpeedtab.text?.localized
        lblAdBlockTab.text = lblAdBlockTab.text?.localized
        lblCleanerTab.text = lblCleanerTab.text?.localized
        
        lblPhotoTitle.text = lblPhotoTitle.text?.localized
        lblVideotitle.text = lblVideotitle.text?.localized
        lblstorageTitle.text = lblstorageTitle.text?.localized
        lblContactTitle.text = lblContactTitle.text?.localized
        btnFastCleaner.setTitle(btnFastCleaner.currentTitle?.localized, for: .normal)
        proButton.setTitle(proButton.currentTitle?.localized, for: .normal)
        lblHeadertitle.text = lblHeadertitle.text?.localized
        lblPrTitle.text = lblPrTitle.text?.localized
        lblFindTitle.text = lblFindTitle.text?.localized
        lblFreeTitle.text = lblFreeTitle.text?.localized
        lblMergeTitle.text = lblMergeTitle.text?.localized
        lblCompresstitle.text = lblCompresstitle.text?.localized
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgvSpeakerBack.layer.cornerRadius = imgvSpeakerBack.frame.height / 2
        
        if (UserDefaults.standard.string(forKey: "saveDate") == nil) {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            UserDefaults.standard.set(result, forKey: "saveDate")
            UserDefaults.standard.set(5, forKey: "Count")
        }
        
        let appCurrentLang = UserDefaults.standard.string(forKey: "i18n_language")
        if (appCurrentLang == "zh-Hans") {
            openVaultIMV.image = UIImage(named: "open_vault_zh")
        }
        
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd.MM.yyyy"
        
        let currentDate = formatter.string(from: date)
        
        switch currentDate.compare(UserDefaults.standard.string(forKey: "saveDate")!) {
        case .orderedSame:
            
            break // exact same
        case .orderedAscending:
            
            break // date2 comes after date1 in calendar
        case .orderedDescending:
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            UserDefaults.standard.set(result, forKey: "saveDate")
            UserDefaults.standard.set(5, forKey: "Count")
            break // date2 comes before date1 in calendar
        }
     
        self.circleProgressView.progress = Double(0/Double(100))
        //  self.loadDeviceInfo()
        self.totalStorageInfo()
        
        photoView.dropShadow2()
        videoView.dropShadow2()
        contactView.dropShadow2()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainView.frame.size.height = 1250//1880
            self.circleProgressView.trackWidth = 12
        } else {
            mainView.frame.size.height = 680//925
        }
        if UIScreen.main.bounds.height < 668 {
            topConstraintsSettings.constant = 25
            topConstraintsPro.constant = 25
            bottomConstraintForNotesStackView.constant = 0
            topConstraintForLogo.constant = 25
            topConstraintForLogoText.constant = -5
            //permissionAlertBG.image = UIImage(named: "permission_alert_bg_for_iphone7.png")
        }
        
        if #available(iOS 14, *) {
            self.permissionAlertBG.alpha = 1.0
            
            ATTrackingManager.requestTrackingAuthorization { (status) in
                Settings.shared.isAdvertiserTrackingEnabled = (status == .authorized)
                Settings.shared.isAdvertiserIDCollectionEnabled = (status == .authorized)
                
                DispatchQueue.main.async {
                    self.permissionAlertBG.alpha = 0.0
                    self.checkForPersmissions()
                }
            }
        } else {
            checkForPersmissions()
        }
        
//        notificationCenter.addObserver(self, selector: #selector(self.backgroundthread), name: Notification.Name("dataUpdated"), object: nil)
        getLocalization()
        
        permissionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        permissionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        permissionView.dropShadow3()

        if #available(iOS 14.0, *) {
            self.imgWidgets.alpha = 1
        } else {
            self.imgWidgets.alpha = 0
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeVC.tapOnWidgets(_:)))

        self.imgWidgets.isUserInteractionEnabled = true
        self.imgWidgets.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if PaymentManager.shared.isPurchase() == true {
            proButton.isHidden = true
            proButton.alpha = 0.0
        } else {
            proButton.isHidden = false
            proButton.alpha = 1.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialising == false {
            self.FetchAllNumber()
        }
    }

    @objc func tapOnWidgets(_ sender:AnyObject){

//        let vc = UIStoryboard.init(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "WidgetVC") as! WidgetVC
//        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func checkForPersmissions() {
        if UserDefaults.standard.bool(forKey: "isFirstTime") == true {
            UserDefaults.standard.set(false, forKey: "isFirstTime")
            view.addSubview(permissionView)
        } else {
            permissionView.removeFromSuperview()
            self.permissionAlertBG.isHidden = true
        }
        
        PHPhotoLibrary.requestAuthorization({ (newStatus) in
            CNContactStore().requestAccess(for: .contacts, completionHandler: { granted, error in
                self.performSelector(inBackground: #selector(self.backgroundthread), with: nil)
                
                DispatchQueue.main.async {
                    self.FetchAllNumber()
                    self.initialising = false
                    
                    UIView.transition(with: self.permissionAlertBG, duration: 0.5, options: .transitionCrossDissolve) {
                        self.permissionAlertBG.alpha = 0.0
                        self.permissionView.removeFromSuperview()
                    } completion: { status in
                        self.permissionView.removeFromSuperview()
                        self.permissionAlertBG.isHidden = true
                    }
                }
                
                self.askForNotficationPermission()
            })
        })
        
    }
    
    func askForNotficationPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        let contactStatus = CNContactStore.authorizationStatus(for: .contacts)
        if (status == PHAuthorizationStatus.authorized) && (contactStatus == .authorized) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
                let isNotificationOff = UserDefaults.standard.bool(forKey: "ofNotification")
                
                if accepted && isNotificationOff == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0, execute: {
                        if let delegate = UIApplication.shared.delegate as? AppDelegate {
                            let newDate = Date(timeInterval: 86400, since: Date())
                            Utilities.scheduleNotification(at: newDate, delegate: delegate)
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
    }
    
    @objc func backgroundthread() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)
        images = imagesAndVideos
        DispatchQueue.main.async {
            self.allImagesLabel.text = "\(imagesAndVideos.count)" + "items".localized + " • " +  String(format: "%.2f", self.imagesAssetSize / 1024) + " GB".localized
        }
        
        self.FetchAllVideo()
        self.getPhotos()
    }
    
    func navigateToSettingForFaceID() {
        let storyBoard = UIStoryboard.init(name: "Settings", bundle: nil)
        let settingsVC = storyBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        settingsVC.shouldAutoPerformAuthSwitch = true
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func openVaultPressed(_ sender: UIButton) {
        if UserDefaults.standard._BioAuthEnabled {
            if let topVC = UIApplication.getTopViewController() {
                BiometricAuthVC.presentVC(from: topVC)
            } else {
                BiometricAuthVC.presentVC(from: self)
            }

            NotificationCenter.default.addObserver(self, selector: #selector(showPrivateVault(notification:)),
                                                   name: NSNotification.Name.init("Get_Authenticated_For_Vault"), object: nil)
        } else if !UserDefaults.standard._BioAuthFirstTimeAlertPrompt {
            let bioAuth = BiometricIDAuth()
            let authType = bioAuth.biometricType.typeAsString
            let title = authType
            let txt = "Would you like to secure Boost Cleaner with".localized
            let msg = "\(txt) \(authType)?"
            let btnSecureNow = "Secure Now".localized
            let btnCancel = "Cancel".localized
            
            UIAlertController.showVDAlertWith(title: title, message: msg, style: .alert, buttons: [btnSecureNow, btnCancel], controller: self) { action in
                UserDefaults.standard._BioAuthFirstTimeAlertPrompt = true
                
                if action == btnSecureNow {
                    self.navigateToSettingForFaceID()
                } else if action == btnCancel {
                    let vc = UIStoryboard.init(name: "Vault", bundle: Bundle.main).instantiateInitialViewController()
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        } else {
            let vc = UIStoryboard.init(name: "Vault", bundle: Bundle.main).instantiateInitialViewController()
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @objc func showPrivateVault(notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("Get_Authenticated_For_Vault"), object: nil)

        let vc = UIStoryboard.init(name: "Vault", bundle: Bundle.main).instantiateInitialViewController()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func fastButtonPressed(_ sender: UIButton) {
        sender.isHighlighted = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FastVC") as? FastVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func speedButtonPressed(_ sender: UIButton) {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        let vc = UIStoryboard.init(name: "SpeedChecker", bundle: Bundle.main).instantiateViewController(withIdentifier: "SpeedVC") as? SpeedVC
//        self.navigationController?.pushViewController(vc!, animated: false)
    }
    @IBAction func adblockerButtonPressed(_ sender: UIButton) {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdBlockVC") as? AdBlockVC
//        self.navigationController?.pushViewController(vc!, animated: false)
    }
    
    @IBAction func contactButtonPressed(_ sender: UIButton) {
        sender.isHighlighted = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContactsVC") as? ContactsVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        sender.isHighlighted = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VideoVC") as? VideoVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        sender.isHighlighted = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PhotoVC") as? PhotoVC
        vc?.arrAllImage = images
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func settingsBtnPressed(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Settings", bundle: nil)
        let HomeVCController = storyBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(HomeVCController, animated: true)
    }
    
    @IBAction func ejectorBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func batteryBtnPressed(_ sender: Any) {
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        StartBatteryAnimationVC.pushVC(from: self, animated: false)
    }
    
    @IBAction func onClickPremium(_ sender: Any) {
        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: true, iapEvent: InAppEventLocations.onHome)
//                UserDefaults.standard.set("zh-Hans", forKey: "i18n_language")
//        let langCode = "en"
//        UserDefaults.standard.set(langCode, forKey: "i18n_language")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//
//            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
//            let vc = storyBoard.instantiateViewController(withIdentifier: "HomeVC")
//            if #available(iOS 13.0, *) {
//                let rootviewcontroller: UIWindow = self.sceneDelegate.window ?? UIWindow()
//                rootviewcontroller.rootViewController = vc
//
//            } else {
//                let rootviewcontroller: UIWindow = self.appDelegate.window ?? UIWindow()
//                rootviewcontroller.rootViewController = vc
//
//            }
//        }
    }
    
    func totalStorageInfo() {
//        print("totalDiskSpaceInBytes: \(UIDevice.current.totalDiskSpaceInGB)")
//        print("freeDiskSpace: \(UIDevice.current.totalDiskSpaceInMB)")
//        print("usedDiskSpace: \(UIDevice.current.freeDiskSpaceInGB)")
        let totaldata = String(UIDevice.current.totalDiskSpaceInGB.dropLast(3))
        let str2 = totaldata.replacingOccurrences(of: ",", with: ".", options:  NSString.CompareOptions.literal, range: nil)
        let str3 = str2.replacingOccurrences(of: " ", with: "", options:  NSString.CompareOptions.literal, range: nil)
        
        total = Double(str3) ?? 0.0
        
        let freedata = String(UIDevice.current.freeDiskSpaceInGB.dropLast(3))
        let strfree = freedata.replacingOccurrences(of: ",", with: ".", options:  NSString.CompareOptions.literal, range: nil)
        let strfree2 = strfree.replacingOccurrences(of: " ", with: "", options:  NSString.CompareOptions.literal, range: nil)
        
        free = Double(strfree2) ?? 0.0
        
        let freespace = free
        let a = abs(total - free)
        let b = abs(total)
        
        //let finaltotal =   String(format: "%.0f", b)
        //let totalInt = Double(finaltotal) ?? 0.0
        var result  = Int( (a/b)*100 )
        // usageLabel.text = String(format: "%.0f", result)
        //let freetotal =   String(format: "%.1f", a )
        //let total =   String(format: "%.0f", b )
        let ftotal =   String(format: "%.02f  ", freespace )

        if result > 100 {
            result = 100
        }
        
        self.storageLabel.text = "\(result)" + "%"
        self.totalstorageLabel.text = ftotal + "GB".localized
        self.circleProgressView.progress = Double(((a/b)*100 )/Double(100))
    }
    
    private func getPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)
        images = imagesAndVideos
        for i in 0..<images!.count {
            let asset = images!.object(at: i)
            let resources = PHAssetResource.assetResources(for: asset) // your PHAsset
            var sizeOnDisk: Int64? = 0
            if let resource = resources.first {
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
                let fullNameArr = converByteToHumanReadable(sizeOnDisk!).components(separatedBy: " ")
                let name    = fullNameArr[0]
                let mb    = fullNameArr[1]
                if(mb == "MB".localized){
                    let sizevideo = Double(name) ?? 0.0
                    imagesAssetSize = imagesAssetSize + sizevideo
                }
                if(mb == "KB".localized){
                    let sizevideo = Double(name) ?? 0.0
                    let fileSize = Double(sizevideo / 1024)
                    imagesAssetSize = imagesAssetSize + fileSize
                }
            }
            DispatchQueue.main.async { [self] in
                
                if(timerflgvideo){
                    timerflgvideo = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                        self.allImagesLabel.text = "\(imagesAndVideos.count) " + "items".localized + " • " +  String(format: "%.2f ", self.imagesAssetSize / 1024) + "GB".localized
                        timerflgvideo = true
                    })
                }
                
                
            }
        }
        
        DispatchQueue.main.async {
            self.allImagesLabel.text = "\(imagesAndVideos.count) " + "items".localized + " • " +  String(format: "%.2f", self.imagesAssetSize / 1024) + " GB".localized
        }
        
        
        
    }
    func FetchAllVideo(){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)
        
        videos = imagesAndVideos
        DispatchQueue.main.async {
            self.allVideoLabel.text = "\(imagesAndVideos.count) " + "items".localized + " • " +  String(format: "%.2f", self.videosAssetSize / 1024) + " GB".localized
        }
        
        for i in 0..<videos!.count {
            let asset = videos!.object(at: i)
            let resources = PHAssetResource.assetResources(for: asset) // your PHAsset
            var sizeOnDisk: Int64? = 0
            if let resource = resources.first {
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
                let fullNameArr = converByteToHumanReadable(sizeOnDisk!).components(separatedBy: " ")
                let name    = fullNameArr[0]
                let mb    = fullNameArr[1]
                if(mb == "MB"){
                    let sizevideo = Double(name) ?? 0.0
                    videosAssetSize = videosAssetSize + sizevideo
                }
                if(mb == "KB"){
                    let sizevideo = Double(name) ?? 0.0
                    // print(sizevideo)
                    let fileSize = Double(sizevideo / 1024)
                    videosAssetSize = videosAssetSize + fileSize
                }
                else if(mb == "GB"){
                    let sizevideo = Double(name) ?? 0.0
                    let fileSize = Double(sizevideo * 1024)
                    videosAssetSize = videosAssetSize + fileSize
                }
            }
            DispatchQueue.main.async { [self] in
                
                if(timerflg){
                    timerflg = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                        self.allVideoLabel.text = "\(imagesAndVideos.count) " + "items".localized + " • " +  String(format: "%.2f ", self.videosAssetSize / 1024) + "GB".localized
                        timerflg = true
                    })
                }
            }
        }
        
        DispatchQueue.main.async {
            self.allVideoLabel.text = "\(imagesAndVideos.count) " + "items".localized + " • " +  String(format: "%.2f ", self.videosAssetSize / 1024) + "GB".localized
        }
        
    }
    
    func FetchAllNumber(){
        fetchContacts({ (result) in
            switch result{
            case .success(response: let contacts):
                self.allContactArray = contacts
                self.allContactLabel.text = "\(contacts.count) " + "items".localized
                break
            case .failure(error: let error):
                print(error)
                break
            }
        })
        
    }
    func converByteToHumanReadable(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
}
extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    @available(iOS 13.0, *)
    var sceneDelegate: SceneDelegate{
        return UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    }
    
    /**
     returns true only if the viewcontroller is presented.
     */
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            if let parent = parent, !(parent is UINavigationController || parent is UITabBarController) {
                return false
            }
            return true
        } else if let navController = navigationController, navController.presentingViewController?.presentedViewController == navController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
    
}
