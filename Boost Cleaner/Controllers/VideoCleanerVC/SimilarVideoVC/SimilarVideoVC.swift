//
//  SimilarVideoVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/7/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation
import StoreKit
import PinterestLayout
import EzPopup
import SDWebImagePhotosPlugin

class SimilarVideoVC: UIViewController {
    
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var btnKeep: UIButton!
    
    var similardeletevideos = [SimilarVideoModel]()
    var videos: PHFetchResult<PHAsset>?
    var selectedRows:[IndexPath] = []
    var deleteRows:[IndexPath] = []
    let user = SharedData.sharedUserInfo
    let AlterDeleteComplete = AlterVideoDelete.instantiate()
    var arrayIndx = [Int]()
    var emptyIndx = [Int]()
    var deletevideos = [PHAsset]()
    let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    var flg = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Similar Videos".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        deletevideos.removeAll()
        DispatchQueue.main.async { [self] in
            if Utilities.containsRatingEvent(event: ReviewPopupLocation.onVideo) {
                Utilities.rateApp(controller: self)
                //AdmobManager.shared.openRateView()
            } else {
                print("Rating pop is not showing")
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var videosTableView: UITableView!{
        didSet {
            videosTableView.delegate = self
            videosTableView.dataSource = self
            
        }
    }
    //    var image5 : UIImage {
    //        var thumbnail = UIImage()
    //        var cellDimension = UIScreen.main.bounds.size.width / 2.0
    //
    //
    //        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
    //            cellDimension = UIScreen.main.bounds.size.width / 4.0
    //        }
    //
    //
    //        let size = CGSize(width: cellDimension, height: cellDimension)
    //        let manager = PHImageManager.default()
    //        let option = PHImageRequestOptions()
    //        option.resizeMode = PHImageRequestOptionsResizeMode.exact
    //        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
    //        option.isNetworkAccessAllowed = true
    //        option.isSynchronous = true
    //        option.deliveryMode = .highQualityFormat
    //
    //        manager.requestImage(for: self,
    //                             targetSize: size,
    //                             contentMode: .aspectFit,
    //                             options: option) { (image, info) in
    //            //print(image?.size)
    //            thumbnail = image!
    //        }
    //        return thumbnail
    //
    //    }
    //    func getUIImage(asset: PHAsset, complition : @escaping ((_ img:UIImage?,_ error:String?) -> Void)){
    //    let manager = PHImageManager.default()
    //    let options = PHImageRequestOptions()
    //    options.version = .original
    //    options.isSynchronous = true
    //    manager.requestImageData(for: asset, options: options) { data, _, _, _ in
    //
    //        if let data = data,
    //        let img = UIImage(data: data){
    //            complition(img,nil)
    //        }else{
    //            complition(nil,"Something went wrong")
    //            }
    //        }
    //    }
    
    static func getAssetThumbnail(asset: PHAsset, handler: (@escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) ) {
        var cellDimension = UIScreen.main.bounds.size.width / 1.0
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = UIScreen.main.bounds.size.width / 1.0
        }
        
        let size = CGSize(width: cellDimension, height: cellDimension)
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.fast
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        //  option.isNetworkAccessAllowed = true
        // option.version = .original
        //  option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: handler)
    }
    static func getAssetThumbnail2(asset: PHAsset, size: CGSize? = nil, handler: (@escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) ) {
        var cellDimension = UIScreen.main.bounds.size.width / 3.0
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = UIScreen.main.bounds.size.width / 3.0
        }
        
        let imageSize = size ?? CGSize(width: cellDimension, height: cellDimension)
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.fast
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        //  option.isNetworkAccessAllowed = true
        // option.version = .original
        //  option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset,
                             targetSize: imageSize,
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: handler)
    }
    
    func deleteVideos() {        
        deletevideos.removeAll()
        emptyIndx.removeAll()
        
        for i in 0..<arrayIndx.count {
            let section = selectedRows[arrayIndx[i]].section
            let row = selectedRows[arrayIndx[i]].row
            let asset =    self.videos![user.similarvideos[section].videosData![row]]
            deletevideos.append(asset)
            //deletevideos.append((similarvideos[section].videosData?[row])!)
        }
        
        print(arrayIndx)
        
        // self.arrayIndx.sort(by: { $1 < $0 })
        
        //            for i in 0..<arrayIndx.count {
        //                let section = selectedRows[arrayIndx[i]].section
        //                let row = selectedRows[arrayIndx[i]].row
        //                similarvideos[section].videosData?.remove(at: row)
        //
        //            }
                
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.deletevideos as NSArray)
        }, completionHandler: {success, error in
            if(success) {
                UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                
                DispatchQueue.main.async { [self] in
                    deleteRows.removeAll()
                    // self.arrayIndx.sort(by: { $1 < $0 })
                    
                    for index in self.arrayIndx
                    {
                        let section = selectedRows[index].section
                        //let row = selectedRows[index].row
                        
                        self.user.similarvideos[section].videosData?.remove(at: 0)
                        
                        // similarvideos[section].videosData?.remove(at: row)
                        //                        deleteRows.append(selectedIndexPath)
                    }
                    
                    
                    for i in 0..<self.user.similarvideos.count {
                        print( self.user.similarvideos[i].videosData!.count)
                        if( self.user.similarvideos[i].videosData!.isEmpty ||  self.user.similarvideos[i].videosData!.count == 1){
                            self.emptyIndx.append(i)
                        }
                        
                    }
                    
                    
                    
                    
                    //
                    //                    self.similarvideos = self.similarvideos
                    //                        .enumerated()
                    //                        .filter { !self.emptyIndx.contains($0.offset) }
                    //                        .map { $0.element }
                    
                    print(self.emptyIndx)
                    self.emptyIndx.sort(by: { $1 < $0 })
                    
                    for index in self.emptyIndx
                    {
                        
                        self.user.similarvideos.remove(at: index)
                        
                        
                    }
                    
                    
                    self.selectedRows = self.selectedRows
                        .enumerated()
                        .filter { !self.arrayIndx.contains($0.offset) }
                        .map { $0.element }
                    
                    
                    self.selectedRows = self.selectedRows
                        .enumerated()
                        .filter { !self.arrayIndx.contains($0.offset) }
                        .map { $0.element }
                    self.arrayIndx.removeAll()
                    self.videosTableView.reloadData()
                    // self.createAlertSend ()
                    self.createAlertSend ()
                    
                }
            }
        })
        
        
        
    }
    func createAlertSend (){
        guard let pickerVC = AlterDeleteComplete else { return }
        let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 300, popupHeight: 382)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        present(popupVC, animated: true, completion: nil)
        
    }
    
    func playvideo (asset: PHAsset, view: UIViewController) {
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.deliveryMode = .fastFormat
        options.version = .current
        options.isNetworkAccessAllowed = true
        //  options.deliveryMode = .fastFormat
        options.deliveryMode = .automatic
        DispatchQueue.main.async {
            // self.hud.dismiss()
        }
        var flg = true
        
        
        options.progressHandler = { (progress, error, stop, info) in
            // do something with the returned parameters
            if(flg){
                if Network.isAvailable == true {
                    DispatchQueue.main.async {
                        //                        self.hud.vibrancyEnabled = true
                        //
                        //                        self.hud.indicatorView = JGProgressHUDRingIndicatorView()
                        //
                        //                        self.hud.detailTextLabel.text = "0% Complete"
                        //                        self.hud.textLabel.text = "Downloading"
                        //                        self.hud.show(in: self.view)
                        
                        print("Not a valid video media type")
                        flg = false
                    }
                }
                else{
                    
                    DispatchQueue.main.async {
                        let alert = AlertView.prepare(title: "Alert".localized, message:"No Internet connection found please check network and try again.".localized, okAction: nil)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                
            }
            print(progress)
            DispatchQueue.main.async {
                //                self.hud.progress = Float(Int(progress*100))
                //                self.hud.detailTextLabel.text = "\(Int(progress*100))% Complete"
                
                
            }
            //  self.incrementHUD(hud, progress: Int(progress*100))
            
            
            if(progress == 1.0){
                DispatchQueue.main.async {
                    //  self.hud.dismiss(afterDelay: 1.0)
                }
            }
        }
        
        
        //  let asset =    self.videos![similarvideos[currentIndex].topVideo!]
        //  let asset2 =      similarvideos[0].videosData?[currentIndex]
        // let asset =    self.videos![ asset2!]
        
        guard (asset.mediaType == PHAssetMediaType.video)
        
        else {
            print("Not a valid video media type")
            return
        }
        
        
        PHCachingImageManager().requestAVAsset(forVideo:  asset, options: options, resultHandler: {(asset, audioMix, info) in
            
            
            if let asset = asset as? AVURLAsset {
                DispatchQueue.main.async {
                    
                    let player = AVPlayer(url: asset.url)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    view.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            }
            else {
                //  hud = JGProgressHUD(style: .light)
                
            }
            
        } )
        
        
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

extension SimilarVideoVC: UITableViewDelegate,UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 1060
        }
        else{
            return 530
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return   self.user.similarvideos.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videosTableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell") as! VideoTableViewCell
        
        let CategoryData =  self.user.similarvideos[indexPath.row]
        cell.selectedCell.setBackgroundImage(UIImage(named:"video_uncheck_ic"), for: .normal)
        let selectedIndexPath = IndexPath(row: 0, section: indexPath.row)
        var countSelect = 0
        cell.countselectedCell.setTitle("Move 0 to Trash".localized, for: .normal)
        for i in 0..<selectedRows.count {
            print(selectedRows[i].row)
            print(selectedRows[i].section)
            if(indexPath.row == selectedRows[i].section){
                
                countSelect = countSelect + 1
                cell.countselectedCell.setTitle("Move ".localized + "\(countSelect)" + " to Trash".localized, for: .normal)
            }
            
        }
        
        if selectedRows.contains(selectedIndexPath)
        {
            cell.selectedCell.setBackgroundImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            cell.selectedCell.setBackgroundImage(UIImage(named:"video_uncheck_ic"), for: .normal)
        }
        
        let asset =    self.videos![CategoryData.topVideo!]
        cell.configureCell(phAsset: asset)
        cell.cellView.dropShadow()
        cell.cellView.layer.cornerRadius = 30.0
        
        cell.cellView.clipsToBounds = true
        
        cell.countselectedCell.tag = indexPath.row
        cell.countselectedCell.addTarget(self, action: #selector(deleteSelection(_:)), for: .touchUpInside)
        
        
        cell.keepselectedCell.tag = indexPath.row
        cell.keepselectedCell.addTarget(self, action: #selector(keepSelection(_:)), for: .touchUpInside)
        cell.selectedCell.mk_addTapHandler { (btn) in
            print("You can use here also directly : \(indexPath.row)")
            let selectedIndexPath = IndexPath(row: 0, section: indexPath.row)
            
            self.allbtnTapped(btn: btn, indexPath: selectedIndexPath)
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 
        guard let tableViewCell = cell as? VideoTableViewCell else { return }
        if( self.user.similarvideos[indexPath.row].videosData!.count <= 3){
            tableViewCell.leftConstraints.constant = 150
        }
        else{
            tableViewCell.leftConstraints.constant = 20
        }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        
    }
    @objc func keepSelection(_ sender:UIButton)
    {
        let keepIndexPath = sender.tag
        print(keepIndexPath)
        arrayIndx.removeAll()
        for i in 0..<selectedRows.count {
            if(keepIndexPath == selectedRows[i].section){
                arrayIndx.append(i)
            }
        }
        
        print(arrayIndx)
        
        selectedRows = selectedRows
            .enumerated()
            .filter { !arrayIndx.contains($0.offset) }
            .map { $0.element }
        
        print(selectedRows)
         let indexPosition = IndexPath(row: keepIndexPath, section: 0)

        let cell: VideoTableViewCell = self.videosTableView.cellForRow(at: indexPosition) as! VideoTableViewCell
        var countSelect = 0
        cell.countselectedCell.setTitle("Move 0 to Trash".localized, for: .normal)
        for i in 0..<selectedRows.count {
            print(selectedRows[i].row)
            print(selectedRows[i].section)
            if(indexPosition.row == selectedRows[i].section){
                print("fiaz")
                countSelect = countSelect + 1
                cell.countselectedCell.setTitle("Move ".localized + "\(countSelect)" + " to Trash".localized, for: .normal)
            }
            
        }
        
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: keepIndexPath)
    }
    
    @objc func deleteSelection(_ sender:UIButton) {
        if selectedRows.count <= 0 {
            return
        }
        
        let deleteIndexPath = sender.tag
        arrayIndx.removeAll()
        
        print(deleteIndexPath)
        
        for i in 0..<selectedRows.count {
            if(deleteIndexPath == selectedRows[i].section){
                arrayIndx.append(i)
            }
        }
        
        if EventManager.shared.dailyLimit == true && PaymentManager.shared.isPurchase() == false {
            let dailyLimitStr = "Daily Limit".localized
            let leftStr = "Left".localized
            let deleteStr = "Delete".localized
            let leftCount = abs(UserDefaults.standard.integer(forKey: "Count"))
            let alert = UIAlertController(title: "Limit on Cleaning".localized, message: "\(dailyLimitStr): 5 \n \(leftStr): " + "\(leftCount)", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "\(deleteStr) (" + "\(selectedRows.count)" + ")", style: .default) { (action) in
                if(leftCount >= self.selectedRows.count) {
                    self.deleteVideos()
                    //UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                }
                else{
                    let inAppSpot = EventManager.shared.inAppLocations
                    if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onVideosSimilarDelete) {
                        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onVideosSimilarDelete)
                    } else {
                        self.deleteVideos()
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) in
               
            }
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                alert.popoverPresentationController?.sourceView = sender
                alert.popoverPresentationController?.sourceRect = sender.bounds
            }
            self.present(alert, animated: true)
        } else {
            let inAppSpot = EventManager.shared.inAppLocations
            if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onVideosSimilarDelete) {
                Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onVideosSimilarDelete)
            } else {
                deleteVideos()
            }
        }
    }
}

extension SimilarVideoVC:  UICollectionViewDelegate,UICollectionViewDataSource  ,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return   self.user.similarvideos[collectionView.tag].videosData?.count ?? 0
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoDataCollectionViewCell", for: indexPath) as! VideoDataCollectionViewCell
        let divison =  self.user.similarvideos[collectionView.tag].videosData?[indexPath.row]
        cell.selectedCell.setBackgroundImage(UIImage(named:"video_uncheck_ic"), for: .normal)
        print(indexPath)
        let selectedIndexPath = IndexPath(row: indexPath.row, section: collectionView.tag)
        if selectedRows.contains(selectedIndexPath)
        {
            cell.selectedCell.setBackgroundImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            cell.selectedCell.setBackgroundImage(UIImage(named:"video_uncheck_ic"), for: .normal)
        }
        
        let asset =    self.videos![ divison!]
        
        cell.configureCell(phAsset:asset)
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        
        SDImagePhotosLoader.shared.requestImageAssetOnly = false
        
        
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
        //        cell.selectedCell.tag = indexPath.row
        //        cell.selectedCell.addTarget(self, action: #selector(checkBoxSelection(_:)), for: .touchUpInside)
        
        cell.selectedCell.mk_addTapHandler { (btn) in
            print("You can use here also directly : \( collectionView.tag)")
            let selectedIndexPath = IndexPath(row: indexPath.row, section: collectionView.tag)
            
            self.allbtnTapped(btn: btn, indexPath: selectedIndexPath)
        }
        cell.selectedCell2.mk_addTapHandler { (btn) in
            print("You can use here also directly : \( collectionView.tag)")
            let selectedIndexPath = IndexPath(row: indexPath.row, section: collectionView.tag)
            
            self.allbtnTapped(btn: btn, indexPath: selectedIndexPath)
        }
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        return cell
        
    }
    func allbtnTapped(btn: UIButton, indexPath: IndexPath) {
        let selectedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        print("IndexPath : \(selectedIndexPath)")
        
        if self.selectedRows.contains(selectedIndexPath)
        {
            self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
        }
        else
        {
            self.selectedRows.append(selectedIndexPath)
        }
        
        let indexPosition = IndexPath(row: indexPath.section, section: 0)

       let cell: VideoTableViewCell = self.videosTableView.cellForRow(at: indexPosition) as! VideoTableViewCell
       var countSelect = 0
       cell.countselectedCell.setTitle("Move 0 to Trash".localized, for: .normal)
       for i in 0..<selectedRows.count {
           print(selectedRows[i].row)
           print(selectedRows[i].section)
           
           if(indexPosition.row == selectedRows[i].section){
               countSelect = countSelect + 1
               cell.countselectedCell.setTitle("Move ".localized + "\(countSelect)" + " to Trash".localized, for: .normal)
           }
       }
       
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
        let selectedIndexPath1 = IndexPath(row: indexPath.row, section: 0)
        cell.topCollecView.scrollToItem(at: selectedIndexPath1, at: .left, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let searchData =  self.user.similarvideos[collectionView.tag].videosData?[indexPath.row]
        
      playvideo( asset: self.videos![ searchData!], view: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: UIScreen.main.bounds.width - 32 , height: 624 )
        }
        else{
            
            return CGSize(width: UIScreen.main.bounds.width - 40 , height: 312 )
        }
        
    }
    
    
    
}
