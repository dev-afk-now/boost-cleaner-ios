//
//  Contact.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/22/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import ContactsUI

class Contact: NSObject {
    public var identifier: String
    public var dateUpdated: Date!
    public var date: Date!
    public var selected: Bool = false
    public var image: UIImage!
    public var imageURL : URL!
    public var emails = [String]()
    public var phones = [String]()
    public var lastName: String!
    public var firstName: String!
    public var address: [String] = []
    public var company: String = ""
    public var departmentName: String = ""
    public var jobTitle: String = ""
    public var birthday: Date?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    public init(cnContact: CNContact) {
        self.identifier = cnContact.identifier
        self.firstName = cnContact.givenName.isEmpty ? nil : cnContact.givenName
        self.lastName = cnContact.familyName.isEmpty ? nil : cnContact.familyName
        if (cnContact.phoneNumbers.count > 0) {
            for i in 0 ..< cnContact.phoneNumbers.count {
                self.phones.append((cnContact.phoneNumbers[i].value ).stringValue)
            }
        }
        if (cnContact.emailAddresses.count > 0) {
            for i in 0 ..< cnContact.emailAddresses.count {
                self.emails.append(cnContact.emailAddresses[i].value as String)
            }
        }
        
        if(cnContact.imageDataAvailable) {
            if let imgData = cnContact.imageData {
                let img = UIImage(data: imgData)
                self.image = img
            }
        }
        birthday = cnContact.birthday?.date
//        company = cnContact.co
        
        if (cnContact.postalAddresses.count > 0) {
            for i in 0 ..< cnContact.postalAddresses.count {
                let storeAddress = cnContact.postalAddresses[i]
                self.address.append(storeAddress.value.city)
            }
        }
        self.company = cnContact.organizationName
        self.departmentName = cnContact.departmentName
        self.jobTitle = cnContact.jobTitle
    }
}

