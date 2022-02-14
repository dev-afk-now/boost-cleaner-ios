//
//  AlterVideoDelete.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/5/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
class AlterVideoDelete: UIViewController {
    
    var dismissDuration = 2.25
    
    static func instantiate() -> AlterVideoDelete? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(AlterVideoDelete.self)") as? AlterVideoDelete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissDuration) {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
        }
    }
   
  
}

