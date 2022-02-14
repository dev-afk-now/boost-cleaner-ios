//
//  HomeTabbarVC.swift
//  RealEstate
//

import UIKit
import Foundation
import AVFoundation
//import NVActivityIndicatorView

class ChangeLanguageLoaderVC: BaseViewController {
    
    //@IBOutlet weak var indicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        //indicatorView.startAnimating()
        showLoading(with: "Changing Language")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            guard let window = UIApplication.shared.keyWindow else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            guard let _ = window.rootViewController else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let homeVC = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let navController = UINavigationController (rootViewController: homeVC)
                        
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = navController
            }, completion: nil)
        }
    }
}
