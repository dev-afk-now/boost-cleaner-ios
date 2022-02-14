//
//  ScreenshotsVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/9/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation
import PinterestLayout
import EzPopup

class ScreenshotsVC: UIViewController {
    var screenshotsresultArray = [[NSString]]()
    var photos = [PHAsset]()
    var deletephotos = [PHAsset]()
    var allselectedRows:[IndexPath] = []
    let user = SharedData.sharedUserInfo
    var totalcount = 0;
    var screenshotsArray = [PhotosModel]()
    var screenshots: PHFetchResult<PHAsset>?
    var selectedRows:[IndexPath] = []
    var deleteArray = [Int]()
    
    @IBOutlet weak var CollecView: UICollectionView!
    @IBOutlet weak var selectedAll: UIButton!
    @IBOutlet weak var deletebtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Screenshots Photos".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        
        autoreleasepool {
            for k in 0..<screenshotsresultArray.count {
                var numberData = [Int]()
                for l in 0..<screenshotsresultArray[k].count {
                    let number = Int(screenshotsresultArray[k][l] as String)
                    numberData.append(number!)
                }
                if(!numberData.isEmpty){
                    self.screenshotsArray.append(PhotosModel( title: "\(screenshotsresultArray[k].count)", NumberArry: numberData, firstPhoto: numberData[0] ) )
                }
            }
        }
        CollecView.delegate = self
        CollecView.dataSource = self
        setupLayout()
        CollecView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    private func setupLayout() {
        let layout: PinterestLayout = {
            if let layout = CollecView.collectionViewLayout as? PinterestLayout {
                return layout
            }
            let layout = PinterestLayout()
            CollecView?.collectionViewLayout = layout
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
extension ScreenshotsVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshotsArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
      //  let asset =  screenshotsArray[indexPath.row].photoData
        let asset =    self.screenshots![screenshotsArray[indexPath.row].firstPhoto!]
        cell.configureCell(phAsset: asset)
        cell.countLbl.text = screenshotsArray[indexPath.row].title
        cell.contentView.layer.cornerRadius = 15
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        return cell;
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
        
        
        var photosArray = [PhotosModel]()
        photosArray.removeAll()
        photosArray.append(screenshotsArray[indexPath.row])
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SimilarVC") as? SimilarVC
//        vc!.similarphotos = photosArray
//        vc!.photosArray = screenshots
//        self.navigationController?.pushViewController(vc!, animated: true)
        
        // playvideo (currentIndex: indexPath.row, view: self)
        
    }
    
}
extension ScreenshotsVC: PinterestLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        
        let asset =    self.screenshots![screenshotsArray[indexPath.row].firstPhoto!]
        let image =   configureCell2(phAsset: asset)
        return image.height(forWidth: withWidth)
    }
    
    func collectionView(collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        return 0
    }
    func configureCell2(phAsset: PHAsset) -> UIImage{
        
        var image2 : UIImage = .init()
        AllVideoVC.getAssetThumbnail(asset: phAsset) { (result, info) in
            
            if(result != nil){
                image2 = result!
            }
            //  self.activityIndicator.isHidden = true
            // self.activityIndicator.stopAnimating()
            
        }
        return image2
    }
}
