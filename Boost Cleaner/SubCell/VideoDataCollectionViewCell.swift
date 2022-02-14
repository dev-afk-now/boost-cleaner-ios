//
//  VideoDataCollectionViewCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/7/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos

class VideoDataCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageV: UIImageView!
    @IBOutlet weak var selectedCell: UIButton!
    @IBOutlet weak var selectedCell2: UIButton!

    func configureCell(phAsset: PHAsset) {
        imageV.isHidden = true
        SimilarVC.getAssetThumbnail(asset: phAsset) { (result, info) in
            self.imageV.image = result ?? nil
             self.imageV.isHidden = false
        }
    }
}
