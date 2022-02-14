//
//  VideoTableViewCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/7/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos

class VideoTableViewCell: UITableViewCell, UICollectionViewDelegate {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var selectedCell: UIButton!
    @IBOutlet weak var countselectedCell: UIButton!
    @IBOutlet weak var keepselectedCell: UIButton!
    @IBOutlet weak var CollecView: UICollectionView!
    @IBOutlet weak var topCollecView: UICollectionView!
    @IBOutlet weak var leftConstraints: NSLayoutConstraint!

    @IBOutlet  weak var imageV: UIImageView!
    func collectionReloadData(row : Int){
            DispatchQueue.main.async(execute: {
                self.CollecView.delegate = self
                self.topCollecView.delegate = self
                self.CollecView.tag = row
                self.topCollecView.tag = row
                self.CollecView.reloadData()
                self.topCollecView.reloadData()
            })
       }
    func configureCell(phAsset: PHAsset) {
        keepselectedCell.setTitle("Keep All".localized, for: .normal)
        keepselectedCell.setTitle("Keep All".localized, for: .selected)
        keepselectedCell.setTitle("Keep All".localized, for: .highlighted)
        
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
        CollecView.delegate = self
        topCollecView.delegate = dataSourceDelegate
        topCollecView.dataSource = dataSourceDelegate
        topCollecView.tag = row
        topCollecView.reloadData()
        
        
    }
}
