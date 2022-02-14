//
//  VideosModel.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/5/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import Foundation
import Photos
import UIKit

class VideosModel : NSObject, NSCoding{
    
    
    var nameContact: String?
    var sizetype: String?
    var videosData : Int?
    var sizevideos: Double?
    var image: UIImage?
    
    
    init(sizetype: String, nameContact: String ,videosData: Int ,sizevideos: Double) {
        self.sizetype = sizetype
        self.nameContact = nameContact
        self.sizevideos = sizevideos
        self.videosData = videosData
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.sizetype = aDecoder.decodeObject(forKey: "sizetype") as? String;
        self.nameContact = aDecoder.decodeObject(forKey: "nameContact") as? String;
        self.sizevideos = aDecoder.decodeObject(forKey: "sizevideos") as? Double;
        self.videosData = aDecoder.decodeObject(forKey: "videosData") as? Int;
        
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.sizetype, forKey: "sizetype");
        aCoder.encode(self.nameContact, forKey: "nameContact");
        aCoder.encode(self.sizevideos, forKey: "sizevideos");
        aCoder.encode(self.videosData, forKey: "videosData");
    }
}
