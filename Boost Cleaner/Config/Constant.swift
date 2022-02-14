//
//  Constant.swift
//  BitEclipse
//
//  Created by Nhuom Tang on 24/4/19.
//  Copyright © 2019 Nhuom Tang. All rights reserved.
//

import UIKit
import Foundation

//VALUE
let DEVICE_WIDTH = UIScreen.main.bounds.width
let DEVICE_HEIGHT = UIScreen.main.bounds.height
let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad

enum PurchaseType: Int {
    case none = 0
    case weekly = 1
    case monthly = 2
    case yearly = 3
    case lifetime = 4
}

enum PurchaseScreenType: Int {
    case One = 1     //7_days_trial_then_weekly_subscription
    case Two = 2     //7_days_trial_then_monthly_subscription
    case Three = 3   //7_days_trial_then_annually_or_weekly_without_trial
    case Four = 4    //7_days_trial_then_annually_or_7_days_trial_then_monthly
    case Five = 5    //7_days_trial_then_weekly_subscription_or_weekly_without_trial
    case Six = 6     //yearly_or_monthly_lifetime_subscription
    case Seven = 7   //7_days_trial_then_weekly_subscription - Newly Designed
    case Eight = 8
    case Nine = 9
    case Ten = 10
    case Eleven = 11
    case Twelve = 12
    case Thirteen = 13
    case Fourteen = 14
    case Fifteen = 15
    case Sixteen = 16
    // Vacant Spots
    case NineNineOne = 991
    case NineNineTwo = 992
    case NineNineThree = 993
    case NineNineFour = 994
    case NineNineFive = 995
    case NineNineSix = 996
    case NineNineSeven = 997
    case NineNineEight = 998
    // Outdated Events
    case Halloween1 = 9911
    case Halloween2 = 9922
    case FridayOne = 9933
    case FridayTwo = 9944
    case FridayThree = 9955
    case FridayFour = 9966
    case CharistmasOne = 9977
    case CharistmasTwo = 9988
    case CharistmasThree = 9999
    case CharistmasFour = 99999
}

enum ReviewPopupLocation: Int {
    case None=0
    case onBoarding=1
    case onScan=2
    case onPhoto=3
    case onContact=4
    case onVideo=5
}

enum InAppEventLocations: Int {
    case None=0
    case afterOnboarding=1
    case onFastScan=2
    case onFastSimilarDelete=3
    case onPhotoSimilarDelete=4
    case onScreenshotsDelete=5
    case onLiveDelete=6
    case onSelfieDelete=7
    case onDuplicatesDelete=8
    case onVideosSimilarDelete=9
    case onVideosDelete=10
    case onContactsDuplicateName=11
    case onContactsDuplicatePhone=12
    case onContactsDuplicateEmail=13
    case onAdblocker=14
    case onSpeedChecker=15
    case onSettings=16
    case onHome=17
    case onPhotoCompression=18
    case onBatteryAnimationSet=19
    case onSimilarFastClean=20
}


