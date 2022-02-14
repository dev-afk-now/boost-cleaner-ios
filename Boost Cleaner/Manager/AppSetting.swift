//
//  AppSetting.swift
//  Fitness Challenge
//
//  Created by Fresh Brain on 4/16/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Foundation


class AppSetting {
    
    static let sharedInstance = AppSetting()      
    private var touchIDRunAfterInstall = false

    func initialize() {
        setLanguageSettings()
        
        UserDefaults.standard.set(0, forKey: "similar_photos_found_count")
        
        touchIDRunAfterInstall = !UserDefaults.standard.bool(forKey: "RunAfterInstall")
        if touchIDRunAfterInstall {
            //UserDefaults.standard.set("en", forKey: "i18n_language")
            UserDefaults.standard.set(true, forKey: "RunAfterInstall")
            UserDefaults.standard.set(true, forKey: "isFirstTime")
            UserDefaults.standard.set(false, forKey: "backup")
            UserDefaults.standard.set("Provider Name".localized, forKey: "provider")
            UserDefaults.standard.set("City".localized, forKey: "city")
            UserDefaults.standard.set("Country".localized, forKey: "country")
            UserDefaults.standard.set(false, forKey: "showsize")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    func setLanguageSettings() {
        let appCurrentLang = UserDefaults.standard.string(forKey: "i18n_language")
        
        if (appCurrentLang == nil || appCurrentLang == "") {
            if Locale.current.isChinese {
                UserDefaults.standard.set("zh-Hans", forKey: "i18n_language")
            } else {
                UserDefaults.standard.set("en", forKey: "i18n_language")
            }
        } else if (appCurrentLang == "en") {
            UserDefaults.standard.set("en", forKey: "i18n_language")
        } else if (appCurrentLang == "zh-Hans") {
            UserDefaults.standard.set("zh-Hans", forKey: "i18n_language")
        } else {
            UserDefaults.standard.set("en", forKey: "i18n_language")
        }
    }
}
