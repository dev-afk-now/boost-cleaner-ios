//
//  VideoVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/30/20.
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

class VideoVC: UIViewController {
    var videos: PHFetchResult<PHAsset>?
    var deletevideos = [PHAsset]()
    var totalcount = 0;
    var doubleArry = [Double]();
    var locationArry = [Double]();
    var doubleArry2 = [Double]();
    var locationArry2 = [Double]();
    let user = SharedData.sharedUserInfo
    var typeVideo = "All".localized
    var selectedRows:[IndexPath] = []
    var deleteArray = [Int]()
    
    //LocalizationAsset
    
    @IBOutlet weak var lblSimilarVidoItme: UILabel!
    @IBOutlet weak var lblsimilar: UILabel!
    @IBOutlet weak var lblVideoSizeItem: UILabel!
    @IBOutlet weak var lblVideoSize: UILabel!
    
    
    @IBOutlet weak var largeVideoItems: UILabel!
    @IBOutlet weak var similarVideoItems: UILabel!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    
    var flagback = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video Cleaner".localized
        self.lblsimilar.text = "Similar".localized
        self.lblVideoSize.text = "Large size videos".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        firstView.dropShadow()
        secondView.dropShadow()
        popupView.isHidden = false
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 ) {
        //            self.checkAuthorizationForPhotoLibraryAndGet()
        //        }
        self.circleProgressView.progress = Double(0/Double(100))
        
        performSelector(inBackground: #selector(backgroundthread), with: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.circleProgressView.trackWidth = 12
        }
        
        // Do any additional setup after loading the view.
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        similarVideoItems.text = "\( self.user.similarvideos.count)" + " videos".localized
        if(self.user.finalvideos1.isEmpty){
            largeVideoItems.text = "\(self.user.finalvideos.count)" + " videos".localized
        }
        else{
            largeVideoItems.text = "\(self.user.finalvideos1.count)" + " videos".localized
        }
        
    }
    
    @objc func backgroundthread() {
        self.checkAuthorizationForPhotoLibraryAndGet()
    }
    
    @IBAction func similarVideoButtonPressed(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SimilarVideoVC") as? SimilarVideoVC
        // vc!.similarvideos =  self.user.similarvideos
        vc!.videos = videos
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func allVideoButtonPressed(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AllVideoVC") as? AllVideoVC
        
        if (self.user.finalvideos1.isEmpty) {
            self.user.sortfinalvideos = self.user.finalvideos
            UserDefaults.standard.set("All".localized, forKey: "typeVideo")
            
        } else {
            self.user.sortfinalvideos = self.user.finalvideos1
            UserDefaults.standard.set("Higher than 100 MB", forKey: "typeVideo")
        }
        
        //        vc!.finalvideos = self.user.finalvideos
        //        vc!.finalvideos1 = self.user.finalvideos1
        //        vc!.finalvideos2 = self.user.finalvideos2
        //        vc!.finalvideos3 = self.user.finalvideos3
        //        vc!.finalvideos4 = self.user.finalvideos4
       
        vc!.videos = videos
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    private func checkAuthorizationForPhotoLibraryAndGet(){
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            getPhotosAndVideos()
        }else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.getPhotosAndVideos()
                }else {
                    
                }
            })
        }
    }
    
    private func getPhotosAndVideos(){
        deletevideos.removeAll()
        self.user.finalvideos.removeAll()
        self.user.finalvideos1.removeAll()
        self.user.finalvideos2.removeAll()
        self.user.finalvideos3.removeAll()
        self.user.finalvideos4.removeAll()
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
        videos = imagesAndVideos
        self.totalcount = imagesAndVideos.count
        
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
                self.largeVideoItems.text = "\(self.user.finalvideos1.count)" + " videos".localized
            }
            
            let asset = videos!.object(at: i)
            let resources = PHAssetResource.assetResources(for: asset) // your PHAsset
            var sizeOnDisk: Int64 = 0
            
            if let resource = resources.first {
                //let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                //sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
                
                if let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
                    sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64))
                }
                
                let fullNameArr = converByteToHumanReadable(sizeOnDisk).components(separatedBy: " ")
                let name = fullNameArr[0]
                let mb = fullNameArr[1]

                if (mb == "MB") {
                    let sizevideo = Double(name) ?? 0.0
                    let videoModel = VideosModel(sizetype: "MB", nameContact: "key" , videosData: i , sizevideos : sizevideo )
                    
                    print(sizevideo)
                    
                    self.doubleArry.append(sizevideo)
                    self.user.finalvideos.append(videoModel)
                    //self.user.finalvideos.append(VideosModel(sizetype: "MB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                    
                    if (sizevideo >= 100.0) {
                        self.user.finalvideos1.append(videoModel)
                        //self.user.finalvideos1.append(VideosModel(sizetype: "MB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                        
                    } else if(sizevideo >= 50.0 && (i < self.user.finalvideos.count) && ( self.user.finalvideos[i].sizevideos! < 100.0 ) ){
                        self.user.finalvideos2.append(videoModel)
                        //self.user.finalvideos2.append(VideosModel(sizetype: "MB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                        
                    } else if(sizevideo >= 10.0 && (i < self.user.finalvideos.count) && (self.user.finalvideos[i].sizevideos! < 50.0) ){
                        self.user.finalvideos3.append(videoModel)
                        //self.user.finalvideos3.append(VideosModel(sizetype: "MB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                        
                    } else {
                        self.user.finalvideos4.append(videoModel)
                        //self.user.finalvideos4.append(VideosModel(sizetype: "MB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                    }
                } else if(mb == "KB") {
                    let sizevideo = Double(name) ?? 0.0
                    let videoModel = VideosModel(sizetype: "KB", nameContact: "key" , videosData: i , sizevideos : sizevideo )
                    
                    print(sizevideo)
                    
                    self.doubleArry.append(sizevideo)
                    self.user.finalvideos.append(videoModel)
                    self.user.finalvideos4.append(videoModel)
                    
                    /*if(sizevideo >= 100.0){
                        
                        self.user.finalvideos1.append(VideosModel(sizetype: "KB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                        
                    }
                    else if(sizevideo >= 50.0 && (i < self.user.finalvideos.count) && (self.user.finalvideos[i].sizevideos! < 100.0) ){
                        
                        self.user.finalvideos2.append(VideosModel(sizetype: "KB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                        
                    }
                    else if(sizevideo >= 10.0 && (i < self.user.finalvideos.count) && (self.user.finalvideos[i].sizevideos! < 50.0) ){
                        
                        self.user.finalvideos3.append(VideosModel(sizetype: "KB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                        
                    }
                    else {
                        self.user.finalvideos4.append(VideosModel(sizetype: "KB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))
                    }*/
                    
                }
                else if(mb == "GB"){
                    let sizevideo = Double(name) ?? 0.0
                    let videoModel = VideosModel(sizetype: "GB", nameContact: "key" , videosData: i , sizevideos : sizevideo )
                    
                    print(sizevideo)
                    
                    self.doubleArry.append(sizevideo)
                    self.user.finalvideos.append(videoModel)
                    self.user.finalvideos1.append(videoModel)
                    
                    /*if(sizevideo >= 100.0){

                        self.user.finalvideos1.append(VideosModel(sizetype: "GB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))

                    }
                    else if(sizevideo >= 50.0 && (i < self.user.finalvideos.count) && (self.user.finalvideos[i].sizevideos! < 100.0) ){

                        self.user.finalvideos2.append(VideosModel(sizetype: "GB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))

                    }
                    else if(sizevideo >= 10.0 && (i < self.user.finalvideos.count) && (self.user.finalvideos[i].sizevideos! < 50.0) ){

                        self.user.finalvideos3.append(VideosModel(sizetype: "GB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))

                    }
                    else {
                        self.user.finalvideos4.append(VideosModel(sizetype: "GB", nameContact: "key" , videosData: i , sizevideos : sizevideo ))

                    }*/
                    
                    //                    if(finalvideos1.isEmpty){
                    //                        largeVideoItems.text = "\(self.finalvideos.count)" + " videos"
                    //                    }
                    //                    else{

                    // }
                }
                
            }
        }
        
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
        self.user.finalvideos1 = self.user.finalvideos1.sorted(by: { (img0: VideosModel, img1: VideosModel) -> Bool in
            let sizetype0 = img0.sizetype
            let sizetype1 = img1.sizetype
            
            if sizetype0 == sizetype1 {
                return img0.sizevideos! > img1.sizevideos!
            } else if sizetype0 == "GB" {
                return true
            } else if sizetype1 == "GB" {
                return false
            }
            
            return img0.sizevideos! > img1.sizevideos!
        })
        self.user.finalvideos2 = self.user.finalvideos2.sorted(by: { (img0: VideosModel, img1: VideosModel) -> Bool in
            return img0.sizevideos! > img1.sizevideos!
        })
        self.user.finalvideos3 = self.user.finalvideos3.sorted(by: { (img0: VideosModel, img1: VideosModel) -> Bool in
            return img0.sizevideos! > img1.sizevideos!
        })
        self.user.finalvideos4 = self.user.finalvideos4.sorted(by: { (img0: VideosModel, img1: VideosModel) -> Bool in
            let sizetype0 = img0.sizetype
            let sizetype1 = img1.sizetype
            
            if sizetype0 == sizetype1 {
                return img0.sizevideos! > img1.sizevideos!
            } else if sizetype0 == "KB" {
                return false
            } else if sizetype1 == "KB" {
                return true
            }
            
            return img0.sizevideos! > img1.sizevideos!
        })
        
        doubleArry2 = findDuplicates(array: doubleArry)
        doubleArry2 = doubleArry2.sorted(by: { $0 > $1 })
        
        
        for k in 0..<doubleArry2.count {
            if(flagback) {
                return
            }
            for i in 0..<self.user.finalvideos.count {
                if(doubleArry2[k] == self.user.finalvideos[i].sizevideos!){
                    // print(findDuplicates(array: doubleArry)[k])
                    //  self.similarvideos.append(finalvideos[i])
                    let asset =    self.videos![self.user.finalvideos[i].videosData!]
                    locationArry.append(asset.duration)
                }
                
            }
        }
        
        //        print(findDuplicates(array: locationArry))
        //        for k in 0..<findDuplicates(array: locationArry).count {
        //            for i in 0..<finalvideos.count {
        //                if(findDuplicates(array: locationArry)[k] == finalvideos[i].videosData!.duration){
        //                self.similarvideos.append(finalvideos[i])
        //                }
        //            }
        //        }
        locationArry2 = findDuplicates(array: locationArry)
        locationArry2 = locationArry2.sorted(by: { $0 > $1 })
        
        for k in 0..<locationArry2.count {
            var videoData = [Int]()
            if(flagback) {
                return
            }
            for i in 0..<self.user.finalvideos.count {
                let asset =    self.videos![self.user.finalvideos[i].videosData!]
                if(locationArry2[k] == asset.duration){
                    videoData.append(self.user.finalvideos[i].videosData!)
                }
                
                //  let number = Int(finalvideos[k][i] as String) //here number
                // photosData.append(similarPhotosArray![number!])
                
            }
            if(!videoData.isEmpty){
                DispatchQueue.main.async { [self] in
                    similarVideoItems.text = "\( self.user.similarvideos.count)" + " videos".localized
                }
                self.user.similarvideos.append(SimilarVideoModel(topVideo: videoData[0] , videosData: videoData) )
            }
            
        }
        DispatchQueue.main.async { [self] in
            if(self.user.finalvideos1.isEmpty){
                largeVideoItems.text = "\(self.user.finalvideos.count)" + " videos".localized
            }
            else{
                largeVideoItems.text = "\(self.user.finalvideos1.count)" + " videos".localized
            }
            
            
            print( self.user.similarvideos.count)
            similarVideoItems.text = "\( self.user.similarvideos.count)" + " videos".localized
            self.user.sortfinalvideos = self.user.finalvideos
            print(self.user.sortfinalvideos.count)
            self.circleProgressView.progress = Double(100/Double(100))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                popupView.isHidden = true
                // Code you want to be delayed
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
