//
//  AlterFastCleaner.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 11/12/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//
import UIKit

protocol AlterFastCleanerDelegate: class {
    func AlterViewController(sender: AlterFastCleaner, didSelectNumber number: Int)
}

class AlterFastCleaner: UIViewController {
    
    @IBOutlet weak var deleteValue: UILabel!
    @IBOutlet weak var deletelable: UILabel!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    
    @IBOutlet weak var btnYEs: UIButton!
    let user = SharedData.sharedUserInfo
    
    weak var delegate: AlterFastCleanerDelegate?
    
    static func instantiate() -> AlterFastCleaner? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(AlterFastCleaner.self)") as? AlterFastCleaner
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let description = "Do you want to calculate storage size that can be cleaned up? Calculating Size will increase the processing time."
        
        deleteValue.text = "Show Size".localized
        deletelable.text = description.localized
        yesBtn.setTitle("Yes".localized, for: .normal)
        btnNo.setTitle("No".localized, for: .normal)
        
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


