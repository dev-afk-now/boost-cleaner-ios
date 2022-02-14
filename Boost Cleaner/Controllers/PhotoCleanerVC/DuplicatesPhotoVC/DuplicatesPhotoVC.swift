//
//  DuplicatesPhotoVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/14/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation
import PinterestLayout
import EzPopup
import CircleProgressView
import SDWebImagePhotosPlugin

class DuplicatesPhotoVC: UIViewController {
    var photosArray: PHFetchResult<PHAsset>?
    var duplicatesresultArray = [[NSString]]()
    var photos = [PHAsset]()
    var deletephotos = [PHAsset]()
    var allselectedRows:[IndexPath] = []
    let user = SharedData.sharedUserInfo
    var totalcount = 0
    var chuckCount = -1
    var flg = false
    var backFlg = false
    var   finalArry = [PhotosModel]()
    var  chuckResult = [[PhotosModel]]()
    var selectedRows:[IndexPath] = []
    var deleteArray = [Int]()
    let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    var dismissBlock: (() -> Void)?
    
    @IBOutlet weak var CollecView: UICollectionView!
    @IBOutlet weak var selectedAll: UIButton!
    @IBOutlet weak var deletebtn: UIButton!
    
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Duplicate Photos".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        self.indicator.isHidden = true
        CollecView.delegate = self
        CollecView.dataSource = self
        setupLayout()
        DispatchQueue.main.async { [self] in
            if Utilities.containsRatingEvent(event: ReviewPopupLocation.onPhoto) {
                Utilities.rateApp(controller: self)
                //AdmobManager.shared.openRateView()
            } else {
                print("Rating pop is not showing")
            }
        }
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
             self.chuckResult = self.user.duplicatesphotosArray.chunked(into: 50)
            print(chuckResult)
             chuckCount = 0
            if(!chuckResult.isEmpty){
             self.finalArry = chuckResult[self.chuckCount]
            }
             flg = true
             CollecView.delegate = self
             CollecView.dataSource = self
             setupLayout()
             self.CollecView.reloadData()
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//       // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
//            self.chuckResult = self.user.duplicatesphotosArray.chunked(into: 50)
//            chuckCount = 0
//            self.finalArry = chuckResult[self.chuckCount]
//            flg = true
//            CollecView.delegate = self
//            CollecView.dataSource = self
//            setupLayout()
        if(backFlg){
            self.CollecView.reloadData()
        }
        //}
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    private func setupLayout() {
        let layout: PinterestLayout = {
            if let layout = CollecView.collectionViewLayout as? PinterestLayout {
                return layout
            }
            let layout = PinterestLayout()
            
            CollecView?.collectionViewLayout = layout
            //  layout.invalidateLayout()
            return layout
        }()
        layout.delegate = self
        
        layout.cellPadding = 5
        layout.numberOfColumns = 2
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension DuplicatesPhotoVC:UICollectionViewDelegate,UICollectionViewDataSource , PinterestLayoutDelegate ,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(flg){
            
            return self.finalArry.count
        }
        else{
            return 0
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        if(!self.finalArry[indexPath.row].NumberArry!.isEmpty){
            let asset =    self.photosArray![self.finalArry[indexPath.row].NumberArry![0]]
            cell.configureCell(phAsset: asset)
            let photosURL = NSURL.sd_URL(with: asset)
            let option = PHImageRequestOptions()
            option.resizeMode = PHImageRequestOptionsResizeMode.exact
            option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            option.isNetworkAccessAllowed = true
            option.version = .original
            option.isSynchronous = true
            option.deliveryMode = .highQualityFormat
            cell.imageV.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageV.sd_setImage(with: photosURL as URL?, placeholderImage: nil, context:[.photosImageRequestOptions: option, .customManager: manager])
            cell.countLbl.text = "\(String(describing: self.finalArry[indexPath.row].NumberArry!.count))"
            cell.contentView.layer.cornerRadius = 15
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true
            
            return cell;
        }
        else{
            return cell;
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var cellDimension = (UIScreen.main.bounds.size.width  / 3.0)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = (UIScreen.main.bounds.size.width / 6.0)
        }
        
        
        
        return CGSize(width: cellDimension - 10 , height: cellDimension - 10 )
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if indexPath.row < self.user.duplicatesphotosArray.count {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DuplicatesVC") as? DuplicatesVC
            
            vc?.similarphotos = [self.user.duplicatesphotosArray[indexPath.row]]
            vc?.delegate = self
            
            backFlg = true
            
            vc?.photosArray = photosArray
            vc?.indArray = indexPath.row
            vc?.dismissBlock = dismissBlock
            print(indexPath.row)
            
            if let controller = vc {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            //cause by user
            print("SCROLL scrollViewDidEndDragging")
        }
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //caused by user
        print("SCROLL scrollViewDidEndDecelerating")
        flg = true
        print(self.chuckResult.count)
        if(self.chuckCount < self.chuckResult.count - 1){
            self.chuckCount = self.chuckCount + 1
            print(self.chuckCount)
            self.finalArry =  self.finalArry + chuckResult[self.chuckCount]
            //self.CollecView.activityIndicator(show: true)
            DispatchQueue.main.async {
                self.indicator.startAnimating()
                self.indicator.isHidden = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                self.CollecView.collectionViewLayout.invalidateLayout()
                self.CollecView.reloadData()
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.indicator.isHidden = true
                }
            }
            
            
            
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        let asset =    self.photosArray![self.finalArry[indexPath.item].firstPhoto!]
        let image =   configureCell2(phAsset: asset)
        return image.height(forWidth: withWidth)
    }
    
    
    func collectionView(collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        return 0
    }
    func getAssetThumbnail(asset: PHAsset, handler: (@escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) ) {
        var cellDimension = UIScreen.main.bounds.size.width / 2.0
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = UIScreen.main.bounds.size.width / 4.0
        }
        
        let size = CGSize(width: 50, height: 50)
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: handler)
    }
    
    func configureCell2(phAsset: PHAsset) -> UIImage{
        
        var image2 : UIImage = .init()
        getAssetThumbnail(asset: phAsset) { (result, info) in
            
            if(result != nil){
                image2 = result!
            }
            
        }
        return image2
    }
}
extension Array {
    func split() -> (left: [Element], right: [Element]) {
        let ct = self.count
        let half = ct / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< ct]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    
}
