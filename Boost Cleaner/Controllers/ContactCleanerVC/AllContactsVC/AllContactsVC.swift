//
//  AllContactsVC.swift
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
import ContactsUI
import EzPopup


class AllContactsVC: UIViewController ,CNContactViewControllerDelegate{
    var allContactArray: [CNContact] = []
    var selectedRows:[IndexPath] = []
    var deleteArray = [Int]()
    let contactStore = CNContactStore()
    var flagselect = false
    let Alterdelete = AlterDeleteContact.instantiate()
    let user = SharedData.sharedUserInfo
    
    @IBOutlet weak var deletebtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeNavigationBarTransparent()
        rightBarButtonItemsSelect()
        //  allcontactsTableView.dropShadow()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var allcontactsTableView: UITableView!{
        didSet {
            allcontactsTableView.delegate = self
            allcontactsTableView.dataSource = self
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "All Contacts".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        FetchAllNumber()
        if(selectedRows.isEmpty){
            
            deletebtn.isHidden = true
        }
        else{
            
            deletebtn.isHidden = false
        }
        NotificationCenter.default.addObserver(self,selector: #selector(activeMethod),name:UIApplication.didBecomeActiveNotification, object: nil)
        //
        
    }
    @objc func activeMethod(){
        FetchAllNumber()
        
    }
    @IBAction func deleteBtnAction(_ sender: UIButton) {
        deleteAlert()
    }
    func deleteAlert (){
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.user.deleteValue = selectedRows.count
            print( self.user.deleteValue)
            self.user.deleteflg = true
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
            self.user.deleteValue = selectedRows.count
            print( self.user.deleteValue)
            self.user.deleteflg = true
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
    
    func confirmedDelete() {
        self.deleteArray.removeAll()
        
        for i in 0..<selectedRows.reversed().count {
            
            let contact = allContactArray[selectedRows[i].row]
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            
            
            deleteContact(Contact: mutableContact ) { (result) in
                switch result{
                case .success(response: let bool):
                    if bool{
                        print("Contact Sucessfully Deleted")
                        self.deleteArray.append(self.selectedRows[i].row)
                        
                    }
                    break
                case .failure(error: let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
        
        deleteArray.sort(by: { $1 < $0 })
        
        for index in deleteArray
        {
            // arr.removeAtIndex(index)
            self.allContactArray.remove(at:  index)
            self.allcontactsTableView.reloadData()
        }
        
        
        self.selectedRows.removeAll()
        if(selectedRows.isEmpty){
            flagselect = false
            
            deletebtn.setTitle("DELETE".localized, for: .normal)
            deletebtn.setTitle("DELETE".localized, for: .selected)
            deletebtn.setTitle("DELETE".localized, for: .highlighted)
            
            deletebtn.isHidden = true
            rightBarButtonItemsSelect()
            
            
        }
        else{
            let locaText = "DELETE SELECTED".localized
            
            flagselect = true
            
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .normal)
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .selected)
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .highlighted)
            
            deletebtn.isHidden = false
            rightBarButtonItemsUnselect()
            
            
        }
    }
    func FetchAllNumber(){
        fetchContacts(completionHandler: { (result) in
            switch result{
            
            case .success(response: let contacts):
                print(contacts.count)
                self.allContactArray = contacts.sorted { (a, b) -> Bool in
                    if (a.givenName+a.familyName).isEmpty {
                        return false
                    } else if (b.givenName+b.familyName).isEmpty {
                        return true
                    } else {
                        return (a.givenName+a.familyName).localizedCaseInsensitiveCompare(b.givenName+b.familyName) == .orderedAscending
                    }
                }
                self.allcontactsTableView.reloadData()
                break
            case .failure(error: let error):
                print(error)
                break
            }
        })
        
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
        
        self.navigationItem.rightBarButtonItems = [rightItem]
        
    }
    func rightBarButtonItemsUnselect(){
        
        let rightItem = UIBarButtonItem(title: "Deselect all", style: .plain, target: self, action: #selector(self.selectAllbtn))
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
            flagselect = false
            rightBarButtonItemsSelect()
            //selectedAll.setBackgroundImage(UIImage(named:"unselect_icon"), for: .normal)
            self.selectedRows.removeAll()
            self.allcontactsTableView.reloadData()
            deletebtn.isHidden = true
            deletebtn.setTitle("DELETE", for: .normal)
        }
        else{
            flagselect = true
            rightBarButtonItemsUnselect()
            // selectedAll.setBackgroundImage(UIImage(named:"select_icon"), for: .normal)
            self.selectedRows = getAllIndexPaths()
            self.allcontactsTableView.reloadData()
            if(selectedRows.isEmpty){
                deletebtn.isHidden = true
                deletebtn.setTitle("DELETE".localized, for: .normal)
                deletebtn.setTitle("DELETE".localized, for: .selected)
                deletebtn.setTitle("DELETE".localized, for: .highlighted)
            }
            else{
                let locaText = "DELETE SELECTED".localized
                
                deletebtn.isHidden = false
                deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .normal)
                deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .selected)
                deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .highlighted)
                
            }
            
        }
        
    }
    
    func getAllIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for j in 0..<allcontactsTableView.numberOfRows(inSection: 0) {
            indexPaths.append(IndexPath(row: j, section: 0))
        }
        return indexPaths
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
extension AllContactsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return  self.allContactArray.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.allcontactsTableView.dequeueReusableCell(withIdentifier: "AllContactsCell", for: indexPath) as! AllContactsCell
        var dataArry = self.allContactArray[indexPath.row]
        
        if !dataArry.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                dataArry = try self.contactStore.unifiedContact(withIdentifier: dataArry.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        // cell.cellView.dropShadow()
        
        if(dataArry.imageData == nil){
            if(dataArry.givenName == "" &&  dataArry.familyName == ""){
                cell.shortNamelbl.text = "UC"
            }
            else{
                cell.shortNamelbl.text = String(dataArry.givenName.prefix(1)) +  String(dataArry.familyName.prefix(1))
            }
            cell.imagev.image = UIImage(named: "contacts_icon")
            
        }
        else{
            if let image = UIImage(data:(dataArry.imageData!)) {
                DispatchQueue.main.async {
                    cell.shortNamelbl.text = ""
                    cell.imagev.layer.borderWidth = 1
                    cell.imagev.layer.masksToBounds = false
                    cell.imagev.layer.borderColor = UIColor.white.cgColor
                    cell.imagev.layer.cornerRadius = cell.imagev.frame.height/2
                    cell.imagev.clipsToBounds = true
                    cell.imagev.image = image
                }
            }
            
        }
        if(dataArry.phoneNumbers.first?.value.stringValue == nil){
            cell.numberlbl.text = "No phone"
        }
        else{
            cell.numberlbl.text = dataArry.phoneNumbers.first?.value.stringValue
            
        }
        // cell.numberlbl.text = dataArry.phoneNumbers.first?.value.stringValue
        //  cell.namelbl.text = dataArry.givenName + " " + dataArry.familyName
        
        if(dataArry.givenName == "" &&  dataArry.familyName == ""){
            cell.namelbl.text = "Unnamed contact".localized
            //            if(dataArry.phoneNumbers.first?.value.stringValue == nil){
            //
            //                if(dataArry.organizationName == ""){
            //                    cell.namelbl.text = dataArry.emailAddresses.first?.value as String?
            //                }
            //                else{
            //                    cell.namelbl.text = dataArry.organizationName
            //                }
            //            }
            //            else{
            //                cell.namelbl.text = dataArry.phoneNumbers.first?.value.stringValue
            //            }
            
        }
        else{
            cell.namelbl.text = dataArry.givenName + " " + dataArry.familyName
        }
        
        if selectedRows.contains(indexPath)
        {
            cell.selectedCell.setImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            cell.selectedCell.setImage(UIImage(named:"checkbox_unselect_ic"), for: .normal)
        }
        cell.selectedCell.tag = indexPath.row
        cell.selectedCell.addTarget(self, action: #selector(checkBoxSelection(_:)), for: .touchUpInside)
        
        
        
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
            
            deletebtn.isHidden = true
            deletebtn.setTitle("DELETE".localized, for: .normal)
            deletebtn.setTitle("DELETE".localized, for: .selected)
            deletebtn.setTitle("DELETE".localized, for: .highlighted)
        }
        else{
            let locaText = "DELETE SELECTED".localized
            
            deletebtn.isHidden = false
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .normal)
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .selected)
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .highlighted)
        }
        self.allcontactsTableView.reloadData()
    }
    
    //MARK: - Delegate
    
    func contactViewController(viewController: CNContactViewController, didCompleteWithContact contact: CNContact?) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func contactViewController(viewController: CNContactViewController, shouldPerformDefaultActionForContactProperty property: CNContactProperty) -> Bool {
        return true
    }
    @objc func doneButtonClicked(_ button:UIBarButtonItem!){
       self.dismiss(animated: true, completion: nil)
     //   self.navigationController?.popViewController(animated: true)
        print("Done clicked")
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.title = ""
            self.navigationItem.setHidesBackButton(false, animated: false)
            var contact = self.allContactArray[indexPath.row]
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
            let barButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.doneButtonClicked(_:)))
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
            return 170
        }
        else{
            return 85
        }
    }
    
    
    
    
}
extension AllContactsVC: AlterDeleteDelegate {
    
    
    
    func AlterViewController(sender: AlterDeleteContact, didSelectNumber number: Int) {
        dismiss(animated: true) {
            
            if(number == 1){
                
                self.confirmedDelete()
            }
            
        }
    }
    
}
