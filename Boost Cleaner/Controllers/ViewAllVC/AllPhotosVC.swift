//
//  AllPhotosVC.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 27/09/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import UIKit
import Photos
import PinterestLayout
import SDWebImage

class PhotoAssets: NSObject, Comparable {
    static func < (lhs: PhotoAssets, rhs: PhotoAssets) -> Bool {
        return lhs.asset.sizeInBytes < rhs.asset.sizeInBytes
    }
    let asset: PHAsset
    var isLoaded: Bool = false
    var isSelected: Bool = false
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
}

class AllPhotosVC: BaseViewController {
    
}
