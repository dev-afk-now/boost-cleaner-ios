//
//  PhotoVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/30/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import UIKit
import Photos
import AVKit
import AVFoundation
import StoreKit
import CircleProgressView

class PhotoVC: BaseViewController {
    
    //Localization
    @IBOutlet weak var lblLive: UILabel!
    @IBOutlet weak var lblSimilarDesc: UILabel!
    @IBOutlet weak var lblScreenShots: UILabel!
    @IBOutlet weak var lblDuplicate: UILabel!
    @IBOutlet weak var lblSelfie: UILabel!
    @IBOutlet weak var lblSelfieItem: UILabel!
    
    @IBOutlet weak var blurrView: UIView!
    @IBOutlet weak var similarView: UIView!
    @IBOutlet weak var screenshotView: UIView!
    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var duplicateView: UIView!
    
    @IBOutlet var similarphotoslbl: UILabel!
    @IBOutlet var screenshotslbl: UILabel!
    @IBOutlet var livephotoslbl: UILabel!
    @IBOutlet var duplicatephotoslbl: UILabel!
    @IBOutlet var selfiephotoslbl: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var screenshotbtn: UIButton!
    @IBOutlet weak var duplicatesbtn: UIButton!
    @IBOutlet weak var livebtn: UIButton!
    @IBOutlet weak var selfiebtn: UIButton!
    @IBOutlet weak var similarbtn: UIButton!
    @IBOutlet weak var placesbtn: UIButton!
    
    
    @IBOutlet weak var prcLblScreenshot: UILabel!
    @IBOutlet weak var progressscreenshotV: UIView!
    @IBOutlet weak var cProgressVscreenshot: CircleProgressView!
    @IBOutlet weak var prcLblSimilar: UILabel!
    @IBOutlet weak var progressSimilarV: UIView!
    @IBOutlet weak var cProgressSimilar: CircleProgressView!
    
    @IBOutlet weak var prcLblSelfie: UILabel!
    @IBOutlet weak var progressSelfieV: UIView!
    @IBOutlet weak var cProgressVSelfie: CircleProgressView!
    
    
    @IBOutlet weak var prcLblLive: UILabel!
    @IBOutlet weak var progressLiveV: UIView!
    @IBOutlet weak var cProgressVLive: CircleProgressView!
    @IBOutlet weak var prcLblDuplicates: UILabel!
    @IBOutlet weak var progressDuplicatesV: UIView!
    @IBOutlet weak var cProgressVDuplicates: CircleProgressView!
    var arrPhotoAssetsData = [AssetsData]()
    // var finalarrPhotoAssetsData = [FinalAssetsData]()
    
    var arrPhotoAssetsData2 = [AssetsData]()
    
    var arrCreationDate = [Date]()
    var arrDates = [String]()
    var finalarrDates = [String]()
    var arrAllImage: PHFetchResult<PHAsset>?
    var screenshots: PHFetchResult<PHAsset>?
    var livephotos: PHFetchResult<PHAsset>?
    var selfiephotos: PHFetchResult<PHAsset>?
    var burstphotos: PHFetchResult<PHAsset>?
    var duplicatesphotosArray = [PhotosModel]()
    var allPhotos: [PhotoAssets] = []
    var calcStateDic = NSMutableDictionary(capacity: 5)
    let user = SharedData.sharedUserInfo
    var flagback = false
    var totalcount = 0
    var allImage = true
    var similarImage = true
    
    struct AssetsData {
        var  imageDate: String, creationDate: Date, assetResult: PHFetchResult<PHAsset>
    }
    
    struct FinalAssetsData {
        var  imageDate: String,  assetResult: [PHAsset], size: Double? = nil, sizeUnit: String? = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photo Cleaner".localized
        self.lblLive.text = "Live".localized
        self.lblSimilarDesc.text = "Similar".localized
        self.lblScreenShots.text = "Screenshots".localized
        self.lblDuplicate.text = "Duplicates".localized
        self.lblSelfie.text = "Selfie".localized
        
        let similarCount = UserDefaults.standard.integer(forKey: "similar_photos_found_count")
        if similarCount > 0 {
            self.similarphotoslbl.text = "\(similarCount)" + " photos".localized
        } else {
            self.similarphotoslbl.text = "0" + " photos".localized
        }
        
        self.screenshotslbl.text = "0" + " photos".localized
        self.livephotoslbl.text = "0" + " photos".localized
        self.duplicatephotoslbl.text = "0" + " photos".localized
        self.selfiephotoslbl.text = "0" + " photos".localized

        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        
        blurrView.dropShadow2()
        similarView.dropShadow2()
        screenshotView.dropShadow2()
        otherView.dropShadow2()
        duplicateView.dropShadow2()
        similarbtn.isEnabled = false
        screenshotbtn.isEnabled = false
        livebtn.isEnabled = false
        duplicatesbtn.isEnabled = false
        selfiebtn.isEnabled = false
        placesbtn.isEnabled = false
        
        calcStateDic.setValue(false, forKey: "similar")
        calcStateDic.setValue(false, forKey: "duplicates")
        calcStateDic.setValue(false, forKey: "screenshots")
        calcStateDic.setValue(false, forKey: "live")
        calcStateDic.setValue(false, forKey: "selfie")
        
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            mainView.frame.size.height = 1470//1880
//        } else {
//            mainView.frame.size.height = 735//925
//        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        if (status != PHAuthorizationStatus.authorized) {
            Utilities.showAlert(title: "Photos Access Disabled".localized, message: "turn on Photos Access for this app.".localized, parentController: self, delegate: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  checkAuthorizationForPhotoLibraryAndGet()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)

        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if self.isMovingFromParent {
            self.flagback = true
        }
      
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.duplicatephotoslbl.text =  "\(self.user.countPhotos) " + " photos".localized
        performSelector(inBackground: #selector(backgroundthread), with: nil)
    }
    @objc func backgroundthread() {
        self.checkAuthorizationForPhotoLibraryAndGet()
    }
    @IBAction func otherButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelfiephotosVC") as? SelfiephotosVC
        vc!.selfieresultArray =  self.user.SelfiephotosresultArray
        vc!.selfiePhoto = self.user.SelfiearrAllImage
        vc!.titleName = "Selfie".localized
        vc!.dismissBlock = { [weak self] in
            vc!.navigationController?.popViewController(animated: false)
            guard let weakSelf = self else { return }
            weakSelf.findDuplicateSelfiePhotos()
        }
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func onBtnPlaceAction(_ sender: UIButton) {
//        if let allImg = self.arrAllImage {
//            //PhotosPlacesVC.pushVC(from: self, with: allImg)
//        }
    }
    
    @IBAction func blurredButtonPressed(_ sender: UIButton) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LivephotosVC") as? LivephotosVC
        vc!.liveresultArray =  self.user.LivephotosresultArray
        vc!.livep = self.user.LivearrAllImage
        vc!.titleName = "Live".localized
        vc!.dismissBlock = { [weak self] in
            vc!.navigationController?.popViewController(animated: false)
            guard let weakSelf = self else { return }
            weakSelf.findDuplicateLivePhotos()
        }
        self.navigationController?.pushViewController(vc!, animated: true)
        
        //        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BlurredVC") as? BlurredVC
        //        self.navigationController?.pushViewController(vc!, animated: true)
        
        //        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BurstPhotoVC") as? BurstPhotoVC
        //        vc!.burstresultArray = self.user.BurstphotosresultArray
        //        vc!.photosArray = self.user.BurstarrAllImage
        //        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func duplicatesButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DuplicatesPhotoVC") as? DuplicatesPhotoVC
        vc!.photosArray =   self.user.arrAllImageDuplicates
        vc!.dismissBlock = { [weak self] in
            vc!.navigationController?.popViewController(animated: false)
            guard let weakSelf = self else { return }
            weakSelf.findDuplicatePhotos()
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func screenshotsButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ScreenshotsphotosVC") as? ScreenshotsphotosVC
        vc!.screenshotsresultArray = self.user.ScreenphotosresultArray
        vc!.screenshots = self.user.ScreenarrAllImage
        vc!.titleName = "Screenshots".localized
        vc!.dismissBlock = { [weak self] in
            vc!.navigationController?.popViewController(animated: false)
            guard let weakSelf = self else { return }
            weakSelf.findDuplicateScreenshots()
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func similarButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SimilarMonthPhotosVC") as? SimilarMonthPhotosVC
        //self.user.finalarrPhotoAssetsData = self.finalarrPhotoAssetsData
        // vc!.photosresultArray = self.user.photosresultArray
        self.navigationController?.pushViewController(vc!, animated: true)
        //        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SimilarVC") as? SimilarVC
        //        vc!.photosArray = self.user.arrAllImage
        //        vc!.photosresultArray = self.user.photosresultArray
        //        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func getAllPhotos(completionHandler: ((_ assets: [PHAsset]?)->())?) {
        guard let allAssets = arrAllImage else { completionHandler?(nil); return }
        var arrAssets: [PHAsset] = []
        for i in 0..<allAssets.count {
            let asset = allAssets[i]
            arrAssets.append(asset)
            if arrAssets.count == allAssets.count {
                completionHandler?(arrAssets)
            }
        }
    }
    
    func findDuplicates(array: [String]) -> [String]
    {
        var duplicates = Set<String>()
        var prevItem = ""
        
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
    
    func checkAllCalculationStates() {
        let similar = calcStateDic.value(forKey: "similar") as? Bool ?? false
        let duplicates = calcStateDic.value(forKey: "duplicates") as? Bool ?? false
        let screenshots = calcStateDic.value(forKey: "screenshots") as? Bool ?? false
        let live = calcStateDic.value(forKey: "live") as? Bool ?? false
        let selfie = calcStateDic.value(forKey: "selfie") as? Bool ?? false
        
        if similar && duplicates && screenshots && live && selfie {
            similarbtn.isEnabled = true
            screenshotbtn.isEnabled = true
            livebtn.isEnabled = true
            duplicatesbtn.isEnabled = true
            selfiebtn.isEnabled = true
            placesbtn.isEnabled = true
        } else {
            similarbtn.isEnabled = false
            screenshotbtn.isEnabled = false
            livebtn.isEnabled = false
            duplicatesbtn.isEnabled = false
            selfiebtn.isEnabled = false
            placesbtn.isEnabled = false
        }
    }
    
    private func checkAuthorizationForPhotoLibraryAndGet(){
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
           // let concurrentQueue = DispatchQueue(label: "Suntechltd.Phuongnga.Boost", attributes: .concurrent)
            let concurrentQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".concurrentQueue", qos: .utility, attributes: .concurrent)

            concurrentQueue.async {
                if(self.user.similarImage) {
                    if(self.similarImage ) {
                        self.fetchPhotosSimilar()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.progressSimilarV.isHidden = true
                        //self.similarbtn.isEnabled = true
                        self.calcStateDic.setValue(true, forKey: "similar")
                        self.checkAllCalculationStates()
                    }
                }
            }
            
            concurrentQueue.async { [self] in
                getAllPhotos()
            }
        } else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    let concurrentQueue = DispatchQueue(label: "Suntechltd.Phuongnga.Boost", attributes: .concurrent)
                    
                    concurrentQueue.async {
                        if(self.user.similarImage){
                            if(self.similarImage ){
                                self.fetchPhotosSimilar()
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.progressSimilarV.isHidden = true
                                //self.similarbtn.isEnabled = true
                                self.calcStateDic.setValue(true, forKey: "similar")
                                self.checkAllCalculationStates()
                            }
                        }
                    }

                    concurrentQueue.async { [self] in
                        getAllPhotos()
                    }
                    
                }else {
                    
                }
            })
        }
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
    func fetchPhotosSimilarMonths() {
        let uniqueStrings = uniqueElementsFrom(array:finalarrDates)
        var photosFoundCount = 0
        print(uniqueStrings)
        
        for k in 0..<uniqueStrings.count  {
            var photosData =  [PHAsset]()
            var imagesAssetSize = 0.0
            var unit: String = "KB"
            for i in 0..<self.arrPhotoAssetsData.count  {
                if(uniqueStrings[k] == self.arrPhotoAssetsData[i].imageDate){
                    for m in 0..<self.arrPhotoAssetsData[i].assetResult.count  {
                        let asset = self.arrPhotoAssetsData[i].assetResult[m]
                        photosData.append(asset)
//                        let resources = PHAssetResource.assetResources(for: asset)
//                        var sizeOnDisk: Int64? = 0
//                        if let resource = resources.first {
//                            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
//                            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
//                            let fullNameArr = converByteToHumanReadable(sizeOnDisk!).components(separatedBy: " ")
//                            let name = fullNameArr[0]
//                            let mb = fullNameArr[1]
//                            if(mb == "MB"){
//                                let size = Double(name) ?? 0.0
//                                imagesAssetSize = imagesAssetSize + size
//                                unit = mb
//                            } else if(mb == "KB"){
//                                let size = Double(name) ?? 0.0
//                                // print(sizevideo)
//                                let fileSize = Double(size / 1024)
//                                imagesAssetSize = imagesAssetSize + fileSize
//                                unit = mb
//                            } else if(mb == "GB"){
//                                let size = Double(name) ?? 0.0
//                                let fileSize = Double(size * 1024)
//                                imagesAssetSize = imagesAssetSize + fileSize
//                                unit = mb
//                            }
//                        }
                        photosFoundCount = photosFoundCount + 1
                    }
                }
            }
            self.user.finalarrPhotoAssetsData.append(FinalAssetsData(imageDate: uniqueStrings[k], assetResult: photosData)) //FinalAssetsData(imageDate: uniqueStrings[k], assetResult: photosData, size: imagesAssetSize, sizeUnit: unit)
            let value2 = Double(k/2)
            let totalInt = Double(uniqueStrings.count)
            let result  = (value2/totalInt) * 100
            
            print(result)
            DispatchQueue.main.async {
                self.cProgressSimilar.progress = Double((result+50.0)/Double(100))
                let x = Double((result+50.0)/Double(100))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblSimilar.text = "\(result)" + "%"
                
            }
            
        }
        DispatchQueue.main.async {
            // This needs to be handled better, just making a quick fix but not a good approach
            UserDefaults.standard.set(photosFoundCount, forKey: "similar_photos_found_count")
            UserDefaults.standard.synchronize()
            
            self.user.similarImage = false
            self.cProgressSimilar.progress = Double((100)/Double(100))
            self.prcLblSimilar.text = "\(100)" + "%"
            self.similarphotoslbl.text = "\(photosFoundCount)" + " photos".localized
            //self.similarbtn.isEnabled = true
            self.progressSimilarV.isHidden = true
            self.calcStateDic.setValue(true, forKey: "similar")
            self.checkAllCalculationStates()
        }
    }
    
    func converByteToHumanReadable(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func fetchPhotosSimilar() {
        self.similarImage = false
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        
        //Photos fetch
        let fetchOptions = PHFetchOptions()
        let sortOrder = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.sortDescriptors = sortOrder
        let assetsFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        arrCreationDate = [Date]()
        arrDates = [String]()
        arrPhotoAssetsData = [AssetsData]()
        
        //Getting All dates
        for index in 0..<assetsFetchResult.count  {
            if(flagback) {
                return
            }
            if let creationDate = assetsFetchResult[index].creationDate {
                let formattedDate = formatter.string(from: creationDate)
//                let dateStringFormatter = DateFormatter()
//                dateStringFormatter.dateFormat = "d-MMM-yyyy"
//                let outputFormatter = DateFormatter()
//                outputFormatter.dateFormat = "MMMM-yyyy"
//                let showDate = dateStringFormatter.date(from: formattedDate)
//                let resultString = outputFormatter.string(from: showDate!)
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "MMMM-yyyy"
                let resultString = outputFormatter.string(from: creationDate)
                
                DispatchQueue.main.async {
                    self.calcStateDic.setValue(false, forKey: "similar")
                    self.similarbtn.isEnabled = false
                    self.progressSimilarV.isHidden = false
                    self.checkAllCalculationStates()
                    
                    let value2 = Double(index/2)
                    self.cProgressSimilar.progress = Double(value2/Double(assetsFetchResult.count))
                    let x = Double(value2/Double(assetsFetchResult.count))
                    let y = Double(round(100*x)/100)
                    let result = Int(y * 100)
                    self.prcLblSimilar.text = "\(result)" + "%"
                }
                if !arrDates.contains(formattedDate) {
                    arrDates.append(formattedDate)
                    finalarrDates.append(resultString)
                    arrCreationDate.append(creationDate)
                    convertToAssetsDataAndAppend(dateimage: resultString, date: creationDate, fetchOptions: fetchOptions, toArray: &arrPhotoAssetsData)
                }
            }
        }
        fetchPhotosSimilarMonths()
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
    
    private func getAllPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)
        //   arrAllImage = imagesAndVideos
        self.totalcount = imagesAndVideos.count
        self.user.arrAllImage = imagesAndVideos
        //  arrAllImage =  self.user.arrAllImage
        
        print( self.user.arrAllImage!.count)
        let sc_Fetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject!
        let Screenshots = PHAsset.fetchAssets(in: sc_Fetch , options: nil)
        
        print("All ScreenShots Count : " , Screenshots.count)
        //  self.user.ScreenarrAllImage = Screenshots
        
        if( self.user.ScreenarrAllImage?.count == Screenshots.count){
            
            DispatchQueue.main.async {
                self.screenshotslbl.isHidden = false
                //self.screenshotbtn.isEnabled = true
                self.calcStateDic.setValue(true, forKey: "screenshots")
                self.checkAllCalculationStates()
                
                self.screenshotslbl.text =    "\(self.user.countScreenshots)" + " photos".localized
                self.progressscreenshotV.isHidden = true
                //
                //  self.progressBar2.isHidden = true
            }
        }
        else{
            findDuplicateScreenshots()
        }
        
        
        
        if #available(iOS 10.3, *) {
            let sc_Fetchlive = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumLivePhotos, options: nil).firstObject!
            let sc_Assetslive = PHAsset.fetchAssets(in: sc_Fetchlive , options: nil)
            
            print("All sc_Assetslive Count : " , sc_Assetslive.count)
            
            // self.user.LivearrAllImage = sc_Assetslive
            if( self.user.LivearrAllImage?.count == sc_Assetslive.count){
                DispatchQueue.main.async {
                    self.livephotoslbl.isHidden = false
                    //self.livebtn.isEnabled = true
                    self.calcStateDic.setValue(true, forKey: "live")
                    self.checkAllCalculationStates()
                    self.progressLiveV.isHidden = true
                    self.livephotoslbl.text =    "\(self.user.countLive)" + " photos".localized
                    // self.progressBar3.isHidden = true
                }
            }
            else{
                findDuplicateLivePhotos()
            }
        } else {
            
            // Fallback on earlier versions
        }
        
        
        let sc_Fetchburst = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: nil).firstObject!
        
        let sc_Assetsburst = PHAsset.fetchAssets(in: sc_Fetchburst , options: nil)
        
        print("All sc_Assetsburst Count : " , sc_Assetsburst.count)
        
        //   self.user.BurstarrAllImage = sc_Assetsburst
        if( self.user.SelfiearrAllImage?.count == sc_Assetsburst.count){
            DispatchQueue.main.async {
                self.selfiephotoslbl.isHidden = false
                self.calcStateDic.setValue(true, forKey: "selfie")
                self.checkAllCalculationStates()
                //self.selfiebtn.isEnabled = true
                self.progressSelfieV.isHidden = true
                self.selfiephotoslbl.text =    "\(self.user.countSelfie)" + " photos".localized
            }
        }
        else{
            findDuplicateSelfiePhotos()
        }
        
        if(allImage){
            if(self.user.duplicatesImages){
                findDuplicatePhotos()
            }
            else{
                DispatchQueue.main.async {
                    self.prcLblDuplicates.text = "\(100)" + "%"
                    self.cProgressVDuplicates.progress = Double((100)/Double(100))
                    self.calcStateDic.setValue(true, forKey: "duplicates")
                    self.checkAllCalculationStates()
                    //self.duplicatesbtn.isEnabled = true
                    self.progressDuplicatesV.isHidden = true
                }
            }
        }
        
    }
    
    func findDuplicatePhotos() {
        allImage = false
        
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false /*true*/) ]
        options.predicate = NSPredicate(format: "NOT (((mediaSubtype & %d) != 0) || ((mediaSubtype & %d) != 0))", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoLive.rawValue)
        let imagesAndVideos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
        arrAllImage =  imagesAndVideos
        self.user.arrAllImageDuplicates = arrAllImage
        print(arrAllImage!.count)
        DispatchQueue.main.async {
            
            self.duplicatephotoslbl.text =  "0" + " photos".localized
            if(self.arrAllImage?.count == 0) {
                self.calcStateDic.setValue(true, forKey: "duplicates")
                self.checkAllCalculationStates()
                //self.duplicatesbtn.isEnabled = true
                self.progressDuplicatesV.isHidden = true
                self.similarphotoslbl.isHidden = false
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didcomplete"), object: nil )
            }
        }
        
        var images: [OSTuple<NSString, NSData>] = []
        if(arrAllImage!.count == 0) {
            DispatchQueue.main.async {
                self.duplicatephotoslbl.text =  "0" + " photos".localized
                self.prcLblDuplicates.text = "\(100)" + "%"
                self.cProgressVDuplicates.progress = Double((100)/Double(100))
                self.calcStateDic.setValue(true, forKey: "duplicates")
                self.checkAllCalculationStates()
                //self.duplicatesbtn.isEnabled = true
                self.progressDuplicatesV.isHidden = true
            }
        }
        
        
        for i in 0..<arrAllImage!.count  {
            if(flagback) {
                return
            }
            
            let value2 = Float(i)
            let totalInt = Float(arrAllImage!.count)
            let result  = (value2/totalInt)
            
            print(result)
            
            DispatchQueue.main.async {
                self.calcStateDic.setValue(false, forKey: "duplicates")
                self.duplicatesbtn.isEnabled = false
                self.progressDuplicatesV.isHidden = false
                self.checkAllCalculationStates()
                
                let value2 = Double(i/2)
                self.cProgressVDuplicates.progress = Double(value2/Double(self.arrAllImage!.count))
                let x = Double(value2/Double(self.arrAllImage!.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblDuplicates.text = "\(result)" + "%"
            }
            
            autoreleasepool {
                if let allImageArr = arrAllImage {
                    if i < allImageArr.count {
                        let imgContainer = allImageArr[i]
                        let image = imgContainer.image
                        
                        if let imgData = image.pngData() {
                            images.append(OSTuple<NSString, NSData>(first: NSString(string: "\(i)"), andSecond: imgData as NSData?))
                        }
                    }
                }
                
                //guard let imgData = arrAllImage![i].image.pngData() ?? nil else {return}
                //images.append(OSTuple<NSString, NSData>(first: NSString(string: "\(i)"), andSecond: imgData as NSData?))
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
                //                self.simlarButton.isEnabled = true
                //                self.simlarButton2.setBackgroundImage(UIImage(named: "contact_bg"), for: .normal)
            }
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
                self.cProgressVDuplicates.progress = Double((result+50.0)/Double(100))
                let x = Double((result+50.0)/Double(100))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblDuplicates.text = "\(result)" + "%"
                
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
            self.user.photosresultArray = resultArray
        }
        
        
        
        var number2 = 0
        DispatchQueue.main.async {
            self.duplicatephotoslbl.text =  "0" + " photos".localized
            if(resultArray.count == 0){
                self.calcStateDic.setValue(true, forKey: "duplicates")
                self.checkAllCalculationStates()
                //self.duplicatesbtn.isEnabled = true
                self.progressDuplicatesV.isHidden = true
                self.similarphotoslbl.isHidden = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didcomplete"), object: nil )
                
            }
            
        }
        for k in 0..<resultArray.count {
            if(flagback){
                return
            }
            print(resultArray[k].count)
            number2 += resultArray[k].count
            DispatchQueue.main.async { // Correct
                self.similarphotoslbl.isHidden = false
                self.duplicatephotoslbl.text =  "\(number2)" + " photos".localized
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didcomplete"), object: nil )
            }
            
            var numberData = [Int]()
            for l in 0..<resultArray[k].count {
                let number = Int(resultArray[k][l] as String)
                numberData.append(number!)
            }
            if(!numberData.isEmpty){
                self.user.duplicatesphotosArray.append(PhotosModel( title: "\(resultArray[k].count)", NumberArry: numberData, firstPhoto: numberData[0] ) )
            }
            
            
            
        }
        
        self.user.countPhotos = number2
        self.user.photosresultArray = resultArray
        
        DispatchQueue.main.async {
            self.user.duplicatesImages = false
            self.prcLblDuplicates.text = "\(100)" + "%"
            self.cProgressVDuplicates.progress = Double((100)/Double(100))
            //self.duplicatesbtn.isEnabled = true
            self.calcStateDic.setValue(true, forKey: "duplicates")
            self.checkAllCalculationStates()
            self.progressDuplicatesV.isHidden = true
        }
        
        UserDefaults.standard.set( self.user.arrAllImage?.count, forKey: "allImages")
        
    }
    
    //    func findDuplicateBurstPhotos() {
    //
    //        let sc_Fetchburst = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: nil).firstObject!
    //
    //        let sc_Assetsburst = PHAsset.fetchAssets(in: sc_Fetchburst , options: nil)
    //
    //        print("All sc_Assetsburst Count : " , sc_Assetsburst.count)
    //
    //        self.user.BurstarrAllImage = sc_Assetsburst
    //        burstphotos =  self.user.BurstarrAllImage
    //
    //        DispatchQueue.main.async {
    //            self.burstphotoslbl.text =   "0" + " photos"
    //            if(self.burstphotos?.count == 0){
    //                //                self.progressBar4.setProgress(progress: (CGFloat(1)), animated: true)
    //                //                self.progressBar4.isHidden = true
    //                self.burstphotoslbl.isHidden = false
    //            }
    //        }
    //        var images: [OSTuple<NSString, NSData>] = []
    //
    //        for i in 0..<burstphotos!.count {
    //            if(flagback){
    //                return
    //            }
    //            let value2 = Float(i)
    //            let totalInt = Float(arrAllImage!.count)
    //            let result  = (value2/totalInt)
    //
    //            print(result)
    //
    //            DispatchQueue.main.async {
    //                //                self.progressBar4.isHidden = false
    //                //                self.progressBar4.setProgress(progress: (CGFloat(result)), animated: true)
    //
    //            }
    //            autoreleasepool {
    //                let imgData = burstphotos![i].image.pngData() ?? nil
    //                images.append(OSTuple<NSString, NSData>(first: NSString(string: "\(i)"), andSecond: imgData as NSData?))
    //            }
    //        }
    //
    //        let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: images)
    //
    //        var arrayID = [[NSString]]()
    //        for tuple in similarImageIdsAsTuples {
    //            let id = [tuple.first!, tuple.second!]
    //            arrayID.append(id)
    //
    //        }
    //
    //        var resultArray = [[NSString]]()
    //
    //        for (i,arrayI) in arrayID.enumerated() {
    //            if(flagback){
    //                return
    //            }
    //            DispatchQueue.main.async {
    //                print("\(i)", "\(arrayID.count)")
    //
    //            }
    //
    //            if i == 0 {
    //                resultArray.append(arrayI)
    //            } else {
    //                var isContains = false
    //                for (j,result) in resultArray.enumerated() {
    //                    if result.contains(arrayI[1]) && result.contains(arrayI.first!) {
    //                        isContains = true
    //                        break
    //                    } else if result.contains(arrayI.first!)  {
    //                        var newdata = result
    //                        resultArray.remove(at: j)
    //                        newdata.append(arrayI[1])
    //                        resultArray.insert(newdata, at: j)
    //                        isContains = true
    //                        break
    //                    } else if result.contains(arrayI[1]) {
    //                        var newdata = result
    //                        resultArray.remove(at: j)
    //                        newdata.append(arrayI.first!)
    //                        resultArray.insert(newdata, at: j)
    //                        isContains = true
    //                        break
    //                    }
    //                }
    //                if !isContains {
    //                    resultArray.append(arrayI)
    //
    //                }
    //            }
    //        }
    //
    //
    //
    //        var number2 = 0
    //        DispatchQueue.main.async {
    //            self.burstphotoslbl.text =    "0" + " photos"
    //            if(resultArray.count == 0){
    //                //                self.progressBar4.setProgress(progress: (CGFloat(1)), animated: true)
    //                //                self.progressBar4.isHidden = true
    //                self.burstphotoslbl.isHidden = false
    //            }
    //        }
    //
    //        for k in 0..<resultArray.count {
    //            if(flagback){
    //                return
    //            }
    //            print(resultArray[k].count)
    //            number2 += resultArray[k].count
    //            //   print("fiaz " + "\(number2)")
    //            DispatchQueue.main.async { // Correct
    //                //                self.progressBar4.setProgress(progress: (CGFloat(1)), animated: true)
    //                //                self.progressBar4.isHidden = true
    //                self.burstphotoslbl.isHidden = false
    //                self.burstphotoslbl.text =   "\(number2)" + " photos"
    //
    //            }
    //
    //        }
    //        self.user.countBurst = number2
    //
    //
    //        self.user.BurstphotosresultArray = resultArray
    //
    //    }
    func findDuplicateSelfiePhotos (){
        let sc_Fetchlive = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: nil).firstObject!
        
        let sc_Assetslive = PHAsset.fetchAssets(in: sc_Fetchlive , options: nil)
        
        print("All sc_Assetslive Count : " , sc_Assetslive.count)
        
        self.user.SelfiearrAllImage = sc_Assetslive
        selfiephotos =  self.user.SelfiearrAllImage
        
        
        
        DispatchQueue.main.async {
            self.selfiephotoslbl.text =   "0" + " photos".localized
            if(self.selfiephotos?.count == 0){
                self.calcStateDic.setValue(true, forKey: "selfie")
                self.checkAllCalculationStates()
                //self.selfiebtn.isEnabled = true
                self.progressSelfieV.isHidden = true
                self.selfiephotoslbl.isHidden = false
            }
        }
        var images: [OSTuple<NSString, NSData>] = []
        
        
        
        for i in 0..<selfiephotos!.count {
            if(flagback){
                return
            }
            // let value2 = Double(i)
            DispatchQueue.main.async {
                self.progressSelfieV.isHidden = false
                self.selfiebtn.isEnabled = false
                self.calcStateDic.setValue(false, forKey: "selfie")
                self.checkAllCalculationStates()
                
                let value2 = Double(i/2)
                self.cProgressVSelfie.progress = Double(value2/Double(self.selfiephotos!.count))
                let x = Double(value2/Double(self.selfiephotos!.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblSelfie.text = "\(result)" + "%"
                
            }
            autoreleasepool {
                guard let imgData = selfiephotos![i].image.pngData() ?? nil else {return}
                images.append(OSTuple<NSString, NSData>(first: NSString(string: "\(i)"), andSecond: imgData as NSData?))
            }
        }
        
        let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: images)
        
        var arrayID = [[NSString]]()
        for tuple in similarImageIdsAsTuples {
            if(flagback){
                return
            }
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
                self.cProgressVSelfie.progress = Double((result+50.0)/Double(100))
                let x = Double((result+50.0)/Double(100))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblSelfie.text = "\(result)" + "%"
                
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
            self.selfiephotoslbl.text =   "0" + " photos".localized
            if(resultArray.count == 0){
                self.calcStateDic.setValue(true, forKey: "selfie")
                self.checkAllCalculationStates()
                //self.selfiebtn.isEnabled = true
                self.progressSelfieV.isHidden = true
                self.selfiephotoslbl.isHidden = false
            }
        }
        
        for k in 0..<resultArray.count {
            if(flagback){
                return
            }
            print(resultArray[k].count)
            number2 += resultArray[k].count
            
            DispatchQueue.main.async { // Correct
                self.prcLblSelfie.text = "\(100)" + "%"
                self.cProgressVSelfie.progress = Double((100)/Double(100))
                self.selfiephotoslbl.isHidden = false
                self.selfiephotoslbl.text =    "\(number2)" + " photos".localized
            }
            
            
        }
        DispatchQueue.main.async {
            self.calcStateDic.setValue(true, forKey: "selfie")
            self.checkAllCalculationStates()
            //self.selfiebtn.isEnabled = true
            self.progressSelfieV.isHidden = true
            self.cProgressVSelfie.progress = Double((100)/Double(100))
        }
        
        self.user.countSelfie = number2
        
        self.user.SelfiephotosresultArray = resultArray
        
        
        
    }
    
    
    
    
    @available(iOS 10.3, *)
    func findDuplicateLivePhotos() {
        let sc_Fetchlive = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumLivePhotos, options: nil).firstObject!
        
        let sc_Assetslive = PHAsset.fetchAssets(in: sc_Fetchlive , options: nil)
        
        print("All sc_Assetslive Count : " , sc_Assetslive.count)
        
        self.user.LivearrAllImage = sc_Assetslive
        livephotos =  self.user.LivearrAllImage
        
        DispatchQueue.main.async {
            self.livephotoslbl.text =   "0" + " photos".localized
            if(self.livephotos?.count == 0){
                self.calcStateDic.setValue(true, forKey: "live")
                self.checkAllCalculationStates()
                //self.livebtn.isEnabled = true
                self.progressLiveV.isHidden = true
                self.livephotoslbl.isHidden = false
            }
        }
        var images: [OSTuple<NSString, NSData>] = []
        
        for i in 0..<livephotos!.count {
            if(flagback){
                return
            }
            let value2 = Double(i)
            //            let totalInt = Double(arrAllImage!.count)
            //            let result  = ((value2/totalInt))
            //
            //            print(result)
            
            DispatchQueue.main.async {
                self.progressLiveV.isHidden = false
                self.livebtn.isEnabled = false
                self.calcStateDic.setValue(false, forKey: "live")
                self.checkAllCalculationStates()
                
                let value2 = Double(i/2)
                self.cProgressVLive.progress = Double(value2/Double(self.livephotos!.count))
                let x = Double(value2/Double(self.livephotos!.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblLive.text = "\(result)" + "%"
                
            }
            autoreleasepool {
                guard let imgData = livephotos![i].image.pngData() ?? nil else {return}
                images.append(OSTuple<NSString, NSData>(first: NSString(string: "\(i)"), andSecond: imgData as NSData?))
            }
        }
        
        let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: images)
        
        var arrayID = [[NSString]]()
        for tuple in similarImageIdsAsTuples {
            if(flagback){
                return
            }
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
                self.cProgressVLive.progress = Double((result+50.0)/Double(100))
                let x = Double((result+50.0)/Double(100))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblLive.text = "\(result)" + "%"
                
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
            self.livephotoslbl.text =   "0" + " photos".localized
            if(resultArray.count == 0){
                self.calcStateDic.setValue(true, forKey: "live")
                self.checkAllCalculationStates()
                //self.livebtn.isEnabled = true
                self.progressLiveV.isHidden = true
                self.livephotoslbl.isHidden = false
            }
        }
        
        for k in 0..<resultArray.count {
            if(flagback){
                return
            }
            print(resultArray[k].count)
            number2 += resultArray[k].count
            
            DispatchQueue.main.async { // Correct
                self.prcLblLive.text = "\(100)" + "%"
                self.cProgressVLive.progress = Double((100)/Double(100))
                self.livephotoslbl.isHidden = false
                self.livephotoslbl.text =    "\(number2)" + " photos".localized
            }
            
            
            
            
        }
        DispatchQueue.main.async {
            self.calcStateDic.setValue(true, forKey: "live")
            self.checkAllCalculationStates()
            //self.livebtn.isEnabled = true
            self.progressLiveV.isHidden = true
            self.cProgressVLive.progress = Double((100)/Double(100))
        }
        
        self.user.countLive = number2
        
        self.user.LivephotosresultArray = resultArray
        
        
        
    }
    
    
    func findDuplicateScreenshots() {
        
        let sc_Fetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject!
        
        let Screenshots = PHAsset.fetchAssets(in: sc_Fetch , options: nil)
        
        print("All ScreenShots Count : " , Screenshots.count)
        self.user.ScreenarrAllImage = Screenshots
        screenshots =  self.user.ScreenarrAllImage
        
        
        
        
        DispatchQueue.main.async {
            self.screenshotslbl.text =   "0" + " photos".localized
            if(self.screenshots?.count == 0){
                self.progressscreenshotV.isHidden = true
                //self.screenshotbtn.isEnabled = true
                self.calcStateDic.setValue(true, forKey: "screenshots")
                self.checkAllCalculationStates()
                self.screenshotslbl.isHidden = false
            }
            
        }
        var images: [OSTuple<NSString, NSData>] = []
        
        for i in 0..<screenshots!.count {
            if(flagback){
                return
            }
            let value2 = Float(i)
            //            let totalInt = Float(arrAllImage!.count)
            //            let result  = (value2/totalInt)
            //
            //            print(result)
            
            DispatchQueue.main.async {
                self.screenshotbtn.isEnabled = false
                self.progressscreenshotV.isHidden = false
                self.calcStateDic.setValue(false, forKey: "screenshots")
                self.checkAllCalculationStates()
                
                let value2 = Double(i/2)
                self.cProgressVscreenshot.progress = Double(value2/Double(self.screenshots!.count))
                let x = Double(value2/Double(self.screenshots!.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblScreenshot.text = "\(result)" + "%"
                
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
                self.cProgressVscreenshot.progress = Double((result+50.0)/Double(100))
                let x = Double((result+50.0)/Double(100))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblScreenshot.text = "\(result)" + "%"
                
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
                self.calcStateDic.setValue(true, forKey: "screenshots")
                self.checkAllCalculationStates()
                //self.screenshotbtn.isEnabled = true
                self.progressscreenshotV.isHidden = true
                self.screenshotslbl.isHidden = false
            }
            
        }
        
        for k in 0..<resultArray.count {
            if(flagback){
                return
            }
            print(resultArray[k].count)
            number2 += resultArray[k].count
            DispatchQueue.main.async {
                self.prcLblScreenshot.text = "\(100)" + "%"
                self.cProgressVscreenshot.progress = Double((100)/Double(100))
                self.screenshotslbl.isHidden = false
                self.screenshotslbl.text =    "\(number2)" + " photos".localized
            }
            
            
            
            
        }
        DispatchQueue.main.async {
            self.calcStateDic.setValue(true, forKey: "screenshots")
            self.checkAllCalculationStates()
            //self.screenshotbtn.isEnabled = true
            self.progressscreenshotV.isHidden = true
            self.cProgressVscreenshot.progress = Double((100)/Double(100))
        }
        self.user.countScreenshots = number2
        self.user.ScreenphotosresultArray = resultArray
        
        
        
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

extension PHAsset {
    
    var image : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.version = .current
        //        options.deliveryMode = .opportunistic
        //let scale  = UIScreen.main.scale
        let size = CGSize(width: 50.0 , height: 50.0 )
        //                let size = CGSize(width: 100.0, height: 100.0)
        
        imageManager.requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: nil) { (image, info) in
            thumbnail = image ?? UIImage.init()
        }
        return thumbnail
    }
    var image3 : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.version = .current
        //        options.deliveryMode = .opportunistic
        let scale  = UIScreen.main.bounds.width / 2
        let height  = UIScreen.main.bounds.height
        
        let size = CGSize(width: scale , height: height )
        //                let size = CGSize(width: 100.0, height: 100.0)
        
        imageManager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: nil) { (image, info) in
            thumbnail = image ?? UIImage.init()
        }
        return thumbnail
    }
    
    var image2 : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.isSynchronous = true
        //        options.deliveryMode = .opportunistic
        //let scale  = UIScreen.main.scale
        let size = UIScreen.main.bounds.size //CGSize(width: 100.0 * scale, height: 100.0 * scale)
        
        imageManager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: requestOptions) { (image, info) in
            //print(image?.size)
            thumbnail = image ?? UIImage.init()
        }
        return thumbnail
    }
    var image5 : UIImage {
        var thumbnail = UIImage()
        var cellDimension = UIScreen.main.bounds.size.width / 2.0
        
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = UIScreen.main.bounds.size.width / 4.0
        }
        
        
        let size = CGSize(width: cellDimension, height: cellDimension)
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.exact
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: self,
                             targetSize: size,
                             contentMode: .aspectFit,
                             options: option) { (image, info) in
            //print(image?.size)
            thumbnail = image ?? UIImage.init()
        }
        return thumbnail
        
    }
    
    var image4 : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.isSynchronous = true
        //        options.deliveryMode = .opportunistic
        //let scale  = UIScreen.main.scale
        let size = UIScreen.main.bounds.size //CGSize(width: 100.0 * scale, height: 100.0 * scale)
        
        imageManager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: requestOptions) { (image, info) in
            //print(image?.size)
            thumbnail = image ?? UIImage.init()
        }
        return thumbnail
    }
    
}
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}

extension PhotoVC: AlterLocationContactDelegate {

    func AlterViewController(sender: AlterLocationContact, didSelectNumber number: Int) {
        dismiss(animated: true) {
            if(number == 1) {
                Utilities.openAppSetting()
            }
        }
    }
}
