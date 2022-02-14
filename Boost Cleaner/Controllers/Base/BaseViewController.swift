//
//  BaseViewController.swift
//  BitEclipse
//
//  Created by Nhuom Tang on 23/4/19.
//  Copyright © 2019 Nhuom Tang. All rights reserved.
//

import UIKit
import JGProgressHUD
import StoreKit

class BaseViewController: UIViewController {
    
    let hud = JGProgressHUD(style: .dark)
    var timer = Double()
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Deallocated: \(self.classForCoder)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppBackgroundColor
        print("Allocated: \(self.classForCoder)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
  
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
        
    func showLoading(shouldAllowInteractin: Bool = false) {
        hud.textLabel.text = "Processing".localized//locale()
        hud.show(in: self.view)
        self.navigationController?.view.isUserInteractionEnabled = shouldAllowInteractin
        self.view.isUserInteractionEnabled = shouldAllowInteractin
    }

    func showLoading(with text: String) {
        hud.textLabel.text = text.localized//locale()
        hud.show(in: self.view)
        self.navigationController?.view.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false
    }

    func hideLoading(){
        hud.dismiss(animated: true)
        self.navigationController?.view.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
    }
        
    func showProgressHUD() -> JGProgressHUD {
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.indicatorView = JGProgressHUDRingIndicatorView()
        hud.detailTextLabel.text = "0% Complete"
        hud.textLabel.text = "Loading".localized
        hud.show(in: self.view)

        self.navigationController?.view.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false

        return hud
    }
    
    func incrementHUD(_ hud: JGProgressHUD, progress previousProgress: Int) {
        DispatchQueue.main.async {
            let progress = previousProgress
            hud.progress = Float(progress)/100.0
            hud.detailTextLabel.text = "\(progress)% Complete"
        }
    }
    
    func markDone(_ hud: JGProgressHUD) {
        UIView.animate(withDuration: 0.1, animations: {
            hud.textLabel.text = "Done".localized
            hud.detailTextLabel.text = nil
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        }) { (completion) in
            hud.dismiss(afterDelay: 0.25)
            self.navigationController?.view.isUserInteractionEnabled = true
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func prepareTransparentNavigation(with title: String?, leftBarItemIcon: String?, rightBarItemIcon: String? = nil) {
        self.title = title
        if let leftIcon = leftBarItemIcon {
            
            self.leftBarCloseButtonItems(iconName: leftIcon)
        }
        if let rightIcon = rightBarItemIcon {
            self.RightBarItemWithImage(iconName: rightIcon)
        }
        makeNavigationBarTransparent()
    }
    
    func verifyUrlString(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func verifyUrl(url: URL?) -> Bool {
        if let url = url {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
    
}
