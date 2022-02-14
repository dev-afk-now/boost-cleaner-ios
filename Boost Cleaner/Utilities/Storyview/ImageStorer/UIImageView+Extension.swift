
import Foundation
import UIKit

extension UIImageView {

    //Responsiblity: to holds the List of Activity Indicator for ImageView
    //DataSource: UI-Level
    struct ActivityIndicator {
        static var isEnabled = false
        static var style = UIActivityIndicatorView.Style.whiteLarge
        static var view = UIActivityIndicatorView(style: .whiteLarge)
    }
    
    //MARK: Public Vars
    public var isActivityEnabled: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &ActivityIndicator.isEnabled) as? Bool else {
                return false
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ActivityIndicator.isEnabled, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var activityStyle: UIActivityIndicatorView.Style {
        get{
            guard let value = objc_getAssociatedObject(self, &ActivityIndicator.style) as? UIActivityIndicatorView.Style else {
                return .whiteLarge
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ActivityIndicator.style, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var activityIndicator: UIActivityIndicatorView {
        get {
            guard let value = objc_getAssociatedObject(self, &ActivityIndicator.view) as? UIActivityIndicatorView else {
                return UIActivityIndicatorView(style: .whiteLarge)
            }
            return value
        }
        set(newValue) {
            let activityView = newValue
            activityView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            activityView.hidesWhenStopped = true
            objc_setAssociatedObject(self, &ActivityIndicator.view, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //MARK: - Private methods
    func showActivityIndicator() {
        if isActivityEnabled {
            DispatchQueue.main.async {
                self.backgroundColor = IGTheme.redOrange
                self.activityIndicator = UIActivityIndicatorView(style: self.activityStyle)
                if !self.subviews.contains(self.activityIndicator) {
                    self.addSubview(self.activityIndicator)
                }
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    func hideActivityIndicator() {
        if isActivityEnabled {
            DispatchQueue.main.async {
                self.backgroundColor = UIColor.white
                self.subviews.forEach({ (view) in
                    if let av = view as? UIActivityIndicatorView {
                        av.stopAnimating()
                    }
                })
            }
        }
    }
}

extension UIImage {
    var heic: Data? { heic() }
    func heic(compressionQuality: CGFloat = 1) -> Data? {
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 1, nil),
            let cgImage = cgImage
        else { return nil }
        CGImageDestinationAddImage(destination, cgImage, [kCGImageDestinationLossyCompressionQuality: compressionQuality, kCGImagePropertyOrientation: cgImageOrientation.rawValue] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
    var cgImageOrientation: CGImagePropertyOrientation { .init(imageOrientation) }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}
