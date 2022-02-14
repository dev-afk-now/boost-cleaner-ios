//
//  BackupHistory.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/23/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

class BackupHistory: UIViewController {
    
    @IBOutlet weak var backupNoteLbl: UILabel!
    var datas: [Backup] = []
    let noteText = "This application only backup your contact in this device, if you delete this application you will the lost all backup. But you can send this backup to your storage to save it before deleting the applicaiton."

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Backups".localized
        self.backupNoteLbl.text = noteText.localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
       // rightBarButtonItemsSelect()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
        
    }
    func reloadData(){
        datas = DataManager.shared.getAllBackup()
        self.historycontactsTableView.reloadData()
    }
    @IBOutlet var historycontactsTableView: UITableView!{
        didSet {
            historycontactsTableView.delegate = self
            historycontactsTableView.dataSource = self
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
extension BackupHistory : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return  self.datas.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.historycontactsTableView.dequeueReusableCell(withIdentifier: "AllContactsCell", for: indexPath) as! AllContactsCell
        let dataArry = self.datas[indexPath.row]
        let totalContactsStr = "Total contacts".localized
        
        cell.namelbl.text = dataArry.date
        cell.numberlbl.text = "\(totalContactsStr) (" + "\(dataArry.numberContact)" + ")"
        cell.imagev.image = UIImage(named: "contacts_i")
        cell.shortNamelbl.text = ""
        
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let backup = datas[indexPath.row]
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HistoryDetailsVC") as? HistoryDetailsVC
        vc!.backup = backup
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let backup = datas[indexPath.row]
            DataManager.shared.removeBackup(backup: backup)
            self.reloadData()
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
