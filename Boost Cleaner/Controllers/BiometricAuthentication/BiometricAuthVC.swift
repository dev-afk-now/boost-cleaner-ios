//
//  BiometricAuthVC.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 05/10/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import UIKit

class BiometricAuthVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnFaceID: UIButton!
    
    let biometricIDAuth = BiometricIDAuth()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autheticate()
    }

    func prepareUI() {
        let availableAuthType = biometricIDAuth.biometricType.typeAsString
        let useStr = "Use".localized
        let lockedStr = "Boost Cleaner Locked".localized
        var finalString = "Unlock with Face ID to open\nBoost Cleaner"
        
        switch biometricIDAuth.biometricType {
        case .touchID:
            finalString = "Unlock with Touch ID to open\nBoost Cleaner".localized
        case .faceID:
            finalString = "Unlock with Face ID to open\nBoost Cleaner".localized
        case .unknown, .none :
            finalString = "Unlock with Passcode to open\nBoost Cleaner".localized
//            case .none :
//                return "Touch ID/Face ID"
        }
        
        
        lblTitle.text = lockedStr.localized
        lblSubTitle.text = finalString //"\(unlockWith) \(availableAuthType) \(toOpen)\n\(boostCleaner)"
        
        let btnTitle = "\(useStr) \(availableAuthType)"
        btnFaceID.setTitle(btnTitle, for: .normal)
    }
    
    @IBAction func onBtnBioAuthAction(_ sender: UIButton) {
        autheticate()
    }
    
    func autheticate() {
        biometricIDAuth.evaluate { [weak self] wasCorrect, Error in
            guard let weakSelf = self else {return}
            
            if wasCorrect {
                NotificationCenter.default.post(name: NSNotification.Name.init("Get_Authenticated_For_Vault"), object: nil)
                weakSelf.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    class func presentVC(from controller: UIViewController) {
        if let vc = UIStoryboard.init(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "BiometricAuthVC") as? BiometricAuthVC {
            controller.modalTransitionStyle = .crossDissolve
            UIViewController.preventPageSheetPresentation
            if #available(iOS 13.0, *) {
                controller.isModalInPresentation = false
            } else {
                // Fallback on earlier versions
            }
            controller.present(vc, animated: false, completion: nil)
        }
    }

}

extension UIViewController {
    
    static func _swizzling(forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        if let originalMethod = class_getInstanceMethod(forClass, originalSelector),
           let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    static let preventPageSheetPresentation: Void = {
        if #available(iOS 13, *) {
            _swizzling(forClass: UIViewController.self,
                       originalSelector: #selector(present(_: animated: completion:)),
                       swizzledSelector: #selector(_swizzledPresent(_: animated: completion:)))
        }
    }()

    @available(iOS 13.0, *)
    @objc private func _swizzledPresent(_ viewControllerToPresent: UIViewController,
                                        animated flag: Bool,
                                        completion: (() -> Void)? = nil) {
        if viewControllerToPresent.modalPresentationStyle == .pageSheet
                   || viewControllerToPresent.modalPresentationStyle == .automatic {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
        _swizzledPresent(viewControllerToPresent, animated: flag, completion: completion)
    }
}
