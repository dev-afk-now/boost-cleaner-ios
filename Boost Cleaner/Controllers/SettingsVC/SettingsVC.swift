//
//  SettingsVC.swift
//  Boost Cleaner
//
//  Created by HABIB on 14/10/2020.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Toast_Swift
import Contacts
import Photos
import StoreKit
import SafariServices
import EzPopup

class SettingsVC: BaseViewController {
        
    @IBOutlet weak var lblCleanerTitle: UILabel!
    @IBOutlet weak var lblPhototitle: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var lblTermsTitle: UILabel!
    @IBOutlet weak var lblAboutApp: UILabel!
    @IBOutlet weak var lblShareWithFriend: UILabel!
    @IBOutlet weak var lblFaceIdTitle: UILabel!
    @IBOutlet weak var lblNotificationtitle: UILabel!
    @IBOutlet weak var lblSettingstitle: UILabel!
    @IBOutlet weak var activatePreButton: UIButton!    
    
    @IBOutlet var topView: UIView!
    @IBOutlet weak var imgSettings: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let content = UNMutableNotificationContent()
    
    var isAllowedPhotos: Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        return status == .authorized
    }
    
    var isAllowedContacts: Bool {
        let contactStatus = CNContactStore.authorizationStatus(for: .contacts)
        return contactStatus == .authorized
    }
    
    var shouldAutoPerformAuthSwitch: Bool = false
        
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        self.title = "Settings".localized
        self.lblSettingstitle.text = "Settings".localized
        self.leftBarCloseButtonItems(iconName: "crossVector")
        self.makeNavigationBarTransparent()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.reloadData()
        
        topView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 400)
        activatePreButton.setTitle(activatePreButton.currentTitle?.localized, for: .normal)
        lblCleanerTitle.text = lblCleanerTitle.text?.localized
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(checkEnabled), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if PaymentManager.shared.isPurchase() == true {
            activatePreButton.isEnabled = false
            activatePreButton.setTitleColor(.systemGray, for: .disabled)
        } else {
            activatePreButton.isEnabled = true
            activatePreButton.setTitleColor(.systemGray, for: .disabled)
        }
        
        checkEnabled()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @IBAction func onClickEnablePhotosAccess(_ sender: Any) {
        Utilities.openAppSetting()
    }
    
    @IBAction func onClickEnableContactsAccess(_ sender: Any) {
        Utilities.openAppSetting()
    }
    
    @IBAction func onClickPremium(_ sender: Any) {
        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: true, iapEvent: InAppEventLocations.onSettings)
    }
    
    @IBAction func onClickClose(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickShare(_ sender: UIButton){
        let activityController = UIActivityViewController(activityItems: [ "https://apps.apple.com/us/app/id" + appid ], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (nil, competed, _, error) in
        }
        present(activityController, animated: true) {
            print("Presented the activity view controller ")
        }
    }
    
    @IBAction func onClickAboutUs(_ sender: UIButton){
        if let url = URL(string: "https://apps.apple.com/ai/app/boost-cleaner-clean-storage/id1475887456") {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func onClickterms(_ sender: UIButton){
        if let url = URL(string: "http://sharpforksapps.com/terms-of-use/") {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func onClickprivacy(_ sender: UIButton){
        if let url = URL(string: "http://sharpforksapps.com/privacy-policy/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func onClickFAQs(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/ai/app/boost-cleaner-clean-storage/id1475887456") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func btnNotificationsToggle(_ sender: UISwitch) {
        if sender.isOn == true {
            UserDefaults.standard.set(true, forKey: "showBadgeCount")
            UserDefaults.standard.setValue(false, forKey: "ofNotification")
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
                let isNotificationOff = UserDefaults.standard.bool(forKey: "ofNotification")
                
                if accepted && isNotificationOff == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0, execute: {
                        let newDate = Date(timeInterval: 86400, since: Date())
                        
                        if let delegate = UIApplication.shared.delegate as? AppDelegate {
                            Utilities.scheduleNotification(at: newDate, delegate: delegate)
                        }
                    })
                }
            }
        } else {
            UserDefaults.standard.set(false, forKey: "showBadgeCount")
            UserDefaults.standard.setValue(true, forKey: "ofNotification")
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber )
            Utilities.removeAllNotification()
        }        
    }
    
    @IBAction func blockAdsSwitchToggle(_ sender: UISwitch) {
        let turnON = sender.isOn
        sender.isOn = !turnON
        
        let AlteradsBlocker = AlterAdsBlocker.instantiate()
        guard let pickerVC = AlteradsBlocker else { return }
        pickerVC.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 500, popupHeight: 320)
            
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            
            present(popupVC, animated: true) {
                if turnON {
                    pickerVC.updateTitle()
                }
            }
        } else {
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 300, popupHeight: 270)
            
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            
            present(popupVC, animated: true) {
                if turnON {
                    pickerVC.updateTitle()
                }
            }
        }
        
        //sender.isOn = !turnON
    }
    
    @IBAction func bioAuthSwitchToggle(_ sender: UISwitch) {
        sender.isOn = UserDefaults.standard._BioAuthEnabled
        let biometricIDAuth = BiometricIDAuth()
        biometricIDAuth.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                alert(title: "Error",
                      message: canEvaluateError?.localizedDescription ?? "Face ID/Touch ID may not be configured".localized,
                      okActionTitle: "Ok".localized)
                UserDefaults.standard._BioAuthEnabled = false
                sender.isOn = false
                return
            }
            
            biometricIDAuth.evaluate { (success, error) in
                guard success else {
                    sender.isOn = UserDefaults.standard._BioAuthEnabled
                    return
                }
                UserDefaults.standard._BioAuthEnabled.toggle()
                sender.isOn = UserDefaults.standard._BioAuthEnabled
                //                            self?.alert(title: "Success",
                //                                        message: "You have a free pass, now",
                //                                        okActionTitle: "Yay!")
            }
        }
    }
    
    @IBAction func btnSelectLang(_ sender: UIButton) {
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertStyle = UIAlertController.Style.alert
        }
        
        // create the alert
        let alert = UIAlertController(title: "", message: "", preferredStyle: alertStyle)
        let titleFont = [NSAttributedString.Key.font: UIFont(name: "SFRounded-Bold", size: 22.0)!, NSAttributedString.Key.foregroundColor : UIColor.black]
        let titleAttrString = NSMutableAttributedString(string: "\n" + "Choose Language".localized, attributes: titleFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "English".localized, style: UIAlertAction.Style.default, handler: {_ in
            UserDefaults.standard.set("en", forKey: "i18n_language")
            
            let storyBoard = UIStoryboard.init(name: "Settings", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "ChangeLanguageLoaderVC") as! ChangeLanguageLoaderVC

            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Chinese".localized, style: UIAlertAction.Style.default, handler: {_ in
            UserDefaults.standard.set("zh-Hans", forKey: "i18n_language")
            
            let storyBoard = UIStoryboard.init(name: "Settings", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "ChangeLanguageLoaderVC") as! ChangeLanguageLoaderVC

            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertAction.Style.cancel, handler: { action in
            print("Cancel")
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func btnSelectWidgets(_ sender: UIButton) {

//        let vc = UIStoryboard.init(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "WidgetVC") as! WidgetVC
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func alert(title: String, message: String, okActionTitle: String) {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
    
    @objc func checkEnabled() {
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: "Suntechltd.Phuongnga.Boost.extension", completionHandler: {
            (state, error) in
            if let state = state {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource, CrossAppAdCellDelegate {
    func closed() {
        return
    }
    
    
    func selectedApp(at app: CrossAppAds) {
        //        if let appID = app.appID, verifyUrl(url: app.appURL), app != .ringtone {
        //            openStoreProductWithiTunesItemIdentifier(appID)
        //        } else {
        if verifyUrl(url: app.appURL) {
            openAppURL(appURL: app.appURL)
        }
    }
    func openAppURL(appURL: URL?) {
        if let url = appURL {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 25 : .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let frameSize = tableView.frame.size
            let headerView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: frameSize.width, height: 25))
            headerView.backgroundColor = .clear
            headerView.clipsToBounds = false
            let labelView: UILabel = UILabel.init(frame: CGRect(x: 18, y: 0, width: frameSize.width, height: 20))
            labelView.text = "More Apps".localized
            labelView.font = UIFont(name: "SF-Pro-Rounded-Medium", size: 16)
            labelView.textColor = hexStringToUIColor(hex: "062549")
            headerView.addSubview(labelView)
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsOptionsCell.cellID, for: indexPath) as! SettingsOptionsCell
            
            cell.allowedPhotoAccess(isAllowed: isAllowedPhotos)
            cell.allowedContactAccess(isAllowed: isAllowedContacts)
            cell.checkEnabled()
            
            if !cell.bioAuthSwitch.isOn && shouldAutoPerformAuthSwitch {
                cell.bioAuthSwitch.sendActions(for: .valueChanged)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CrossAppAdCell.cellID, for: indexPath) as! CrossAppAdCell
            
            cell.delegate = self
            cell.reloadCollection()
            
            return cell
        }
    }
    
//    func startTimer() {
//
//        let timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
//    }
//
//
//    @objc func scrollAutomatically(_ timer1: Timer) {
//
//        if let coll  = topMenuCollection {
//            for cell in coll.visibleCells {
//                let indexPath: IndexPath? = coll.indexPath(for: cell)
//                if ((indexPath?.row)! < banner.count - 1){
//                    let indexPath1: IndexPath?
//                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
//
//                    coll.scrollToItem(at: indexPath1!, at: .right, animated: true)
//                }
//                else{
//                    let indexPath1: IndexPath?
//                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
//                    coll.scrollToItem(at: indexPath1!, at: .left, animated: true)
//                }
//
//            }
//        }
//    }
    
}

extension SettingsVC: SKStoreProductViewControllerDelegate {
    
    func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self

        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        showLoading()
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            guard let weakSelf = self else {return}
            weakSelf.hideLoading()
            if loaded {
                // Parent class of self is UIViewContorller
                DispatchQueue.main.async {
                    weakSelf.present(storeViewController, animated: true, completion: nil)
                }
            } else {
                print("Error: \(error.debugDescription)")
            }
        }
    }
    
    private func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        navigationController?.navigationBar.alpha = 1 - (self.tableView.contentOffset.y / (self.tableView.contentSize.height - self.tableView.frame.size.height))
//    }
    
}

extension UIViewController {
    
    func showError(message: String) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.red.withAlphaComponent(1)
        //        currentView().view.makeToast(message, duration: 3.0, position: .top, style: style)
    }
    
    func showSuccess(message: String) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.green.withAlphaComponent(1)
        //        currentView().view.makeToast(message, duration: 3.0, position: .top, style: style)
    }
    
    @IBAction func openSubscription(_ sender: UIButton) {
        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: true, iapEvent: InAppEventLocations.onSettings)
    }
    
    @IBAction func openAppSettings(_ sender: UIButton) {
        let storyBoard = UIStoryboard.init(name: "Settings", bundle: nil)
        let HomeVCController = storyBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(HomeVCController, animated: true)
    }
}

extension UICollectionView {
  var visibleCurrentCellIndexPath: IndexPath? {
    for cell in self.visibleCells {
      let indexPath = self.indexPath(for: cell)
      return indexPath
    }
    
    return nil
  }
}

extension SettingsVC: AlterAdsBlockerDelegate {
    
    func AlterViewController(sender: AlterAdsBlocker, didSelectNumber number: Int) {
        dismiss(animated: true) {
            if (number == 1) {
                self.openUrl()
            }
        }
    }
    
    func openUrl() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
}
