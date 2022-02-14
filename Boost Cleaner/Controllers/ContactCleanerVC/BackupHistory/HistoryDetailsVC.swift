//
//  HistoryDetailsVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/23/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import ContactsUI

class HistoryDetailsVC: UIViewController {
   

    var contacts = [Contact]()
    var backup: Backup!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History details".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        self.loadContacts()
        rightBarButtonItemsSelect()
        // Do any additional setup after loading the view.
    }
    func rightBarButtonItemsSelect(){
        
        let rightItem = UIBarButtonItem(title: "Import".localized, style: .plain, target: self, action: #selector(self.historybtn))
        if UIDevice.current.userInterfaceIdiom == .pad {
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
        }
        else{
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14  )!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
         //   rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
        }
        
        self.navigationItem.rightBarButtonItems = [rightItem]
        
    }
    
    @objc func historybtn(_ sender: UIBarButtonItem) {
        let fileLocation = FilePaths.backupPath(id: backup.id)
        let activityVC = UIActivityViewController(activityItems: [fileLocation], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
        present(activityVC, animated: true, completion: nil)
    }
    @IBOutlet var historycontactsTableView: UITableView!{
        didSet {
            historycontactsTableView.delegate = self
            historycontactsTableView.dataSource = self
        }
    }
    
     func loadContacts(){
         contacts.removeAll()
         if let data = try? Data(contentsOf: FilePaths.backupPath(id: backup.id)){
             if let temps = try? CNContactVCardSerialization.contacts(with: data){
                 for temp in temps{
                     let contact = Contact.init(cnContact: temp)
                     contacts.append(contact)
                 }
             }
         }
         self.historycontactsTableView.reloadData()
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
extension HistoryDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return contacts.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.historycontactsTableView.dequeueReusableCell(withIdentifier: "AllContactsCell", for: indexPath) as! AllContactsCell
        let dataArry = self.contacts[indexPath.row]
        
        let name = ContactManager.shared.contactName(dataArry)
        
        
        if(dataArry.image == nil){
            if(dataArry.firstName == nil &&  dataArry.lastName == nil){
                cell.shortNamelbl.text = "UC"
            }
            else{
              
                if(dataArry.lastName == nil){
                    if(!(dataArry.firstName == nil)){
                    cell.shortNamelbl.text = String(dataArry.firstName.prefix(1))
                    }
                }
                else{
                    cell.shortNamelbl.text = String(dataArry.firstName.prefix(1)) +  String(dataArry.lastName.prefix(1))
                }
                  
                
                
            }
            cell.imagev.image = UIImage(named: "contacts_icon")
            
        }
        else{
            if let image = dataArry.image {
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

        cell.numberlbl.text = ContactManager.shared.contactPhones(dataArry);

        if(name == ""){
            cell.namelbl.text = "Unnamed contact".localized
         
        }
        else{
            cell.namelbl.text = name
        }
        
  
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
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
