//
//  CrossAppAdCell.swift
//  Boost Cleaner
//
//  Created by HABIB on 13/10/2021.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import Contacts
import Photos
import StoreKit
import SafariServices

protocol CrossAppAdCellDelegate: AnyObject {
    func selectedApp(at app: CrossAppAds)
    func closed()
}



class CrossAppAdCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrCrossApps = CrossAppAds.allCases
    weak var delegate: CrossAppAdCellDelegate?
    static let cellID = "crossAppAdCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "CrossAppsColCell", bundle: nil), forCellWithReuseIdentifier: CrossAppsColCell.cellID)
    }
    
    func reloadCollection() {
        collectionView.reloadData()
    }
}
extension CrossAppAdCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCrossApps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CrossAppsColCell.cellID, for: indexPath) as! CrossAppsColCell
        cell.prepareUI(with: arrCrossApps[indexPath.item])
        cell.dropShadowRadius8()
        cell.layer.cornerRadius = 20
//        cell.contentView.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.size.width / 3) - 20.0
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

enum CrossAppAds: Int, CaseIterable {
    
    case fontMaker, fonts, copypaste, ringtone
    
    var icons: UIImage? {
        switch self {
        case .fontMaker:
            return UIImage(named: "ic_fonts_maker_app")
        case .fonts:
            return UIImage(named: "ic_fonts_app")
        case .copypaste:
            return UIImage(named: "ic_copy_paste_app")
        case .ringtone:
            return UIImage(named: "ic_ringtone_app")
        }
    }
    
    var name: String? {
        switch self {
        case .fontMaker:
            return "Font Maker".localized
        case .fonts:
            return "Fonts Keyboards".localized
        case .copypaste:
            return "Auto Text\nPaste".localized
        case .ringtone:
            return "Ringtone\nMaker".localized
        }
    }
    
    var appURL: URL? {
        switch self {
        case .fontMaker:
            return URL(string: "https://apps.apple.com/us/app/font-maker-keyboard/id1582959159")
        case .fonts:
            return URL(string: "https://apps.apple.com/us/app/fonts-keyboards/id1490060871")
        case .copypaste:
            return URL(string: "https://apps.apple.com/us/app/copy-and-paste-keyboard/id1571464033")
        case .ringtone:
            return URL(string: "https://apps.apple.com/us/app/id1585814310")
        }
    }
    
    var appID: String? {
        switch self {
        case .fontMaker:
            return "1582959159"
        case .fonts:
            return "1490060871"
        case .copypaste:
            return "1571464033"
        case .ringtone:
            return "1585814310"
        }
    }
    
}
