//
//  MissingContactsVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/30/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import SwiftyContacts
import Foundation
import Contacts
import CoreTelephony
import StoreKit

class MissingContactsVC: UIViewController {
    
    @IBOutlet var phoneNamelbl: UILabel!
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var emaillbl: UILabel!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet var missNamelbl: UILabel!
    @IBOutlet var missPhonelbl: UILabel!
    @IBOutlet var missEmaillbl: UILabel!
    
    let contactStore = CNContactStore()
    var noEmailsArray: [CNContact] = []
    var noPhonesArray: [CNContact] = []
    var noNameArray: [CNContact] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeNavigationBarTransparent()
        firstView.dropShadow()
        secondView.dropShadow()
        thirdView.dropShadow()
        // Do any additional setup after loading the view.
    }
    @IBAction func missingNameButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MissingNameVC") as? MissingNameVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func missingPhoneButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MissingPhoneVC") as? MissingPhoneVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func missingEmailButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MissingEmailVC") as? MissingEmailVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Missing Information".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        fetchContactsWithNoName()
        FetchNophone ()
        fetchContactsWithNoEmail()
    }
    func fetchContactsWithNoEmail() {
        var results: [CNContact] = []
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor])
        
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                if(contact.emailAddresses.first?.value == nil ){
                    results.append(contact)
                }
                
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        print(results.count)
        
        
        self.noEmailsArray = results
        self.missEmaillbl.text = "\( self.noEmailsArray.count)" + " items".localized
        
        
    }
    
    func fetchContactsWithNoName() {
        var results: [CNContact] = []
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor])
        
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                
                if(contact.givenName == "" && contact.familyName == ""){
                    results.append(contact)
                }
                
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        print(results.count)
        // noNameslbl.text = "(" + "\(results.count)" + ")"
        
        self.noNameArray = results
        self.missNamelbl.text = "\( self.noNameArray.count)" + " items".localized
        
        
    }
    func FetchNophone (){
        var results: [CNContact] = []
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor])
        
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                
                if(contact.phoneNumbers.first?.value.stringValue == nil){
                    results.append(contact)
                    
                }
                
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        //  print(results.count)
        //  nophonelbl.text = "(" + "\(results.count)" + ")"
        
        self.noPhonesArray = results
        self.missPhonelbl.text = "\( self.noPhonesArray.count)" + " items".localized
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
