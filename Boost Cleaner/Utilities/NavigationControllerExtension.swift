//
//  NavigationControllerExtension.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 29/09/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import Foundation

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true, completion: (() -> Void)?) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
//            popToViewController(vc, animated: animated)
            popToViewController(vc: vc, animated: animated, completion: completion)
        }
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popToViewController(vc: UIViewController, animated: Bool = true, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToViewController(vc, animated: animated)
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
}
