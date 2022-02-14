//
//  SettingsOptionsCell.swift
//  Boost Cleaner
//
//  Created by HABIB on 13/10/2021.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import Contacts
import Photos
import StoreKit
import SafariServices

class SettingsOptionsCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var notificationsView: UIView!
    @IBOutlet weak var biometricAuthView: UIView!
    @IBOutlet weak var blockAdsView: UIView!
    @IBOutlet weak var FAQsView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var photosAccessView: UIView!
    @IBOutlet weak var contactsAccessView: UIView!
    @IBOutlet weak var changeLangView: UIView!
    @IBOutlet weak var widgetsView: UIView!
    @IBOutlet weak var btnNotificationSwitch: UISwitch!
    @IBOutlet weak var bioAuthSwitch: UISwitch!
    @IBOutlet weak var lblBioAuthType: UILabel!
    @IBOutlet weak var blockAdsSwitch: UISwitch!
    
    @IBOutlet weak var lblNotiTitle: UILabel!
    @IBOutlet weak var lblfaceTitle: UILabel!
    
    @IBOutlet weak var lblContactAccess: UILabel!
    @IBOutlet weak var lblPhotoAccess: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var changeLangLbl: UILabel!
    @IBOutlet weak var widgetsLbl: UILabel!
    
    static let cellID = "settingsOptionsCell"
    
    private func getLocalized9(){
        lblAbout.text = lblAbout.text?.localized
        lblShare.text = lblShare.text?.localized
        lblNotiTitle.text = lblNotiTitle.text?.localized
        lblShare.text = lblShare.text?.localized
        lblPrivacy.text = lblPrivacy.text?.localized
        lblTerms.text = lblTerms.text?.localized
        lblPhotoAccess.text = lblPhotoAccess.text?.localized
        lblContactAccess.text = lblContactAccess.text?.localized
        changeLangLbl.text = changeLangLbl.text?.localized
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        getLocalized9()
        notificationsView.dropShadow2()
        FAQsView.dropShadow2()
        shareView.dropShadow2()
        aboutView.dropShadow2()
        termsView.dropShadow2()
        privacyView.dropShadow2()
        photosAccessView.dropShadow2()
        contactsAccessView.dropShadow2()
        biometricAuthView.dropShadow2()
        changeLangView.dropShadow2()
        blockAdsView.dropShadow2()
        widgetsView.dropShadow2()
        
        FAQsView.layer.cornerRadius = 20
        notificationsView.layer.cornerRadius = 20
        shareView.layer.cornerRadius = 20
        aboutView.layer.cornerRadius = 20
        termsView.layer.cornerRadius = 20
        privacyView.layer.cornerRadius = 20
        photosAccessView.layer.cornerRadius = 20
        contactsAccessView.layer.cornerRadius = 20
        changeLangView.layer.cornerRadius = 20
        widgetsView.layer.cornerRadius = 20
        biometricAuthView.layer.cornerRadius = 20
        blockAdsView.layer.cornerRadius = 20
        btnNotificationSwitch.isOn = UserDefaults.standard.bool(forKey: "showBadgeCount")
        
        checkForBiometricAuth()
        checkEnabled()

        if #available(iOS 14.0, *) {
            self.widgetsView.alpha = 1
        } else {
            self.widgetsView.alpha = 0
        }
    }
    
    func allowedPhotoAccess(isAllowed: Bool) {
        photosAccessView.isHidden = isAllowed
    }
    
    func allowedContactAccess(isAllowed: Bool) {
        contactsAccessView.isHidden = isAllowed
    }
    
    func checkForBiometricAuth() {
        let biometricIDAuth = BiometricIDAuth()
        lblBioAuthType.text = biometricIDAuth.biometricType.typeAsString
        bioAuthSwitch.isOn = UserDefaults.standard._BioAuthEnabled
        biometricIDAuth.canEvaluate { canEvaluate, _, _ in
            if !canEvaluate {
                bioAuthSwitch.isOn = false
            }
        }        
    }
    
    func checkEnabled() {
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: "Suntechltd.Phuongnga.Boost.extension", completionHandler: {
            (state, error) in
            if let state = state {
                DispatchQueue.main.async {
                    self.blockAdsSwitch.isOn = state.isEnabled
                }
            }
        })
    }
}
