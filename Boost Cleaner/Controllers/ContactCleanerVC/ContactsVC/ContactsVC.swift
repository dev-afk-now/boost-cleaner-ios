//
//  ContactsVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/23/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import SwiftyContacts
import Foundation
import Contacts
import CoreTelephony
import StoreKit
import ContactsUI
import IHProgressHUD
import CircleProgressView
import EzPopup

class ContactsVC: UIViewController {
    
    @IBOutlet weak var lblAutoBackup: UILabel!
    @IBOutlet var allContlbl: UILabel!
    @IBOutlet var DuplicateNamelbl: UILabel!
    @IBOutlet var missinglbl: UILabel!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet var allContactlbl: UILabel!
    @IBOutlet var dupContactlbl: UILabel!
    @IBOutlet var missingContactlbl: UILabel!
    @IBOutlet var backupContactbtn: UIButton!
    @IBOutlet weak var switchbtn: UISwitch!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var popupView2: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    let Alterdelete = AlterDeleteContact.instantiate()
    let user = SharedData.sharedUserInfo
    let contactStore = CNContactStore()
    var allContactArray: [CNContact] = []
    var selectedRowsSection:[Int] = []
    
    var datas: [Backup] = []
    var noEmailsArray: [CNContact] = []
    var noPhonesArray: [CNContact] = []
    var noNameArray: [CNContact] = []
    
    var duplicatePhone = 0
    var duplicateName = 0
    var duplicateEmail = 0
    
    
    var  SimilarContactArrayPhone = [String: [CNContact]]()
    var  ContactArrayPhone = [[CNContact]]()
    var  mainDataArryPhone = [ContactModel]()
    var  allmainDataArryContacts = [ContactModel]()
    var  allduplicatesDataArry = [DuplicatesModel]()
    var  SimilarContactArrayName = [String: [CNContact]]()
    var  ContactArrayName = [[CNContact]]()
    var  mainDataArryName = [ContactModel]()
    
    var  SimilarContactArrayEmail = [String: [CNContact]]()
    var  ContactArrayEmail = [[CNContact]]()
    var  mainDataArryEmail = [ContactModel]()
    let AlterMerge = AlterSuccessMerge.instantiate()
    
    //MARK:- ViewLife Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact Cleaner".localized
        self.allContlbl.text = "All Contacts".localized
        self.DuplicateNamelbl.text = "Duplicate Contacts".localized
        self.missinglbl.text = "Missing Information".localized
        self.lblAutoBackup.text = "Auto-Backup".localized
        self.backupContactbtn.setTitle("\("AUTO MERGE CONTACTS".localized) (" + "0" + ")", for: .normal)
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        
        firstView.dropShadow()
        secondView.dropShadow()
        thirdView.dropShadow()
        rightBarButtonItemsSelect()
        
        if (UserDefaults.standard.bool(forKey: "backup")) {
            self.switchbtn.setOn(true, animated: false)
            self.reloadDataBackup()
        } else {
            self.switchbtn.setOn(false, animated: false)
        }
        
        switchbtn.addTarget(self, action:#selector(self.SwitchValueChanged(_:)), for: .valueChanged)
        
        let contactStatus = CNContactStore.authorizationStatus(for: .contacts)
        if (contactStatus != .authorized) {
            Utilities.showAlert(title: "Contacts Access Disabled".localized, message: "turn on Contacts Access for this app.".localized, parentController: self, delegate: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        duplicatePhone = 0
        duplicateName = 0
        duplicateEmail = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            self.FetchAllNumber()
            self.fetchContactsWithNoName()
            self.FetchNophone ()
            self.fetchContactsWithNoEmail()
            self.FetchSimilarPhone()
            self.FetchSimilarNames()
            self.FetchSimilarEmail()
            self.missingContactlbl.text = "\(noEmailsArray.count+noPhonesArray.count+noNameArray.count)" + " items".localized
            
        }
        
        ContactManager.shared.loadContacts { _ in
        }
    }
    func reloadDataBackup(){
        datas = DataManager.shared.getAllBackup()
        if(datas.isEmpty){
            DispatchQueue.main.async {
                self.popupView.isHidden = false
                UserDefaults.standard.set(true, forKey: "backup")
                IHProgressHUD.show(withStatus: "Backing Up".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.BackupContacts()
                }
            }
        }
        else{
            
//            let currentDateTime = Date()
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let date1 = dateFormatter.date(from: (currentconvertDateFormater("\(currentDateTime)")))
//            let date2 = dateFormatter.date(from: (convertDateFormater(datas[0].date)))
//
//            if(date1!.isGreaterThan(date2!)){
                DispatchQueue.main.async {
                    self.popupView.isHidden = false
                    UserDefaults.standard.set(true, forKey: "backup")
                    IHProgressHUD.show(withStatus: "Backing Up".localized)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.BackupContacts()
                    }
                }
                
            //}
            
            
        }
    }
    func currentconvertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return  dateFormatter.string(from: date!)
        
    }
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return  dateFormatter.string(from: date!)
        
    }
    
    
    @objc func SwitchValueChanged(_ sender : UISwitch!){
        
        if sender.isOn {
            DispatchQueue.main.async {
                self.popupView.isHidden = false
                UserDefaults.standard.set(true, forKey: "backup")
                IHProgressHUD.show(withStatus: "Backing Up".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.BackupContacts()
                }
            }
        } else {
            UserDefaults.standard.set(false, forKey: "backup")
        }
        
        
    }
    
    @IBAction func allContactsButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AllContactsVC") as? AllContactsVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func missingInfoContactsButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MissingContactsVC") as? MissingContactsVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func duplicateContactsButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DuplicateContactsVC") as? DuplicateContactsVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func backupContactsButtonPressed(_ sender: UIButton) {
        //  deleteAlert()
        datas = DataManager.shared.getAllBackup()
        if(datas.isEmpty){
            let alertController = UIAlertController(title: "Back Up Now".localized, message: "Would you like to take back up your contacts before auto merging?".localized, preferredStyle: .alert)
            let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "SFRounded-Bold", size: 21)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let titleString = NSAttributedString(string: "Back Up Now".localized, attributes: titleAttributes)
            let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let messageString = NSAttributedString(string: "Would you like to take back up your contacts before auto merging?".localized, attributes: messageAttributes)
            alertController.setValue(titleString, forKey: "attributedTitle")
            alertController.setValue(messageString, forKey: "attributedMessage")
            
            
            let okAction = UIAlertAction(title: "YES".localized, style: .default) { (action) in
                IHProgressHUD.show(withStatus: "Backing Up".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.BackupContacts()
                    self.deleteAlert()
                }
                
                
            }
            
            let cancelAction = UIAlertAction(title: "NO".localized, style: .default) { (action) in
                self.deleteAlert()
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            self.deleteAlert()
        }
    }
    func deleteAlert (){
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.user.deleteflg = false
            guard let pickerVC = Alterdelete else { return }
            pickerVC.delegate = self
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 600, popupHeight: 300)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            present(popupVC, animated: true, completion: nil)
        }
        else{
            self.user.deleteflg = false
            guard let pickerVC = Alterdelete else { return }
            pickerVC.delegate = self
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 300, popupHeight: 200)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            present(popupVC, animated: true, completion: nil)
        }
        
    }
    @objc func backgroundthread() {
        DispatchQueue.main.async {
            self.popupView.isHidden = false
            IHProgressHUD.show(withStatus: "Backing Up".localized)
        }
        print(mainDataArryEmail.count)
        print(mainDataArryPhone.count)
        print(mainDataArryName.count)
        self.allmainDataArryContacts = mainDataArryEmail + mainDataArryPhone + mainDataArryName
        for i in 0..<allmainDataArryContacts.count {
            //            DispatchQueue.main.async {
            //                let value2 = (Double(i)/3)
            //                self.circleProgressView.progress = Double(value2/Double(self.allmainDataArryContacts.count))
            //                let x = Double(value2/Double(self.allmainDataArryContacts.count))
            //                let y = Double(round(100*x)/100)
            //                let result = Int(y * 100)
            //                self.percentageLbl.text = "\(result)" + "%"
            //            }
            mergeAllDuplicates(ContactArray: allmainDataArryContacts[i].ContactArray!)
        }
        DispatchQueue.main.async { [self] in
            self.selectedRowsSection = self.getAllIndexPathsSection()
            
            
            self.confirmedMerge()
            duplicatePhone = 0
            duplicateName = 0
            duplicateEmail = 0
            FetchSimilarPhone()
            FetchSimilarNames()
            FetchSimilarEmail()
        }
        
        
    }
    
    func getAllIndexPathsSection() -> [Int] {
        var indexPaths: [Int] = []
        for i in 0..<allduplicatesDataArry.count {
            indexPaths.append(i)
        }
        return indexPaths
    }
    
    func confirmedMerge() {
        for k in 0..<selectedRowsSection.count  {
            DispatchQueue.main.async {
                let value2 = (Double(k)*3)
                self.circleProgressView.progress = Double(value2/Double(self.allmainDataArryContacts.count))
                
                if self.allmainDataArryContacts.count > 0 {
                    let x = Double(value2/Double(self.allmainDataArryContacts.count))
                    let y = Double(round(100*x)/100)
                    let result = Int(y * 100)
                    
                    self.percentageLbl.text = "\(result)" + "%"
                }
            }
            
            for i in 0..<allduplicatesDataArry[selectedRowsSection[k]].ContactArray!.count  {
                let contact = allduplicatesDataArry[selectedRowsSection[k]].ContactArray![i]
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                
                deleteContact(Contact: mutableContact ) { (result) in
                    switch result{
                    case .success(response: let bool):
                        if bool{
                            print("Contact Sucessfully Deleted")
                            
                            
                            // self.dismiss(animated: true, completion: nil)
                            
                            //self.deleteArray.append(self.selectedRows[i].row)
                            
                        }
                        break
                    case .failure(error: let error):
                        print(error.localizedDescription)
                        break
                    }
                }
            }
            
        }
        for k in 0..<selectedRowsSection.count  {
            
            let contact = allduplicatesDataArry[selectedRowsSection[k]].MergeArray!
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            
            
            addContact(Contact: mutableContact ) { (result) in
                switch result{
                case .success(response: let bool):
                    if bool{
                        print("Contact Sucessfully add")
                        
                        
                        
                    }
                    break
                case .failure(error: let error):
                    print(error.localizedDescription)
                    break
                }
            }
            
        }
        createAlertSend()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.popupView.isHidden = true
            IHProgressHUD.dismiss()
            // self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    func createAlertSend (){
        if UIDevice.current.userInterfaceIdiom == .pad {
            let bounds = UIScreen.main.bounds
            let width = bounds.size.width
            guard let pickerVC = AlterMerge else { return }
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 400, popupHeight: 375)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            present(popupVC, animated: true, completion: nil)
        }
        else{
            let bounds = UIScreen.main.bounds
            let width = bounds.size.width
            guard let pickerVC = AlterMerge else { return }
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 300, popupHeight: 325)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            present(popupVC, animated: true, completion: nil)
        }
        
    }
    func mergeAllDuplicates(ContactArray : [CNContact]) {
        
        
        let duplicates: [Array<CNContact>] = [ContactArray]
        
        
        
        for item in duplicates {
            
            
            // CNCONTACT PROPERTIES
            
            var namePrefix: [String] = [String]()
            var givenName: [String] = [String]()
            var middleName: [String] = [String]()
            var familyName: [String] = [String]()
            var previousFamilyName: [String] = [String]()
            var nameSuffix: [String] = [String]()
            var nickname: [String] = [String]()
            var organizationName: [String] = [String]()
            var departmentName: [String] = [String]()
            var jobTitle: [String] = [String]()
            var phoneNumberslbl: [String] = [String]()
            
            var phoneNumbers: [CNPhoneNumber] = [CNPhoneNumber]()
            var emailAddresses: [NSString] = [NSString]()
            var emailAddresseslbl: [String] = [String]()
            
            var postalAddresses: [CNPostalAddress] = [CNPostalAddress]()
            var urlAddresses: [NSString] = [NSString]()
            
            var contactRelations: [CNContactRelation] = [CNContactRelation]()
            var socialProfiles: [CNSocialProfile] = [CNSocialProfile]()
            var instantMessageAddresses: [CNInstantMessageAddress] = [CNInstantMessageAddress]()
            
            var flg = true
            // Filter
            for items in item {
                
                var dataArry = items
                if !dataArry.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
                    do {
                        dataArry = try self.contactStore.unifiedContact(withIdentifier: dataArry.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
                    }
                    catch { }
                }
                
                
//                print(dataArry.givenName)
//                print(dataArry.familyName)
                if(flg){
                    namePrefix.append(dataArry.namePrefix)
                    givenName.append(dataArry.givenName)
                    middleName.append(dataArry.middleName)
                    familyName.append(dataArry.familyName)
                    flg = false
                }
                previousFamilyName.append(dataArry.previousFamilyName)
                nameSuffix.append(dataArry.nameSuffix)
                nickname.append(dataArry.nickname)
                organizationName.append(dataArry.organizationName)
                departmentName.append(dataArry.departmentName)
                jobTitle.append(dataArry.jobTitle)
                
                for number in dataArry.phoneNumbers {
                    phoneNumbers.append(number.value)
                    phoneNumberslbl.append(number.label ?? "")
                }
                for email in dataArry.emailAddresses {
                    emailAddresses.append(email.value)
                    emailAddresseslbl.append(email.label ?? "")
                }
                for postal in dataArry.postalAddresses {
                    postalAddresses.append(postal.value)
                }
                for url in dataArry.urlAddresses {
                    urlAddresses.append(url.value)
                }
                for relation in dataArry.contactRelations {
                    contactRelations.append(relation.value)
                }
                for social in dataArry.socialProfiles {
                    socialProfiles.append(social.value)
                }
                for message in dataArry.instantMessageAddresses {
                    instantMessageAddresses.append(message.value)
                }
                
            }
            
            let newContact = CNMutableContact()
            newContact.namePrefix = Array(Set(namePrefix))[0]
            newContact.givenName = Array(Set(givenName))[0]
            newContact.middleName = Array(Set(middleName))[0]
            newContact.familyName = Array(Set(familyName))[0]
            newContact.previousFamilyName = Array(Set(previousFamilyName))[0]
            newContact.nameSuffix = Array(Set(nameSuffix))[0]
            newContact.nickname = Array(Set(nickname))[0]
            newContact.organizationName = Array(Set(namePrefix))[0]
            newContact.departmentName = Array(Set(namePrefix))[0]
            newContact.jobTitle = Array(Set(namePrefix))[0]
            for item in Array(Set(phoneNumbers)) {
                
                if("_$!<Home>!$_" == phoneNumberslbl[phoneNumbers.firstIndex(of: item)!]){
                    newContact.phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: item))
                }
                else if("_$!<Work>!$_" == phoneNumberslbl[phoneNumbers.firstIndex(of: item)!]){
                    newContact.phoneNumbers.append(CNLabeledValue(label: CNLabelWork, value: item))
                }
                else if("_$!<School>!$_" == phoneNumberslbl[phoneNumbers.firstIndex(of: item)!]){
                    if #available(iOS 13.0, *) {
                        newContact.phoneNumbers.append(CNLabeledValue(label: CNLabelSchool, value: item))
                    } else {
                        newContact.phoneNumbers.append(CNLabeledValue(label: CNLabelOther, value: item))
                        
                        // Fallback on earlier versions
                    }
                }
                else{
                    newContact.phoneNumbers.append(CNLabeledValue(label: CNLabelOther, value: item))
                    
                }
            }
            for item in Array(Set(emailAddresses)) {
                
                newContact.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
                
                if("_$!<Home>!$_" == emailAddresseslbl[emailAddresses.firstIndex(of: item)!]){
                    newContact.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
                }
                else if("_$!<Work>!$_" == emailAddresseslbl[emailAddresses.firstIndex(of: item)!]){
                    newContact.emailAddresses.append(CNLabeledValue(label: CNLabelWork, value: item))
                }
                else if("_$!<School>!$_" == emailAddresseslbl[emailAddresses.firstIndex(of: item)!]){
                    if #available(iOS 13.0, *) {
                        newContact.emailAddresses.append(CNLabeledValue(label: CNLabelSchool, value: item))
                    } else {
                        newContact.emailAddresses.append(CNLabeledValue(label: CNLabelOther, value: item))
                        
                        // Fallback on earlier versions
                    }
                }
                else{
                    newContact.emailAddresses.append(CNLabeledValue(label: CNLabelOther, value: item))
                    
                }
                
            }
            for item in Array(Set(postalAddresses)) {
                newContact.postalAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
            }
            for item in Array(Set(urlAddresses)) {
                newContact.urlAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
            }
            for item in Array(Set(contactRelations)) {
                newContact.contactRelations.append(CNLabeledValue(label: CNLabelHome, value: item))
            }
            for item in Array(Set(socialProfiles)) {
                newContact.socialProfiles.append(CNLabeledValue(label: CNLabelHome, value: item))
            }
            for item in Array(Set(instantMessageAddresses)) {
                newContact.instantMessageAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
            }
            
            // print( newContact)
            
            self.allduplicatesDataArry.append(DuplicatesModel( ContactArray :ContactArray, MergeArray: newContact ))
            
            // ContactArray2 = [newContact]
            
        }
        
    }
    func rightBarButtonItemsSelect(){
        
        let rightItem = UIBarButtonItem(title: "All Backups".localized, style: .plain, target: self, action: #selector(self.historybtn))
        if UIDevice.current.userInterfaceIdiom == .pad {
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
        }
        else{
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14  )!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
          //  rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
        }
        
        self.navigationItem.rightBarButtonItem = rightItem
        
    }
    
    @objc func historybtn() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BackupHistory") as? BackupHistory
        self.navigationController?.pushViewController(vc!, animated: true)
        
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
//        print(duplicates.keys)
//        print(duplicates.values)
        
        
        SimilarContactArrayEmail.removeAll()
        mainDataArryEmail.removeAll()
        ContactArrayEmail.removeAll()
        SimilarContactArrayEmail =  duplicates
        
        for (key, array) in SimilarContactArrayEmail
        {
           // print( key)
           // print( array.count)
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
        
        self.dupContactlbl.text = "\((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))" + " items".localized
        self.user.deleteValue = ((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))
        let txt = "AUTO MERGE CONTACTS".localized
        self.backupContactbtn.setTitle("\(txt) (" + "\((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))" + ")", for: .normal)
        
    }
    func BackupContacts(){
        if ContactManager.shared.contacts.count == 0 {
            DispatchQueue.main.async {
                self.popupView.isHidden = true
                IHProgressHUD.dismiss()
            }
            let alert = AlertView.prepare(title: "Alert".localized, message:"You can not back up with empty contact!".localized, okAction: nil)
            self.present(alert, animated: true, completion: nil)
            
            // self.showError(message: "You can not back up with empty contact!")
            return
        }
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        
        let backup = Backup.init(numberContact: ContactManager.shared.contacts.count, date: dateString)
        if  self.createBackgup(id: backup.id) {
            DataManager.shared.addBackup(backup: backup)
            print(self.datas.count)
            self.reloadData()
        }
        
    }
    func reloadData(){
        datas = DataManager.shared.getAllBackup()
        // self.tableView.reloadData()
        //  self.switchbtn.setOn(false, animated: false)
        DispatchQueue.main.async {
            self.popupView.isHidden = true
            IHProgressHUD.dismiss()
            self.showSimpleActionSheet(controller: self, title: "", message: "")
        }
    }
    func createBackgup(id: String) -> Bool{
        let fileLocation = FilePaths.backupPath(id: id)
        var contacts: [CNContact] = []
        for contact in ContactManager.shared.contacts{
            let appconact = try? ContactManager.shared.store.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()] )
            if  let appconact = appconact {
                contacts.append(appconact)
            }
        }
        let contactData = try? CNContactVCardSerialization.data(with: contacts)
        if let contactData = contactData{
            do {
                _ = try contactData.write(to: fileLocation, options: .atomic)
                return true
            } catch let error {
                print(error)
                let alert = AlertView.prepare(title: "Alert".localized, message:error.localizedDescription, okAction: nil)
                self.present(alert, animated: true, completion: nil)
                //  self.showError(message: error.localizedDescription)
                return false
            }
        }
        return false
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
        
        self.dupContactlbl.text = "\((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))" + " items".localized
        self.user.deleteValue = ((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))
        let txt = "AUTO MERGE CONTACTS".localized
        self.backupContactbtn.setTitle("\(txt) (" + "\((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))" + ")", for: .normal)
        
        
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
        self.dupContactlbl.text = "\((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))" + " items".localized
        self.user.deleteValue = ((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))
        let txt = "AUTO MERGE CONTACTS".localized
        self.backupContactbtn.setTitle("\(txt) (" + "\((duplicateEmail+duplicateName+duplicatePhone) - ( mainDataArryPhone.count+mainDataArryName.count+mainDataArryEmail.count))" + ")", for: .normal)
        //  similarPhoneTable.reloadData()
        
        // var similarPhonesArray: [CNContact] = []
        // var similarNameArray: [CNContact] = []
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
        
        
        //   noEmaillbl.text = "(" + "\(results.count)" + ")"
        self.noEmailsArray = results
        
        
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
    }
    
    func FetchAllNumber(){
        fetchContacts(completionHandler: { (result) in
            switch result{
            case .success(response: let contacts):
                print(contacts.count)
                self.allContactArray = contacts
                self.allContactlbl.text = "\(contacts.count)" + " items".localized
                
                //   findDuplicateContacts()
                // Do your thing here with [CNContacts] array
                break
            case .failure(error: let error):
                print(error)
                break
            }
        })
        
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

extension UIViewController{
    //MARK:- Alert Controller
    func showSimpleActionSheet(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let newWidth = UIScreen.main.bounds.width * 0.2
        // Adding constraint for alert base view
        let widthConstraint = NSLayoutConstraint(item: alert.view as Any,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: newWidth)
        let heightConstraint = NSLayoutConstraint(item: alert.view as Any,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: newWidth)
        alert.view.addConstraint(widthConstraint)
        alert.view.addConstraint(heightConstraint)
        
        let image = UIImageView(image: UIImage(named: "checkMark"))
        alert.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: alert.view, attribute: .centerX, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: alert.view, attribute: .centerY, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        
        
        self.present(alert, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
}

extension ContactsVC: AlterDeleteDelegate {
    func AlterViewController(sender: AlterDeleteContact, didSelectNumber number: Int) {
        dismiss(animated: true) { [self] in
            
            if(number == 1){
                
                performSelector(inBackground: #selector(backgroundthread), with: nil)
            }
            else{
                self.selectedRowsSection.removeAll()
                print("Cancel Event")
            }
            
        }
    }
}

extension ContactsVC: AlterLocationContactDelegate {

    func AlterViewController(sender: AlterLocationContact, didSelectNumber number: Int) {
        dismiss(animated: true) {
            if (number == 1) {
                Utilities.openAppSetting()
            }
        }
    }
}
