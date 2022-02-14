//
//  PHAssetsExtension.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 29/09/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    var fileSize: Float {
        get {
            let resource = PHAssetResource.assetResources(for: self)
            let imageSizeByte = resource.first?.value(forKey: "fileSize") as? Float ?? 0
            let imageSizeMB = imageSizeByte / (1024.0*1024.0)
            return imageSizeMB
        }
    }
    
    var sizeInBytes: Float {
        let resource = PHAssetResource.assetResources(for: self)
        let imageSizeByte = resource.first?.value(forKey: "fileSize") as? Float ?? 0
        return imageSizeByte
    }
    
    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte, notDetermine
        
        var fileSizeUnits: String {
            switch self {
            case .byte:
                return "B"
            case .kilobyte:
                return "KB"
            case .megabyte:
                return "MB"
            case .gigabyte:
                return "GB"
            default:
                return ""
            }
        }
        
    }
    
    func getSizeIn(_ type: DataUnits)-> String {
        
        let resource = PHAssetResource.assetResources(for: self)
        let imageSizeByte = resource.first?.value(forKey: "fileSize") as? Float ?? 0
        let isLocallayAvailable = (resource.first?.value(forKey: "locallyAvailable") as? NSNumber)?.boolValue ?? false // If this returns NO, then the asset is in iCloud and not saved locally yet
        print(">>>> isLocallyAvailable: \(isLocallayAvailable)")
        var size: Float = 0.0
        
        if type == .notDetermine {
            let formatter:ByteCountFormatter = ByteCountFormatter()
            formatter.countStyle = .binary
            return formatter.string(fromByteCount: Int64(imageSizeByte))
        }
        
        switch type {
        case .byte:
            size = imageSizeByte
        case .kilobyte:
            size = imageSizeByte / 1024
        case .megabyte:
            size = imageSizeByte / (1024.0*1024.0)
        case .gigabyte:
            size = imageSizeByte / (1024.0*1024.0*1024.0)
        case .notDetermine:
            break
        }
        
        return String(format: "%.2f", size)
    }
    
    func getImage(at index: Int, with size: CGSize = CGSize(width: 100, height: 100), type: PHImageRequestOptionsDeliveryMode? = .opportunistic, completionHandler: @escaping((_ index: Int, _ image: UIImage?)->Void)){
        let manager = PHCachingImageManager()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        if let mode = type {
            option.deliveryMode = mode
        }
        option.resizeMode = PHImageRequestOptionsResizeMode.exact
        option.version = .original
        option.isNetworkAccessAllowed = true
        manager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            completionHandler(index, result)
        })
    }
    
    func getOriginalImage(at index: Int, completionHandler: @escaping((_ index: Int, _ image: UIImage?)->Void)) {
        getImage(at: index, with: PHImageManagerMaximumSize, type: .highQualityFormat, completionHandler: completionHandler)
    }
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.deliveryMode = .fastFormat
            options.version = .original
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .fastFormat
            options.deliveryMode = .automatic
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
}
