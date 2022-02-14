//
//  DataManager.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/23/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class DataManager {
    
    static let shared = DataManager()
    private var realm : Realm!

    init() {
        var defaultRealmConfig = Realm.Configuration.defaultConfiguration
        defaultRealmConfig.schemaVersion = 1
        defaultRealmConfig.migrationBlock = {(migration, oldVersion) in
            //migration code here
        }
        Realm.Configuration.defaultConfiguration = defaultRealmConfig
        do {
            self.realm = try Realm(configuration: defaultRealmConfig)
        } catch {
            if let fileURL = defaultRealmConfig.fileURL {
                try? FileManager.default.removeItem(at: fileURL)
                self.realm = try? Realm(configuration: defaultRealmConfig)
            }
        }
    }

    
    func addBackup(backup: Backup){
        try! realm.write {
            realm.add(backup)
        }
    }
    
    func addBackup(backup: ResultHistory){
        try! realm.write {
            realm.add(backup)
        }
    }
    
    func removeBackup(backup: Backup){
        try! realm.write {
            realm.delete(backup)
        }
    }
    
    func removeBackup(backup: ResultHistory){
        try! realm.write {
            realm.delete(backup)
        }
    }
    
    
    func getAllBackup() -> [Backup] {
        return Array(realm.objects(Backup.self).sorted(byKeyPath: "date", ascending: false))
    }
    func getAllBackup() -> [ResultHistory] {
        return Array(realm.objects(ResultHistory.self))
    }
    
    func saveLanguage(language: String){
        self.save(key: "language", value: language)
    }
    
    func getLanguage() -> String{
        if let language =  self.getValue(key: "language"){
            return language
        }
        return "English"
    }
    
    func save(key: String, value: String){
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getValue(key: String) -> String?{
         return UserDefaults.standard.string(forKey: key)
    }

}

class FilePaths {
    
    static let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
  
    static func backupPath(id: String) -> URL{
        let dataPath = FilePaths.documentsPath
        let fileURL = URL(fileURLWithPath:dataPath as! String).appendingPathComponent(id + ".vcf")
        print(fileURL)
        return fileURL
    }
}

