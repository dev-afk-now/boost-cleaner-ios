//
//  SelfiephotosVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 11/6/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation
import SDWebImagePhotosPlugin
import EzPopup



class SelfiephotosVC: UIViewController {
    var selfieresultArray = [[NSString]]()
    var photos = [Int]()
    var deletephotos = [PHAsset]()
    var allselectedRows:[IndexPath] = []
    let user = SharedData.sharedUserInfo
    var totalcount = 0;
    var titleName = "";
    var selfieArray = [PhotosModel]()
    var selfiePhoto: PHFetchResult<PHAsset>?
    let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    var selectedRows:[IndexPath] = []
    var deleteArray = [Int]()
    let AlterDeleteComplete = AlterVideoDelete.instantiate()
    var flagselect = false
    var dismissBlock: (() -> Void)?
        // var flgFirst = true
    @IBOutlet weak var selectedAll: UIButton!
    @IBOutlet weak var deletebtn: UIButton!
    @IBOutlet weak var CollecView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleName
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
       // performSelector(inBackground: #selector(backgroundthread), with: nil)
        rightBarButtonItemsSelect()
        CollecView.delegate = self
        CollecView.dataSource = self
        if(selectedRows.isEmpty){
            
            deletebtn.isHidden = true
        }
        else{
            
            deletebtn.isHidden = false
        }
        
        print(selfieresultArray)
        for k in 0..<selfieresultArray.count {
            var numberData = [Int]()
            for l in 0..<selfieresultArray[k].count {
                let number = Int(selfieresultArray[k][l] as String)
                numberData.append(number!)
            }
            if(!numberData.isEmpty){
                self.selfieArray.append(PhotosModel( title: "\(selfieresultArray[k].count)" + " similar".localized, NumberArry: numberData , firstPhoto: numberData[0]) )
            }
        }
        
    }
    
    func rightBarButtonItemsSelect(){
        
        let rightItem = UIBarButtonItem(title: "Select all".localized, style: .plain, target: self, action: #selector(self.selectAllbtn))
        if UIDevice.current.userInterfaceIdiom == .pad {
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 28)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
        }
        else{
            rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14  )!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .normal)
         //   rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
        }
        
        self.navigationItem.rightBarButtonItem = rightItem
        
    }
    func rightBarButtonItemsUnselect(){
        
        let rightItem = UIBarButtonItem(title: "Deselect all", style: .plain, target: self, action: #selector(self.selectAllbtn))
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
    
    @objc func selectAllbtn() {
        let txt = "DELETE SELECTED".localized
        print(self.selectedRows)
        if(flagselect){
            self.selectedRows.removeAll()
            flagselect = false
            rightBarButtonItemsSelect()
            self.selectedRows.removeAll()
            self.CollecView.reloadData()
            if(selectedRows.isEmpty){
                let txt = "DELETE SELECTED".localized
                deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .normal)
                deletebtn.setTitle("\(txt) (0)" , for: .normal)
                deletebtn.setTitle("\(txt) (0)" , for: .selected)
                deletebtn.setTitle("\(txt) (0)" , for: .highlighted)
                deletebtn.isHidden = true
            }
            else{
                deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .normal)
                deletebtn.isHidden = false
            }
        }
        else{
            self.selectedRows.removeAll()
            flagselect = true
            rightBarButtonItemsUnselect()
            self.selectedRows = getAllIndexPaths()
            self.CollecView.reloadData()
            if(selectedRows.isEmpty){
                deletebtn.setTitle("\(txt) (0)" , for: .normal)
                deletebtn.isHidden = true
            }
            else{
                deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .normal)
                deletebtn.isHidden = false
            }

            
        }
    }
    func getAllIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for i in 0..<self.selfieArray.count {
            for j in 0..<selfieArray[i].NumberArry!.count {
                indexPaths.append(IndexPath(row: j, section: i))
            }
        }
        return indexPaths
    }
//    @objc func backgroundthread2() {
//        DispatchQueue.main.async {
//           // self.showLoader()
//        }
//        let sc_Fetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject!
//
//        let Screenshots = PHAsset.fetchAssets(in: sc_Fetch , options: nil)
//
//        print("All ScreenShots Count : " , Screenshots.count)
//        self.user.ScreenarrAllImage = Screenshots
//        //  photosresultArray = self.user.photosresultArray
//        let newtotalcount = Screenshots.count
//        if( self.totalcount == newtotalcount){
//
//            print("equal")
//            DispatchQueue.main.async {
//              //  self.stopAnimating()
//            }
//
//        }
//        else{
//            DispatchQueue.main.async {
//                self.allselectedRows.removeAll()
//                self.selectedRows.removeAll()
//                if(self.selectedRows.isEmpty){
//
//                    self.deletebtn.isHidden = true
//                }
//                else{
//
//                    self.deletebtn.isHidden = false
//                }
//            }
//            self.liveresultArray.removeAll()
//            self.liveArray.removeAll()
//            // self.CollecView.reloadData()
//
//        }
//        // }
//
//    }
    
    override var prefersStatusBarHidden: Bool{
        return true
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
//    @objc func backgroundthread() {
//
//        let sc_Fetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject!
//
//        let Screenshots = PHAsset.fetchAssets(in: sc_Fetch , options: nil)
//
//        print("All ScreenShots Count : " , Screenshots.count)
//        totalcount = Screenshots.count
//
//    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        NotificationCenter.default.removeObserver(self)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        //  self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(activeMethod),name:UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    @objc func activeMethod(){
       // performSelector(inBackground: #selector(backgroundthread2), with: nil)
        
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
                if(leftCount >= self.selectedRows.count){
                    self.deletePhoto()
                    //UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                } else {
                    let inAppSpot = EventManager.shared.inAppLocations
                    if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onSelfieDelete) {
                        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onSelfieDelete)
                    } else {
                        self.deletePhoto()
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
            if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onSelfieDelete) {
                Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onSelfieDelete)
            } else {
                deletePhoto()
            }
        }
    }
    
    func deletePhoto() {
        deletephotos.removeAll()
        
        for i in 0..<selectedRows.count {
            print(selectedRows[i].row)
            print(selectedRows[i].section)
            
            deletephotos.append( self.selfiePhoto![self.selfieArray[self.selectedRows[i].section].NumberArry![self.selectedRows[i].row]])
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.deletephotos as NSArray)
        }, completionHandler: {success, error in
            if(success) {
                UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                DispatchQueue.main.async {
                    self.user.countSelfie  = self.user.countSelfie - self.selectedRows.count
                    
                    self.selectedRows.sort(by: { $1 < $0 })
                    
                    for index in self.selectedRows
                    {
                        // arr.removeAtIndex(index)
                        self.selfieArray[index.section].NumberArry!.remove(at:index.row)
                        if(self.selfieArray[index.section].NumberArry!.isEmpty)
                        {
                            self.selfieArray.remove(at: index.section)
                            
                            
                        }
                        else{
                            self.selfieArray[index.section].title = "\( self.selfieArray[index.section].NumberArry!.count)" + " Photos"
                        }
                        self.allselectedRows.removeAll()
                        
                        self.CollecView.reloadData()
                        
                    }
                    self.createAlertSend ()
                    self.selectedRows.removeAll()
                    
                    self.flagselect = false
                    self.rightBarButtonItemsSelect()
                    if(self.selectedRows.isEmpty){
                        
                        self.deletebtn.isHidden = true
                    }
                    else{
                        
                        self.deletebtn.isHidden = false
                    }
                }
            }
        })
        
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
extension SelfiephotosVC:UICollectionViewDelegate,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selfieArray[section].NumberArry!.count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        return  self.selfieArray.count
        
        
    }
    
    
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        //   let screenshotsData =  photos[indexPath.row]
       // let screenshotsData =  screenshotsArray[indexPath.section].photosData![indexPath.row]
        let screenshotsData =    self.selfiePhoto![selfieArray[indexPath.section].NumberArry![indexPath.row]]
        
//        if(flgFirst){
//            cell.configureCell(phAsset: screenshotsData)
//        }
        
        //let photosURL = NSURL.sd_URL(with: screenshotsData)
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.exact
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isNetworkAccessAllowed = true
        option.version = .original
        option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        cell.imageV.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        SimilarVideoVC.getAssetThumbnail(asset: screenshotsData) { [self] (result, info) in
            /* Disabling HD fetching here as only thumbnails are enough to be fetch */
            cell.imageV.sd_setImage(with: nil, placeholderImage:  result ?? nil, context:[.photosImageRequestOptions: option, .customManager: manager])
            
            //cell.imageV.sd_setImage(with: photosURL as URL?, placeholderImage:  result ?? nil, context:[.photosImageRequestOptions: option, .customManager: manager])
        }
        
        if selectedRows.contains(indexPath)
        {
            cell.imageV.alpha = 0.6
            cell.selectedCell.setImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            cell.imageV.alpha = 1
            cell.selectedCell.setImage(UIImage(named:"checkbox_unselect_ic"), for: .normal)
        }
        
        
        //  let selectedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        
        //  cell.selectedCell.tag = indexPath.row
        // cell.selectedCell.tag = (selectedIndexPath)
        //   cell.selectedCell.section = indexPath.row
        
        cell.selectedCell.mk_addTapHandler { (btn) in
            print("You can use here also directly : \(indexPath.row)")
            self.btnTapped(btn: btn, indexPath: indexPath)
        }
        //  cell.selectedCell.addTarget(self, action: #selector(checkBoxSelection(_:)), for: .touchUpInside)
        
        
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        return cell;
    }
    func btnTapped(btn:UIButton, indexPath:IndexPath) {
        print("IndexPath : \(indexPath.row)")
        let txt = "DELETE SELECTED".localized
        let selectedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        var indx = -1
        if self.selectedRows.contains(selectedIndexPath)
        {
            for k in 0..<allselectedRows.count {
                
                
                
                if(allselectedRows[k].section == selectedIndexPath.section){
                    //  self.selectedRows.remove(at: k)
                    print(allselectedRows)
                    indx = k
                    
                    
                }
            }
            if(indx == -1)
            {
                
            }
            else{
                self.allselectedRows.remove(at: indx)
                let sectionIndex = IndexSet(integer: selectedIndexPath.section)
                CollecView.reloadSections(sectionIndex)
            }
            
            
            self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
        }
        else
        {
            self.selectedRows.append(selectedIndexPath)
        }
        
        
        if(selectedRows.isEmpty){
            deletebtn.setTitle("\(txt) (0)" , for: .normal)
            deletebtn.setTitle("\(txt) (0)" , for: .selected)
            deletebtn.setTitle("\(txt) (0)" , for: .highlighted)
            deletebtn.isHidden = true
        }
        else{
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .normal)
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .selected)
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .highlighted)
            deletebtn.isHidden = false
        }
        guard let cell = self.CollecView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell else{
            return
        }

        
        if selectedRows.contains(selectedIndexPath)
        {
            cell.imageV.alpha = 0.6
            cell.selectedCell.setImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            cell.imageV.alpha = 1
            cell.selectedCell.setImage(UIImage(named:"checkbox_unselect_ic"), for: .normal)
        }
        
     //   flgFirst = false
      //  CollecView.reloadItems(at: [selectedIndexPath])
      //  flgFirst = true
        
    }
    
    @objc func checkBoxSelection(_ sender:UIButton)
    {
        print(sender.tag)
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
            let txt = "DELETE SELECTED".localized
            deletebtn.setTitle("\(txt)D (0)" , for: .normal)
            deletebtn.setTitle("\(txt)D (0)" , for: .selected)
            deletebtn.setTitle("\(txt)D (0)" , for: .highlighted)
            deletebtn.isHidden = true
        }
        else{
            let txt = "DELETE SELECTED".localized
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .normal)
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .selected)
            deletebtn.setTitle("\(txt) (" + "\(selectedRows.count)" + ")", for: .highlighted)
            deletebtn.isHidden = false
        }
        self.CollecView.reloadData()
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
        
        var  currentIndexFetch = 0
        var flag = true
        photos.removeAll()
        for i in 0..<selfieArray.count {
            
            if(flag){
                currentIndexFetch += selfieArray[i].NumberArry!.count
                if(indexPath.section == i){
                    currentIndexFetch += indexPath.row - selfieArray[i].NumberArry!.count
                    flag = false
                    
                }
            }
            
            for k in 0..<selfieArray[i].NumberArry!.count {
                
              //  photos.append(screenshotsArray[i].photosData![k])
               // photos.append(self.screenshots![screenshotsArray[i].NumberArry![k]])
                photos.append(selfieArray[i].NumberArry![k])
                
            }
            
            
        }
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImagesDetailVC") as? ImagesDetailVC
        
        vc!.finalImages = photos
        vc!.PhotosArray = selfiePhoto
        vc!.displayIndex = currentIndexFetch
        vc!.currentIndex = currentIndexFetch
        
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImagesDetailVC") as? ImagesDetailVC
//
//        vc!.finalImages = photos
//        vc!.PhotosArray = screenshots
//        vc!.displayIndex = currentIndexFetch
//        vc!.currentIndex = currentIndexFetch
//
//
//        self.navigationController?.pushViewController(vc!, animated: true)
        
        
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollection", for: indexPath) as! HeaderCollection
        
        
        headerView.sizelbl.text =  selfieArray[indexPath.section].title
        
        
        if allselectedRows.contains(indexPath)
        {
            headerView.allselectedCell.setImage(UIImage(named:"select_check_icon"), for: .normal)
        }
        else
        {
            headerView.allselectedCell.setImage(UIImage(named:"check_icon"), for: .normal)
        }
        headerView.allselectedCell.mk_addTapHandler { (btn) in
            print("You can use here also directly : \(indexPath.row)")
            self.allbtnTapped(btn: btn, indexPath: indexPath)
        }
        
        return headerView;
        
    }
   
    
    func allbtnTapped(btn:UIButton, indexPath:IndexPath) {
        print("IndexPath : \(indexPath.row)")
        
        let selectedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        
        if self.allselectedRows.contains(selectedIndexPath)
        {
            self.allselectedRows.remove(at: self.allselectedRows.firstIndex(of: selectedIndexPath)!)
            
            
            for j in 0..<selfieArray[selectedIndexPath.section].NumberArry!.count {
                
                
                let selectedIndexPath = IndexPath(row: j, section: selectedIndexPath.section)
                if self.selectedRows.contains(selectedIndexPath)
                {
                    self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
                }
                
            }
            //            for k in 0..<selectedRows.count {
            //                if(selectedRows[k].section == selectedIndexPath.section){
            //                    self.selectedRows.remove(at: k)
            //                }
            //            }
            
        }
        else
        {
            self.deleteArray.removeAll()
            for k in 0..<selectedRows.count {
                if(selectedRows[k].section == selectedIndexPath.section){
                    //  self.selectedRows.remove(at: k)
                    self.deleteArray.append(k)
                }
            }
            
            
            selectedRows.remove(at: self.deleteArray)
            
            for j in 0..<selfieArray[selectedIndexPath.section].NumberArry!.count {
                
                self.selectedRows.append(IndexPath(row: j, section: selectedIndexPath.section))
                
                
            }
            
            self.allselectedRows.append(selectedIndexPath)
        }
        
        
        if(selectedRows.isEmpty){
            
            deletebtn.isHidden = true
        }
        else{
            
            deletebtn.isHidden = false
        }
        
        let sectionIndex = IndexSet(integer: selectedIndexPath.section)
        
        CollecView.reloadSections(sectionIndex) // or fade, right, left, top, bottom, none, middle, automatic
        
        // CollecView.reloadSections(selectedIndexPath.section)
        //   CollecView.reloadData()
        
        
    }
    
    
}


//extension UIButton {
//
//    private class Action {
//        var action: (UIButton) -> Void
//
//        init(action: @escaping (UIButton) -> Void) {
//            self.action = action
//        }
//    }
//
//    private struct AssociatedKeys {
//        static var ActionTapped = "actionTapped"
//    }
//
//    private var tapAction: Action? {
//        set { objc_setAssociatedObject(self, &AssociatedKeys.ActionTapped, newValue, .OBJC_ASSOCIATION_RETAIN) }
//        get { return objc_getAssociatedObject(self, &AssociatedKeys.ActionTapped) as? Action }
//    }
//
//
//    @objc dynamic private func handleAction(_ recognizer: UIButton) {
//        tapAction?.action(recognizer)
//    }
//
//
//
//}
