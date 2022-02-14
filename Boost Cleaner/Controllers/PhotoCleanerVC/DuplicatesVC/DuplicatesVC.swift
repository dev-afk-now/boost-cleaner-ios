//
//  DuplicatesVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/14/20.
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

class DuplicatesVC: UIViewController {
    @IBOutlet weak var deletebtn: UIButton!
    var similarphotos = [PhotosModel]()
    var photosArray: PHFetchResult<PHAsset>?
    var selectedRows:[IndexPath] = []
    var deleteRows:[IndexPath] = []
    var indArray = -1
    var totalcount = 0
    var arrayIndx = [Int]()
    var emptyIndx = [Int]()
    var arrayIndxPath = [Int]()
    var deletephotos = [PHAsset]()
    let user = SharedData.sharedUserInfo
    let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    let AlterDeleteComplete = AlterVideoDelete.instantiate()
    var delegate: DuplicatesPhotoVC? = nil
    var dismissBlock: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Duplicate Photos".localized
        self.leftBarCloseButtonItems2(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        
        deletephotos.removeAll()
        
        //print(self.user.duplicatesphotosArray[self.indArray].NumberArry?.count)
        // leftConstraints.constant = 20
        
        totalcount = self.user.duplicatesphotosArray[self.indArray].NumberArry!.count
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
        let currCount = self.user.duplicatesphotosArray[self.indArray].NumberArry!.count
        if( currCount <= 1) {
            if currCount == 1 {
                //self.user.duplicatesphotosArray.remove(at: self.indArray)
                self.user.countPhotos = self.user.countPhotos - (totalcount - 1)
            } else {
                self.delegate?.finalArry.remove(at: self.indArray)
                self.user.duplicatesphotosArray.remove(at: self.indArray)
                self.user.countPhotos = self.user.countPhotos - totalcount
            }
        } else {
            self.user.countPhotos = self.user.countPhotos - self.arrayIndxPath.count
        }
        
        self.arrayIndxPath.removeAll()
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if(selectedRows.isEmpty){
            
            deletebtn.isHidden = true
        }
        else{
            
            deletebtn.isHidden = false
        }
        
    }
    
    @IBOutlet var photoTableView: UITableView!{
        didSet {
            photoTableView.delegate = self
            photoTableView.dataSource = self
            
        }
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
                    self.arrayIndx.removeAll()
                    for i in 0..<self.selectedRows.count {
                        self.arrayIndx.append(i)
                    }
                    self.photosDelete()
                    //UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                }
                else{
                    let inAppSpot = EventManager.shared.inAppLocations
                    if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onDuplicatesDelete) {
                        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onDuplicatesDelete)
                    } else {
                        self.arrayIndx.removeAll()
                        for i in 0..<self.selectedRows.count {
                            self.arrayIndx.append(i)
                        }
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
            if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onDuplicatesDelete) {
                Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onDuplicatesDelete)
            } else {
                arrayIndx.removeAll()
                
                for i in 0..<selectedRows.count {
                    arrayIndx.append(i)
                }
                
                photosDelete()
            }
        }
    }
    
    func photosDelete() {
        deletephotos.removeAll()
        emptyIndx.removeAll()
        
        for i in 0..<arrayIndx.count {
            let section = selectedRows[arrayIndx[i]].section
            let row = selectedRows[arrayIndx[i]].row
            deletephotos.append(self.photosArray![similarphotos[section].NumberArry![row]])
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.deletephotos as NSArray)
        }, completionHandler: {success, error in
            if(success) {
                UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "Count")) - self.selectedRows.count), forKey: "Count")
                DispatchQueue.main.async { [self] in
                    deleteRows.removeAll()
                    
                    for i in 0..<arrayIndx.count {
                        //let section = selectedRows[arrayIndx[i]].section
                        // let row = selectedRows[arrayIndx[i]].row
                        self.arrayIndxPath.append(arrayIndx[i])
                    }
                    
                    // self.arrayIndx.sort(by: { $1 < $0 })
                    let sorted =  self.arrayIndx.sorted(by: { $1 < $0 })
                    print(self.arrayIndx)
                                        
                    for index in sorted {
                        let section = selectedRows[index].section
                        let row = selectedRows[index].row
                        
                        if section < similarphotos.count {
                            let simPhotos = similarphotos[section]
                            
                            if var numArr = simPhotos.NumberArry {
                                if row < numArr.count {
                                    numArr.remove(at: row)
                                } else if numArr.count > 0 {
                                    numArr.remove(at: 0)
                                }
                            }
                        }
                        
                        //similarphotos[section].NumberArry?.remove(at: row)
                        //similarphotos[section].NumberArry?.remove(at: 0)
                    }
                                        
                    for i in 0..<self.similarphotos.count {
                        if let numberArry = self.similarphotos[i].NumberArry {
                            if ( numberArry.isEmpty || (numberArry.count == 1) ) {
                                self.emptyIndx.append(i)
                            }
                        }
                    }
                    
                    self.emptyIndx.sort(by: { $1 < $0 })
                    
                    for index in self.emptyIndx {
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
                    
                    if(selectedRows.isEmpty) {
                        deletebtn.isHidden = true
                    } else {
                        deletebtn.isHidden = false
                    }
                    if self.similarphotos.count <= 0 {
                        backClick2()
                    }
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension DuplicatesVC: UITableViewDelegate,UITableViewDataSource{
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 960
        }
        else{
            return 480
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.similarphotos.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = photoTableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell") as! PhotoTableViewCell
        
        let CategoryData = self.similarphotos[indexPath.row]
        cell.selectedCell.setBackgroundImage(UIImage(named:"video_uncheck_ic"), for: .normal)
        let selectedIndexPath = IndexPath(row: 0, section: indexPath.row)
        var countSelect = 0
        //        cell.countselectedCell.setTitle("Move 0 to Trash", for: .normal)
        //        for i in 0..<selectedRows.count {
        //            print(selectedRows[i].row)
        //            print(selectedRows[i].section)
        //            if(indexPath.row == selectedRows[i].section){
        //
        //                countSelect = countSelect + 1
        //                cell.countselectedCell.setTitle("Move "+"\(countSelect)" + " to Trash", for: .normal)
        //            }
        //
        //        }
        
        if selectedRows.contains(selectedIndexPath)
        {
            cell.selectedCell.setImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            cell.selectedCell.setImage(UIImage(named:"video_uncheck_ic"), for: .normal)
        }
        
        
        let asset =  self.photosArray![similarphotos[indexPath.row].firstPhoto!]
        cell.configureCell(phAsset: asset)
        cell.cellView.dropShadow()
        cell.cellView.layer.cornerRadius = 30.0
        
        cell.cellView.clipsToBounds = true
        
        //        cell.countselectedCell.tag = indexPath.row
        //        cell.countselectedCell.addTarget(self, action: #selector(deleteSelection(_:)), for: .touchUpInside)
        //        
        //        
        //        cell.keepselectedCell.tag = indexPath.row
        //        cell.keepselectedCell.addTarget(self, action: #selector(keepSelection(_:)), for: .touchUpInside)
        //        cell.selectedCell.mk_addTapHandler { (btn) in
        //            print("You can use here also directly : \(indexPath.row)")
        //            let selectedIndexPath = IndexPath(row: 0, section: indexPath.row)
        //            
        //            self.allbtnTapped(btn: btn, indexPath: selectedIndexPath)
        //        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //  playvideo(currentIndex: indexPath.row, view: self)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? PhotoTableViewCell else { return }
        if(similarphotos[indexPath.row].NumberArry!.count <= 3){
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
        photoTableView.reloadData()
    }
    
    @objc func deleteSelection(_ sender:UIButton) {
        if selectedRows.count <= 0 {
            return
        }
        
        let deleteIndexPath = sender.tag
        arrayIndx.removeAll()
        
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
                }
                else{
                    let inAppSpot = EventManager.shared.inAppLocations
                    if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onDuplicatesDelete) {
                        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onDuplicatesDelete)
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
            if (PaymentManager.shared.isPurchase() == false) && inAppSpot.contains(InAppEventLocations.onDuplicatesDelete) {
                Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: false, iapEvent: InAppEventLocations.onDuplicatesDelete)
            } else {
                photosDelete()
            }
        }
    }    
}

extension DuplicatesVC: UICollectionViewDelegate,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  similarphotos[collectionView.tag].NumberArry?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoDataCollectionViewCell", for: indexPath) as! VideoDataCollectionViewCell
        let divison = similarphotos[collectionView.tag].NumberArry?[indexPath.row]
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
        let asset =  self.photosArray![divison!]
        
        
        cell.configureCell(phAsset:asset)
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
            deletebtn.setTitle("DELETE DUPLICATE".localized, for: .normal)
        }
        else{
            
            deletebtn.isHidden = false
            deletebtn.setTitle("DELETE DUPLICATE".localized, for: .normal)
        }
        
        self.photoTableView.reloadData()
        
        let indexPosition = IndexPath(row: indexPath.section, section: 0)
        let cell = self.photoTableView.cellForRow(at: indexPosition) as! PhotoTableViewCell
        let selectedIndexPath1 = IndexPath(row: indexPath.row, section: 0)
        
        cell.topCollecView.scrollToItem(at: selectedIndexPath1, at: .left, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        
        
        
        
        
        
    }
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
