//
//  ImagesDetailCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 11/10/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos
import ImageScrollView

class ImagesDetailCell: UICollectionViewCell, ImageScrollViewDelegate {
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
        print("Did change orientation")
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming at scale \(scale)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
    }
    

    @IBOutlet var imageV: ImageScrollView!
    //@IBOutlet weak var imageScrollView: ImageScrollView!

    func configureCell(phAsset: PHAsset) {
           imageV.isHidden = true
          // activityIndicator.isHidden = false
          // activityIndicator.startAnimating()
           
        SimilarVideoVC.getAssetThumbnail(asset: phAsset) { (result, info) in
              // self.imageV.image = result ?? nil
               self.imageV.isHidden = false
            self.imageV.setup()
            self.imageV.imageScrollViewDelegate = self
            self.imageV.imageContentMode = .aspectFit
            self.imageV.initialOffset = .center
            self.imageV.display(image: result!)
            
             //  self.activityIndicator.isHidden = true
              // self.activityIndicator.stopAnimating()
           }
       }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
