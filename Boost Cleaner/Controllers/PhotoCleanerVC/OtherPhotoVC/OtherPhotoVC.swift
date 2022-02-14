//
//  OtherPhotoVC.swift
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

class OtherPhotoVC: UIViewController {
    @IBOutlet weak var CollecView: UICollectionView!
     let user = SharedData.sharedUserInfo
    var selectedRows:[IndexPath] = []
    var deleteArray = [Int]()
    var finalArray = [Int]()
    var deletevideos = [PHAsset]()
    

    @IBOutlet weak var deletebtn: UIButton!
    var flagselect = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Other"
        self.leftBarCloseButtonItems(iconName: "back_btn_ic")
        self.makeNavigationBarTransparent()
        CollecView.delegate = self
        CollecView.dataSource = self
        setupLayout()
        CollecView.reloadData()
        rightBarButtonItemsSelect()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        for i in 0..<self.user.arrAllImage!.count {
//            finalArray.append(i)
//        }
        if(selectedRows.isEmpty){
            
            deletebtn.isHidden = true
        }
        else{
            
            deletebtn.isHidden = false
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
           // rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
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
          //  rightItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 14)!,NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "#CCCCCC")], for: .selected)
            
        }
        
        self.navigationItem.rightBarButtonItems = [rightItem]
        
    }
    @objc func selectAllbtn() {
        print(self.selectedRows)
        if(flagselect){
            flagselect = false
            rightBarButtonItemsSelect()
            //selectedAll.setBackgroundImage(UIImage(named:"unselect_icon"), for: .normal)
            self.selectedRows.removeAll()
            self.CollecView.reloadData()
            deletebtn.isHidden = true
            deletebtn.setTitle("DELETE", for: .normal)
        }
        else{
            flagselect = true
            rightBarButtonItemsUnselect()
            // selectedAll.setBackgroundImage(UIImage(named:"select_icon"), for: .normal)
            self.selectedRows = getAllIndexPaths()
            self.CollecView.reloadData()
            if(selectedRows.isEmpty){
                deletebtn.isHidden = true
                deletebtn.setTitle("DELETE".localized, for: .normal)
                
            }
            else{
                let locaText = "DELETE SELECTED".localized
                
                deletebtn.isHidden = false
                deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .normal)
                deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .selected)
                deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .highlighted)
                
            }
            
        }
        
    }
    
    @IBAction func deleteBtnAction(_ sender: UIButton) {
        deletevideos.removeAll()
        for i in 0..<selectedRows.count {
           // let asset =   self.arrAllImage![selectedRows[i].row] //self.videos![sortfinalvideos[self.selectedRows[i].row].videosData!]
            deletevideos.append(self.user.arrAllImage![self.finalArray[self.selectedRows[i].row]])
            //deletevideos.append(asset)

        }
        print(self.deletevideos)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.deletevideos as NSArray)
        }, completionHandler: {success, error in
            print(success ? "Success" : error )
            if(success){
                
                DispatchQueue.main.async {
                    
                    self.selectedRows.sort(by: { $1 < $0 })
                    
                    for index in self.selectedRows
                    {
                   self.finalArray.remove(at:index.row)
                        
                    }
                    self.selectedRows.removeAll()
                    self.CollecView.reloadData()
                   
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
    
    func getAllIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for j in 0..<self.finalArray.count {
            indexPaths.append(IndexPath(row: j, section: 0))
        }
        return indexPaths
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
extension OtherPhotoVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.finalArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        
        
        let asset =   self.user.arrAllImage![self.finalArray[indexPath.row]]
        cell.configureCell(phAsset: asset)
        if selectedRows.contains(indexPath)
        {
            cell.selectedCell.setBackgroundImage(UIImage(named:"checkbox_select_ic"), for: .normal)
        }
        else
        {
            cell.selectedCell.setBackgroundImage(UIImage(named:"checkbox_unselect_ic"), for: .normal)
        }
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
            let locaText = "DELETE SELECTED".localized
            
            deletebtn.isHidden = false
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .normal)
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .selected)
            deletebtn.setTitle("\(locaText) (" + "\(selectedRows.count)" + ")", for: .highlighted)
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
        
        
       // playvideo (currentIndex: indexPath.row, view: self)
 
    }
    
}
extension OtherPhotoVC: PinterestLayoutDelegate {

    func collectionView(collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
      
        let asset =  self.user.arrAllImage![self.finalArray[indexPath.row]]
        
      
       
        
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
