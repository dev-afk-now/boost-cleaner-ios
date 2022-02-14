//
//  ImagesDetailVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 11/10/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import MSPeekCollectionViewDelegateImplementation
import Photos
import AVKit
import AVFoundation
import SDWebImagePhotosPlugin
import ImageScrollView

class ImagesDetailVC: UIViewController {
    var  currentIndex = 0
    var displayIndex = 0
    var similarflg = false
    var NumberArry =  [Int]()
    
    @IBOutlet var collectionView: UICollectionView!
    var peekImplementation: MSPeekCollectionViewDelegateImplementation!
    var finalImages = [Int]()
    var PhotosArray: PHFetchResult<PHAsset>?
    var SimilarPhotosArray = [PHAsset]()
    var allPhotosArray = [PHAsset]()
    var isForAll: Bool = false
    var count = ""
    var flag = true
    let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        setNeedsStatusBarAppearanceUpdate()
        self.title = "Photos".localized
        if(similarflg){
            count =  "\(currentIndex+1)" + "/" + "\(NumberArry.count)"
        }else if isForAll {
            count =  "\(currentIndex+1)" + "/" + "\(allPhotosArray.count)"
        }else{
            
            count =  "\(currentIndex+1)" + "/" + "\(finalImages.count)"
        }
    }
    
    func rightBarButtonItems(){
        
        let numberbtn = UIBarButtonItem(title: count , style: .plain, target: self, action: #selector(self.numberclick))
        self.navigationItem.rightBarButtonItems = [numberbtn]
        
    }
    @objc func numberclick() {
        
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //  self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        viewConfigrations()
        
        peekImplementation = MSPeekCollectionViewDelegateImplementation(cellSpacing: CGFloat(0), cellPeekWidth: CGFloat(0), scrollThreshold: CGFloat(50), maximumItemsToScroll: Int(1), numberOfItemsToShow: Int(1))
        
        // peekImplementation = MSPeekCollectionViewDelegateImplementation()
        peekImplementation.delegate = self
        collectionView.configureForPeekingDelegate()
        collectionView.backgroundColor = UIColor.clear
        //  collectionView.delegate = MSPeekCollectionViewDelegateImplementation(cellSpacing: 0)
        //   collectionView.delegate = MSPeekCollectionViewDelegateImplementation(cellPeekWidth: 0)
        collectionView.delegate = peekImplementation
        collectionView.dataSource = self
        //  collectionView.delegate = MSPeekCollectionViewDelegateImplementation(cellSpacing: 0)
        rightBarButtonItems()
        
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at:IndexPath(item: self.displayIndex, section: 0), at: .centeredHorizontally, animated: false)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.flag = false
            let selectedIndexPath = IndexPath(row: self.displayIndex, section: 0)
            
            self.collectionView.reloadItems(at: [selectedIndexPath])
            //  self.flag = true
            
        }
        
        //        self.flag = false
        //               DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        //
        //                   let selectedIndexPath = IndexPath(row: self.displayIndex, section: 0)
        //
        //                   self.collectionView.reloadItems(at: [selectedIndexPath])
        //                    self.flag = true
        //
        //               }
        
        
        
    }
    
    private func viewConfigrations() {
        
        collectionView.register(UINib(nibName: "ImagesDetailCell", bundle: nil), forCellWithReuseIdentifier: "ImagesDetailCell")
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    private func getAssetThumbnail(asset: PHAsset, handler: (@escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) ) {
        var cellDimension = UIScreen.main.bounds.size.width / 2.0
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = UIScreen.main.bounds.size.width / 4.0
        }
        
        let size = CGSize(width: cellDimension, height: cellDimension)
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        
        option.isNetworkAccessAllowed = true
        option.isSynchronous = false
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: handler)
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
extension ImagesDetailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate ,ImageScrollViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(similarflg){
            return NumberArry.count
        }
        else{
            return finalImages.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesDetailCell", for: indexPath) as! ImagesDetailCell
        
        if(similarflg){
            let asset =    self.SimilarPhotosArray[NumberArry[indexPath.row]]
            cell.imageV.setup()
            cell.imageV.imageScrollViewDelegate = self
            cell.imageV.imageContentMode = .aspectFit
            cell.imageV.initialOffset = .center
            if(self.flag){
                cell.imageV.display(image: asset.image5 )
            }
            else if(!self.flag && self.currentIndex == indexPath.row){
                cell.imageV.display(image: asset.image2 )
            }

            return cell
        }else if isForAll {
            let asset =    self.allPhotosArray[indexPath.row]
            cell.imageV.setup()
            cell.imageV.imageScrollViewDelegate = self
            cell.imageV.imageContentMode = .aspectFit
            cell.imageV.initialOffset = .center
            if(self.flag){
                cell.imageV.display(image: asset.image5 )
            }
            else if(!self.flag && self.currentIndex == indexPath.row){
                cell.imageV.display(image: asset.image2 )
            }
    
            return cell
        } else{
            let asset =    self.PhotosArray![finalImages[indexPath.row]]
            cell.imageV.setup()
            cell.imageV.imageScrollViewDelegate = self
            cell.imageV.imageContentMode = .aspectFit
            cell.imageV.initialOffset = .center
            if(self.flag){
                cell.imageV.display(image: asset.image5 )
            }
            else if(!self.flag && self.currentIndex == indexPath.row){
                cell.imageV.display(image: asset.image2 )
            }
    
            return cell
        }
    }
    
    
    
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
        print("Did change orientation")
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming at scale \(scale)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item selected at \(indexPath.row)")
    }
}

extension ImagesDetailVC: MSPeekImplementationDelegate {
    func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didChangeActiveIndexTo activeIndex: Int) {
        print("Changed active index to \(activeIndex)")
        
        currentIndex = activeIndex
        if(similarflg){
            count =   "\(currentIndex+1)" + "/" + "\(NumberArry.count)"
        }
        else{
            count =   "\(currentIndex+1)" + "/" + "\(finalImages.count)"
        }
        self.flag = false
        rightBarButtonItems()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //  self.flag = false
            let selectedIndexPath = IndexPath(row: activeIndex, section: 0)
            
            self.collectionView.reloadItems(at: [selectedIndexPath])
            self.flag = true
            
        }
        
    }
    
    func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at \(indexPath)")
        
        
        self.currentIndex = indexPath.item
        //  playvideo ()
        if(similarflg){
            count =   "\(currentIndex+1)" + "/" + "\(NumberArry.count)"
        }
        else{
            count =   "\(currentIndex+1)" + "/" + "\(finalImages.count)"
        }
        self.flag = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let selectedIndexPath = IndexPath(row: indexPath.item, section: 0)
            
            self.collectionView.reloadItems(at: [selectedIndexPath])
            self.flag = true
            
        }
        rightBarButtonItems()
    }
    
    
}

