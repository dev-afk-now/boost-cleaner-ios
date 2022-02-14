//
//  BaseNavigationController.swift
//  BitEclipse
//
//  Created by Nhuom Tang on 23/4/19.
//  Copyright © 2019 Nhuom Tang. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = AppBackgroundColor
        navigationBar.tintColor = UIColor.white
        if  IS_IPAD {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                 NSAttributedString.Key.font: UIFont.boldApplicationFont(25)]
        }else{
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                 NSAttributedString.Key.font: UIFont.boldApplicationFont(18)]
        }
        view.backgroundColor = UIColor.clear
        let backgroundImage = UIImage.init(named: "bg_bar")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)
        navigationBar.setBackgroundImage(backgroundImage, for: .default)
        navigationBar.shadowImage = UIImage()
        
        let imgBack = UIImage(named: "ic_back")
        navigationBar.backIndicatorImage = imgBack
        navigationBar.backIndicatorTransitionMaskImage = imgBack
        navigationItem.leftItemsSupplementBackButton = true
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}
extension BaseNavigationController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
