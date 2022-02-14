//
//  PolicyViewController.swift
//  CallSanta
//
//  Created by Nhuom Tang on 6/21/19.
//  Copyright © 2019 Luy Nguyen. All rights reserved.
//

import UIKit

enum PolicyType {
    case policy
    case terms
}
class PolicyViewController: UIViewController {
    
    var policyType: PolicyType = .policy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Privacy policy"
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
