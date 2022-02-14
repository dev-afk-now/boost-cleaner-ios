//
//  PolicyViewController.swift
//  CallSanta
//
//  Created by Nhuom Tang on 6/21/19.
//  Copyright © 2019 Luy Nguyen. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Terms and Conditions"
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
