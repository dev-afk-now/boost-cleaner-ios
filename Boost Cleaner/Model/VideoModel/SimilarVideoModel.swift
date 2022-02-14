//
//  SimilarVideoModel.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/7/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import Foundation
import Photos

class SimilarVideoModel : NSObject, NSCoding{
    
    
    var topVideo: Int?
    var videosData : [Int]?
    
    
    
    init(topVideo: Int ,videosData: [Int] ) {
        
        self.topVideo = topVideo
        self.videosData = videosData
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.topVideo = aDecoder.decodeObject(forKey: "topVideo") as? Int;
        self.videosData = aDecoder.decodeObject(forKey: "videosData") as? [Int];
        
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.topVideo, forKey: "topVideo");
        aCoder.encode(self.videosData, forKey: "videosData");
        
        
        
        
    }
    
    
    
    
    
    
}

