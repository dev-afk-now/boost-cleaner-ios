//
//  FastSimilarVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 11/5/20.
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

class FastSimilarVC: UIViewController {
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var btnKeep: UIButton!
    
    var similarphotos = [PhotosModel]()
    var photosArray = [PHAsset]()
    var selectedRows:[IndexPath] = []
    var deleteRows:[IndexPath] = []
    var photosresultArray = [[NSString]]()
    var deletevideos = [PHAsset]()
    var indArray = -1
    let user = SharedData.sharedUserInfo
    var dateTitle = ""
    let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    let AlterDeleteComplete = AlterVideoDelete.instantiate()

  //  var videos: PHFetchResult<PHAsset>?
    var flag = true
    var arrayIndx = [Int]()
    var arrayIndxPath = [Int]()
    var emptyIndx = [Int]()
    
    var deletephotos = [PHAsset]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Similar Images".localized
        self.leftBarCloseButtonItems2(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        deletephotos.removeAll()
        self.similarphotos.removeAll()
        autoreleasepool {
            for k in 0..<photosresultArray.count {
                var numberData = [Int]()
                for l in 0..<photosresultArray[k].count {
                    let number = Int(photosresultArray[k][l] as String)
                    numberData.append(number!)
                }
                if(!numberData.isEmpty){
                    self.similarphotos.append(PhotosModel( title: "\(photosresultArray[k].count)", NumberArry: numberData, firstPhoto: numberData[0] ) )
                }
            }
        }
        
        photoTableView.delegate = self
        photoTableView.dataSource = self
       
        photoTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    func leftBarCloseButtonItems2(iconName : String){
        let editbtn = UIButton.init(type: .custom)
        editbtn.setImage(UIImage.init(named: iconName), for: UIControl.State.normal)
        editbtn.addTarget(self, action:#selector(self.backClick2), for: UIControl.Event.touchUpInside)
        editbtn.frame = CGRect.init(x: 0, y: 0, width: 25, height: 24)
        let barButton = UIBarButtonItem.init(customView: editbtn)
        self.navigationItem.leftBarButtonItems = [barButton]
        
    }
    @objc func backClick2() {
        self.arrayIndxPath.sort(by: { $1 < $0 })
        print(self.arrayIndxPath)
        
        for i in 0..<self.arrayIndxPath.count {
            if self.indArray < self.user.fastarrPhotoAssetsData.count {
                let photoData = self.user.fastarrPhotoAssetsData[self.indArray]
                
                if i < self.arrayIndxPath.count {
                    let aIndexPath = self.arrayIndxPath[i]
                    var aResult = photoData.assetResult

                    if aIndexPath < aResult.count {
                        aResult.remove(at: aIndexPath)
                    }
                }
            }
            
            //self.user.fastarrPhotoAssetsData[self.indArray].assetResult.remove(at: self.arrayIndxPath[i])
        }
        
        
        if self.indArray < self.user.fastarrPhotoAssetsData.count {
            let photoData = self.user.fastarrPhotoAssetsData[self.indArray]
            
            if photoData.assetResult.count <= 1 {
                if self.indArray < self.user.fastarrPhotoAssetsData.count {
                    self.user.fastarrPhotoAssetsData.remove(at: self.indArray)
                }
            }
        }
        
        /*if ( self.user.fastarrPhotoAssetsData[self.indArray].assetResult.count <= 1) {
            self.user.fastarrPhotoAssetsData.remove(at: self.indArray)
        }*/
        
        self.arrayIndxPath.removeAll()
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
         
    }
    @IBOutlet var photoTableView: UITableView!{
        didSet {
            photoTableView.delegate = self
            photoTableView.dataSource = self
            
        }
    }
    
  
    func photosDelete() {
        deletevideos.removeAll()
        emptyIndx.removeAll()
        
       // arrayIndxPath.removeAll()
        
        for i in 0..<arrayIndx.count {
            let section = selectedRows[arrayIndx[i]].section
            let row = selectedRows[arrayIndx[i]].row
            //let selectedIndexPath = IndexPath(row: row, section: section)

            //self.arrayIndxPath.append(similarphotos[section].NumberArry![row])
            //print(similarphotos[section].NumberArry![row])
            
            let asset =    self.photosArray[similarphotos[section].NumberArry![row]]
            deletevideos.append(asset)
            //deletevideos.append((similarvideos[section].videosData?[row])!)
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.deletevideos as NSArray)
        }, completionHandler: {success, error in
            if(success) {
                UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                DispatchQueue.main.async { [self] in
                    deleteRows.removeAll()
                    
                    for i in 0..<arrayIndx.count {
                        let section = selectedRows[arrayIndx[i]].section
                        let row = selectedRows[arrayIndx[i]].row
                        self.arrayIndxPath.append(similarphotos[section].NumberArry![row])
                    }
                    
                    
//                    self.arrayIndxPath.sort(by: { $1 < $0 })
//                    print(self.arrayIndxPath)
//                    for i in 0..<self.arrayIndxPath.count {
//                        self.user.fastarrPhotoAssetsData[self.indArray].assetResult.remove(at: self.arrayIndxPath[i])
//                    }
//                    if( self.user.fastarrPhotoAssetsData[self.indArray].assetResult.count == 0){
//                        self.user.fastarrPhotoAssetsData.remove(at: self.indArray)
//                    }
//               self.arrayIndxPath.removeAll()
                    for index in self.arrayIndx
                    {
                        let section = selectedRows[index].section
                        //let row = selectedRows[index].row
                        self.similarphotos[section].NumberArry?.remove(at: 0)
                    }
                    
//                    if(self.user.fastarrPhotoAssetsData[self.indArray].assetResult.count == 0){
//                        self.user.fastarrPhotoAssetsData.remove(at: self.indArray)
//                    }
                    
                    for i in 0..<self.similarphotos.count {
                        
                        if( self.similarphotos[i].NumberArry!.isEmpty ||  self.similarphotos[i].NumberArry!.count == 1){
                            self.emptyIndx.append(i)
                        }
                        
                    }
                    
                    
                    print(self.emptyIndx)
                    self.emptyIndx.sort(by: { $1 < $0 })
                    
                    for index in self.emptyIndx
                    {
                        self.similarphotos.remove(at: index)
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
                    self.photoTableView.reloadData()
                    self.createAlertSend ()
                    // self.createAlertSend ()
                    
                }
            }
        })
        
        
        
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
    static func getAssetThumbnail2(asset: PHAsset, handler: (@escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) ) {
        var cellDimension = UIScreen.main.bounds.size.width / 1.0
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = UIScreen.main.bounds.size.width / 2.0
        }
        
        let size = CGSize(width: cellDimension, height: cellDimension)
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.exact
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isNetworkAccessAllowed = true
         option.version = .original
         option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: handler)
    }
    static func getAssetThumbnail(asset: PHAsset, handler: (@escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) ) {
        var cellDimension = UIScreen.main.bounds.size.width / 1.0
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cellDimension = UIScreen.main.bounds.size.width / 2.0
        }
        
        let size = CGSize(width: cellDimension, height: cellDimension)
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.exact
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isNetworkAccessAllowed = true
      // option.version = .original
        option.isSynchronous = true
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

extension FastSimilarVC: UITableViewDelegate,UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 1060
        }
        else{
            return 530
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return   self.similarphotos.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = photoTableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell") as! VideoTableViewCell
        
        let CategoryData =   self.similarphotos[indexPath.row]
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
            cell.selectedCell.setImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            cell.selectedCell.setImage(UIImage(named:"video_uncheck_ic"), for: .normal)
        }
        
//        let asset =    self.videos![CategoryData.NumberArry!]
//        cell.configureCell(phAsset: asset)
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
        
        //  playvideo(currentIndex: indexPath.row, view: self)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        guard let tableViewCell = cell as? VideoTableViewCell else { return }
        if( self.similarphotos[indexPath.row].NumberArry!.count <= 3){
            tableViewCell.leftConstraints.constant = 150
        }
        else{
            tableViewCell.leftConstraints.constant = 20
        }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            guard let tableViewCell = cell as? VideoTableViewCell else { return }
//            self.flag = true
//            tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
//
//
//        }
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
      //  photoTableView.reloadData()
        
        let indexPosition = IndexPath(row: keepIndexPath, section: 0)

       let cell: VideoTableViewCell = self.photoTableView.cellForRow(at: indexPosition) as! VideoTableViewCell
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
                if(leftCount >= self.selectedRows.count){
                    self.photosDelete()
                    //UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                } else {
                    let inAppSpot = EventManager.shared.inAppLocations
                    if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onFastSimilarDelete) {
                        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onFastSimilarDelete)
                    } else {
                        self.photosDelete()
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
            if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onFastSimilarDelete) {
                Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onFastSimilarDelete)
            } else {
                photosDelete()
            }
        }
        //deleteVideos()
    }
    
}

extension FastSimilarVC:  UICollectionViewDelegate,UICollectionViewDataSource  ,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return    self.similarphotos[collectionView.tag].NumberArry?.count ?? 0
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FastDataCollectionViewCell", for: indexPath) as! FastDataCollectionViewCell
        let divison =   self.similarphotos[collectionView.tag].NumberArry?[indexPath.row]
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
        
        let asset =    self.photosArray[ divison!]
       
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
    func allbtnTapped(btn:UIButton, indexPath:IndexPath) {
        
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

       let cell: VideoTableViewCell = self.photoTableView.cellForRow(at: indexPosition) as! VideoTableViewCell
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
        
//        let selectedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
//        print("IndexPath : \(selectedIndexPath)")
//        if self.selectedRows.contains(selectedIndexPath)
//        {
//            self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
//        }
//        else
//        {
//            self.selectedRows.append(selectedIndexPath)
//        }
//
//        //        if(selectedRows.isEmpty){
//        //
//        //            deletebtn.isHidden = true
//        //            deletebtn.setTitle("DELETE", for: .normal)
//        //        }
//        //        else{
//        //
//        //            deletebtn.isHidden = false
//        //            deletebtn.setTitle("DELETE SELECTED (" + "\(selectedRows.count)" + ")", for: .normal)
//        //        }
//        self.photoTableView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        var  currentIndexFetch = 0
        let divison =   self.similarphotos[collectionView.tag].NumberArry
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImagesDetailVC") as? ImagesDetailVC
        vc!.NumberArry = divison!
        vc!.similarflg = true
        vc!.SimilarPhotosArray = self.photosArray
        vc!.displayIndex = currentIndexFetch
        vc!.currentIndex = currentIndexFetch
        
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        for cell in topCollecView.visibleCells {
//            let indexPath = topCollecView.indexPath(for: cell)
//            print(indexPath)
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: UIScreen.main.bounds.width - 32 , height: 720 )
        }
        else{
            
            return CGSize(width: UIScreen.main.bounds.width - 40 , height: 360 )
        }
        
    }
    
    
    
}
