//
//  MediaComparatorService.swift
//  Boost Cleaner
//
//  Created by devmac on 14.02.2022.
//  Copyright © 2022 Fresh Brain. All rights reserved.
//

import UIKit
import CryptoKit
import Vision

final class MediaComparatorService {
    
    struct HammingDistanceConstants {
        static let identical: Float = 0
        static let maxToBeSimilar: Float = 15
    }
    
    func searchSimilar(images: [UIImage]) -> [MCSimilarDataContainer] {
        var resultArray = [MCSimilarDataContainer]()
        for index in images.indices {
            for imageToCompareIndex in images.indices {
                if index == imageToCompareIndex {
                    continue
                }
                guard let distance = computeHammingDistance(firstImage: images[index],
                                                          secondImage: images[imageToCompareIndex]) else {
                    continue
                }
                if distance > HammingDistanceConstants.identical,
                   distance < HammingDistanceConstants.maxToBeSimilar {
                    var analyzingInfoContainer = MCSimilarDataContainer.defaultInstance()
                    analyzingInfoContainer.generalItemHash = images[index].md5value
                    analyzingInfoContainer.similar.append(images[imageToCompareIndex].md5value)
                    analyzingInfoContainer.hammingDistance = distance
                    resultArray.append(analyzingInfoContainer)
                }
            }
        }
        return resultArray
    }
    
    private func computeHammingDistance(firstImage: UIImage,
                                        secondImage: UIImage) -> Float? {
        if #available(iOS 13.0, *) {
            guard
                let cgImage = firstImage.cgImage,
                let featurePrint = featureprintObservationFor(cgImage: cgImage) else { return nil }
            guard
                let cgImage = secondImage.cgImage,
                let featurePrintToCompare = featureprintObservationFor(cgImage: cgImage) else { return nil }
            do {
                var distance = Float(0)
                try featurePrint.computeDistance(&distance,
                                                 to: featurePrintToCompare)
                return distance
            } catch {
                return nil
            }
        }
        return nil
        // 9.3
        // 15
        // 18
        // 22.55
    }
    
    @available(iOS 13.0, *)
    private func featureprintObservationFor(cgImage: CGImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
//        request.revision = VNGeneratePersonSegmentationRequestRevision1
        do {
            try requestHandler.perform([request])
            return request.results?.first
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
}

struct MCSimilarDataContainer {
    var generalItemHash: String
    var similar: [String]
    var hammingDistance: Float
    
    static func defaultInstance() -> MCSimilarDataContainer {
        MCSimilarDataContainer(generalItemHash: "",
                           similar: [],
                           hammingDistance: 111)
    }
}

extension UIImage {
    var md5value: String {
        MD5()
    }
    
    private func MD5() -> String {
        if #available(iOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: self.compressedData() ?? Data())
            return digest.map {
                String(format: "%02hhx", $0)
            }.joined()
        } else {
            return ""
        }
    }
}
