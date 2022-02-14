//
//  ContactModel.swift
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

class ContactModel : NSObject, NSCoding{
    var nameContact: String?
    var totalCount: Int?
    var  ContactArray : [CNContact]?
    init(ContactArray: [CNContact],nameContact: String ,totalCount: Int) {
        self.nameContact = nameContact
        self.totalCount = totalCount
        self.ContactArray = ContactArray
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.ContactArray = aDecoder.decodeObject(forKey: "ContactArray") as? [CNContact];
        self.nameContact = aDecoder.decodeObject(forKey: "nameContact") as? String;
        self.totalCount = aDecoder.decodeObject(forKey: "totalCount") as? Int;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.ContactArray, forKey: "ContactArray");
        aCoder.encode(self.nameContact, forKey: "nameContact");
        aCoder.encode(self.totalCount, forKey: "totalCount");
    }
    
}

