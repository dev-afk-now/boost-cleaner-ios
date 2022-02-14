//
//  SpeedVC.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/13/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//


//MARK:- Screen Note


import UIKit
//import SpeedcheckerSDK
import CoreLocation
import MapKit
import Foundation
import SystemConfiguration.CaptiveNetwork
import CoreTelephony
import SystemConfiguration
import Reachability
import CFNetwork
import NetworkExtension
import EzPopup
import Charts

class SpeedVC: UIViewController, URLSessionDelegate, URLSessionDataDelegate {
    
    @IBOutlet weak var lblejector: UILabel!
    @IBOutlet weak var lblSpeedtab: UILabel!
    @IBOutlet weak var lblAdBlockTab: UILabel!
    @IBOutlet weak var lblCleanerTab: UILabel!
    @IBOutlet weak var lblBatteryTab: UILabel!
    @IBOutlet weak var lblPingLabel: UILabel!
    @IBOutlet weak var lblJitterLabel: UILabel!
    @IBOutlet weak var downloadSpeedLabel: UILabel!
    @IBOutlet weak var uploadSpeedLabel: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var lblCityTitle: UILabel!
    @IBOutlet weak var lblTelnetTitle: UILabel!
    @IBOutlet weak var lblProviderTitle: UILabel!
    @IBOutlet weak var btnResult: UIButton!
    
    @IBOutlet weak var lblCompressor: UILabel!
    
    @IBOutlet weak var checkAgainButton: UIButton!
    @IBOutlet weak var proButton: UIButton!
    @IBOutlet weak var gaugeView: GDGaugeView!
    @IBOutlet weak var gauge : GaugeView!
    @IBOutlet weak var gauge1 : UIView?
    @IBOutlet weak var gauge2 : UIView?
    @IBOutlet weak var latencyValue: UILabel!
    @IBOutlet weak var downloadValue: UILabel!
    @IBOutlet weak var uploadValue: UILabel!
    @IBOutlet weak var ispValue: UILabel!
    @IBOutlet weak var ipValue: UILabel!
    @IBOutlet weak var jitterFinalValueLabel: UILabel!
    
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgSpeed: UIImageView!
    @IBOutlet weak var btnGo1: UIButton!
    @IBOutlet weak var speedVCView: UIView!
    @IBOutlet weak var btnGo: UIButton!
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    
    @IBOutlet weak var guageContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var guageCentreConst: NSLayoutConstraint!
    @IBOutlet weak var heightConstGauge: NSLayoutConstraint!
    @IBOutlet weak var heightConstChart: NSLayoutConstraint!
    @IBOutlet weak var widthConstGauge: NSLayoutConstraint!
    
    
    //ResultView Outlets
    @IBOutlet weak var speedResultView: UIView!
    @IBOutlet var speedResultMainView: UIView!
    @IBOutlet weak var lblUploadingSpeed: UILabel!
    @IBOutlet weak var lblDownLoadingSpeed: UILabel!
    
    @IBOutlet weak var restartTestView: UIView!
    @IBOutlet weak var closeButtonAction: UIView!
    @IBOutlet weak var lblLatencyValue: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var telCompView: UIView!
    @IBOutlet var speedTestView: UIView!
    @IBOutlet weak var lblinternetService: UILabel!
    @IBOutlet var chartView: LineChartView!
    
    private var internetTest: InternetSpeedTest?
    private var locationManager = CLLocationManager()
    
    let Alterloc = AlterLocationContact.instantiate()
    let gaugeDelegate: GaugeViewDelegate? = nil
    var timeDelta: Double = 1.0/24
    var velocity: Double = 0
    var acceleration: Double = 5
    var isUpload = false
    var dataPoints = [Double]()
    var dSpeed: String!
    var uSpeed: String!
    var networkType: String!
    var flg = true
    var flgdownload = true
    
    private func getLocalization() {
//        lblejector.text = lblejector.text?.localized
        lblSpeedtab.text = "SPEED TEST".localized
        lblAdBlockTab.text = "AD BLOCK".localized
        lblCleanerTab.text = "CLEANER".localized
        lblCompressor.text = "COMPRESS".localized
        providerLabel.text = "provider".localized
        lblBatteryTab.text = lblBatteryTab.text?.capitalized.localized.uppercased()
        lblPingLabel.text = "ping"//.localized
        lblJitterLabel.text = "jitter".localized
        downloadSpeedLabel.text = "Download speed".localized
        uploadSpeedLabel.text = "Upload speed".localized
        lblCity.text = "City".localized
        lblCountry.text = "Country".localized
        checkAgainButton.setTitle(checkAgainButton.currentTitle?.localized, for: .normal)
        proButton.setTitle(proButton.currentTitle?.localized, for: .normal)
        btnResult.setTitle("Results history".localized, for: .normal)
        btnStart.setTitle(btnStart.currentTitle?.localized, for: .normal)
        proButton.setTitle(proButton.currentTitle?.localized, for: .selected)
        btnResult.setTitle("Results history".localized, for: .selected)
        btnStart.setTitle(btnStart.currentTitle?.localized, for: .selected)
        proButton.setTitle(proButton.currentTitle?.localized, for: .highlighted)
        btnResult.setTitle("Results history".localized, for: .highlighted)
        btnStart.setTitle(btnStart.currentTitle?.localized, for: .highlighted)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getLocalization()
        telCompView.dropShadow2()
        locationView.dropShadow2()
        speedResultView.dropShadow2()
        speedVCView.dropShadow2()
        //        speedResultMainView.applyDropShadowS(scale: false)
        speedTestView.applyDropShadowS(scale: false)
        
        self.lblinternetService.text =  UserDefaults.standard.string(forKey: "provider")
        self.lblCity.text = UserDefaults.standard.string(forKey: "city")
        self.lblCountry.text =  UserDefaults.standard.string(forKey: "country")
        self.latencyValue.text = "\(Int(0.0))"
        self.downloadValue.text = "\(Int(0.0))"
        
        let cityName = UserDefaults.standard.string(forKey: "city")
        let countryName = UserDefaults.standard.string(forKey: "country")
        let appCurrentLang = UserDefaults.standard.string(forKey: "i18n_language")
        
        if cityName == "City" && (appCurrentLang == "zh-Hans") {
            lblCity.text = "City".localized
        }
        if countryName == "Country" && (appCurrentLang == "zh-Hans") {
            lblCountry.text = "Country".localized
        }
        
        //        restartTestView.applyDropShadowS()
        
        getWiFiInfo()
        getInternetServiceProviderName()
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        // Get carrier name
        let carrierName = carrier?.carrierName
        
        let url = URL(string: "https://ipinfo.io/org")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else { print(error!); return }
            guard let data = data else { print("Empty data"); return }
            
            if let ispName = String(data: data, encoding: .utf8) {
                print(ispName)
                DispatchQueue.main.async {
                    let isp = ispName.components(separatedBy: " ")
                    if(!isp.isEmpty){
                        if(isp.count >= 3){
                            self.lblinternetService.text = isp[1] + " " + isp[2]
                        }
                        if(isp.count == 2){
                            self.lblinternetService.text = isp[1]
                        }
                    }
                    UserDefaults.standard.set( self.lblinternetService.text, forKey: "provider")
                    
                }
            } else {
                print("Can't obtain ISP name")
            }
            
        }.resume()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if UIScreen.main.bounds.height < 668 {
            heightConstChart.constant = 70
            speedTestView.frame = CGRect(x: 0, y: 70, width: UIScreen.main.bounds.width, height: 510)
            speedResultMainView.frame = CGRect(x: 0, y: 70, width: UIScreen.main.bounds.width, height: 460)
        } else {
            speedResultMainView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 505)
            speedTestView.frame = CGRect(x: 0, y: 94, width: UIScreen.main.bounds.width, height: 575)
        }
        
        restartTestView.layer.cornerRadius = restartTestView.frame.height / 2
        self.view.addSubview(speedResultMainView)
        self.view.addSubview(speedTestView)
        
        speedResultView.layer.cornerRadius = 20
        speedResultMainView.layer.cornerRadius = 30
        speedVCView.layer.cornerRadius = 30
       // chartView.layer.cornerRadius = 30
        speedTestView.layer.cornerRadius = 30
      //  chartView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        speedVCView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        speedTestView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        speedResultMainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        speedResultView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        speedTestView.alpha = 0
        speedResultMainView.alpha = 0
        setupGauge()
        btnGo.isHidden = false
        gaugeView.isHidden = false
        // To setup the upper gauge view
        gaugeView
            .setupGuage(startDegree: 45, endDegree: 315, sectionGap: 20, minValue: 0, maxValue: 200)
            .setupContainer()
            .setupUnitTitle(title: "Mbps")
            .buildGauge()
        
    }

    func setDataCount() {
        var values: [ChartDataEntry] = []

        for i in 0..<dataPoints.count {
               let dataEntry = ChartDataEntry(x: Double(i), y: dataPoints[i] , icon: #imageLiteral(resourceName: "btnresult"))
            values.append(dataEntry)
           }
        
//        let values = (0..<count).map { (i) -> ChartDataEntry in
//            let val = Double(arc4random_uniform(range) + 3)
//            return ChartDataEntry(x: Double(i), y: val, icon: #imageLiteral(resourceName: "btnresult"))
//        }
            print(values)
        let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
        set1.drawIconsEnabled = false
      
        setup(set1)

        let value = ChartDataEntry(x: Double(3), y: 3)
//        set1.valueColors = valueColors
//       set1.addEntryOrdered(value)
      

        if(flgdownload){
        let gradientColors = [ChartColorTemplates.colorFromString("#FFFFFF").cgColor,
                              ChartColorTemplates.colorFromString("#D4E8FF").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
            set1.fillAlpha = 1
            set1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
            set1.drawFilledEnabled = true

            let data = LineChartData(dataSet: set1)

            chartView.data = data
        }
        else{
            let gradientColors = [ChartColorTemplates.colorFromString("#FFFFFF").cgColor,
                                  ChartColorTemplates.colorFromString("#D4F4FF").cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
            set1.fillAlpha = 1
            set1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
            set1.drawFilledEnabled = true

            let data = LineChartData(dataSet: set1)

            chartView.data = data
        }
     
    }
   
    private func setup(_ dataSet: LineChartDataSet) {
        let downloadColors: UIColor = UIColor(red: 47 / 255, green: 130 / 255, blue: 226 / 255, alpha: 1)
        let uploadColors: UIColor = UIColor(red: 31 / 255, green: 177 / 255, blue: 224 / 255, alpha: 1)
        
        if(flgdownload){
            dataSet.setColor(downloadColors)
        }
        else{
            dataSet.setColor(uploadColors)
        }
            dataSet.setCircleColor(.white)
       // dataSet.v = [.clear]
      

            dataSet.valueTextColor = UIColor.red
           //  dataSet.gradientPositions = nil
            dataSet.lineWidth = 2
            dataSet.circleRadius = 0
            dataSet.drawCircleHoleEnabled = false
            dataSet.valueFont = .systemFont(ofSize: 0)
            dataSet.formLineDashLengths = [5, 2.5]
            dataSet.formLineWidth = 1
            dataSet.formSize = 0
       // }
    }

    func chartShow () {
//        chartView.delegate = self
//
//        chartView.chartDescription.enabled = true
        chartView.dragEnabled = false
      
        self.chartView.setScaleEnabled(false)
        self.chartView.isUserInteractionEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.drawBordersEnabled = false
        chartView.legend.textColor = UIColor.red
        self.chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
       // self.chartView.topAnchor = false
        self.chartView.xAxis.drawGridLinesEnabled = false
        self.chartView.leftAxis.drawLabelsEnabled = false
      //  self.chartView.yAxis.drawGridLinesEnabled = false
        self.chartView.rightAxis.drawLabelsEnabled = false
        self.chartView.legend.enabled = false
        chartView.xAxis.labelTextColor = UIColor.clear
      
        self.setDataCount()
        chartView.animate(xAxisDuration: 2.5)


    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIScreen.main.bounds.size.width < 414 && (UIDevice.current.userInterfaceIdiom != .pad) {
            //            guageContainerHeight.constant = -25
            
        }
        
        if UIScreen.main.bounds.height > 667 {
            //            guageContainerHeight.constant = -100
            //            guageCentreConst.constant = 60
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if PaymentManager.shared.isPurchase() == true {
            proButton.isHidden = true
            proButton.alpha = 0.0
        } else {
            proButton.isHidden = false
            proButton.alpha = 1.0
        }
    }
    
    
    
    
    //MARK:- Custom Methods
    func setupGauge(){
        // Configure gauge view
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gauge.divisionsRadius = 1.25 * ratio
        gauge.subDivisionsRadius = (1.25 - 0.5) * ratio
        gauge.ringThickness = 16 * ratio
        gauge.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(140 * ratio))!
        gauge.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        gauge.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(12 * ratio))!
        
        // Update gauge view
        gauge.minValue = 0
        gauge.maxValue = 200
        gauge.limitValue = 50
    }
    @IBAction func settingsBtnPressed(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Settings", bundle: nil)
        let HomeVCController = storyBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(HomeVCController, animated: true)
        
    }
    @IBAction func homeButtonPressed(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    @IBAction func adblockerButtonPressed(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdBlockVC") as? AdBlockVC
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    @IBAction func onClickPremium(_ sender: Any) {
        Utilities.showPremium(parentController: self, isAppDelegate: false, isFromStore: true, iapEvent: InAppEventLocations.onSpeedChecker)
    }
    
    func locAlert (){
        if UIDevice.current.userInterfaceIdiom == .pad {
            guard let pickerVC = Alterloc else { return }
            pickerVC.delegate = self
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 500, popupHeight: 260)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            present(popupVC, animated: true, completion: nil)
        }
        else{
            guard let pickerVC = Alterloc else { return }
            pickerVC.delegate = self
            let popupVC = PopupViewController(contentController: pickerVC, popupWidth: 300, popupHeight: 160)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            present(popupVC, animated: true, completion: nil)
            
        }
        
    }
    @IBAction func startTouched(_ sender: UIButton) {
        self.latencyValue.text = "\(Int(0.0))"
        self.downloadValue.text = "\(Int(0.0))"
        
        chartShow ()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                locAlert ()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
              
                self.dataPoints.removeAll()
                self.setDataCount()
                
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutSubviews()
                    //            self.speedResultMainView.alpha = 1
                    self.speedTestView.alpha = 1
                }
                
                //        speedTestView.alpha = 1
                let isFirstTest = !UserDefaults.standard.bool(forKey: "is_first_speed_test")
                
                
                btnGo.isHidden = true
                let indicatorsColors: UIColor = UIColor(red: 47 / 255, green: 130 / 255, blue: 226 / 255, alpha: 1)
                let containerColors: UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0)
                self.gaugeView.updateColors(containerColor: containerColors, indicatorsColor: indicatorsColors)
                
                internetTest = InternetSpeedTest(delegate: self)
                internetTest?.startTest() { (error) in
                    print(error as Any)
                }
            @unknown default:
                break
            }
        } else {
            locAlert ()
            print("Location services are not enabled")
        }
        
        
    }
    
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.speedResultMainView.alpha = 0
    }
    
    @IBAction func btnHistory(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = UIStoryboard.init(name: "SpeedChecker", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResulHistoryVC") as? ResulHistoryVC
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    
    @IBAction func restartTestAction(_ sender: Any) {
        self.speedResultMainView.alpha = 0
        //        startTouched(sender as! UIButton)
    }
    
    @IBAction func compressorBtnPressed(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        CompressMediaVC.pushVC(from: self, animated: false)
    }
    
    @IBAction func batteryBtnPressed(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        StartBatteryAnimationVC.pushVC(from: self, animated: false)
    }
    
    //
    func getInternetServiceProviderName(){
        
        
        
    }
    
}

extension SpeedVC: InternetSpeedTestDelegate {

    func internetTest(finish error: SpeedTestError) {
        print("speedTestDidFinish error: \(error.rawValue)")
    }

    func internetTestDownloadStart() {
        print("speedTestDownloadDidStart")
        self.flg = true
        self.flgdownload = true
    }

    func internetTestDownloadFinish() {
        print("speedTestDownloadDidFinish")
        self.flg = true
        self.flgdownload = false
    }

    func internetTestUploadStart() {
        print("speedTestUploadDidStart")
        self.flg = true
    }
    func internetTestUploadFinish() {
        print("speedTestUploadDidFinish")
        self.flg = true
        self.flgdownload = false
    }
    func internetTest(received servers: [SpeedTestServer]) {
        print(servers)
    }


    //MARK:- SpeedTest Finish
    func internetTest(finish result: SpeedTestResult) {
        /*print(result.latencyInMs)
        print(result.uploadSpeed.mbps)
        print(result.downloadSpeed.mbps)
        print(result.server.domain as Any)*/

        UserDefaults.standard.set(true, forKey: "is_first_speed_test")
        DispatchQueue.main.async {
            self.latencyValue.text = "\(result.latencyInMs)"
            self.downloadValue.text = "\(Int(result.jitter))"
            //self.downloadValue.text = "\(result.latencyType)"
            self.lblSpeed.text = "\(result.uploadSpeed.descriptionInMbps)"
            self.lblLatencyValue.text = "\(result.latencyInMs)"
            self.jitterFinalValueLabel.text = "\(Int(result.jitter))"

            self.btnGo.isHidden = false
            self.imgSpeed.image = UIImage(named: "btnDown")
            self.lblSpeed.text = "0.0"
            self.lblTitle.text = "Mbps"
            self.gaugeView.updateValueTo(CGFloat(0.0))

            let indicatorsColors: UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.0)
            let containerColors: UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0)
            self.gauge.value = 0

            self.networkType = self.getNetworkType()
            //print("\(self.networkType)")

            let speedResult = ResultHistory(ip:  result.ipAddress ?? "", dSpeed: self.dSpeed ?? "", uSpeed: self.uSpeed ?? "", ispName: result.ispName ?? "", networkType: self.networkType ?? "")
            DataManager.shared.addBackup(backup: speedResult)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutSubviews()
                    self.speedResultMainView.alpha = 1
                    self.speedTestView.alpha = 0
                }
            }
            self.gaugeView.updateColors(containerColor: containerColors, indicatorsColor: indicatorsColors)
        }

    }

    //MARK:- initial Setup
    func internetTest(selected server: SpeedTestServer, latency: Int) {
        self.latencyValue.text = "\(latency)"

        if latency <= 0 {
            gaugeView.resetColors()
        } else {
            let indicatorsColors: UIColor = UIColor(red: 47 / 255, green: 130 / 255, blue: 226 / 255, alpha: 1)
            let containerColors: UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0)
            self.gaugeView.updateColors(containerColor: containerColors, indicatorsColor: indicatorsColors)
        }
    }


    //MARK:- Download Speedtest
    func internetTestDownload(progress: Double, _ speed: SpeedTestSpeed?) {

        if let speed = speed {
            DispatchQueue.main.async {
                self.imgSpeed.image = UIImage(named: "btnDown")
                // self.downloadValue.text = "\(result.latencyType)"
                self.lblSpeed.text = "\(speed.descriptionInMbps)"
                self.lblDownLoadingSpeed.text = "\(speed.descriptionInMbps)"
                self.dSpeed = "\(speed.descriptionInMbps)"
                let speedtest = ( self.lblDownLoadingSpeed.text! as NSString).floatValue


                //                DispatchQueue.main.async {
                self.isUpload = false
                self.gauge.delegate = self
                self.gauge.value = Double(speedtest)
                //                }

                self.gaugeView.updateValueTo(CGFloat(speedtest))
                if(self.flg){
                    self.dataPoints.removeAll()
                    self.flg = false
                }

                self.dataPoints.append(Double(speedtest))
                self.setDataCount()
            }
        }
    }

    //MARK:- Speedtest Finish


    //MARK:- Upload Speedtest
    func internetTestUpload(progress: Double, _ speed: SpeedTestSpeed?) {
        if let speed = speed {
            DispatchQueue.main.async {
                let indicatorsColors: UIColor = UIColor(red: 31 / 255, green: 177 / 255, blue: 224 / 255, alpha: 1)
                let containerColors: UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0)
                self.gaugeView.updateColors(containerColor: containerColors, indicatorsColor: indicatorsColors)
                self.gaugeView.updateFontColor(fontColor: indicatorsColors)

                self.imgSpeed.image = UIImage(named: "btnUploadimg")
                self.lblSpeed.text = "\(speed.descriptionInMbps)"
                self.lblSpeed.text = "\(speed.descriptionInMbps)"
                self.lblUploadingSpeed.text = "\(speed.descriptionInMbps)"

                self.uSpeed = "\(speed.descriptionInMbps)"
                let speedtest = ( self.lblSpeed.text! as NSString).floatValue
                self.isUpload = true
                self.gauge.delegate = self
                self.gauge.value = Double(speedtest)
                self.gaugeView.updateValueTo(CGFloat(speedtest))
                if(self.flg){
                    self.dataPoints.removeAll()
                    self.flg = false
                }

                self.dataPoints.append(Double(speedtest))
                self.setDataCount()
            }
        }
    }
}

extension SpeedVC: GaugeViewDelegate {
    func ringStokeColor(gaugeView: GaugeView, value: Double) -> UIColor {
        if isUpload == true {
            return UIColor(red: 31 / 255, green: 177 / 255, blue: 224 / 255, alpha: 1)
        } else {
            return UIColor(red: 47 / 255, green: 130 / 255, blue: 226 / 255, alpha: 1)
        }
        
    }
}




//Wifi info

enum WiFISignalStrength: Int {
    case weak = 0
    case ok = 1
    case veryGood = 2
    case excellent = 3
    
    func convertBarsToDBM() -> Int {
        switch self {
        case .weak:
            return -90
        case .ok:
            return -70
        case .veryGood:
            return -50
        case .excellent:
            return -30
        }
    }
}

struct WiFiInfo {
    var rssi: String
    var networkName: String
    var macAddress: String
}


extension SpeedVC {
    //  MARK - WiFi info
    func getWiFiInfo() -> WiFiInfo? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        var wifiInfo: WiFiInfo? = nil
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else {
                return nil
            }
            guard let ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            guard let bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String else {
                return nil
            }
            print(ssid)
            print(bssid)
            
            //            wifiInfo = WiFiInfo(rssi: "\(rssi)", networkName: ssid, macAddress: bssid)
            break
        }
        return wifiInfo
    }
    
    
}

extension SpeedVC: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        convertLatLongToAddress(latitude: locValue.latitude,longitude: locValue.longitude)
    }
    
    func convertLatLongToAddress(latitude:Double,longitude:Double){
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if(placeMark != nil){
                
                if let city = placeMark.locality {
                    print(city)
                    self.lblCity.text = city
                    UserDefaults.standard.set( self.lblCity.text, forKey: "city")
                }
                
                if let country = placeMark.country {
                    print(country)
                    UserDefaults.standard.set( self.lblCountry.text, forKey: "country")
                    self.lblCountry.text = country
                }
            }
        })
        
    }
    
    
}

//MARK:- Get IOS Network type
extension SpeedVC {
    func getNetworkType()->String {
        do{
            let reachability:Reachability = try Reachability()
            try reachability.startNotifier()
            let status = reachability.connection
            if(status == .unavailable){
                return ""
            }else if (status == .wifi){
                return "Wifi"
            }else if (status == .cellular){
                let networkInfo = CTTelephonyNetworkInfo()
                let carrierType = networkInfo.currentRadioAccessTechnology
                switch carrierType{
                case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?: return "2G"
                case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?: return "3G"
                case CTRadioAccessTechnologyLTE?: return "4G"
                default: return ""
                }
                
                
            }else{
                return ""
            }
        }catch{
            return ""
        }
        
    }
    
}

extension SpeedVC: AlterLocationContactDelegate {

    func AlterViewController(sender: AlterLocationContact, didSelectNumber number: Int) {
        dismiss(animated: true) {
            if(number == 1) {
                Utilities.openAppSetting()
                
                //UIApplication.shared.open(URL(string: "App-prefs:Location")!)
                //  self.confirmedDelete()
            }
        }
    }
}
