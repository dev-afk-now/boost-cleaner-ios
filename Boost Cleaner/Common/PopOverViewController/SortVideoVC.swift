//
//  SortVideoVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/6/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

class SortVideoVC: UIViewController {
 
    
    var titleArray = [ "All".localized, "Higher than 100 MB".localized, "50-100 MB".localized ,"10-50 MB".localized ,"Others".localized ]
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sortTableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBOutlet var sortTableView: UITableView!{
        didSet {
            sortTableView.delegate = self
            sortTableView.dataSource = self
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        //  self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        sender.showsTouchWhenHighlighted = true
        self.dismiss(animated: true, completion: nil)
        
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
extension SortVideoVC : UITableViewDelegate, UITableViewDataSource {
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return titleArray.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.sortTableView.dequeueReusableCell(withIdentifier: "SortVideoTableViewCell", for: indexPath) as! SortVideoTableViewCell
        
        let dataArry = self.titleArray[indexPath.row]
        
        cell.nameLbl.text = dataArry
      
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
        UserDefaults.standard.set(self.titleArray[indexPath.row], forKey: "typeVideo")
        self.dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)

     
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    
}
