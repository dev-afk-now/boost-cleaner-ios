//
//  DuplicateNameVC.swift
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
import ContactsUI
import EzPopup
import CircleProgressView


class DuplicateNameVC: UIViewController ,CNContactViewControllerDelegate{
    
    @IBOutlet var mergeContact: UILabel!
    @IBOutlet var selctToMergelbl: UILabel!
    @IBOutlet var unnamedlbl: UILabel!
    
    
    var  mainDataArryName = [ContactModel]()
    let contactStore = CNContactStore()
    var  duplicatesDataArryName = [DuplicatesModel]()
    var selectedRows:[IndexPath] = []
    var flagselect = false
    var selectedRowsSection:[Int] = []
    let AlterMerge = AlterSuccessMerge.instantiate()
    let Alterdelete = AlterDeleteContact.instantiate()
    let user = SharedData.sharedUserInfo
    @IBOutlet weak var mergebtn: UIButton!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.circleProgressView.trackWidth = 12
        }
        self.makeNavigationBarTransparent()
        popupView.isHidden = false
        self.circleProgressView.progress = Double(0/Double(100))
        self.contactsTableView.reloadData()
        DispatchQueue.main.async { [self] in
            if Utilities.containsRatingEvent(event: ReviewPopupLocation.onContact) {
                Utilities.rateApp(controller: self)
                //AdmobManager.shared.openRateView()
            } else {
                print("Rating pop is not showing")
            }
        }
        performSelector(inBackground: #selector(backgroundthread), with: nil)
        
        // Do any additional setup after loading the view.
    }
    @objc func backgroundthread() {
        duplicatesDataArryName.removeAll()
        
        for i in 0..<mainDataArryName.count {
            DispatchQueue.main.async {
                let value2 = Double(i)
                self.circleProgressView.progress = Double(value2/Double(self.mainDataArryName.count))
                let x = Double(value2/Double(self.mainDataArryName.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.percentageLbl.text = "\(result)" + "%"
            }
            mergeAllDuplicates(ContactArray: mainDataArryName[i].ContactArray!)
            
        }
        DispatchQueue.main.async {
            self.circleProgressView.progress = Double(100/Double(100))
            self.popupView.isHidden = true
            self.contactsTableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Duplicate Name".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        if(selectedRows.isEmpty){
            
            mergebtn.isHidden = true
        }
        else{
            
            mergebtn.isHidden = false
        }
        
        
        
        rightBarButtonItemsSelect()
    }
    func rightBarButtonItemsSelect(){
        
        let rightItem = UIBarButtonItem(title: "Select all".localized, style: .plain, target: self, action: #selector(self.selectAllbtn))
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
    func rightBarButtonItemsUnselect(){
        
        let rightItem = UIBarButtonItem(title: "Deselect all".localized, style: .plain, target: self, action: #selector(self.selectAllbtn))
        if UIDevice.current.userInterfaceIdiom == .pad {
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
        }
        else{
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14  )!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
          //  rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
        }
        
        self.navigationItem.rightBarButtonItems = [rightItem]
        
    }
    @objc func selectAllbtn() {
        print(self.selectedRows)
        if(flagselect){
            self.selectedRows.removeAll()
            self.selectedRowsSection.removeAll()
            flagselect = false
            rightBarButtonItemsSelect()
            //selectedAll.setBackgroundImage(UIImage(named:"unselect_icon"), for: .normal)
            self.selectedRows.removeAll()
            self.contactsTableView.reloadData()
            mergebtn.isHidden = true
            mergebtn.setTitle("MERGE".localized, for: .normal)
        }
        else{
            self.selectedRows.removeAll()
            self.selectedRowsSection.removeAll()
            flagselect = true
            rightBarButtonItemsUnselect()
            // selectedAll.setBackgroundImage(UIImage(named:"select_icon"), for: .normal)
            self.selectedRows = getAllIndexPaths()
            self.selectedRowsSection = getAllIndexPathsSection()
            self.contactsTableView.reloadData()
            if(selectedRows.isEmpty){
                mergebtn.isHidden = true
                mergebtn.setTitle("MERGE".localized, for: .normal)
                
            }
            else{
                mergebtn.isHidden = false
                self.user.deleteValue = (selectedRows.count   - mainDataArryName.count )
                let txt = "MERGE SELECTED".localized
                mergebtn.setTitle("\(txt) (" + "\(selectedRows.count  - mainDataArryName.count )" + ")", for: .normal)
                
                // mergebtn.setTitle("MERGE SELECTED (" + "\(selectedRows.count)" + ")", for: .normal)
                
            }
            
        }
    }
    func createAlertSend (){
        if UIDevice.current.userInterfaceIdiom == .pad {
            //let bounds = UIScreen.main.bounds
            //let width = bounds.size.width
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
            //let bounds = UIScreen.main.bounds
            //let width = bounds.size.width
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
    func removeSingleIndexPathsSection(ind : Int){
        self.selectedRowsSection.remove(at: ind)
    }
    
    func removeSingleIndexPaths(ind : Int) {
        for j in 0..<contactsTableView.numberOfRows(inSection: ind) {
            let selectedIndexPath = IndexPath(row: j, section: ind)
            self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
            
        }
        self.contactsTableView.reloadData()
    }
    
    func addSingleIndexPathsSection(ind : Int){
        var indexPaths: [Int] = []
        indexPaths.append(ind)
        self.selectedRowsSection.append(contentsOf: indexPaths)
        addSingleIndexPaths(ind: ind)
    }
    
    func addSingleIndexPaths(ind : Int) {
        var indexPaths: [IndexPath] = []
        for j in 0..<contactsTableView.numberOfRows(inSection: ind) {
            indexPaths.append(IndexPath(row: j, section: ind))
        }
        self.selectedRows.append(contentsOf: indexPaths)
        self.contactsTableView.reloadData()
    }
    func getAllIndexPathsSection() -> [Int] {
        var indexPaths: [Int] = []
        for i in 0..<duplicatesDataArryName.count {
            indexPaths.append(i)
        }
        return indexPaths
    }
    func getAllIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for i in 0..<duplicatesDataArryName.count {
            for j in 0..<contactsTableView.numberOfRows(inSection: i) {
                indexPaths.append(IndexPath(row: j, section: i))
            }
        }
        return indexPaths
    }
    
    @IBOutlet var contactsTableView: UITableView!{
        didSet {
            contactsTableView.delegate = self
            contactsTableView.dataSource = self
        }
    }
    @IBAction func mergeBtnAction(_ sender: UIButton) {
        let inAppSpot = EventManager.shared.inAppLocations
        if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onContactsDuplicateName) {
            Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onContactsDuplicateName)
        } else {
            deleteAlert()
        }
    }
    func deleteAlert (){
        if UIDevice.current.userInterfaceIdiom == .pad {
            print( self.user.deleteValue)
            self.user.deleteflg = false
            guard let pickerVC = Alterdelete else { return }
            pickerVC.delegate = self
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 550, popupHeight: 310)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            present(popupVC, animated: true, completion: nil)
        }
        else{
            print( self.user.deleteValue)
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
    func confirmedMerge() {
        for k in 0..<selectedRowsSection.count  {
            for i in 0..<duplicatesDataArryName[selectedRowsSection[k]].ContactArray!.count  {
                
                let contact = duplicatesDataArryName[selectedRowsSection[k]].ContactArray![i]
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                
                
                deleteContact(mutableContact ) { (result) in
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
            
            let contact = duplicatesDataArryName[selectedRowsSection[k]].MergeArray!
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            
            
            addContact(mutableContact ) { (result) in
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {            self.navigationController?.popViewController(animated: true)
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
                
                
                print(dataArry.givenName)
                print(dataArry.familyName)
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
            
            self.duplicatesDataArryName.append(DuplicatesModel( ContactArray :ContactArray, MergeArray: newContact ))
            
            // ContactArray2 = [newContact]
            
        }
        
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
extension DuplicateNameVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return duplicatesDataArryName.count
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return  duplicatesDataArryName[section].ContactArray!.count
        
        
    }
    @objc func doneButtonClicked(_ button:UIBarButtonItem!){
        self.dismiss(animated: true, completion: nil)
       // self.navigationController?.popViewController(animated: true)
        
        print("Done clicked")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = self.contactsTableView.dequeueReusableCell(withIdentifier: "AllContactsCell", for: indexPath) as! AllContactsCell
        var dataArry = duplicatesDataArryName[indexPath.section].ContactArray![indexPath.row]
        
        if !dataArry.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                dataArry = try self.contactStore.unifiedContact(withIdentifier: dataArry.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        cell.cellView.dropShadow()
        cell.maincellView.layer.cornerRadius = 0
        cell.maincellView.layer.masksToBounds = true
        cell.maincellView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        if(duplicatesDataArryName[indexPath.section].ContactArray!.count == indexPath.row+1){
            cell.maincellView.isHidden = false
            cell.maincellView.layer.roundCorners([.leftBottom,.rightBottom], corner: 15)
            
        }
        //        cell.cellView.dropShadow()
        //        // cell.maincellView.isHidden = true
        //        cell.maincellView.roundCorners([.bottomLeft, .bottomRight], radius: 0)
        //        if(duplicatesDataArryName[indexPath.section].ContactArray!.count == indexPath.row+1){
        //            cell.maincellView.isHidden = false
        //            cell.maincellView.roundCorners([.bottomLeft, .bottomRight], radius: 15)
        //        }
        if(dataArry.phoneNumbers.first?.value.stringValue == nil){
            cell.numberlbl.text = "No phone".localized
        }
        else{
            cell.numberlbl.text = dataArry.phoneNumbers.first?.value.stringValue
            
        }
        // cell.numberlbl.text = dataArry.phoneNumbers.first?.value.stringValue
        //  cell.namelbl.text = dataArry.givenName + " " + dataArry.familyName
        
        if(dataArry.givenName == "" &&  dataArry.familyName == ""){
            cell.namelbl.text = "Unnamed contact".localized
            
        }
        else{
            cell.namelbl.text = dataArry.givenName + " " + dataArry.familyName
        }
        // cell.selectedCell.isHidden = true
        if selectedRows.contains(indexPath)
        {
            //  cell.selectedCell.isHidden = false
            cell.selectedCell.setBackgroundImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            // cell.selectedCell.isHidden = true
            cell.selectedCell.setBackgroundImage(UIImage(named:"checkbox_unselect_ic"), for: .normal)
        }
        //        cell.selectedCell.tag = indexPath.row
        //        cell.selectedCell.addTarget(self, action: #selector(checkBoxSelection(_:)), for: .touchUpInside)
        //
        
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    @objc func checkBoxSelection(_ sender:UIButton)
    {
        let selectedIndexPath = IndexPath(row: sender.tag, section: 0)
        if self.selectedRows.contains(selectedIndexPath)
        {
            self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
        }
        else
        {
            self.selectedRows.append(selectedIndexPath)
        }
        
        if(selectedRows.isEmpty){
            
            mergebtn.isHidden = true
            mergebtn.setTitle("MERGE".localized, for: .normal)
        }
        else{
            
            mergebtn.isHidden = false
            self.user.deleteValue = (selectedRows.count )
            let txt = "MERGE SELECTED".localized
            mergebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .normal)
        }
        self.contactsTableView.reloadData()
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.title = ""
            self.navigationItem.setHidesBackButton(false, animated: false)
            var contact = self.duplicatesDataArryName[indexPath.section].ContactArray![indexPath.row]
            if !contact.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
                do {
                    contact = try self.contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
                }
                catch { }
            }
            let contactViewController = CNContactViewController(for: contact)
            
            
            contactViewController.contactStore = CNContactStore()
            contactViewController.allowsEditing = true
            contactViewController.allowsActions = true
            contactViewController.delegate = self
            let barButtonItem = UIBarButtonItem(title: "Close".localized, style: .plain, target: self, action: #selector(self.doneButtonClicked(_:)))
            contactViewController.navigationItem.backBarButtonItem = barButtonItem
          
            UINavigationBar.appearance().tintColor =  self.hexStringToUIColor(hex: "#062549")
       
            if #available(iOS 13.0, *) {
                // use the feature only available in iOS 9
                // for ex. UIStackView
            } else {
                UINavigationBar.appearance().backgroundColor =  self.hexStringToUIColor(hex: "#062549")
                // or use some work around
            }
            
            let navigationVC = UINavigationController(rootViewController: contactViewController)
            
            navigationVC.modalPresentationStyle = .fullScreen
            self.present(navigationVC, animated: true, completion: nil)
            
            
            
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "SimilarHeaderCell") as! SimilarHeaderCell
        
        var dataArry = duplicatesDataArryName[section].MergeArray!
        
        if !dataArry.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                dataArry = try self.contactStore.unifiedContact(withIdentifier: dataArry.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        headerCell.maincellView.layer.cornerRadius = 15
        headerCell.maincellView.layer.masksToBounds = true
        headerCell.maincellView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        // headerCell.maincellView.roundCorners([.topLeft, .topRight], radius: 15)
        //headerCell.maincellView.dropShadow()
        headerCell.cellView.dropShadow()
        
        if self.selectedRowsSection.contains(section){
            headerCell.selectedContacts.setTitle("Deselect".localized, for: .normal)
        }
        else{
            headerCell.selectedContacts.setTitle("Select".localized, for: .normal)
        }
        if(dataArry.phoneNumbers.first?.value.stringValue == nil){
            headerCell.numberlbl.text = "No phone".localized
        }
        else{
            headerCell.numberlbl.text = dataArry.phoneNumbers.first?.value.stringValue
            
        }
        // cell.numberlbl.text = dataArry.phoneNumbers.first?.value.stringValue
        //  cell.namelbl.text = dataArry.givenName + " " + dataArry.familyName
        
        if(dataArry.givenName == "" &&  dataArry.familyName == ""){
            headerCell.namelbl.text = "Unnamed contact".localized
            
        }
        else{
            headerCell.namelbl.text = dataArry.givenName + " " + dataArry.familyName
        }
        
        
        headerCell.selectedHeader.tag = section
        headerCell.selectedHeader.addTarget(self, action: #selector(headerSelection(_:)), for: .touchUpInside)
        
        headerCell.selectedContacts.tag = section
        headerCell.selectedContacts.addTarget(self, action: #selector(addremoveSelection(_:)), for: .touchUpInside)
        return headerCell
    }
    @objc func addremoveSelection(_ sender:UIButton){
        let selectedIndexPath = sender.tag
        print(self.selectedRowsSection)
        print(selectedIndexPath)
        print(self.selectedRows)
        if self.selectedRowsSection.contains(selectedIndexPath)
        {
            // removeSingleIndexPaths(ind: selectedIndexPath)
            print(selectedRowsSection.whatFunction(selectedIndexPath)[0])
            
            removeSingleIndexPathsSection(ind: selectedRowsSection.whatFunction(selectedIndexPath)[0])
            removeSingleIndexPaths(ind: selectedIndexPath)
            // self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
        }
        else
        {
            addSingleIndexPathsSection(ind: selectedIndexPath)
            //  self.selectedRows.append(selectedIndexPath)
        }
        
        if(selectedRows.isEmpty){
            
            mergebtn.isHidden = true
            mergebtn.setTitle("MERGE".localized, for: .normal)
        }
        else{
            let txt = "MERGE SELECTED".localized
            mergebtn.isHidden = false
            self.user.deleteValue = (selectedRows.count   - selectedRowsSection.count )
            mergebtn.setTitle("\(txt) (" + "\(selectedRows.count - selectedRowsSection.count)" + ")", for: .normal)
        }
        
        
        
        
    }
    @objc func headerSelection(_ sender:UIButton)
    {
        let selectedIndexPath = sender.tag
        DispatchQueue.main.async {
            self.title = ""
            self.navigationItem.setHidesBackButton(false, animated: false)
            var contact = self.duplicatesDataArryName[selectedIndexPath].MergeArray!
            if !contact.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
                do {
                    contact = try self.contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
                }
                catch { }
            }
            let contactViewController = CNContactViewController(for: contact)
            
            
            contactViewController.contactStore = CNContactStore()
            contactViewController.allowsEditing = true
            contactViewController.allowsActions = true
            contactViewController.delegate = self
            let barButtonItem = UIBarButtonItem(title: "Close".localized, style: .plain, target: self, action: #selector(self.doneButtonClicked(_:)))
            contactViewController.navigationItem.backBarButtonItem = barButtonItem
          
            UINavigationBar.appearance().tintColor =  self.hexStringToUIColor(hex: "#062549")
       
            if #available(iOS 13.0, *) {
                // use the feature only available in iOS 9
                // for ex. UIStackView
            } else {
                UINavigationBar.appearance().backgroundColor =  self.hexStringToUIColor(hex: "#062549")
                // or use some work around
            }
            
            let navigationVC = UINavigationController(rootViewController: contactViewController)
            
            navigationVC.modalPresentationStyle = .fullScreen
            self.present(navigationVC, animated: true, completion: nil)
            
            
            
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 166
        }
        else{
            return 83
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 326
        }
        else{
            return 163
        }
    }
    
    
    
}

extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
extension DuplicateNameVC: AlterDeleteDelegate {
    func AlterViewController(sender: AlterDeleteContact, didSelectNumber number: Int) {
        dismiss(animated: true) {
            
            if(number == 1){
                
                self.confirmedMerge()
            }
            
        }
    }
    
}
