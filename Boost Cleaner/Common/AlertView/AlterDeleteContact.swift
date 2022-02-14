//
//  AlterDeleteContact.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/27/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

protocol AlterDeleteDelegate: class {
    func AlterViewController(sender: AlterDeleteContact, didSelectNumber number: Int)
}

class AlterDeleteContact: UIViewController {
    
    @IBOutlet weak var lblFromAllDevice: UILabel!
    @IBOutlet weak var lblAllow: UILabel!
    @IBOutlet weak var deleteValue: UILabel!
    @IBOutlet weak var deletelable: UILabel!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var btnDontAllow: UIButton!
    
    let user = SharedData.sharedUserInfo
    
    weak var delegate: AlterDeleteDelegate?
    
    static func instantiate() -> AlterDeleteContact? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(AlterDeleteContact.self)") as? AlterDeleteContact
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(self.user.deleteflg){
            yesBtn.setTitle("Allow".localized, for: .normal)
        if( self.user.deleteValue == 1){
            deleteValue.text = "delete ".localized +  "\(self.user.deleteValue)" + " contact?"
            deletelable.text = "These contact will be deleted".localized        }
        else{
            deleteValue.text = "delete ".localized +  "\(self.user.deleteValue)" + " contacts?"
            deletelable.text = "These contacts will be deleted".localized
        }
        }
        else{
            yesBtn.setTitle("Allow", for: .normal)
            if( self.user.deleteValue == 1){
                deleteValue.text = "merge ".localized +  "\(self.user.deleteValue)" + " contact?".localized
                deletelable.text = "These contact will be merged".localized
            }
            else{
                deleteValue.text = "merge ".localized +  "\(self.user.deleteValue)" + " contacts?".localized
                deletelable.text = "These contacts will be merged".localized
            }
            
        }
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


