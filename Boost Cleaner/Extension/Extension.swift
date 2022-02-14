//
//  Extension.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/23/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Localize
import Purchases


extension UIFont {
    class func applicationFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SFProRounded-Regular", size: size)!
    }
    
}
extension UIView {
    func addTapGesture(callBack: Selector,viewController:UIViewController) -> Void {
        let tap = UITapGestureRecognizer.init(target: viewController, action: callBack)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

//MARK:- UIView Extension
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
}
//Round specific corner only

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIViewController {
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func leftBarCloseButtonItems(iconName : String){
        let editbtn = UIButton.init(type: .custom)
        editbtn.setImage(UIImage.init(named: iconName), for: UIControl.State.normal)
        editbtn.addTarget(self, action:#selector(self.backClick), for: UIControl.Event.touchUpInside)
        editbtn.frame = CGRect.init(x: 0, y: 0, width: 50, height: 44)
        let barButton = UIBarButtonItem.init(customView: editbtn)
        self.navigationItem.leftBarButtonItems = [barButton]
        
    }
    
    func RightBarItemWithImage(iconName : String){
        let editbtn = UIButton.init(type: .custom)
        editbtn.setImage(UIImage.init(named: iconName), for: UIControl.State.normal)
        editbtn.addTarget(self, action:#selector(self.backClick), for: UIControl.Event.touchUpInside)
        editbtn.frame = CGRect.init(x: 0, y: 0, width: 25, height: 24)
        let barButton = UIBarButtonItem.init(customView: editbtn)
        self.navigationItem.rightBarButtonItems = [barButton]
        
    }
    func makeNavigationBarTransparent(){
        navigationController?.navigationBar.alpha = 1
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    @objc func backClick() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = hexStringToUIColor(hex: "#7C9CB4").cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 25
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    func dropShadow3(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = hexStringToUIColor(hex: "#7C9CB4").cgColor
        layer.shadowOpacity = 0.50
        layer.shadowOffset = .zero
        layer.shadowRadius = 225
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    func dropShadow2(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = hexStringToUIColor(hex: "#7C9CB4").cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 15
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadowRadius8(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = hexStringToUIColor(hex: "#7C9CB4").cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 6
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func applyDropShadowS(scale: Bool = true) {
       layer.masksToBounds = false
       layer.shadowColor = hexStringToUIColor(hex: "#7C9CB4").cgColor
       layer.shadowOpacity = 0.2
       layer.shadowOffset = CGSize(width: -1, height: 14)
       layer.shadowRadius = 10
       layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//       layer.shouldRasterize = true
//       layer.rasterizationScale = scale ? UIScreen.main.scale : 1
     }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
extension UIFont {
//    class func applicationFont(_ size: CGFloat) -> UIFont {
//        return UIFont(name: "Muli-Regular", size: size)!
//    }
    class func boldApplicationFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Muli-Bold", size: size)!
    }
    class func lightApplicationFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica-Light", size: size)!
    }
    
    class func italicApplicationFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica-Italic", size: size)!
    }
}

extension UIFont {
    
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        
        // create a new font descriptor with the given traits
        if let fd = fontDescriptor.withSymbolicTraits(traits) {
            // return a new font with the created font descriptor
            return UIFont(descriptor: fd, size: pointSize)
        }
        
        // the given traits couldn't be applied, return self
        return self
    }
    
    func italics() -> UIFont {
        return withTraits(.traitItalic)
    }
    
    func bold() -> UIFont {
        return withTraits(.traitBold)
    }
    
    func boldItalics() -> UIFont {
        return withTraits([ .traitBold, .traitItalic ])
    }
}


extension String {

    func locale() -> String {
        return self.localize()
    }
    
    func nibWithNameiPad()->String{
        var str = self
        if IS_IPAD{
            str = str + "_iPad"
        }
        return str
    }
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    func subStringWithIndex (i: Int) -> String {
        if self.isEmpty {
            return ""
        }
        return String(self[i] as Character)
    }
    
    //    subscript (r: Range<Int>) -> String {
    //        let start = index(startIndex, offsetBy: r.lowerBound)
    //        let end = index(startIndex, offsetBy: r.upperBound)
    //        return self[Range(start ..< end)]
    //    }
    //
    var digits: String {
        if self.contains("*") || self.contains("#") {
            return self
        }
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    func shortString() -> String {
        let displayString = NSMutableString.init()
        var words = components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        
        if words.count > 0 {
            let firstWord = words[0]
            if firstWord.count > 0 {
                let index = firstWord.index(firstWord.startIndex, offsetBy: 1)
                displayString.append(firstWord.substring(to: index))
            }
            if words.count > 1 {
                var lastWord = words.last
                while lastWord?.count == 0 && words.count > 1 {
                    words.removeLast()
                    lastWord = words.last
                }
                
                if words.count > 1 {
                    if let last = lastWord {
                        if last.count > 0 {
                            let index = last.index(last.startIndex, offsetBy: 1)
                            displayString.append(last.substring(to: index))
                        }
                    }
                }
            }
        }
        return displayString.uppercased as String
    }
}
extension UIDevice {
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.file
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
    
}

extension UIButton {
    
    private class Action {
        var action: (UIButton) -> Void
        
        init(action: @escaping (UIButton) -> Void) {
            self.action = action
        }
    }
    
    private struct AssociatedKeys {
        static var ActionTapped = "actionTapped"
    }
    
    private var tapAction: Action? {
        set { objc_setAssociatedObject(self, &AssociatedKeys.ActionTapped, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &AssociatedKeys.ActionTapped) as? Action }
    }
    
    
    @objc dynamic private func handleAction(_ recognizer: UIButton) {
        tapAction?.action(recognizer)
    }
    
    
    func mk_addTapHandler(action: @escaping (UIButton) -> Void) {
        self.addTarget(self, action: #selector(handleAction(_:)), for: .touchUpInside)
        tapAction = Action(action: action)
        
    }
}

extension Date {

  func isEqualTo(_ date: Date) -> Bool {
    return self == date
  }
  
  func isGreaterThan(_ date: Date) -> Bool {
     return self > date
  }
  
  func isSmallerThan(_ date: Date) -> Bool {
     return self < date
  }
}


extension SKProduct.PeriodUnit {
    func description(capitalizeFirstLetter: Bool = false, numberOfUnits: Int? = nil) -> String {
        let period:String = {
            switch self {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            @unknown default:
                print("")
                return ""
            }
        }()

        var numUnits = ""
        var plural = ""
        if let numberOfUnits = numberOfUnits {
            numUnits = "\(numberOfUnits) " // Add space for formatting
            plural = numberOfUnits > 1 ? "s" : ""
        }
        
        return "\(numUnits)" + "\(capitalizeFirstLetter ? period.capitalized : period)\(plural)".localized
        //return "\(numUnits)\(capitalizeFirstLetter ? period.capitalized : period)\(plural)"
    }
}

extension SKProduct {
    func subscriptionPeriodString() -> String {
        let period:String = {
            switch self.subscriptionPeriod?.unit {
            case .day: return "day".localized
            case .week: return "week".localized
            case .month: return "month".localized
            case .year: return "year".localized
            case .none: return ""
            case .some(_): return ""
            }
        }()

        return period
        
        /*let price = self.localizedPrice!
        let numUnits = self.subscriptionPeriod?.numberOfUnits ?? 0
        let plural = numUnits > 1 ? "s" : ""
        
        return String(format: "%@ for %d %@%@", arguments: [price, numUnits, period, plural])*/
    }
}

@available(iOS 13.0, *)
extension UIApplication {
  var currentScene: UIWindowScene? {
    connectedScenes
      .first { $0.activationState == .foregroundActive } as? UIWindowScene
  }
}

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension String {
    var localized: String {
        if let _ = UserDefaults.standard.string(forKey: "i18n_language") {} else {
            UserDefaults.standard.set("en", forKey: "i18n_language")
            UserDefaults.standard.synchronize()
        }
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

extension UserDefaults {
    
    var _BioAuthFirstTimeAlertPrompt: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "bio_auth_first_time_alert")
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.bool(forKey: "bio_auth_first_time_alert")
        }
    }
    
    var _BioAuthEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "bio_auth_enabled")
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.bool(forKey: "bio_auth_enabled")
        }
    }
    
    var batteryAnimationSet: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "battery_animation_set")
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.bool(forKey: "battery_animation_set")
        }
    }
    
    var currentBatteryAnimation: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "current_battery_animation")
            UserDefaults.standard.synchronize()
        } get {
            UserDefaults.standard.integer(forKey: "current_battery_animation")
        }
    }
    
    
}

extension Locale {
  var isChinese: Bool {
    return (languageCode == "zh-Hans" || languageCode == "zh")
  }
}
