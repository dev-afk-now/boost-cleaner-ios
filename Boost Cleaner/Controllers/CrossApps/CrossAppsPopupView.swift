//
//  CrossAppsPopupView.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 04/10/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import UIKit

class CrossAppsPopupView: UIView {

    static let id = "crossAppPopupView"

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgvMascottIcon: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrCrossApps = CrossAppAds.allCases
    weak var delegate: CrossAppAdCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "CrossAppsColCell", bundle: nil), forCellWithReuseIdentifier: CrossAppsColCell.cellID)
    }

    static func instanceFromNib() -> CrossAppsPopupView {
        return UINib(nibName: "CrossAppsPopupView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CrossAppsPopupView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func onBtnCloseAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.delegate?.closed()
        }
    }
    
}

extension CrossAppsPopupView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCrossApps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CrossAppsColCell.cellID, for: indexPath) as! CrossAppsColCell
        cell.prepareUI(with: arrCrossApps[indexPath.item])
//        cell.dropShadowRadius8()
        cell.layer.cornerRadius = 20
//        cell.contentView.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = ((collectionView.frame.size.width - 70) / 3) - 20.0
        return CGSize(width: cellWidth, height: (cellWidth * 1.17))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectedApp(at: arrCrossApps[indexPath.item])
    }
    
}

extension UICollectionView {
    
    var isLastItemFullyVisible: Bool {
       contentSize.width == contentOffset.x + frame.width - contentInset.right
    }
    
}
