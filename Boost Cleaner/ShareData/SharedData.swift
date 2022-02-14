//
//  SharedData.swift

//

import UIKit
import StoreKit
import UIKit
import Photos
import AVKit
import AVFoundation
 
class SharedData  {
    static let sharedUserInfo = SharedData()
    
    
    var countPhotos = 0
       var countPhotos2 = 0
    var countScreenshots = 0
    
    
    var fastimagesAssetSize = 0.0
    var fastSimilarimagesAssetSize = 0.0
    var fastvideosAssetSize = 0.0
    var fasttotalStorage = 0.0
    
    var countLive = 0
    var deleteValue = 0
    var deleteflg = true
    var countSelfie = 0
    var firstTime = true
     var allflag = true
    var similarImage = true
    var similarImagefast = true
    var duplicatesImages = true
    var firstTimeRun = true
    var videosfast = true
    var fastvideos: PHFetchResult<PHAsset>?
    var fastsimilarcount = 0
    var arrAllImage: PHFetchResult<PHAsset>?
    var arrAllImageDuplicates: PHFetchResult<PHAsset>?

    var photosresultArray = [[NSString]]()
    var duplicatesphotosArray = [PhotosModel]()
    var duplicatesphotosArray2 = [PhotosMonthModel]()

    var LivearrAllImage: PHFetchResult<PHAsset>?
    var LivephotosresultArray = [[NSString]]()
    var similarvideos = [SimilarVideoModel]()
//    var videodeleteArray = [Int]()
//    var videodeleteArray = [videodeleteArray]()
    var finalarrPhotoAssetsData = [PhotoVC.FinalAssetsData]()
    var fastarrPhotoAssetsData = [PhotoVC.FinalAssetsData]()

    var SelfiearrAllImage: PHFetchResult<PHAsset>?
    var SelfiephotosresultArray = [[NSString]]()
    var progr : Float = 0
    var ScreenarrAllImage: PHFetchResult<PHAsset>?
    var ScreenphotosresultArray = [[NSString]]()
    
    var finalvideos = [VideosModel]()

    var finalvideos1 = [VideosModel]()
    var finalvideos2 = [VideosModel]()
    var finalvideos3 = [VideosModel]()
    var finalvideos4 = [VideosModel]()
    var sortfinalvideos = [VideosModel]()
    
    
}
