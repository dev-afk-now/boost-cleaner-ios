//
//  AllVideoVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/5/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation
import StoreKit
import PinterestLayout
import EzPopup
import CircleProgressView
import SDWebImagePhotosPlugin
import IHProgressHUD

class AllVideoVC: BaseViewController {
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    var videos: PHFetchResult<PHAsset>?
    var deletevideos = [PHAsset]()
    var totalcount = 0;
    let user = SharedData.sharedUserInfo
    var typeVideo = "All".localized
    var selectedRows:[IndexPath] = []
    var deleteArray = [Int]()
    var firstRun = true
    var flagselect = false
    let AlterDeleteComplete = AlterVideoDelete.instantiate()
    let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    var flagback = false
    var hasHiddenLoadingAfter100Percent = false
    
    //Localization
    @IBOutlet weak var btnDelete: UIButton!
    
    //
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeView: UIView!
    
    @IBOutlet weak var noData: UIImageView!
    @IBOutlet weak var deletebtn: UIButton!
    @IBOutlet weak var VideoCollection: UICollectionView!
    @IBOutlet weak var typeViewHeightConstraint: NSLayoutConstraint!
    var isFromCompressor: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Videos".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25 ) {
        //            self.checkAuthorizationForPhotoLibraryAndGet()
        //        }
        setupLayout()
        if !isFromCompressor {
            rightBarButtonItemsSelect()
        }
        getVideoWithDelay()
        DispatchQueue.main.async { [self] in
            if Utilities.containsRatingEvent(event: ReviewPopupLocation.onVideo) {
                Utilities.rateApp(controller: self)
                //AdmobManager.shared.openRateView()
            } else {
                print("Rating pop is not showing")
            }
        }
        self.typeLabel.text = UserDefaults.standard.string(forKey: "typeVideo")?.localized
        shouldShowVideoFilterTypeView()
    }
    
    func getVideoWithDelay() {
        if isFromCompressor {
            DispatchQueue.main.async { [self] in
//                self.showLoading(shouldAllowInteractin: true)
                self.circleProgressView.progress = Double(0/Double(100))
                popupView.isHidden = false
                VideoCollection.isHidden = true
            }
            performSelector(inBackground: #selector(backgroundthread), with: nil)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.getVideos()
//            }
        }
    }
    
    @objc func backgroundthread() {
        getVideos()
    }
    
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        
        let popoverContentController = self.storyboard?.instantiateViewController(withIdentifier: "SortVideoVC") as? SortVideoVC
        popoverContentController?.modalPresentationStyle = .popover
        popoverContentController!.preferredContentSize = CGSize(width: 200, height: 220)
        /* 3 */
        // Present popover
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
            popoverPresentationController.delegate = self
            if let popoverController = popoverContentController {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    func shouldShowVideoFilterTypeView() {
        if isFromCompressor {
            typeViewHeightConstraint.constant = 0
            typeView.alpha = 0
        } else {
            typeViewHeightConstraint.constant = 40
            typeView.alpha = 1
        }
    }
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)
    }
    
    
    private func setupLayout() {
        let layout: PinterestLayout = {
            if let layout = VideoCollection.collectionViewLayout as? PinterestLayout {
                return layout
            }
            let layout = PinterestLayout()
            VideoCollection?.collectionViewLayout = layout
            return layout
        }()
        layout.delegate = self
        layout.cellPadding = 5
        layout.numberOfColumns = 2
    }
    func rightBarButtonItemsSelect(){
        
        let rightItem = UIBarButtonItem(title: "Select all".localized, style: .plain, target: self, action: #selector(self.selectAllbtn))
        if UIDevice.current.userInterfaceIdiom == .pad {
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
        }
        else{
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14  )!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
          //  rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
        }
        
        self.navigationItem.rightBarButtonItem = rightItem
        
    }
    func rightBarButtonItemsUnselect(){
        
        let rightItem = UIBarButtonItem(title: "Deselect all".localized, style: .plain, target: self, action: #selector(self.selectAllbtn))
        if UIDevice.current.userInterfaceIdiom == .pad {
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
        }
        else{
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14  )!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
           // rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
        }
        
        self.navigationItem.rightBarButtonItems = [rightItem]
        
    }
    func createAlertSend (){
        let bounds = UIScreen.main.bounds
        //        let width = bounds.size.width
        guard let pickerVC = AlterDeleteComplete else { return }
        let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 300, popupHeight: 382)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        present(popupVC, animated: true, completion: nil)
        
    }
    @objc func selectAllbtn() {
        if(flagselect){
            flagselect = false
            rightBarButtonItemsSelect()
            //selectedAll.setBackgroundImage(UIImage(named:"unselect_icon"), for: .normal)
            self.selectedRows.removeAll()
            self.VideoCollection.reloadData()
            deletebtn.isHidden = true
            deletebtn.setTitle("DELETE".localized, for: .normal)
        }
        else{
            flagselect = true
            rightBarButtonItemsUnselect()
            // selectedAll.setBackgroundImage(UIImage(named:"select_icon"), for: .normal)
            self.selectedRows = getAllIndexPaths()
            self.VideoCollection.reloadData()
            if(selectedRows.isEmpty){
                deletebtn.isHidden = true
                deletebtn.setTitle("DELETE".localized, for: .normal)
                
            }
            else{
                deletebtn.isHidden = false
                let txt = "DELETE SELECTED".localized
                deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .normal)
                deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .selected)
                deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .highlighted)
            }
        }
    }
    func getAllIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for j in 0..<self.user.sortfinalvideos.count {
            indexPaths.append(IndexPath(row: j, section: 0))
        }
        return indexPaths
    }
    
    @IBAction func deleteBtnAction(_ sender: UIButton) {
        if selectedRows.count <= 0 {
            return
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
                } else {
                    let inAppSpot = EventManager.shared.inAppLocations
                    if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onVideosDelete) {
                        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onVideosDelete)
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
            if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onVideosDelete) {
                Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onVideosDelete)
            } else {
                deleteVideos()
            }
        }
    }
    
    func deleteVideos() {
        deletevideos.removeAll()
        
        for i in 0..<selectedRows.count {
            let asset = self.videos![self.user.sortfinalvideos[self.selectedRows[i].row].videosData!]
            //deletevideos.append(sortfinalvideos[self.selectedRows[i].row].videosData!)
            deletevideos.append(asset)
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.deletevideos as NSArray)
        }, completionHandler: {success, error in
            if(success) {
                UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                
                DispatchQueue.main.async {
                    self.selectedRows.sort(by: { $1 < $0 })
                    
                    for index in self.selectedRows {
                        // arr.removeAtIndex(index)
                        self.user.sortfinalvideos.remove(at:index.row)
                        
                        if (UserDefaults.standard.string(forKey: "typeVideo") == "All".localized) {
                            let videoObject = self.user.finalvideos[index.row]
                            let sizevideo = videoObject.sizevideos ?? Double(0.0)
                            let sizetype = videoObject.sizetype
                            
                            if (sizetype == "GB") {
                                if let firstIndex = self.user.finalvideos1.firstIndex(of: videoObject) {
                                    self.user.finalvideos1.remove(at: firstIndex)
                                }
                            } else if (sizetype == "MB") {
                                if (sizevideo >= 100.0 ) {
                                    if let firstIndex = self.user.finalvideos1.firstIndex(of: videoObject) {
                                        self.user.finalvideos1.remove(at: firstIndex)
                                    }
                                } else if(sizevideo >= 50.0 && ( sizevideo < 100.0 )) {
                                    if let firstIndex = self.user.finalvideos2.firstIndex(of: videoObject) {
                                        self.user.finalvideos2.remove(at: firstIndex)
                                    }
                                } else if (sizevideo >= 10.0 && (sizevideo < 50.0 )) {
                                    if let firstIndex = self.user.finalvideos3.firstIndex(of: videoObject) {
                                        self.user.finalvideos3.remove(at: firstIndex)
                                    }
                                } else {
                                    if let firstIndex = self.user.finalvideos4.firstIndex(of: videoObject) {
                                        self.user.finalvideos4.remove(at: firstIndex)
                                    }
                                }
                                
                            } else if (sizetype == "KB") {
                                if let firstIndex = self.user.finalvideos4.firstIndex(of: videoObject) {
                                    self.user.finalvideos4.remove(at: firstIndex)
                                }
                            }
                            
                            self.user.finalvideos.remove(at:index.row)
                            
                        } else if (UserDefaults.standard.string(forKey: "typeVideo") == "Higher than 100 MB") {
                            let videoObject = self.user.finalvideos1[index.row]
                            
                            if let firstIndex = self.user.finalvideos.firstIndex(of: videoObject) {
                                self.user.finalvideos.remove(at: firstIndex)
                            }
                            
                            self.user.finalvideos1.remove(at:index.row)
                            
                        } else if(UserDefaults.standard.string(forKey: "typeVideo") == "50-100 MB") {
                            let videoObject = self.user.finalvideos2[index.row]
                            
                            if let firstIndex = self.user.finalvideos.firstIndex(of: videoObject) {
                                self.user.finalvideos.remove(at: firstIndex)
                            }
                            
                            self.user.finalvideos2.remove(at:index.row)
                            
                        } else if(UserDefaults.standard.string(forKey: "typeVideo") == "10-50 MB") {
                            let videoObject = self.user.finalvideos3[index.row]
                            
                            if let firstIndex = self.user.finalvideos.firstIndex(of: videoObject) {
                                self.user.finalvideos.remove(at: firstIndex)
                            }
                            
                            self.user.finalvideos3.remove(at:index.row)
                            
                        } else if(UserDefaults.standard.string(forKey: "typeVideo") == "Others") {
                            let videoObject = self.user.finalvideos4[index.row]
                            
                            if let firstIndex = self.user.finalvideos.firstIndex(of: videoObject) {
                                self.user.finalvideos.remove(at: firstIndex)
                            }
                            
                            self.user.finalvideos4.remove(at:index.row)
                        }
                    }
                    
                    self.selectedRows.removeAll()
                    self.VideoCollection.reloadData()
                    self.createAlertSend()
                    
                    if (self.selectedRows.isEmpty) {
                        self.deletebtn.isHidden = true
                    } else {
                        self.deletebtn.isHidden = false
                    }
                }
            }
        })
    }
    
    
    func playvideo (currentIndex : Int ,view:UIViewController) {
        
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.deliveryMode = .fastFormat
        
        options.version = .current
        options.isNetworkAccessAllowed = true
        //  options.deliveryMode = .fastFormat
        options.deliveryMode = .automatic
        DispatchQueue.main.async {
            // self.hud.dismiss()
            self.popupView.isHidden = true
            self.percentageLbl.text = "0%"
            self.circleProgressView.progress = Double(0/Double(100))
            
            
        }
        var flg = true
        
        
        options.progressHandler = { (progress, error, stop, info) in
            // do something with the returned parameters
            if(flg){
                if Network.isAvailable == true {
                    DispatchQueue.main.async {
                        self.popupView.isHidden = false
                        self.percentageLbl.text = "0%"
                        self.circleProgressView.progress = Double(0/Double(100))
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
                let progrs = progress*100
                self.percentageLbl.text = "\(Int(progress*100))%"
                self.circleProgressView.progress = Double(progrs/Double(100))
                //                self.hud.progress = Float(Int(progress*100))
                //                self.hud.detailTextLabel.text = "\(Int(progress*100))% Complete"
                
                
            }
            //  self.incrementHUD(hud, progress: Int(progress*100))
            
            
            if(progress == 1.0){
                DispatchQueue.main.async {
                    self.popupView.isHidden = true
                    self.percentageLbl.text = "0%"
                    self.circleProgressView.progress = Double(0/Double(100))
                }
            }
        }
        
        
        let asset = self.videos![self.user.sortfinalvideos[currentIndex].videosData!]
        guard (asset.mediaType == PHAssetMediaType.video)
        
        else {
            print("Not a valid video media type")
            return
        }
        PHCachingImageManager().requestAVAsset(forVideo: self.videos![self.user.sortfinalvideos[currentIndex].videosData!], options: options, resultHandler: {(asset, audioMix, info) in
            
            
            if let asset = asset as? AVURLAsset {
                DispatchQueue.main.async {
                    
                    let player = AVPlayer(url: asset.url)
                    player.automaticallyWaitsToMinimizeStalling = true;
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
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
    func converByteToHumanReadable(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    static func getAssetThumbnail(asset: PHAsset, handler: (@escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) ) {
        var cellDimension = UIScreen.main.bounds.size.width / 2.0
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = UIScreen.main.bounds.size.width / 2.0
        }
        
        let size = CGSize(width: cellDimension, height: cellDimension)
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        option.deliveryMode = .fastFormat    //.highQualityFormat
        
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: handler)
    }
    
}

// MARK: - UINavigation Method(s)
extension AllVideoVC {
    
    @IBAction func unwindToVideos(_ unwindSegue: UIStoryboardSegue) {
        //        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resetForUnwind()
        }
    }
    
    func resetForUnwind() {
        DispatchQueue.main.async {
            self.selectedRows.removeAll()
            self.deleteArray.removeAll()
            self.deletebtn.isHidden = true
            self.flagselect = false
        }
        self.getVideos(isFromUnwind: true)
    }
    
    @objc func getVideos(isFromUnwind: Bool = false) {
        self.user.finalvideos.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)
        // print(imagesAndVideos[0].description)
        
        hasHiddenLoadingAfter100Percent = false
        videos = imagesAndVideos
        
        for i in 0..<(videos?.count ?? 0) {
            if (flagback) {
                return
            }
            
            DispatchQueue.main.async {
                let value2 = Double(i)
                self.circleProgressView.progress = Double(value2/Double(self.videos!.count))
                
                let x = Double(value2/Double(self.videos!.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                
                self.percentageLbl.text = "\(result)" + "%"
                
                if result >= 100 {
                    print("qubee:: 100 percent waiting now")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Change `2.0` to the desired number of seconds.
                        print("qubee:: 100 percent waiting now 1")
                        
                        if self.hasHiddenLoadingAfter100Percent == false {
                            print("qubee:: 100 percent waiting now 1-1")
                            
                            self.hasHiddenLoadingAfter100Percent = true
                            self.hideProgressLoader()
                            return
                        }
                    }
                }
            }
            
            let asset = videos!.object(at: i)
            let resources = PHAssetResource.assetResources(for: asset) // your PHAsset
            var sizeOnDisk: Int64 = 0
            
            if let resource = resources.first {
                let isLocallayAvailable = (resource.value(forKey: "locallyAvailable") as? NSNumber)?.boolValue ?? false // If this returns NO, then the asset is in iCloud and not saved locally yet
//                print(">>>> isLocallyAvailable: \(isLocallayAvailable)")
                if let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
                    sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64))
                }
                let fullNameArr = converByteToHumanReadable(sizeOnDisk).components(separatedBy: " ")
                let name = fullNameArr[0]
                let mb = fullNameArr[1]
                if (mb == "MB") {
                    let sizevideo = Double(name) ?? 0.0
                    let videoModel = VideosModel(sizetype: "MB", nameContact: "key" , videosData: i , sizevideos : sizevideo )
                    if isLocallayAvailable {
                        self.user.finalvideos.append(videoModel)
                    }
                    if (sizevideo >= 100.0) {
                        if isLocallayAvailable {
                            self.user.finalvideos1.append(videoModel)
                        }
                    } else if(sizevideo >= 50.0 && (i < self.user.finalvideos.count) && ( self.user.finalvideos[i].sizevideos! < 100.0 ) ){
                        if isLocallayAvailable {
                            self.user.finalvideos2.append(videoModel)
                        }
                    } else if(sizevideo >= 10.0 && (i < self.user.finalvideos.count) && (self.user.finalvideos[i].sizevideos! < 50.0) ){
                        if isLocallayAvailable {
                            self.user.finalvideos3.append(videoModel)
                        }
                    } else {
                        if isLocallayAvailable {
                            self.user.finalvideos4.append(videoModel)
                        }
                    }
                } else if(mb == "KB") {
                    let sizevideo = Double(name) ?? 0.0
                    let videoModel = VideosModel(sizetype: "KB", nameContact: "key" , videosData: i , sizevideos : sizevideo )
                    if isLocallayAvailable {
                        self.user.finalvideos.append(videoModel)
                    }
                }
                else if(mb == "GB"){
                    let sizevideo = Double(name) ?? 0.0
                    let videoModel = VideosModel(sizetype: "GB", nameContact: "key" , videosData: i , sizevideos : sizevideo )
                    if isLocallayAvailable {
                        self.user.finalvideos.append(videoModel)
                    }
                }
            }
        }
        
        if self.hasHiddenLoadingAfter100Percent == false {
            self.hasHiddenLoadingAfter100Percent = true
            self.hideProgressLoader()
        }
    }
    
    func hideProgressLoader() {
        self.user.finalvideos = self.user.finalvideos.sorted(by: { (img0: VideosModel, img1: VideosModel) -> Bool in
            let sizetype0 = img0.sizetype
            let sizetype1 = img1.sizetype
            
            if sizetype0 == sizetype1 {
                return img0.sizevideos! > img1.sizevideos!
            } else if sizetype0 == "GB" {
                return true
            } else if sizetype1 == "GB" {
                return false
            } else if sizetype0 == "MB" {
                return true
            } else if sizetype1 == "MB" {
                return false
            }
            
            return img0.sizevideos! > img1.sizevideos!
        })
        
        DispatchQueue.main.async { [self] in
            self.user.sortfinalvideos = self.user.finalvideos
            self.circleProgressView.progress = Double(100/Double(100))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                self.popupView.isHidden = true
                self.VideoCollection.isHidden = false
                self.VideoCollection.reloadData()
            }
        }
    }
}

extension AllVideoVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.user.sortfinalvideos.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isFromCompressor {
            return self.videos == nil ? 0 : 1
        } else {
            return  1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideosCollectionCell", for: indexPath) as! VideosCollectionCell
        let videoModel = self.user.sortfinalvideos[indexPath.row]
        let asset = self.videos![videoModel.videosData!]
        
        cell.sizelbl.text = "\(videoModel.sizevideos!)" + " " + (videoModel.sizetype ?? "MB")
        cell.configureCell(phAsset: asset)
        
        if selectedRows.contains(indexPath) {
            cell.selectedCell.setImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        } else {
            cell.selectedCell.setImage(UIImage(named:"video_uncheck_ic"), for: .normal)
        }
        
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
        option.deliveryMode = .opportunistic
        cell.imagelbl.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imagelbl.sd_setImage(with: photosURL as URL?, placeholderImage: nil, context:[.photosImageRequestOptions: option, .customManager: manager])
        
        cell.selectedCell.isHidden = isFromCompressor
        cell.selectedCell.tag = indexPath.row
        cell.selectedCell.addTarget(self, action: #selector(checkBoxSelection(_:)), for: .touchUpInside)
        
        
        cell.contentView.layer.cornerRadius = 15
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        return cell;
    }
    @objc func checkBoxSelection(_ sender:UIButton)
    {
        let selectedIndexPath = IndexPath(row: sender.tag, section: 0)
        if self.selectedRows.contains(selectedIndexPath)
        {
            self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
        }
        else
        {
            self.selectedRows.append(selectedIndexPath)
        }
        
        if(selectedRows.isEmpty){
            
            deletebtn.isHidden = true
            deletebtn.setTitle("DELETE".localized, for: .normal)
        }
        else{
            
            deletebtn.isHidden = false
            let txt = "DELETE SELECTED".localized
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .normal)
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .selected)
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .highlighted)
        }
        
        guard let cell = self.VideoCollection.cellForItem(at: selectedIndexPath) as? VideosCollectionCell else{
            return
        }

        
        if selectedRows.contains(selectedIndexPath)
        {
           
            cell.selectedCell.setImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
          
            cell.selectedCell.setImage(UIImage(named:"checkbox_unselect_ic"), for: .normal)
        }
        
     //   self.VideoCollection.reloadItems(at: [selectedIndexPath])
        
        //  self.VideoCollection.reloadData()
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
        if isFromCompressor {
            let selectedAsset = self.videos![self.user.sortfinalvideos[indexPath.row].videosData!]
            openVideo(with: selectedAsset)
        } else {
            playvideo (currentIndex: indexPath.row, view: self)
        }
        
    }
    
    func openVideo(with asset: PHAsset) {
//        let vc = UIStoryboard.init(name: "Compression", bundle: Bundle.main).instantiateViewController(withIdentifier: "VideoCompressionVC") as! VideoCompressionVC
//        vc.video = asset
//        DispatchQueue.main.async {
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
}
extension AllVideoVC: PinterestLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        //let asset =  sortfinalvideos[indexPath.row].videosData
        if let video = self.videos, let videoData = self.user.sortfinalvideos[indexPath.row].videosData {
            let asset = video[videoData]
            let image =   configureCell2(phAsset: asset)
            return image.height(forWidth: withWidth)
        } else {
            var cellDimension = (UIScreen.main.bounds.size.width  / 3.0)
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                cellDimension = (UIScreen.main.bounds.size.width / 6.0)
            }
            return (cellDimension - 10)
        }
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
    
//    func getVideoThumbImage(phAsset: PHAsset, manager: PHCachingImageManager) -> UIImage? {
//        var image: UIImage? = nil
//        var imageRequestID:PHImageRequestID?
//        var representedAssetIdentifier:String?
//        representedAssetIdentifier = ImagePickerManager.default.getAssetIdentifier(asset: phAsset)
//        let imgReqID = ImagePickerManager.default.getPhotoWithAsset(asset: phAsset, photoWidth: UIScreen.main.bounds.size.width / 2, cachingManager: manager){ (photo, info, isDegraded:Bool) in
//
//            guard let representedAssetIdentifier = representedAssetIdentifier else {
//                return
//            }
//
//            if representedAssetIdentifier == ImagePickerManager.default.getAssetIdentifier(asset: phAsset) {
//                image = photo ?? UIImage()
//            } else {
//                PHImageManager.default().cancelImageRequest(imageRequestID!)
//            }
//
//            if (!isDegraded) {
//                imageRequestID = 0;
//            }
//        }
//
//        if let imageRequestID = imageRequestID {
//            if imageRequestID != 0 && imgReqID != imageRequestID {
//                PHImageManager.default().cancelImageRequest(imageRequestID)
//            }
//        }
//        imageRequestID = imgReqID
//        return image
//    }
    
}
extension AllVideoVC: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if(UserDefaults.standard.string(forKey: "typeVideo") == self.typeLabel.text){
            
        } else {
            if (UserDefaults.standard.string(forKey: "typeVideo") == "All".localized) {
                self.user.sortfinalvideos.removeAll()
                VideoCollection.reloadData()
                
                DispatchQueue.main.async {
                    IHProgressHUD.show(withStatus: "Loading".localized)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10 ) { [self] in
                        self.user.sortfinalvideos = self.user.finalvideos
                        self.typeLabel.text = "All".localized
                        self.selectedRows.removeAll()
                        self.deleteArray.removeAll()
                        
                        deletebtn.isHidden = true
                        flagselect = false
                        
                        deletebtn.setTitle("DELETE".localized, for: .normal)
                                                
                        rightBarButtonItemsSelect()
                        VideoCollection.reloadData()
                        IHProgressHUD.dismiss()
                    }
                }
            }
            else if(UserDefaults.standard.string(forKey: "typeVideo") == "Higher than 100 MB"){
                self.user.sortfinalvideos.removeAll()
                VideoCollection.reloadData()
                DispatchQueue.main.async {
                    IHProgressHUD.show(withStatus: "Loading".localized)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10 ) { [self] in
                        self.user.sortfinalvideos = self.user.finalvideos1
                        self.typeLabel.text = "Higher than 100 MB".localized
                        self.selectedRows.removeAll()
                        self.deleteArray.removeAll()
                        deletebtn.isHidden = true
                        deletebtn.setTitle("DELETE".localized, for: .normal)
                        rightBarButtonItemsSelect()
                        flagselect = false
                        VideoCollection.reloadData()
                        IHProgressHUD.dismiss()
                    }
                }
            }
            else if(UserDefaults.standard.string(forKey: "typeVideo") == "50-100 MB"){
                self.user.sortfinalvideos.removeAll()
                VideoCollection.reloadData()
                DispatchQueue.main.async {
                    IHProgressHUD.show(withStatus: "Loading".localized)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10 ) { [self] in
                        self.typeLabel.text = "50-100 MB".localized
                        self.user.sortfinalvideos = self.user.finalvideos2
                        self.selectedRows.removeAll()
                        self.deleteArray.removeAll()
                        deletebtn.isHidden = true
                        flagselect = false
                        deletebtn.setTitle("DELETE".localized, for: .normal)
                        rightBarButtonItemsSelect()
                        VideoCollection.reloadData()
                        IHProgressHUD.dismiss()
                    }
                }
            }
            else if(UserDefaults.standard.string(forKey: "typeVideo") == "10-50 MB"){
                self.user.sortfinalvideos.removeAll()
                VideoCollection.reloadData()
                DispatchQueue.main.async {
                    IHProgressHUD.show(withStatus: "Loading".localized)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10 ) { [self] in
                        self.typeLabel.text = "10-50 MB".localized
                        self.user.sortfinalvideos = self.user.finalvideos3
                        self.selectedRows.removeAll()
                        self.deleteArray.removeAll()
                        deletebtn.isHidden = true
                        flagselect = false
                        deletebtn.setTitle("DELETE".localized, for: .normal)
                        rightBarButtonItemsSelect()
                        VideoCollection.reloadData()
                        IHProgressHUD.dismiss()
                    }
                }
            }
            else if(UserDefaults.standard.string(forKey: "typeVideo") == "Others"){
                self.user.sortfinalvideos.removeAll()
                VideoCollection.reloadData()
                DispatchQueue.main.async {
                    IHProgressHUD.show(withStatus: "Loading".localized)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10 ) { [self] in
                        self.typeLabel.text = "Others".localized
                        self.user.sortfinalvideos = self.user.finalvideos4
                        self.selectedRows.removeAll()
                        self.deleteArray.removeAll()
                        deletebtn.isHidden = true
                        flagselect = false
                        deletebtn.setTitle("DELETE".localized, for: .normal)
                        rightBarButtonItemsSelect()
                        VideoCollection.reloadData()
                        IHProgressHUD.dismiss()
                    }
                }
            }
        }
        
        
    }
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        // to prevent animation, we need to dismiss it manuallly with animated: false
        presentationController.presentingViewController.dismiss(animated: false, completion: nil)
        return true
    }
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
    //    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
    //        return false
    //    }
}
extension UIView {
    func isTransformOnlyView() -> Bool {
        return self.layer.isKind(of: CATransformLayer.self)
    }
}
