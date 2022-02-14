//
//  FastDataCollectionViewCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 11/5/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//


import UIKit
import Photos

class FastDataCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var selectedCell2: UIButton!

    @IBOutlet var imageV: UIImageView!
    @IBOutlet weak var selectedCell: UIButton!
    
    func configureCell(phAsset: PHAsset) {
        imageV.isHidden = true
        SimilarVideoVC.getAssetThumbnail(asset: phAsset) { (result, info) in
            self.imageV.image = result ?? nil
             self.imageV.isHidden = false
        }
    }

}
