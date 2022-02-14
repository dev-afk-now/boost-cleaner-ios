//
//  DuplicateContactsVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/1/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import SwiftyContacts
import Foundation
import Contacts
import CoreTelephony
import StoreKit

class DuplicateContactsVC: UIViewController {
    
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet var phoneNamelbl: UILabel!
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var emaillbl: UILabel!
    @IBOutlet var duplicateNamelbl: UILabel!
    @IBOutlet var duplicatePhonelbl: UILabel!
    @IBOutlet var duplicateEmaillbl: UILabel!
    @IBOutlet var IndicatorViewEmaillbl: UIActivityIndicatorView!
    
    var duplicatePhone = 0
    var duplicateName = 0
    var duplicateEmail = 0
    let contactStore = CNContactStore()
    
    var  SimilarContactArrayPhone = [String: [CNContact]]()
    var  ContactArrayPhone = [[CNContact]]()
    var  mainDataArryPhone = [ContactModel]()
    
    var  SimilarContactArrayName = [String: [CNContact]]()
    var  ContactArrayName = [[CNContact]]()
    var  mainDataArryName = [ContactModel]()
    
    var  SimilarContactArrayEmail = [String: [CNContact]]()
    var  ContactArrayEmail = [[CNContact]]()
    var  mainDataArryEmail = [ContactModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNamelbl.text = "Phone".localized
        self.Namelbl.text = "Name".localized
        self.emaillbl.text = "Email".localized
        self.makeNavigationBarTransparent()
        
        firstView.dropShadow()
        secondView.dropShadow()
        thirdView.dropShadow()
        IndicatorViewEmaillbl.isHidden = true
    }
    
    @IBAction func duplicateNameButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DuplicateNameVC") as? DuplicateNameVC
        vc!.mainDataArryName = self.mainDataArryName
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func duplicatePhoneButtonPressed(_ sender: UIButton) {
//        IndicatorViewEmaillbl.isHidden = false
//        IndicatorViewEmaillbl.startAnimating()
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DuplicatePhoneVC") as? DuplicatePhoneVC
        vc!.mainDataArryPhone = self.mainDataArryPhone
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func duplicateEmailButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DuplicateEmailVC") as? DuplicateEmailVC
        vc!.mainDataArryEmail = self.mainDataArryEmail
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Duplicate Contacts".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        duplicatePhone = 0
        duplicateName = 0
        duplicateEmail = 0
        FetchSimilarPhone()
        FetchSimilarNames()
        FetchSimilarEmail()
        
    }
    func FetchSimilarEmail(){
        
        var results: [CNContact] = []
        var contactsByEmail = [String: [CNContact]]()
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor])
        
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                //  print(contact.phoneNumbers.first?.value ?? "no")
                //  print(contact.emailAddresses.first?.value)
                if(contact.emailAddresses.first?.value != nil){
                    results.append(contact)
                    //  contactsByEmail.append(contact.emailAddresses.first?.value as! String)
                    
                    contactsByEmail[contact.emailAddresses.first?.value as! String] = (contactsByEmail[contact.emailAddresses.first?.value as! String] ?? []) + [contact]
                    
                    
                }
                
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        
        let duplicates = contactsByEmail.filter { $1.count > 1 }
        print(duplicates.keys)
        print(duplicates.values)
        
        
        SimilarContactArrayEmail.removeAll()
        mainDataArryEmail.removeAll()
        ContactArrayEmail.removeAll()
        SimilarContactArrayEmail =  duplicates
        
        for (key, array) in SimilarContactArrayEmail
        {
            print( key)
            print( array.count)
            ContactArrayEmail.append(array)
            self.mainDataArryEmail.append(ContactModel( ContactArray :array,nameContact: key , totalCount:array.count ))
            duplicateEmail = duplicateEmail + array.count
            
        }
        print(self.mainDataArryEmail)
        self.mainDataArryEmail = mainDataArryEmail.sorted { (a, b) -> Bool in
            if a.nameContact!.isEmpty {
                return false
            } else if b.nameContact!.isEmpty {
                return true
            } else {
                return a.nameContact!.localizedCaseInsensitiveCompare(b.nameContact!) == .orderedAscending
            }
        }
        
        self.duplicateEmaillbl.text = "\(duplicateEmail - mainDataArryEmail.count)" + "items".localized
        
        
    }
    func FetchSimilarNames(){
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        
        let keys = [CNContactIdentifierKey as CNKeyDescriptor, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)
        var contactsByName = [String: [CNContact]]()
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: request) { contact, stop in
       // try! self.contactStore.enumerateContacts(with: request) { contact, stop in
            guard let name = formatter.string(from: contact) else { return }
            contactsByName[name] = (contactsByName[name] ?? []) + [contact]
            //   print(name)
            // or in Swift 4, `contactsByName[name, default: []].append(contact)`
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        let duplicates = contactsByName.filter { $1.count > 1 }
        //  print(duplicates)
        
        print(duplicates.keys)
        //  self.similarNameslbl.text = "(" + "\(duplicates.count)" + ")"
        //  SimilarContactArray.removeAll()
        var similarNameArray2  = [String: [CNContact]]()
        self.mainDataArryName.removeAll()
        ContactArrayName.removeAll()
        SimilarContactArrayName.removeAll()
        
        similarNameArray2 =  duplicates
        SimilarContactArrayName = similarNameArray2
        
        
        for (key, array) in SimilarContactArrayName
        {
            print( key)
            print( array.count)
            ContactArrayName.append(array)
            self.mainDataArryName.append(ContactModel(ContactArray :array, nameContact: key , totalCount:array.count ))
            duplicateName = duplicateName + array.count
            
        }
        print(self.mainDataArryName)
        self.mainDataArryName = mainDataArryName.sorted { (a, b) -> Bool in
            if a.nameContact!.isEmpty {
                return false
            } else if b.nameContact!.isEmpty {
                return true
            } else {
                return a.nameContact!.localizedCaseInsensitiveCompare(b.nameContact!) == .orderedAscending
            }
        }
        
        self.duplicateNamelbl.text = "\(duplicateName - mainDataArryName.count)" + "items".localized
        
        
        
    }
    func FetchSimilarPhone(){
        var results: [CNContact] = []
        var contactsByEmail = [String: [CNContact]]()
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor])
        
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                //  print(contact.phoneNumbers.first?.value ?? "no")
                //   print(contact.phoneNumbers.first?.value.stringValue)
                if(contact.phoneNumbers.first?.value.stringValue != nil){
                    results.append(contact)
                    //  contactsByEmail.append(contact.emailAddresses.first?.value as! String)
                    let numberString = contact.phoneNumbers.first?.value.stringValue as! String
                    
                    let trimmed = numberString.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                    
                    let str2 = trimmed.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
                    let str3 = str2.replacingOccurrences(of: "+", with: "", options: .literal, range: nil)
                    
                    print(str3)
                    contactsByEmail[str3] = (contactsByEmail[str3] ?? []) + [contact]
                    
                    
                }
                
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        
        let duplicates = contactsByEmail.filter { $1.count > 1 }
        print(duplicates.keys)
        //   print(duplicates.count)
        //  similarPhonelbl.text = "(" + "\(duplicates.count)" + ")"
        SimilarContactArrayPhone.removeAll()
        mainDataArryPhone.removeAll()
        ContactArrayPhone.removeAll()
        SimilarContactArrayPhone =  duplicates
        
        for (key, array) in SimilarContactArrayPhone
        {
            print( key)
            print( array.count)
            ContactArrayPhone.append(array)
            self.mainDataArryPhone.append(ContactModel(ContactArray :array, nameContact: key , totalCount:array.count ))
            duplicatePhone = duplicatePhone + array.count
            
            
        }
        print(self.mainDataArryPhone)
        self.mainDataArryPhone = mainDataArryPhone.sorted { (a, b) -> Bool in
            if a.nameContact!.isEmpty {
                return false
            } else if b.nameContact!.isEmpty {
                return true
            } else {
                return a.nameContact!.localizedCaseInsensitiveCompare(b.nameContact!) == .orderedAscending
            }
        }
        self.duplicatePhonelbl.text = "\(duplicatePhone - mainDataArryPhone.count)" + "items".localized
        //  similarPhoneTable.reloadData()
        
        // var similarPhonesArray: [CNContact] = []
        // var similarNameArray: [CNContact] = []
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
