//
//  SimilarMonthPhotosVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 11/5/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//
import UIKit
import Photos
import AVKit
import AVFoundation
import PinterestLayout
import EzPopup
import CoreGraphics
import CoreImage
import CircleProgressView
class SimilarMonthPhotosVC: UIViewController {
   // var similarphotos = [PhotosMonthModel]()
  //  var similarphotosMonth = [PhotosMonthModel]()
    var photosArray: PHFetchResult<PHAsset>?
    var selectedRows:[IndexPath] = []
    var deleteRows:[IndexPath] = []
    var photosresultArray = [[NSString]]()
    var dateArry = [String]();
    var dateArryResult = [String]();
    let user = SharedData.sharedUserInfo
    var flagback = false
    var indArray = -1
    var dateTitle = ""

    @IBOutlet weak var prcLblScreenshot: UILabel!
    @IBOutlet weak var progressscreenshotV: UIView!
    @IBOutlet weak var cProgressVscreenshot: CircleProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Similar".localized
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        DispatchQueue.main.async { [self] in
            if Utilities.containsRatingEvent(event: ReviewPopupLocation.onPhoto) {
                Utilities.rateApp(controller: self)
                //AdmobManager.shared.openRateView()
            } else {
                print("Rating pop is not showing")
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.cProgressVscreenshot.trackWidth = 12
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.photosTableView.reloadData()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if self.isMovingFromParent {
            self.flagback = true
        }
        
    }
    func findSimilar(indx : Int) {
        
        let dataArry = self.user.finalarrPhotoAssetsData[indx]
        
        
        
        //        let sc_Fetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject!
        //
        //        let Screenshots = PHAsset.fetchAssets(in: sc_Fetch , options: nil)
        //
        //        print("All ScreenShots Count : " , Screenshots.count)
        //        self.user.ScreenarrAllImage = Screenshots
        //        screenshots =  self.user.ScreenarrAllImage
        //
        //
        
        
        DispatchQueue.main.async {
            self.progressscreenshotV.isHidden = false
            //            self.screenshotslbl.text =   "0" + " photos"
            //            if(self.screenshots?.count == 0){
            //                self.progressscreenshotV.isHidden = true
            //                self.screenshotbtn.isEnabled = true
            //                self.screenshotslbl.isHidden = false
            //            }
            
        }
        var images: [OSTuple<NSString, NSData>] = []
        
        for i in 0..<dataArry.assetResult.count {
            if(flagback){
                return
            }
            
            DispatchQueue.main.async {
                //   self.screenshotbtn.isEnabled = false
                self.progressscreenshotV.isHidden = false
                let value2 = Double(i/2)
                self.cProgressVscreenshot.progress = Double(value2/Double(dataArry.assetResult.count))
                let x = Double(value2/Double(dataArry.assetResult.count))
                let y = Double(round(100*x)/100)
                let result = Int(y * 100)
                self.prcLblScreenshot.text = "\(result)" + "%"
                
            }
            autoreleasepool {
               guard let imgData = dataArry.assetResult[i].image.pngData() ?? nil else {return}
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
            // self.screenshotslbl.text =   "0" + " photos"
            if(resultArray.count == 0){
                //   self.screenshotbtn.isEnabled = true
                self.progressscreenshotV.isHidden = true
                //  self.screenshotslbl.isHidden = false
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
                // self.screenshotslbl.isHidden = false
                // self.screenshotslbl.text =    "\(number2)" + " photos"
            }
            
            
            
            
        }
        print(number2)
        
        
        
        DispatchQueue.main.async {
            // self.screenshotbtn.isEnabled = true
            self.progressscreenshotV.isHidden = true
            self.cProgressVscreenshot.progress = Double((100)/Double(100))
            
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SimilarVC") as? SimilarVC
            vc!.photosArray = self.user.finalarrPhotoAssetsData[indx].assetResult
            vc!.photosresultArray = resultArray
            vc!.indArray = self.indArray
            vc!.dateTitle = self.dateTitle
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
        //  self.user.countScreenshots = number2
        // self.user.ScreenphotosresultArray = resultArray
        
        
        
    }
    
    @IBOutlet var photosTableView: UITableView!{
        didSet {
            photosTableView.delegate = self
            photosTableView.dataSource = self
        }
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
extension SimilarMonthPhotosVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return   self.user.finalarrPhotoAssetsData.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.photosTableView.dequeueReusableCell(withIdentifier: "SimilarPhotosCell", for: indexPath) as! SimilarPhotosCell
        let dataArry = self.user.finalarrPhotoAssetsData[indexPath.row]
        let datePhoto: String = dataArry.imageDate
        let result = datePhoto.split(separator: "-")
        let month: String = String(result[0])
        let year: String = String(result[1])
        cell.lblmonth.text = month
        cell.monthView.dropShadow()
        cell.monthView.layer.cornerRadius = 15
        cell.monthView.layer.masksToBounds = true
        cell.lblyear.text = year + " • " + "\(dataArry.assetResult.count)" + " photos".localized
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    @objc func backgroundthread() {
      //  self.checkAuthorizationForPhotoLibraryAndGet()
        findSimilar(indx: self.indArray)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataArry = self.user.finalarrPhotoAssetsData[indexPath.row]
        dateTitle = dataArry.imageDate
        indArray = indexPath.row
        performSelector(inBackground: #selector(backgroundthread), with: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 285
    }
    
    
    
    
}
