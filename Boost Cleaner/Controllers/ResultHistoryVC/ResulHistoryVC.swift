//
//  ResulHistoryVC.swift
//  Boost Cleaner
//
//  Created by HABIB on 28/10/2020.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

class ResulHistoryVC: UIViewController {
        var datas: [ResultHistory] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            self.title = "Results history".localized
            self.leftBarCloseButtonItems(iconName: "back_btn_ic")
            self.makeNavigationBarTransparent()
            navigationController?.navigationBar.backgroundColor = UIColor.clear
            self.view.dropShadow2()
         
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

    }
    extension ResulHistoryVC : UITableViewDelegate, UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            
            return  datas.count
            
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = self.historycontactsTableView.dequeueReusableCell(withIdentifier: "ResultHistoryTVC", for: indexPath) as! ResultHistoryTVC

            let objResult = datas[indexPath.row]
            cell.lblip.text = objResult.ip
            cell.lblNetworkName.text = objResult.ispName
            
            switch objResult.networkType {
            case "Wifi":
                cell.imageNetwork.image = UIImage(named: "wifi")
            case "4G":
                cell.imageNetwork.image = UIImage(named: "4G")
            case "3G":
                cell.imageNetwork.image = UIImage(named: "3G")
            default:
                cell.imageNetwork.image = UIImage(named: "3G")
            }
            
            cell.lblUpSpeed.text = objResult.uSpeed + "Mb/sec"
            cell.lblDownSpeed.text = objResult.dSpeed + "Mb/sec"
            cell.cellView.dropShadow2()
            cell.layer.cornerRadius = 20.0
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            
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
