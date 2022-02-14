//
//  PhotoTableViewCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/12/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos

class PhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var selectedCell: UIButton!
    @IBOutlet weak var countselectedCell: UIButton!
    @IBOutlet weak var keepselectedCell: UIButton!
    @IBOutlet weak var topCollecView: UICollectionView!
    @IBOutlet weak var leftConstraints: NSLayoutConstraint!

    @IBOutlet weak var CollecView: UICollectionView!
    @IBOutlet  weak var imageV: UIImageView!
    
    func configureCell(phAsset: PHAsset) {
        imageV.isHidden = true
        SimilarVideoVC.getAssetThumbnail(asset: phAsset) { (result, info) in
            self.imageV.image = result ?? nil
            self.imageV.isHidden = false
        }
    }
    
    func setCollectionViewDataSourceDelegate
    <D: UICollectionViewDataSource & UICollectionViewDelegate>
    (dataSourceDelegate: D, forRow row: Int) {
        
        CollecView.delegate = dataSourceDelegate
        CollecView.dataSource = dataSourceDelegate
        CollecView.tag = row
        CollecView.reloadData()
        topCollecView.delegate = dataSourceDelegate
        topCollecView.dataSource = dataSourceDelegate
        topCollecView.tag = row
        topCollecView.reloadData()
    }
}
