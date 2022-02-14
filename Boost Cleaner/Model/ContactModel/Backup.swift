//
//  Backup.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/22/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Backup: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var numberContact = 0
    @objc dynamic var date = ""

    override static func primaryKey() -> String? {
        return "id"
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    convenience init(numberContact: Int, date: String) {
        self.init()
        let uuid = UUID().uuidString
        self.id = uuid
        self.numberContact = numberContact
        self.date = date
    }
}




class ResultHistory: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var ip: String = ""
    @objc dynamic var dSpeed: String = ""
    @objc dynamic var uSpeed: String = ""
    @objc dynamic var ispName: String = ""
    @objc dynamic var networkType: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    convenience init(ip: String, dSpeed: String,uSpeed: String, ispName: String, networkType: String) {
        self.init()
        let uuid = UUID().uuidString
        self.id = uuid
        self.ip = ip
        self.dSpeed = dSpeed
        self.uSpeed = uSpeed
        self.ispName = ispName
        self.networkType = networkType
    }
}



