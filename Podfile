# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Boost Cleaner' do
  # Comment the next line if you don't want to use dynamic frameworks

use_frameworks!
  pod 'CircleProgressView'
  pod 'SystemServices'
  pod 'SwiftyContacts'
  pod 'EzPopup'
  pod 'PinterestLayout', :git => 'https://github.com/dev-afk-now/PinterestLayout.git', :branch => 'master'
  pod 'CocoaImageHashing', :git => 'https://github.com/ameingast/cocoaimagehashing.git'
  pod 'ImageSlideshow', '~> 1.9.0'  #pod 'FileBrowser'
  pod 'RealmSwift', '3.20.0'
  pod 'IHProgressHUD', :git => 'https://github.com/Swiftify-Corp/IHProgressHUD.git'
  pod 'ReachabilitySwift'
  pod 'SDWebImagePhotosPlugin'
  pod 'ImageScrollView'
  pod 'MSPeekCollectionViewDelegateImplementation' ,'~> 2.0.0'
  pod 'SwiftyGif'
  pod 'Charts' ,'~> 3.5.0'
  pod 'FirebaseDatabase'
  pod 'Firebase/Analytics'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Core'
  pod 'Fabric', '~> 1.10.2'
  #pod 'Purchases'
  #pod 'Purchases', '3.10.1'
  pod "CDAlertView"
  #pod 'Amplitude', '~> 7.2.0'
  
  pod 'UIView+Shake'
  pod 'Localize'
  pod 'SwiftyStoreKit'
  
  pod 'JGProgressHUD'
  pod 'UIColor_Hex_Swift'
  pod 'Toast-Swift'
  #pod 'FacebookCore'
  #pod 'AppsFlyerFramework'
  
  # Private Vault
  pod 'YPImagePicker'
  #pod "BSImagePicker"
  pod 'SwiftyContacts'
  pod 'NVActivityIndicatorView'

post_install do |installer|   
      installer.pods_project.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      end
end

end

