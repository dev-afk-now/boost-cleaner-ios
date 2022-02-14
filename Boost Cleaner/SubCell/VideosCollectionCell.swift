//
//  VideosCollectionCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/5/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos

class VideosCollectionCell: UICollectionViewCell {
    @IBOutlet weak var selectedCell: UIButton!
    @IBOutlet weak var cellView: UIView!

    @IBOutlet var sizelbl: UILabel!
       @IBOutlet var imagelbl: UIImageView!
    
   func configureCell(phAsset: PHAsset) {
       imagelbl.isHidden = true
   

       // activityIndicator.isHidden = false
       // activityIndicator.startAnimating()
        
    
    SimilarVideoVC.getAssetThumbnail(asset: phAsset) { (result, info) in
            self.imagelbl.image = result ?? nil
            self.imagelbl.isHidden = false
          //  self.activityIndicator.isHidden = true
           // self.activityIndicator.stopAnimating()
        }
    }
    
    
    
}
