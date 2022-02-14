//
//  AlterSuccessMerge.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/5/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
class AlterSuccessMerge: UIViewController {
    
  //  @IBOutlet weak var cancelButton: UIButton!

   // weak var delegate: AlterSendFaxDelegate?
    
    static func instantiate() -> AlterSuccessMerge? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(AlterSuccessMerge.self)") as? AlterSuccessMerge
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.95) {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
        }
 
    }
    
   
  
}

