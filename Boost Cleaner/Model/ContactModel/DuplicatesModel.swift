//
//  DuplicatesModel.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/1/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import Foundation
import UIKit
import SwiftyContacts
import Foundation
import Contacts
import UIKit
import CoreTelephony
import ContactsUI

class DuplicatesModel : NSObject, NSCoding{
    var  ContactArray : [CNContact]?
    var  MergeArray :  CNContact?
    init(ContactArray: [CNContact],MergeArray: CNContact ) {
        self.MergeArray = MergeArray
        self.ContactArray = ContactArray
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.ContactArray = aDecoder.decodeObject(forKey: "ContactArray") as? [CNContact];
        self.MergeArray = aDecoder.decodeObject(forKey: "MergeArray") as? CNContact;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.ContactArray, forKey: "ContactArray");
        aCoder.encode(self.MergeArray, forKey: "MergeArray");
        
    }
    
}
