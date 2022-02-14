//
//  SegmentedProgressBarProtocols.swift
//  Boost Cleaner
//
//  Created by Vish iOS on 24/11/21.
//  Copyright © 2021 Fresh Brain. All rights reserved.
//

import Foundation
import UIKit

public protocol SegmentedProgressBarDelegate: AnyObject {
    func segmentedProgressBarFinished(finishedIndex: Int, isLastIndex: Bool)
}

public protocol SegmentedProgressBarDataSource: AnyObject {
    var numberOfSegments: Int { get }
    var segmentDuration: TimeInterval { get }
    var paddingBetweenSegments: CGFloat { get }
    var trackColor: UIColor { get }
    var progressColor: UIColor { get }
    var roundCornerType: CornerType { get }
}

public enum CornerType {
    case roundCornerSegments(cornerRadious: CGFloat)
    case roundCornerBar(cornerRadious: CGFloat)
    case none
}

extension UIView {
    func updateWidth(newWidth: CGFloat) {
        let rect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newWidth, height: self.frame.size.height)
        self.frame = rect
    }
    
    func borderAndCorner(cornerRadious: CGFloat, borderWidth: CGFloat, borderColor: UIColor?) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
    }
}
