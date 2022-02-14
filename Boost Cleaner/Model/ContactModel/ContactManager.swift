//
//  ContactManager.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/23/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import ContactsUI

enum ContactType : Int {
    case duplicatePhone = 0
    case duplicateName = 1
    case duplicateEmail = 2
    case missingPhone = 3
    case missingName = 4
    case missingEmail = 5
    case edit = 6
}

enum ContactFilterType : Int {
    case birthday = 0
    case company = 1
    case location = 2
}

class ContactManager: NSObject {
    
    var contacts = [Contact]()
    var store : CNContactStore!
    var needReload = true
    
    //Create share instance object
    
    static let shared: ContactManager = {
        let instance = ContactManager()
        return instance
    }()

    //MARK: Request access and get contact from local
    
    func loadContacts(completionHandler:@escaping (Bool) -> ())
    {
        if self.store == nil {
            self.store = CNContactStore()
        }
        self.store?.requestAccess(for: .contacts, completionHandler: { (granted : Bool, error: Error?) -> Void in
            if(granted) {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.getContactsFromAddressBook(completionHandler: completionHandler)
                })
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    print("show UIalert for problem")
                    completionHandler(false)
                })
            }
        })
    }
    
    //Get contact from local
    
    func getContactsFromAddressBook(completionHandler:@escaping (Bool) -> ()){
        self.contacts.removeAll()
        
        let req : CNContactFetchRequest = CNContactFetchRequest(keysToFetch:
            [CNContactEmailAddressesKey as CNKeyDescriptor,
             CNContactGivenNameKey as CNKeyDescriptor,
             CNContactFamilyNameKey as CNKeyDescriptor,
             CNContactImageDataAvailableKey as CNKeyDescriptor,
             CNContactThumbnailImageDataKey as CNKeyDescriptor,
             CNContactImageDataKey as CNKeyDescriptor,
             CNContactPhoneNumbersKey as CNKeyDescriptor,
             CNContactOrganizationNameKey as CNKeyDescriptor,
             CNContactDepartmentNameKey as CNKeyDescriptor,
             CNContactJobTitleKey as CNKeyDescriptor,
             CNContactPostalAddressesKey as CNKeyDescriptor,
             CNContactBirthdayKey as CNKeyDescriptor
            ])
        
        do {
            try self.store?.enumerateContacts(with: req, usingBlock: { (contact: CNContact, boolprop : UnsafeMutablePointer<ObjCBool> ) -> Void in
                let tmpContact: Contact = Contact(cnContact: contact)
                self.contacts.append(tmpContact)
            })
                    
            self.contacts.sort(by: { (contact1, contact2) -> Bool in
                let name1 = self.contactName(contact1).uppercased().replacingOccurrences(of: " ", with: "")
                let name2 = self.contactName(contact2).uppercased().replacingOccurrences(of: " ", with: "")
                return name1.compare(name2) == ComparisonResult.orderedAscending
            })
            completionHandler(true)
        } catch {
            print("error occured")
            completionHandler(false)
        }
    }
    
    
    func deleteContact(_ contactID: String){
        let request = CNSaveRequest()
        do {
            let appconact = try store.unifiedContact(withIdentifier: contactID, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()] )
            let mutable : CNMutableContact = appconact.mutableCopy() as! CNMutableContact
            request.delete(mutable)
            do{
                try ContactManager.shared.store.execute(request)
                for contact in contacts{
                    if contact.identifier == contactID{
                        if let index = contacts.firstIndex(of: contact){
                            contacts.remove(at: index)
                            break
                        }
                    }
                }
                ContactManager.shared.needReload = true
                print("Successfully stored the contact")
            } catch let err{
                print("Failed to save the contact. \(err)")
            }
        } catch {
            print("error")
        }
    }
    
    func filterByKey(_ key: String) -> [Contact] {
        let keySearch = key.uppercased()
        return contacts.filter({ (contact) -> Bool in
            if contactName(contact).uppercased().contains(keySearch){
                return true
            }
            if contactEmail(contact).uppercased().contains(keySearch){
                return true
            }
            if contactPhones(contact).uppercased().contains(keySearch){
                return true
            }
            if contact.company.uppercased().contains(keySearch){
                return true
            }
            if contact.jobTitle.uppercased().contains(keySearch){
                return true
            }
            if contact.departmentName.uppercased().contains(keySearch){
                return true
            }
            for address in contact.address{
                if address.uppercased().contains(keySearch){
                    return true
                }
            }
            return false
        })
    }
    
    func getCompanyNames() -> [String] {
        var companyName = Set<String>()
        for contact in contacts{
            if contact.company.count > 0{
                companyName.insert(contact.company)
            }
        }
        return Array.init(companyName).sorted(by: { (value1, value2) -> Bool in
            return value1 < value2
        })
    }
    
    func getCityNames() -> [String] {
        var cityName = Set<String>()
        for contact in contacts{
            for city in contact.address{
                cityName.insert(city)
            }
        }
        return Array.init(cityName).sorted(by: { (value1, value2) -> Bool in
            return value1 < value2
        })
    }
    
    func contactName(_ contact :Contact) -> String {
        if let firstName = contact.firstName, let lastName = contact.lastName {
            return "\(firstName) \(lastName)"
        }
        else if let firstName = contact.firstName {
            return "\(firstName)"
        }
        else if let lastName = contact.lastName {
            return "\(lastName)"
        }
        else {
            return "Unnamed contact"
        }
    }
    
    func getNumberFromString(_ str: NSString) -> String{
        
        let intString = str.components(
            separatedBy: NSCharacterSet
                .decimalDigits
                .inverted)
            .joined(separator: "")
        return intString
    }
    
    func contactPhones(_ contact :Contact) ->  String{
        if contact.phones.count > 0 {
            var phonesString = ""
            for phone in contact.phones {
                if phonesString == "" {
                    phonesString = phonesString + "" + phone
                }else{
                    phonesString = phonesString + ", " + phone
                }
            }
            return phonesString
        }
        return "No phone"
    }
    
    func contactFirstPhones(_ contact :Contact) ->  String{
        if contact.phones.count > 0 {
            let phonesString = contact.phones.first
            return phonesString!
        }
        return ""
    }
    
    func contactEmail(_ contact :Contact) -> String {
        if contact.emails.count > 0 {
            var emailsString = ""
            for email in contact.emails {
                if emailsString == "" {
                    emailsString = emailsString + "" + email
                }else{
                    emailsString = emailsString + ", " + email
                }
            }
            return emailsString
        }
        return "No email"
    }
    
    func contactDetail(_ identifier: String) -> CNContactViewController? {
        do {
            let appconact = try self.store?.unifiedContact(withIdentifier: identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()] )
            let vc = CNContactViewController(for: appconact!)
            CNContactViewController.descriptorForRequiredKeys()
            return vc
        } catch {
            print("error")
            return nil
        }
    }
    
    func getContactsFromAddressBook(){
        self.contacts.removeAll()
        self.contacts.append(contentsOf: ContactManager.shared.contacts)
        self.contacts.sort(by: { (contact1, contact2) -> Bool in
            let name1 = ContactManager.shared.contactName(contact1).uppercased().replacingOccurrences(of: " ", with: "")
            let name2 = ContactManager.shared.contactName(contact2).uppercased().replacingOccurrences(of: " ", with: "")
            return name1.compare(name2) == ComparisonResult.orderedAscending
        })
    }
    
    func allDataContacts(dataSource: [NSDictionary]) -> [Contact]{
        var datas = [Contact]()
        for dic in dataSource {
            let setData: [Contact] = dic["data"] as! [Contact]
            for contact in setData {
                datas.append(contact)
            }
        }
        return datas
    }
    
    func isNoName(_ contact :Contact) -> Bool {
        
        if let _ = contact.firstName, let _ = contact.lastName {
            return false
        }
        
        if (contact.firstName) != nil {
            return false
        }
        if (contact.lastName) != nil {
            return false
        }
        return true
        
    }

    func allSelectionContacts(dataSource: [NSDictionary]) -> [Contact]{
        
        var datas = [Contact]()
        
        for dic in dataSource {
            let setData: [Contact] = dic["data"] as! [Contact]
            for contact in setData {
                if contact.selected {
                    datas.append(contact)
                }
            }
        }
        return datas
    }
    
    func getMissingContacts( _ missingType: ContactType) -> [Contact]{
        let items = self.contacts.filter {[weak self] (contact) -> Bool in
            if missingType == .missingName{
                return self?.isNoName(contact) ?? false
            }
            else if missingType == .missingEmail{
                if contact.emails.count == 0{
                    return true
                }
                return false
            }
            else if missingType == .missingPhone{
                if contact.phones.count == 0{
                    return true
                }
                return false
            }
            return false
        }
        return items
    }
 
    func getDuplicateContacts( _ duplicateType: ContactType) -> [NSDictionary]{
        var datas = [NSDictionary]()
        
        if duplicateType == .duplicateName {
            let dictionary = Dictionary.init(grouping: self.contacts) { (contact) -> String in
                let name = ContactManager.shared.contactName(contact).uppercased().replacingOccurrences(of: " ", with: "")
                return name
            }
            let keys = dictionary.keys
            if keys.count == 0{
                return []
            }
            for item in keys{
                let itemContacts = dictionary[item] ?? []
                if itemContacts.count > 1{
                    let temp = itemContacts[0]
                    if (self.contactName(temp) != "Unnamed contact"){
                        let dic: NSDictionary = ["key": self.contactName(temp), "data": itemContacts]
                        datas.append(dic)
                    }
                }
            }
        }else if duplicateType == .duplicatePhone {
            let dictionary = Dictionary.init(grouping: self.contacts) { [weak self](contact) -> String in
                if contact.phones.count > 0{
                    let phone1 = self?.getNumberFromString(NSString.init(string: contact.phones[0]))
                    return phone1 ?? ""
                }
                return ""
            }
            let keys = dictionary.keys
            if keys.count == 0{
                return []
            }
            for item in keys{
                let itemContacts = dictionary[item] ?? []
                if itemContacts.count > 1{
                    let temp = itemContacts[0]
                    if (self.contactPhones(temp) != "No phone"){
                        let dic: NSDictionary = ["key": self.contactPhones(temp), "data": itemContacts]
                        datas.append(dic)
                    }
                }
            }
        }
            
        else if duplicateType == .duplicateEmail {
            let dictionary = Dictionary.init(grouping: self.contacts) {(contact) -> String in
                if contact.emails.count > 0{
                    var email = contact.emails[0].uppercased().replacingOccurrences(of: " ", with: "")
                    email = email.replacingOccurrences(of: "(", with: "")
                    email = email.replacingOccurrences(of: ")", with: "")
                    email = email.replacingOccurrences(of: "+", with: "")
                    email = email.replacingOccurrences(of: "@", with: "")
                    return email
                }
                return ""
            }
            let keys = dictionary.keys
            if keys.count == 0{
                return []
            }
            for item in keys{
                let itemContacts = dictionary[item] ?? []
                if itemContacts.count > 1{
                    let temp = itemContacts[0]
                    if (self.contactEmail(temp) != "No email"){
                        let dic: NSDictionary = ["key": self.contactEmail(temp), "data": itemContacts]
                        datas.append(dic)
                    }
                }
            }
        }else{
            if duplicateType == .missingPhone
                || duplicateType == .missingEmail
                || duplicateType == .missingName{
                let dic: NSDictionary = ["key": "" , "data": self.getMissingContacts(duplicateType)]
                datas.append(dic)
            }else{
                let dic: NSDictionary = ["key": "" , "data": self.contacts]
                datas.append(dic)
            }
        }
        return datas
    }
}
