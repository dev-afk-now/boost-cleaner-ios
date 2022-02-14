//
//  PhotosMonthModel.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/14/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import Foundation
import Photos

class PhotosMonthModel : NSObject, NSCoding{
    
    
    var title: String?
    var NumberArry: [Int]?
    var DateArry: [String]?
    var firstPhoto : Int?
    
    
    
    init(title: String ,DateArry: [String], NumberArry: [Int], firstPhoto : Int) {
        
        self.title = title
        self.DateArry = DateArry
        self.NumberArry = NumberArry
        self.firstPhoto = firstPhoto
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.title = aDecoder.decodeObject(forKey: "title") as? String;
        self.DateArry = aDecoder.decodeObject(forKey: "DateArry") as? [String];
        self.NumberArry = aDecoder.decodeObject(forKey: "NumberArry") as? [Int];
        self.firstPhoto = aDecoder.decodeObject(forKey: "firstPhoto") as? Int;
        
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.title, forKey: "title");
        aCoder.encode(self.DateArry, forKey: "DateArry");
        aCoder.encode(self.NumberArry, forKey: "NumberArry");
        aCoder.encode(self.firstPhoto, forKey: "firstPhoto");
        
        
        
        
    }
    
    
    
    
    
    
}

