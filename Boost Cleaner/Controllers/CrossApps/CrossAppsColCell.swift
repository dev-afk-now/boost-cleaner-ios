//
//  CrossAppsColCell.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 04/10/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import UIKit

class CrossAppsColCell: UICollectionViewCell {
    
    @IBOutlet weak var imgvAppIcon: UIImageView!
    @IBOutlet weak var lblAppName: UILabel!
    @IBOutlet weak var backView: UIView!
    
    static let cellID = "adCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        contentView.layer.masksToBounds = true
//        dropShadow2()
    }
    
    func prepareUI(with ad: CrossAppAds) {
        imgvAppIcon.image = ad.icons
        lblAppName.text = ad.name
        backView.layer.cornerRadius = 20
//        backView.layer.masksToBounds = true
    }
}
