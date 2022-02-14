//
//  PhotoCollectionViewCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/12/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageV: UIImageView!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet weak var selectedCell: UIButton!

    func configureCell(phAsset: PHAsset) {
        imageV.isHidden = true
        SimilarVideoVC.getAssetThumbnail2(asset: phAsset) { (result, info) in
            self.imageV.image = result ?? nil
            self.imageV.isHidden = false
        }
    }
}
