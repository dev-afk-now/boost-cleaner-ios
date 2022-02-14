//
//  AlterLocationContact.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 11/12/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

protocol AlterLocationContactDelegate: AnyObject {
    func AlterViewController(sender: AlterLocationContact, didSelectNumber number: Int)
}

class AlterLocationContact: UIViewController {
    
    @IBOutlet weak var deleteValue: UILabel!
    @IBOutlet weak var deletelable: UILabel!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var btnDowntAllow: UIButton!

    let user = SharedData.sharedUserInfo    
    weak var delegate: AlterLocationContactDelegate?
    var headerTitle = "Location Service Disabled".localized
    var detailMessage1 = "To re-enable, please go to Settings and ".localized
    var detailMessage = "turn on Location Service for this app.".localized
    
    static func instantiate() -> AlterLocationContact? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(AlterLocationContact.self)") as? AlterLocationContact
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.headerLabel.text = headerTitle
        self.detailLabel.text = detailMessage
        self.deletelable.text = detailMessage1
        self.yesBtn.setTitle("Allow".localized, for: .normal)
        self.btnDowntAllow.setTitle("Don’t Allow".localized, for: .normal)
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


