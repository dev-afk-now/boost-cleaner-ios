//
//  AlterAdsBlocker.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/28/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

protocol AlterAdsBlockerDelegate: class {
    func AlterViewController(sender: AlterAdsBlocker, didSelectNumber number: Int)
}

class AlterAdsBlocker: UIViewController {
    
    @IBOutlet weak var lblHeadertitle: UILabel!
    @IBOutlet weak var lblGoSettings: UILabel!
    @IBOutlet weak var lblTapSafari: UILabel!
    @IBOutlet weak var lblSelectContentBlocker: UILabel!
    @IBOutlet weak var lblDisableAdBlocker: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    weak var delegate: AlterAdsBlockerDelegate?
    
    static func instantiate() -> AlterAdsBlocker? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(AlterAdsBlocker.self)") as? AlterAdsBlocker
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeadertitle.text = "How To Disable".localized
        lblGoSettings.text = "Go to Settings".localized
        lblTapSafari.text = "Tap Safari".localized
        lblSelectContentBlocker.text = "Select Extensions".localized
        lblDisableAdBlocker.text = "Disable Boost Cleaner and return to the app".localized
        cancelButton.setTitle("Cancel".localized, for: .normal)
        settingsButton.setTitle("Settings".localized, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    public func updateTitle() {
        lblHeadertitle.text = "How To Enable".localized
        lblDisableAdBlocker.text = "Enable Boost Cleaner and return to the app".localized        
    }
    
    @IBAction func yesbtnPressed(_ sender: UIButton) {
        sender.showsTouchWhenHighlighted = true
        delegate?.AlterViewController(sender: self, didSelectNumber: 1)
    }
    @IBAction func noPressed(_ sender: UIButton) {
        sender.showsTouchWhenHighlighted = true
        delegate?.AlterViewController(sender: self, didSelectNumber: 2)
    }
    
}


