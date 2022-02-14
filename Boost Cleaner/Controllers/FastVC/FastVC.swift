//
//  FastVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/16/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import CircleProgressView
import SystemServices
import SwiftyContacts
import Foundation
import Contacts
import CoreTelephony
import StoreKit
import Photos
import SwiftyGif
import EzPopup

class FastVC: UIViewController {
    
    //Localization
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var lblSimilarDesc: UILabel!
    @IBOutlet weak var lblSimilarVideo: UILabel!
    @IBOutlet weak var lblSimilarVideoItem: UILabel!
    @IBOutlet weak var lblScreenShots: UILabel!
    @IBOutlet weak var lblSimilarPhotos: UILabel!
    @IBOutlet weak var lblSimilarphotosItem: UILabel!
    @IBOutlet weak var btnClear: UIButton!
    
    //
    
    @IBOutlet weak var circleProgressView: CircleProgressView!
    @IBOutlet weak var similarVideoItems: UILabel!
    @IBOutlet var screenshotslbl: UILabel!
    @IBOutlet var screenshotsView: UIView!
    @IBOutlet var screenshotsbtn: UIButton!
    @IBOutlet var photosbtn: UIButton!
    @IBOutlet var videosbtn: UIButton!
    @IBOutlet var photosView: UIView!
    @IBOutlet var videosView: UIView!
    @IBOutlet var stepslbl: UILabel!
    @IBOutlet var searchstepslbl: UILabel!
    @IBOutlet var similarLbl: UILabel!
    @IBOutlet var topstoragelbl: UILabel!
    @IBOutlet var perlbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pImage: UIImageView!
    @IBOutlet weak var gifImage: UIImageView!
    
    @IBOutlet weak var bottomBtn: UIButton!
    
    let content = UNMutableNotificationContent()
    //    var imagesAssetSize = 0.0
    //var videosAssetSize = 0.0
    // var totalStorage = 0.0
    var flagback = false
    var arrAllImage: PHFetchResult<PHAsset>?
    var screenshots: PHFetchResult<PHAsset>?
    let user = SharedData.sharedUserInfo
    // var videos: PHFetchResult<PHAsset>?
    var deletevideos = [PHAsset]()
    var totalcount = 0;
    var doubleArry = [Double]();
    var locationArry = [Double]();
    var doubleArry2 = [Double]();
    var locationArry2 = [Double]();
    var finalvideos = [VideosModel]()
    var typeVideo = "All".localized
    var selectedRows:[IndexPath] = []
    var deleteArray = [Int]()
    
    var arrPhotoAssetsData = [AssetsData]()
    //  var finalarrPhotoAssetsData = [PhotoVC.FinalAssetsData]()
    var arrPhotoAssetsData2 = [AssetsData]()
    var arrCreationDate = [Date]()
    var arrDates = [String]()
    var finalarrDates = [String]()
    var sortfinalarrDates = [String]()
    let AlterSize = AlterFastCleaner.instantiate()
    
    struct AssetsData {
        var  imageDate: String, creationDate: Date, assetResult: PHFetchResult<PHAsset>
    }
    private func getLocalization(){
        lblScreenShots.text = "Similar Screenshots".localized
        lblSimilarVideo.text = lblSimilarVideo.text?.localized
        lblSimilarPhotos.text = lblSimilarPhotos.text?.localized
//        lbl.text = lblSimilarPhotos.text?.localized
        btnClear.setTitle(btnClear.currentTitle?.localized, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Fast Cleaner".localized
        self.getLocalization()
        
        self.similarLbl.isHidden = true
        self.similarVideoItems.isHidden = true
        self.screenshotslbl.isHidden = true
        //self.user.ScreenarrAllImage = screenshots
        self.screenshotsbtn.isEnabled = false
        self.photosbtn.isEnabled = false
        self.videosbtn.isEnabled = false
        self.screenshotsbtn.setBackgroundImage(UIImage(named: "select_bg_ic"), for: .normal)
        self.photosbtn.setBackgroundImage(UIImage(named: "select_bg_ic"), for: .normal)
        self.videosbtn.setBackgroundImage(UIImage(named: "select_bg_ic"), for: .normal)
        self.makeNavigationBarTransparent()
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        // rightBarButtonItemsSelect()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.circleProgressView.progress = Double(0/Double(100))
        //self.circleProgressView.centerImage = UIImage(named: "complete_ic")
        self.circleProgressView.centerImage = UIImage(named: "cricle_ic")
        // self.pImage.image = UIImage(named: "cricle_ic")
        // self.gifImage.image = UIImage.gifImageWithName("gif_search")
        
        do {
            let gif = try UIImage(gifName: "gif_search.gif")
            self.gifImage.setGifImage(gif, loopCount: -1)
        } catch {
            print(error)
        }
        
        stepslbl.text = "Step".localized + " 1 of 3".localized
        searchstepslbl.text = "Looking for Similar Videos".localized
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainView.frame.size.height = 1250//1880
            self.circleProgressView.trackWidth = 12
        } else {
            mainView.frame.size.height = 680//925
        }
       
        let status = PHPhotoLibrary.authorizationStatus()
        if (status != PHAuthorizationStatus.authorized) {
            Utilities.showAlert(title: "Photos Access Disabled".localized, message: "turn on Photos Access for this app.".localized, parentController: self, delegate: self)
        } else {
            if (self.user.videosfast) {
                self.fastAlert()
            } else {
                self.performSelector(inBackground: #selector(self.backgroundthread), with: nil)
            }
        }
    }
    
    func fastAlert() {
        if UIDevice.current.userInterfaceIdiom == .pad {
        guard let pickerVC = AlterSize else { return }
        pickerVC.delegate = self
        let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 500, popupHeight: 300)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        present(popupVC, animated: true, completion: nil)
        }
        else{
            guard let pickerVC = AlterSize else { return }
            pickerVC.delegate = self
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 300, popupHeight: 175)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            present(popupVC, animated: true, completion: nil)
        }
        
    }
    
    @objc func backgroundthread() {
        DispatchQueue.main.async { [self] in
            if Utilities.containsRatingEvent(event: ReviewPopupLocation.onScan) {
                Utilities.rateApp(controller: self)
            }
        }
        if(self.user.videosfast) {
            getVideos()
        } else {
            DispatchQueue.main.async { [self] in
                self.user.videosfast = false
                self.videosbtn.isEnabled = true
                self.similarVideoItems.isHidden = false
                self.videosbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                self.circleProgressView.progress = Double((100)/Double(100))
                self.perlbl.text = "\(100)" + "%"
                stepslbl.text = "Step 2 of 3".localized
                searchstepslbl.text = "Looking for Similar Screenshots".localized
                self.videosView.isHidden = false
                
            }
            self.getPhotos()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.user.fastsimilarcount = 0
        for k in 0..<self.user.fastarrPhotoAssetsData.count  {
            self.user.fastsimilarcount = self.user.fastsimilarcount + self.user.fastarrPhotoAssetsData[k].assetResult.count
            
        }
        if (UserDefaults.standard.bool(forKey: "showsize")) {
            self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastSimilarimagesAssetSize / 1024) + " GB"
            self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB".localized
            self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB".localized
            searchstepslbl.text =  String(format: "%.3f", self.user.fasttotalStorage) + " GB can be cleaned".localized
            self.bottomBtn.setTitle( "CLEAR ALL (" + String(format: "%.3f", self.user.fasttotalStorage) + " GB)", for: .normal)
            
        }
        else{
            self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized
            self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
            self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized
            searchstepslbl.text =  ""
            self.bottomBtn.setTitle( "CLEAR ALL ".localized, for: .normal)
        }
        //  similarVideoItems.text = "\( self.user.similarvideos.count)" + " videos"
        
        self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
        
        
    }
    deinit {
        print("deinit video")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
        if self.isMovingFromParent {
            self.flagback = true
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    @IBAction func similarPhotosButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FastSimilarMonthPhotosVC") as? FastSimilarMonthPhotosVC
        // self.user.finalarrPhotoAssetsData = self.finalarrPhotoAssetsData
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func similarVideoButtonPressed(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SimilarVideoVC") as? SimilarVideoVC
        vc!.videos = self.user.fastvideos
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func screenshotsButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ScreenshotsphotosVC") as? ScreenshotsphotosVC
        vc!.screenshotsresultArray = self.user.ScreenphotosresultArray
        vc!.screenshots = self.user.ScreenarrAllImage
        vc!.titleName = "Screenshots"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let itemsToDeleteCount = self.user.fastsimilarcount + self.user.countScreenshots + self.user.similarvideos.count
        if itemsToDeleteCount <= 0 {
            return
        }
        
        if EventManager.shared.dailyLimit == true && PaymentManager.shared.isPurchase() == false {
            let dailyLimitStr = "Daily Limit".localized
            let leftStr = "Left".localized
            let deleteStr = "Delete".localized
            let leftCount = abs(UserDefaults.standard.integer(forKey: "Count"))
            let alert = UIAlertController(title: "Limit on Cleaning".localized, message: "\(dailyLimitStr): 5 \n \(leftStr): " + "\(leftCount)", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "\(deleteStr) (" + "\(itemsToDeleteCount)" + ")", style: .default) { (action) in
                
                if(leftCount >= itemsToDeleteCount )
                {
                    self.deleteVideos()
                    //UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.user.fastsimilarcount), forKey: "Count")
                } else {
                    let inAppSpot = EventManager.shared.inAppLocations
                    if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onFastScan) {
                        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onFastScan)
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
            if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onFastScan) {
                Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onFastScan)
            } else {
                deleteVideos()
            }
        }
    }
    
    // self.user.duplicatesphotosArray2
    func deletePhotos() {
        deletevideos.removeAll()
        
        for i in 0..<self.user.duplicatesphotosArray2.count {
            
            for k in 0..<self.user.duplicatesphotosArray2[i].NumberArry!.count - 1{
                let dupPhoto = self.user.duplicatesphotosArray2[i]
                
                if let numberArr = dupPhoto.NumberArry {
                    let number = numberArr[k]
                    
                    if let allImageArr = self.arrAllImage {
                        if number < allImageArr.count {
                            let asset = allImageArr[number]
                            deletevideos.append(asset)
                        }
                    }
                }
                
                //let asset =   self.arrAllImage![self.user.duplicatesphotosArray2[i].NumberArry![k]]
                //deletevideos.append(asset)
            }
        }
        
        // In case deletion is failing, atleast avoid the crash
        if deletevideos.count <= 0 {
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.deletevideos as NSArray)
        }, completionHandler: {success, error in
            if (success) {
                DispatchQueue.main.async { [self] in
                    self.user.similarvideos.removeAll()
                    self.user.fastsimilarcount = 0
                    self.user.countScreenshots = 0
                    self.user.fastSimilarimagesAssetSize = 0.0
                    self.user.fastimagesAssetSize = 0.0
                    self.user.fastvideosAssetSize = 0.0
                    self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                    
                    if (UserDefaults.standard.bool(forKey: "showsize")) {
                        self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastSimilarimagesAssetSize / 1024) + " GB".localized
                        self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB".localized
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB".localized
                        searchstepslbl.text =  String(format: "%.3f", 0.000) + " GB can be cleaned".localized
                        self.bottomBtn.setTitle( "CLEAR ALL (" + String(format: "%.3f", 0.000) + " GB)", for: .normal)
                    } else {
                        self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized
                        self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized
                        searchstepslbl.text =  ""
                        self.bottomBtn.setTitle( "CLEAR ALL ".localized, for: .normal)
                    }
                }
            }
        })
    }
    
    private func getVideos() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            getsimilarVideo()
        }else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.getsimilarVideo()
                }else {
                    
                }
            })
        }
    }
    func deleteVideos() {
        deletevideos.removeAll()
        
        for i in 0..<self.user.similarvideos.count {
            for k in 0..<self.user.similarvideos[i].videosData!.count - 1{
                let asset =   self.user.fastvideos![self.user.similarvideos[i].videosData![k]]
                deletevideos.append(asset)
            }
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.deletevideos as NSArray)
        }, completionHandler: {success, error in
            if(success) {
                UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.user.fastsimilarcount), forKey: "Count")
                
                DispatchQueue.main.async { [self] in
                    self.user.similarvideos.removeAll()
                    
                    deletevideos.removeAll()
                    
                    self.user.fastvideosAssetSize = 0.0
                    self.deletePhotos()
                    self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                    if (UserDefaults.standard.bool(forKey: "showsize")) {
                        self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastSimilarimagesAssetSize / 1024) + " GB".localized
                        self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB".localized
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB".localized
                        searchstepslbl.text =  String(format: "%.3f", self.user.fasttotalStorage) + " GB can be cleaned".localized
                        self.bottomBtn.setTitle( "CLEAR ALL (" + String(format: "%.3f", self.user.fasttotalStorage) + " GB)", for: .normal)
                        
                    }
                    else{
                        self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized
                        self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized
                        searchstepslbl.text =  ""
                        self.bottomBtn.setTitle( "CLEAR ALL".localized, for: .normal)
                    }
                    
                }
            }
        })
        
        
        
    }
    
    private func getsimilarVideo(){
        DispatchQueue.main.async { [self] in
            self.perlbl.text = "0" + "%"
            self.circleProgressView.progress = Double(0/Double(100))
            stepslbl.text = "Step 1 of 3".localized
            searchstepslbl.text = "Looking for Similar Videos".localized
        }
        
        deletevideos.removeAll()
        finalvideos.removeAll()
        selectedRows.removeAll()
        deleteArray.removeAll()
        self.user.similarvideos.removeAll()
        doubleArry.removeAll()
        locationArry.removeAll()
        doubleArry2.removeAll()
        locationArry2.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)
        // print(imagesAndVideos[0].description)
        self.user.fastvideos = imagesAndVideos
        self.totalcount = imagesAndVideos.count
        for i in 0..<self.user.fastvideos!.count {
            if(flagback) {
                return
            }
            DispatchQueue.main.async {
                let value2 = Double(i)
                self.circleProgressView.progress = Double(value2/Double(self.user.fastvideos!.count))
                let x = Double(value2/Double(self.user.fastvideos!.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.perlbl.text = "\(result)" + "%"
            }
            
            let asset = self.user.fastvideos!.object(at: i)
            let resources = PHAssetResource.assetResources(for: asset) // your PHAsset
            var sizeOnDisk: Int64? = 0
            if let resource = resources.first {
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
                let fullNameArr = converByteToHumanReadable(sizeOnDisk!).components(separatedBy: " ")
                let name    = fullNameArr[0]
                let mb    = fullNameArr[1]
                // print(mb)
                if(mb == "MB"){
                    // print(name)
                    let sizevideo = Double(name) ?? 0.0
                    print(sizevideo)
                    self.doubleArry.append(sizevideo)
                    self.finalvideos.append(VideosModel( sizetype: "MB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                    
                    
                }
                else if(mb == "KB"){
                    let sizevideo = Double(name) ?? 0.0
                    print(sizevideo)
                    self.doubleArry.append(sizevideo)
                    self.finalvideos.append(VideosModel( sizetype: "KB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                    
                    
                }
                else if(mb == "GB"){
                    let sizevideo = Double(name) ?? 0.0
                    print(sizevideo)
                    self.doubleArry.append(sizevideo)
                    self.finalvideos.append(VideosModel( sizetype: "GB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                    
                    
                }
                
            }
        }
        
        finalvideos = finalvideos.sorted(by: { (img0: VideosModel, img1: VideosModel) -> Bool in
            return img0.sizevideos! > img1.sizevideos!
        })
        
        
        doubleArry2 = findDuplicates(array: doubleArry)
        doubleArry2 = doubleArry2.sorted(by: { $0 > $1 })
        
        
        for k in 0..<doubleArry2.count {
            for i in 0..<finalvideos.count {
                if(doubleArry2[k] == self.finalvideos[i].sizevideos!){
                    // print(findDuplicates(array: doubleArry)[k])
                    //  self.similarvideos.append(finalvideos[i])
                    let asset =    self.self.user.fastvideos![finalvideos[i].videosData!]
                    locationArry.append(asset.duration)
                }
                
            }
        }
        locationArry2 = findDuplicates(array: locationArry)
        locationArry2 = locationArry2.sorted(by: { $0 > $1 })
        
        for k in 0..<locationArry2.count {
            
            var videoData = [Int]()
            for i in 0..<finalvideos.count {
                let asset =    self.self.user.fastvideos![finalvideos[i].videosData!]
                if(locationArry2[k] == asset.duration){
                    videoData.append(finalvideos[i].videosData!)
                    DispatchQueue.main.async {
                        if (UserDefaults.standard.bool(forKey: "showsize")) {
                            self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB".localized
                        }
                        else{
                            self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
                        }
                        // similarVideoItems.text = "\( self.user.similarvideos.count)" + " videos"
                    }
                    if (UserDefaults.standard.bool(forKey: "showsize")) {
                        let resources = PHAssetResource.assetResources(for: asset) // your PHAsset
                        var sizeOnDisk: Int64? = 0
                        if let resource = resources.first {
                            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
                            let fullNameArr = converByteToHumanReadable(sizeOnDisk!).components(separatedBy: " ")
                            let name    = fullNameArr[0]
                            let mb    = fullNameArr[1]
                            // print(mb)
                            if(mb == "MB"){
                                // print(name)
                                let sizevideo = Double(name) ?? 0.0
                                print(sizevideo)
                                self.user.fastvideosAssetSize = self.user.fastvideosAssetSize + sizevideo
                                
                            }
                            else if(mb == "KB"){
                                let sizevideo = Double(name) ?? 0.0
                                print(sizevideo)
                                let fileSize = Double(sizevideo / 1024)
                                self.user.fastvideosAssetSize = self.user.fastvideosAssetSize + fileSize
                                
                            }
                            else if(mb == "GB"){
                                let sizevideo = Double(name) ?? 0.0
                                print(sizevideo)
                                let fileSize = Double(sizevideo * 1024)
                                self.user.fastvideosAssetSize = self.user.fastvideosAssetSize + fileSize
                                
                                
                            }
                            
                        }
                    }
                    
                }
                
                
            }
            if(!videoData.isEmpty){
                
                self.user.similarvideos.append(SimilarVideoModel(topVideo: videoData[0] , videosData: videoData) )
                //                let finaldelete = videoData.remove(at: 0)
                //                self.user.videodeleteArray.append([finaldelete])
            }
            
        }
        DispatchQueue.main.async { [self] in
            if (UserDefaults.standard.bool(forKey: "showsize")) {
                self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB".localized
            }
            else{
                self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
            }
            self.user.videosfast = false
            self.videosbtn.isEnabled = true
            self.similarVideoItems.isHidden = false
            self.videosbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
            self.circleProgressView.progress = Double((100)/Double(100))
            self.perlbl.text = "\(100)" + "%"
            stepslbl.text = "Step 2 of 3".localized
            searchstepslbl.text = "Looking for Similar Screenshots".localized
            self.videosView.isHidden = false
            
        }
        self.getPhotos()
        
    }
    func findDuplicatePhotos() {
        DispatchQueue.main.async { [self] in
            
            stepslbl.text = "Step 3 of 3".localized
            searchstepslbl.text = "Looking for Similar Photos".localized
            
        }
        
        var images: [OSTuple<NSString, NSData>] = []
        if(arrAllImage!.count == 0) {
            DispatchQueue.main.async {
                //                self.simlarButton.isEnabled = true
                //                self.simlarButton2.setBackgroundImage(UIImage(named: "contact_bg"), for: .normal)
            }
        }
        var countArray = 0
        if(arrAllImage!.count > 10000){
          //  countArray = 10000
          countArray = (3 * arrAllImage!.count) / 4
        }
        else{
            countArray = arrAllImage!.count
        }
        
        
        for i in 0..<countArray  {
            if(flagback) {
                return
            }
            
            let value2 = Float(i)
            let totalInt = Float(countArray)
            let result  = (value2/totalInt)
            
          
            
            DispatchQueue.main.async {
                let value2 = Double(i/5)
                self.circleProgressView.progress = Double(value2/Double(countArray))
                let x = Double(value2/Double(countArray))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.perlbl.text = "\(result)" + "%"
            }
            
            autoreleasepool {
                guard let imgData = arrAllImage![i].image.pngData() ?? nil else {return}
                images.append(OSTuple<NSString, NSData>(first: NSString(string: "\(i)"), andSecond: imgData as NSData?))
            }
        }
        
        
        let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.low, forImages: images)
        var arrayID = [[NSString]]()
        for tuple in similarImageIdsAsTuples {
            let id = [tuple.first!, tuple.second!]
            arrayID.append(id)
        }
        
        if(arrayID.isEmpty) {
            DispatchQueue.main.async {
                
            }
        }
        
        var resultArray = [[NSString]]()
        
        for (i,arrayI) in arrayID.enumerated() {
            if(flagback){
                return
            }
            let value2 = Double(i/4)
            let totalInt = Double(similarImageIdsAsTuples.count)
            let result  = (value2/totalInt) * 100
            
          
            DispatchQueue.main.async {
               // if(result+50.0 <= 99.0){
                    self.circleProgressView.progress = Double((result+20)/Double(100))
                    let x = Double((result+20)/Double(100))
                    let y = Double(round(100*x)/100)
                    let result = Int(y * 100)
                    self.perlbl.text = "\(result)" + "%"
                //}
                
            }
            
            
            
            if i == 0 {
                resultArray.append(arrayI)
            } else {
                var isContains = false
                for (j,result) in resultArray.enumerated() {
                    if result.contains(arrayI[1]) && result.contains(arrayI.first!) {
                        isContains = true
                        break
                    } else if result.contains(arrayI.first!)  {
                        var newdata = result
                        resultArray.remove(at: j)
                        newdata.append(arrayI[1])
                        resultArray.insert(newdata, at: j)
                        isContains = true
                        break
                    } else if result.contains(arrayI[1]) {
                        var newdata = result
                        resultArray.remove(at: j)
                        newdata.append(arrayI.first!)
                        resultArray.insert(newdata, at: j)
                        isContains = true
                        break
                    }
                }
                if !isContains {
                    resultArray.append(arrayI)
                    
                }
            }
            
        }
        
        
        
        var number2 = 0
        
        let formatter = DateFormatter()
        //     formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        
        
        for k in 0..<resultArray.count {
            if(flagback) {
                return
            }
            let value2 = Double(Double(k)/(2.5))
            let totalInt = Double(resultArray.count)
            let result  = (value2/totalInt*100)
            
            print( "fiaz Rest2 " + "\(result)")
            
            DispatchQueue.main.async {
                 // if(result+50.0 <= 99.0){
                    self.circleProgressView.progress = Double((result+45)/Double(100))
                    let x = Double((result+45)/Double(100))
                    let y = Double(round(100*x)/100)
                    let result = Int(y * 100)
                    self.perlbl.text = "\(result)" + "%"
                 //}
                
            }
        
            number2 += resultArray[k].count
                        
            if UserDefaults.standard.bool(forKey: "showBadgeCount") == true {
                DispatchQueue.main.async { [self] in // Correct
                    UIApplication.shared.applicationIconBadgeNumber = 1 //number2   // Removed intentionally as asked by client
                    content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber )
                    
                    // self.similarphotoslbl.isHidden = false
                    // self.duplicatephotoslbl.text =  "\(number2)" + " photos"
                }
            }

            var numberData = [Int]()
            var dateresultArray = [String]()
            for l in 0..<resultArray[k].count {
                autoreleasepool {
                    let number = Int(resultArray[k][l] as String)
                   
                    //  let formattedDate = formatter.string(from: self.arrAllImage![number!].creationDate!)
                    numberData.append(number!)
                    // print(formattedDate)
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "MMMM-yyyy"
                    let resultString = outputFormatter.string(from: self.arrAllImage![number!].creationDate!)
                    dateresultArray.append(resultString)
                    self.sortfinalarrDates.append(resultString)
                  
                    
                }
            }
            autoreleasepool {
                if(!numberData.isEmpty){
                    self.user.duplicatesphotosArray2.append(PhotosMonthModel( title: "\(resultArray[k].count)", DateArry: dateresultArray, NumberArry: numberData, firstPhoto: numberData[0] ) )
                }
            }
            //
            //
            
        }
      
        if (number2 == 0 && UserDefaults.standard.bool(forKey: "showBadgeCount")) {
            DispatchQueue.main.async { [self] in // Correct
                UIApplication.shared.applicationIconBadgeNumber = 1 //number2 // Removed intentionally as asked by client
                content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber )
                
                // self.similarphotoslbl.isHidden = false
                // self.duplicatephotoslbl.text =  "\(number2)" + " photos"
                
            }
        }
        
        self.user.fastsimilarcount = 0
        let uniqueStrings = uniqueElementsFrom(array:sortfinalarrDates)
        print("fiaz" + "\(uniqueStrings.count)")
        for k in 0..<uniqueStrings.count  {
            print(k)
            if(flagback) {
                return
            }
            let value2 = Double(k)
            let totalInt = Double(uniqueStrings.count)
            let result  = (value2/6.66/totalInt*100)

            print( "fiaz Rest " + "\(result)")
            DispatchQueue.main.async {
                if(result+85 <= 99.0){
                    self.circleProgressView.progress = Double((result+85)/Double(100))
                    let x = Double((result+85)/Double(100))
                    let y = Double(round(100*x)/100)
                    let result = Int(y * 100)
                    print(result)
                    self.perlbl.text = "\(result)" + "%"
                }

            }
            
            var photosData =  [PHAsset]()
            var imagesAssetSize = 0.0
            var unit: String = "KB"
            for i in 0..<self.user.duplicatesphotosArray2.count  {
                print(self.user.duplicatesphotosArray2[i].DateArry!)
                for m in 0..<self.user.duplicatesphotosArray2[i].DateArry!.count  {
                    autoreleasepool {
                        if(uniqueStrings[k] == self.user.duplicatesphotosArray2[i].DateArry![0]){
                            photosData.append(self.arrAllImage![self.user.duplicatesphotosArray2[i].NumberArry![m]])
                            if (UserDefaults.standard.bool(forKey: "showsize")) {
                                let resources = PHAssetResource.assetResources(for: self.arrAllImage![self.user.duplicatesphotosArray2[i].NumberArry![m]]) // your PHAsset
                                var sizeOnDisk: Int64? = 0
                                if let resource = resources.first {
                                    let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                                    sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
                                    let fullNameArr = converByteToHumanReadable(sizeOnDisk!).components(separatedBy: " ")
                                    let name    = fullNameArr[0]
                                    let mb    = fullNameArr[1]
                                    // print(mb)
                                    if(mb == "MB"){
                                        // print(name)
                                        let sizevideo = Double(name) ?? 0.0
                                        print(sizevideo)
                                        let size = self.user.fastSimilarimagesAssetSize + sizevideo
                                        self.user.fastSimilarimagesAssetSize = size
                                        imagesAssetSize = size
                                    }
                                    else if(mb == "KB"){
                                        let sizevideo = Double(name) ?? 0.0
                                        print(sizevideo)
                                        let fileSize = Double(sizevideo / 1024)
                                        let size = self.user.fastSimilarimagesAssetSize + fileSize
                                        self.user.fastSimilarimagesAssetSize = size
                                        imagesAssetSize = size
                                    }
                                    else if(mb == "GB"){
                                        let sizevideo = Double(name) ?? 0.0
                                        print(sizevideo)
                                        let fileSize = Double(sizevideo * 1024)
                                        let size = self.user.fastSimilarimagesAssetSize + fileSize
                                        self.user.fastSimilarimagesAssetSize = size
                                        imagesAssetSize = size
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
            autoreleasepool {
                if(photosData.count >= 2){
                    self.user.fastsimilarcount = self.user.fastsimilarcount + photosData.count
                    self.user.fastarrPhotoAssetsData.append(PhotoVC.FinalAssetsData(imageDate: uniqueStrings[k], assetResult: photosData)) //PhotoVC.FinalAssetsData(imageDate: uniqueStrings[k], assetResult: photosData, size: imagesAssetSize, sizeUnit: unit)
                }
            }
        }
        
        DispatchQueue.main.async { [self] in
            self.perlbl.text = "\(100)" + "%"
            self.bottomBtn.isHidden = false
            if (UserDefaults.standard.bool(forKey: "showsize")) {
                self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastSimilarimagesAssetSize / 1024) + " GB".localized
                self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items" + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB".localized
                self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                searchstepslbl.text =  String(format: "%.3f", self.user.fasttotalStorage) + " GB can be cleaned".localized
                
                self.bottomBtn.setTitle( "CLEAR ALL (" + String(format: "%.3f", self.user.fasttotalStorage) + " GB)", for: .normal)
            }
            else{
                self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized
                self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
                searchstepslbl.text =  ""
                self.bottomBtn.setTitle( "CLEAR ALL".localized, for: .normal)
            }
            self.circleProgressView.progress = Double((100)/Double(100))
            self.screenshotsbtn.isEnabled = true
            self.screenshotslbl.isHidden = false
            self.screenshotsbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
            self.photosbtn.isEnabled = true
            self.similarLbl.isHidden = false
            self.photosbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
            self.photosView.isHidden = false
            self.user.similarImagefast = false
            self.circleProgressView.progress = Double(100/Double(100))
            print(self.user.fastvideosAssetSize)
            print(  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB" )
            
            self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
            self.gifImage.isHidden = true
            self.pImage.image = UIImage(named: "complete_ic")
            self.circleProgressView.centerImage = UIImage(named: "complete_ic")
            stepslbl.text = "Scanning complete".localized
            
            self.perlbl.text = "100%"
            //            self.duplicatesbtn.isEnabled = true
            //            self.progressDuplicatesV.isHidden = true
        }
        
        
        
    }
    
    func convertToAssetsDataAndAppend(dateimage: String, date: Date, fetchOptions: PHFetchOptions, toArray: inout [AssetsData]){
        let components = date.get(.day, .month, .year)
        if let startDate = getDate(forDay: components.day!, forMonth: components.month!, forYear: components.year!, forHour: 0, forMinute: 0, forSecond: 0), let endDate = getDate(forDay: components.day!, forMonth: components.month!, forYear: components.year!, forHour: 23, forMinute: 59, forSecond: 59) {
            print(startDate)
            print(endDate)
            fetchOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@", startDate as NSDate, endDate as NSDate)
            let assetsPhotoFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
            toArray.append(AssetsData(imageDate: dateimage, creationDate: date, assetResult: assetsPhotoFetchResult))
        }
    }
    
    
    func getDate(forDay day: Int, forMonth month: Int, forYear year: Int, forHour hour: Int, forMinute minute: Int, forSecond second: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        var gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        gregorian.timeZone = NSTimeZone.system
        return gregorian.date(from: dateComponents)
    }
    func uniqueElementsFrom(array: [String]) -> [String] {
        //Create an empty Set to track unique items
        var set = Set<String>()
        let result = array.filter {
            guard !set.contains($0) else {
                //If the set already contains this object, return false
                //so we skip it
                return false
            }
            //Add this item to the set since it will now be in the array
            set.insert($0)
            //Return true so that filtered array will contain this item.
            return true
        }
        return result
    }
    
    private func getPhotos(){
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)
        
        
        //   arrAllImage = imagesAndVideos
        self.totalcount = imagesAndVideos.count
        self.user.arrAllImage = imagesAndVideos
        arrAllImage =  self.user.arrAllImage
        
        let sc_Fetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject ?? nil
        if(sc_Fetch == nil){
            if(self.user.similarImagefast){
                
                DispatchQueue.main.async { [self] in
                    self.screenshotsbtn.isEnabled = true
                    self.screenshotslbl.isHidden = false
                    self.screenshotsbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                    if (UserDefaults.standard.bool(forKey: "showsize")) {
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items" + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB"
                    }
                    else{
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items"
                    }
                }
                self.findDuplicatePhotos()
            }
            else{
                DispatchQueue.main.async { [self] in
                    self.bottomBtn.isHidden = false
                    self.screenshotsbtn.isEnabled = true
                    self.screenshotslbl.isHidden = false
                    self.screenshotsbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                    self.photosbtn.isEnabled = true
                    self.similarLbl.isHidden = false
                    self.photosbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                    if (UserDefaults.standard.bool(forKey: "showsize")) {
                        self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastSimilarimagesAssetSize / 1024) + " GB".localized
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB".localized
                        self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB".localized
                        self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                        searchstepslbl.text =  String(format: "%.3f", self.user.fasttotalStorage) + " GB can be cleaned".localized
                        self.bottomBtn.setTitle( "CLEAR ALL. (" + String(format: "%.3f", self.user.fasttotalStorage) + " GB)", for: .normal)
                    }
                    else{
                        self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized
                        self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
                        searchstepslbl.text =  ""
                        self.bottomBtn.setTitle( "CLEAR ALL ".localized, for: .normal)
                    }
                    self.photosView.isHidden = false
                    
                    self.circleProgressView.progress = Double(100/Double(100))
                    print(self.user.fastvideosAssetSize)
                    print(  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB" )
                    
                    self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                    self.gifImage.isHidden = true
                    self.pImage.image = UIImage(named: "complete_ic")
                    self.circleProgressView.centerImage = UIImage(named: "complete_ic")
                    stepslbl.text = "Scanning complete"
                    
                    self.perlbl.text = "100%"
                }
            }
            return
        }
        let Screenshots = PHAsset.fetchAssets(in: sc_Fetch!  , options: nil)
        
        print("All ScreenShots Count : " , Screenshots.count)
        
        if( self.user.ScreenarrAllImage?.count == Screenshots.count){
            
            if(self.user.similarImagefast){
                DispatchQueue.main.async { [self] in
                    self.screenshotsbtn.isEnabled = true
                    self.screenshotslbl.isHidden = false
                    self.screenshotsbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                    if (UserDefaults.standard.bool(forKey: "showsize")) {
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items" + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB"
                    }
                    else{
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items"
                    }
                }
                self.findDuplicatePhotos()
            }
            else{
                DispatchQueue.main.async { [self] in
                    self.bottomBtn.isHidden = false
                    self.screenshotsbtn.isEnabled = true
                    self.screenshotslbl.isHidden = false
                    self.screenshotsbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                    self.photosbtn.isEnabled = true
                    self.similarLbl.isHidden = false
                    self.photosbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                    if (UserDefaults.standard.bool(forKey: "showsize")) {
                        self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items" + " • " +  String(format: "%.3f", self.user.fastSimilarimagesAssetSize / 1024) + " GB"
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items" + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB"
                        self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items" + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB"
                        self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                        searchstepslbl.text =  String(format: "%.3f", self.user.fasttotalStorage) + " GB can be cleaned"
                        self.bottomBtn.setTitle( "CLEAR ALL (" + String(format: "%.3f", self.user.fasttotalStorage) + " GB)", for: .normal)
                    }
                    else{
                        self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized
                        self.screenshotslbl.text = "\(self.user.countScreenshots)" + " items".localized
                        self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
                        searchstepslbl.text =  ""
                        self.bottomBtn.setTitle( "CLEAR ALL ".localized, for: .normal)
                    }
                    self.photosView.isHidden = false
                    
                    self.screenshotsView.isHidden = false
                    self.circleProgressView.progress = Double(100/Double(100))
                    print(self.user.fastvideosAssetSize)
                    
                    
                    self.gifImage.isHidden = true
                    self.pImage.image = UIImage(named: "complete_ic")
                    self.circleProgressView.centerImage = UIImage(named: "complete_ic")
                    stepslbl.text = "Scanning complete".localized
                    self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                    
                    
                    self.perlbl.text = "100%"
                }
            }
        }
        else{
            findDuplicateScreenshots()
            
        }
        
        
    }
    func findDuplicateScreenshots() {
        
        DispatchQueue.main.async {
            self.perlbl.text = "0" + "%"
            self.circleProgressView.progress = Double(0/Double(100))
        }
        let sc_Fetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject!
        
        let Screenshots = PHAsset.fetchAssets(in: sc_Fetch , options: nil)
        
        print("All ScreenShots Count : ".localized , Screenshots.count)
        self.user.ScreenarrAllImage = Screenshots
        screenshots =  self.user.ScreenarrAllImage
        
        
        
        
        DispatchQueue.main.async {
            self.screenshotslbl.text =   "0" + " photos".localized
            if(self.screenshots?.count == 0){
                //                self.progressBar2.setProgress(progress: (CGFloat(1)), animated: true)
                //                self.progressBar2.isHidden = true
                self.screenshotslbl.isHidden = false
            }
            
        }
        var images: [OSTuple<NSString, NSData>] = []
        
        for i in 0..<screenshots!.count {
            if(flagback){
                return
            }
            let value2 = Float(i)
            let totalInt = Float(arrAllImage?.count ?? 0)
            let result  = (value2/totalInt)
            
            print(result)
            
            
            DispatchQueue.main.async {
                let value2 = Double(i/2)
                self.circleProgressView.progress = Double(value2/Double(self.screenshots!.count))
                let x = Double(value2/Double(self.screenshots!.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.perlbl.text = "\(result)" + "%"
            }
            autoreleasepool {
                guard let imgData = screenshots![i].image.pngData() ?? nil else {return}
                images.append(OSTuple<NSString, NSData>(first: NSString(string: "\(i)"), andSecond: imgData as NSData?))
            }
        }
        
        let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: images)
        
        var arrayID = [[NSString]]()
        for tuple in similarImageIdsAsTuples {
            let id = [tuple.first!, tuple.second!]
            arrayID.append(id)
            
        }
        
        var resultArray = [[NSString]]()
        
        for (i,arrayI) in arrayID.enumerated() {
            if(flagback){
                return
            }
            let value2 = Double(i/2)
            let totalInt = Double(similarImageIdsAsTuples.count)
            let result  = (value2/totalInt) * 100
            
            print(result)
            DispatchQueue.main.async {
                if(result+50.0 <= 99.0){
                    self.circleProgressView.progress = Double((result+50.0)/Double(100))
                    let x = Double((result+50.0)/Double(100))
                    let y = Double(round(100*x)/100)
                    let result = Int(y * 100)
                    self.perlbl.text = "\(result)" + "%"
                }
                
            }
            DispatchQueue.main.async {
                print("\(i)", "\(arrayID.count)")
                
            }
            
            if i == 0 {
                resultArray.append(arrayI)
            } else {
                var isContains = false
                for (j,result) in resultArray.enumerated() {
                    if result.contains(arrayI[1]) && result.contains(arrayI.first!) {
                        isContains = true
                        break
                    } else if result.contains(arrayI.first!)  {
                        var newdata = result
                        resultArray.remove(at: j)
                        newdata.append(arrayI[1])
                        resultArray.insert(newdata, at: j)
                        isContains = true
                        break
                    } else if result.contains(arrayI[1]) {
                        var newdata = result
                        resultArray.remove(at: j)
                        newdata.append(arrayI.first!)
                        resultArray.insert(newdata, at: j)
                        isContains = true
                        break
                    }
                }
                if !isContains {
                    resultArray.append(arrayI)
                    
                }
            }
        }
        
        
        
        var number2 = 0
        DispatchQueue.main.async {
            self.screenshotslbl.text =   "0" + " photos".localized
            if(resultArray.count == 0){
                //                self.progressBar2.setProgress(progress: (CGFloat(1)), animated: true)
                //                self.progressBar2.isHidden = true
                self.screenshotslbl.isHidden = false
            }
            
        }
        
        for k in 0..<resultArray.count {
            if(flagback){
                return
            }
            print(resultArray[k].count)
            number2 += resultArray[k].count
            // print("fiaz " + "\(number2)")
            DispatchQueue.main.async { // Correct
                //self.circleProgressView.progress = Double(100/Double(100))
                //                self.progressBar2.setProgress(progress: (CGFloat(1)), animated: true)
                //                self.progressBar2.isHidden = true
                self.screenshotslbl.isHidden = false
                //    self.screenshotslbl.text =    "\(number2)" + " photos"
                self.screenshotsView.isHidden = false
            }
            
            
            
            
        }
        self.user.countScreenshots = number2
        
        
        
        self.user.ScreenphotosresultArray = resultArray
        for k in 0..<self.user.ScreenphotosresultArray.count {
            
            
            for l in 0..<self.user.ScreenphotosresultArray[k].count {
                let number = Int(self.user.ScreenphotosresultArray[k][l] as String)
                //let asset =  self.user.ScreenarrAllImage(number)
                let asset = self.user.ScreenarrAllImage!.object(at: number!)
                DispatchQueue.main.async {
                    if (UserDefaults.standard.bool(forKey: "showsize")) {
                      //  self.screenshotslbl.text = "\(number2)" + " items" + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB"
                    }
                    else{
                        self.screenshotslbl.text = "\(number2)" + " items".localized
                    }
                    // similarVideoItems.text = "\( self.user.similarvideos.count)" + " videos"
                }
                if (UserDefaults.standard.bool(forKey: "showsize")) {
                    let resources = PHAssetResource.assetResources(for: asset) // your PHAsset
                    var sizeOnDisk: Int64? = 0
                    if let resource = resources.first {
                        let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                        sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
                        let fullNameArr = converByteToHumanReadable(sizeOnDisk!).components(separatedBy: " ")
                        let name    = fullNameArr[0]
                        let mb    = fullNameArr[1]
                        // print(mb)
                        if(mb == "MB"){
                            // print(name)
                            let sizevideo = Double(name) ?? 0.0
                            print(sizevideo)
                            self.user.fastimagesAssetSize = self.user.fastimagesAssetSize + sizevideo
                            
                        }
                        else if(mb == "KB"){
                            let sizevideo = Double(name) ?? 0.0
                            print(sizevideo)
                            let fileSize = Double(sizevideo / 1024)
                            self.user.fastimagesAssetSize = self.user.fastimagesAssetSize + fileSize
                            
                        }
                        else if(mb == "GB"){
                            let sizevideo = Double(name) ?? 0.0
                            print(sizevideo)
                            let fileSize = Double(sizevideo * 1024)
                            self.user.fastimagesAssetSize = self.user.fastimagesAssetSize + fileSize
                            
                            
                        }
                        
                    }
                }
            }
            
        }
        DispatchQueue.main.async {
            self.screenshotsbtn.isEnabled = true
            self.screenshotslbl.isHidden = false
            self.screenshotsbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
            if (UserDefaults.standard.bool(forKey: "showsize")) {
                self.screenshotslbl.text = "\(number2)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastimagesAssetSize / 1024) + " GB".localized
            }
            else{
                self.screenshotslbl.text = "\(number2)" + " items".localized
            }
        }
        if(self.user.similarImagefast){
            self.findDuplicatePhotos()
        }
        else{
            DispatchQueue.main.async { [self] in
                if (UserDefaults.standard.bool(forKey: "showsize")) {
                    self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastSimilarimagesAssetSize / 1024) + " GB"
                    self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized + " • " +  String(format: "%.3f", self.user.fastvideosAssetSize / 1024) + " GB".localized
                    self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                    self.bottomBtn.setTitle( "CLEAR ALL (" + String(format: "%.3f", self.user.fasttotalStorage) + " GB)", for: .normal)
                }
                else{
                    self.similarLbl.text = "\(self.user.fastsimilarcount)" + " items".localized
                    self.similarVideoItems.text = "\(self.user.similarvideos.count)" + " items".localized
                    self.bottomBtn.setTitle( "CLEAR ALL ", for: .normal)
                }
                self.screenshotsbtn.isEnabled = true
                self.screenshotslbl.isHidden = false
                self.screenshotsbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                self.photosbtn.isEnabled = true
                self.similarLbl.isHidden = false
                self.photosbtn.setBackgroundImage(UIImage(named: "list_bg_ic"), for: .normal)
                self.photosView.isHidden = false
                
                self.circleProgressView.progress = Double(100/Double(100))
                print(self.user.fastvideosAssetSize)
                
                
                self.user.fasttotalStorage = self.user.fastvideosAssetSize / 1024 + self.user.fastimagesAssetSize / 1024 + self.user.fastSimilarimagesAssetSize / 1024
                self.gifImage.isHidden = true
                self.pImage.image = UIImage(named: "complete_ic")
                self.circleProgressView.centerImage = UIImage(named: "complete_ic")
                stepslbl.text = "Scanning complete"
                if (UserDefaults.standard.bool(forKey: "showsize")) {
                    searchstepslbl.text =  String(format: "%.3f", self.user.fasttotalStorage) + " GB can be cleaned".localized
                }
                else{
                    searchstepslbl.text = ""
                }
                self.perlbl.text = "100%"
            }
        }
        
        
        
        
    }
    func findDuplicates(array: [Double]) -> [Double]
    {
        var duplicates = Set<Double>()
        var prevItem = 0.0
        
        for item in array
        {
            if(prevItem == item)
            {
                duplicates.insert(item)
            }
            
            prevItem = item
        }
        
        return Array(duplicates)
    }
    func converByteToHumanReadable(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(bytes))
    }
    func rightBarButtonItemsSelect(){
        
        let rightItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelbtn))
        if UIDevice.current.userInterfaceIdiom == .pad {
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
        }
        else{
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14  )!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
         //   rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
        }
        
        self.navigationItem.rightBarButtonItems = [rightItem]
        
    }
    @objc func cancelbtn() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: false, completion: nil)
    }
}

extension FastVC: AlterFastCleanerDelegate {
    func AlterViewController(sender: AlterFastCleaner, didSelectNumber number: Int) {
        dismiss(animated: true) {
            
            if(number == 1){
                UserDefaults.standard.set(true, forKey: "showsize")
                self.performSelector(inBackground: #selector(self.backgroundthread), with: nil)
            }
            if(number == 2){
                UserDefaults.standard.set(false, forKey: "showsize")
                self.performSelector(inBackground: #selector(self.backgroundthread), with: nil)
            }
        }
    }
    
}

extension FastVC: AlterLocationContactDelegate {

    func AlterViewController(sender: AlterLocationContact, didSelectNumber number: Int) {
        dismiss(animated: true) {
            if(number == 1) {
                Utilities.openAppSetting()
            }
        }
    }
}
