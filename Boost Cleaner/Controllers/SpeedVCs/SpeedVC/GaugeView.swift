//
//  GaugeView.swift
//  LMGaugeViewSwift
//
//  Created by LMinh on 5/22/19.
//

import Foundation
import UIKit

public protocol GaugeViewDelegate: class {
    
    /// Return ring stroke color from the specified value.
    func ringStokeColor(gaugeView: GaugeView, value: Double) -> UIColor
}

open class GaugeView: UIView {
    
    // MARK: PROPERTIES
    
    public static let defaultFontName = "HelveticaNeue-CondensedBold"
    
    public static let defaultMinMaxValueFont = "HelveticaNeue"
    fileprivate var handleShape: CAShapeLayer!
    public var handleColor = UIColor(red: 37 / 255, green: 48 / 255, blue: 74 / 255, alpha: 1)
    public var startDegree: CGFloat!
    public var endDegree: CGFloat!
    public var sectionsGapValue: CGFloat!
//    public var minValue: CGFloat!
//    public var maxValue: CGFloat!
    public var currentValue: CGFloat!
    
    
    public var startDegree1: CGFloat!
    public var endDegree1: CGFloat!
    public var sectionsGapValue1: CGFloat!
    public var minValue1: CGFloat!
    public var maxValue1: CGFloat!
    public var currentValue1: CGFloat!
    fileprivate var displayLink: CADisplayLink?
    fileprivate var absStartTime: CFAbsoluteTime?
    
    
    //custom NeedleView
    var needleColor = UIColor(white: 0.7, alpha: 1)
    var needleWidth: CGFloat = 4
    let needle = UIView()
    
    
    /// Current value.
    public var value: Double = 0 {
        didSet {
            value = max(min(value, maxValue), minValue)
            
            // Set text for value label
//            valueLabel.text = String(format: "%.0f", value)
            
            // Trigger the stoke animation of ring layer
            strokeGauge()
        }
    }
    
    /// Minimum value.
    public var minValue: Double = 0
    
    /// Maximum value.
    public var maxValue: Double = 200
    
    /// Limit value.
    public var limitValue: Double = 50
    
    /// The number of divisions.
    @IBInspectable public var numOfDivisions: Int = 6
    
    /// The number of subdivisions.
    @IBInspectable public var numOfSubDivisions: Int = 10
    
    /// The thickness of the ring.
    @IBInspectable public var ringThickness: Double = 15
    
    /// The background color of the ring.
    @IBInspectable public var ringBackgroundColor: UIColor = UIColor(red: 212 / 255, green: 232 / 255, blue: 255 / 255, alpha: 1)
    
    
    /// The divisions radius.
    @IBInspectable public var divisionsRadius: Double = 1.25
    
    /// The divisions color.
    @IBInspectable public var divisionsColor: UIColor = UIColor(white: 0.5, alpha: 0)
    
    /// The padding between ring and divisions.
    @IBInspectable public var divisionsPadding: Double = 12
    
    /// The subdivisions radius.
    @IBInspectable public var subDivisionsRadius: Double = 0.75
    
    /// The subdivisions color.
    @IBInspectable public var subDivisionsColor: UIColor = UIColor(white: 0.5, alpha: 0.0)
    
    /// A boolean indicates whether to show limit dot.
    @IBInspectable public var showLimitDot: Bool = true
    
    /// The radius of limit dot.
    @IBInspectable public var limitDotRadius: Double = 2
    
    /// The color of limit dot.
    @IBInspectable public var limitDotColor: UIColor = .red
    
    /// Font of value label.
    @IBInspectable public var valueFont: UIFont = UIFont(name: defaultFontName, size: 140) ?? UIFont.systemFont(ofSize: 140)
    
    /// Text color of value label.
    @IBInspectable public var valueTextColor: UIColor = UIColor(white: 0.1, alpha: 1)
    
    /// A boolean indicates whether to show min/max value.
    @IBInspectable public var showMinMaxValue: Bool = true
    
    /// Font of min/max value label.
    @IBInspectable public var minMaxValueFont: UIFont = UIFont(name: defaultMinMaxValueFont, size: 12) ?? UIFont.systemFont(ofSize: 12)
    
    /// Text color of min/max value label.
    @IBInspectable public var minMaxValueTextColor: UIColor = UIColor(white: 0.3, alpha: 1)
    
    /// A boolean indicates whether to show unit of measurement.
    @IBInspectable public var showUnitOfMeasurement: Bool = true
    
    /// The unit of measurement.
    @IBInspectable public var unitOfMeasurement: String = "km/h"
    
    /// Font of unit of measurement label.
    @IBInspectable public var unitOfMeasurementFont: UIFont = UIFont(name: defaultFontName, size: 16) ?? UIFont.systemFont(ofSize: 16)
    
    /// Text color of unit of measurement label.
    @IBInspectable public var unitOfMeasurementTextColor: UIColor = UIColor(white: 0.3, alpha: 1)
    
    
    
    // MARK: - Container calculations
    fileprivate var totalSeparationPoints: Int {
        return Int((CGFloat(self.maxValue) - CGFloat(self.maxValue)) / sectionsGapValue1)
    }
    
    fileprivate var calculatedStartDegree: CGFloat {
        return 270.0 - 45.0
    }
    
    fileprivate var calculatedEndDegree: CGFloat {
        return 270.0 - 270.0 + 360
    }
    
    /// The receiver of all gauge view delegate callbacks.
    public weak var delegate: GaugeViewDelegate? = nil
    
    var startAngle: Double = .pi * 3/4
    var endAngle: Double = .pi/4 + .pi * 2
    var divisionUnitAngle: Double = 0
    var divisionUnitValue: Double = 0
    
    lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.lineJoin = CAShapeLayerLineJoin.bevel
        layer.strokeEnd = 0
        return layer
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var unitOfMeasurementLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var minValueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.textColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var maxValueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .right
        label.textColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: DRAWING
    
    override open func draw(_ rect: CGRect) {
        
        // Prepare drawing
        divisionUnitValue = numOfDivisions != 0 ? (maxValue - minValue)/Double(numOfDivisions) : 0
        divisionUnitAngle = numOfDivisions != 0 ? abs(endAngle - startAngle)/Double(numOfDivisions) : 0
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let ringRadius = Double(min(bounds.width, bounds.height))/2 - ringThickness/2
        let dotRadius = ringRadius - ringThickness/2 - divisionsPadding - divisionsRadius/2
        
        // Draw the ring background
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(ringThickness))
        context?.beginPath()
        context?.setLineCap(.round)
        context?.addArc(center: center,
                        radius: CGFloat(ringRadius),
                        startAngle: 0,
                        endAngle: .pi * 2,
                        clockwise: false)
        context?.setStrokeColor(ringBackgroundColor.withAlphaComponent(0.0).cgColor)
        context?.strokePath()
        
        // Draw the ring progress background
        context?.setLineWidth(CGFloat(ringThickness))
        context?.beginPath()
        context?.addArc(center: center,
                        radius: CGFloat(ringRadius),
                        startAngle: CGFloat(startAngle),
                        endAngle: CGFloat(endAngle),
                        clockwise: false)
        context?.setStrokeColor(ringBackgroundColor.cgColor)
        context?.strokePath()
        
        // Draw divisions and subdivisions
        if numOfDivisions != 0 {
            for i in 0...numOfDivisions {
                if i != numOfDivisions && numOfSubDivisions != 0 {
                    for j in 0...numOfSubDivisions {
                        
                        // Subdivisions
                        let value = Double(i) * divisionUnitValue + Double(j) * divisionUnitValue/Double(numOfSubDivisions) + minValue
                        let angle = angleFromValue(value)
                        let point = CGPoint(x: dotRadius * cos(angle) + Double(center.x),
                                            y: dotRadius * sin(angle) + Double(center.y))
                        context?.drawDot(center: point,
                                         radius: subDivisionsRadius,
                                         fillColor: subDivisionsColor)
                    }
                }
                
                // Divisions
                let value = Double(i) * divisionUnitValue + minValue
                let angle = angleFromValue(value)
                let point = CGPoint(x: dotRadius * cos(angle) + Double(center.x),
                                    y: dotRadius * sin(angle) + Double(center.y))
                context?.drawDot(center: point,
                                 radius: divisionsRadius,
                                 fillColor: divisionsColor)
            }
        }
        
        // Draw the limit dot
        if showLimitDot && numOfDivisions != 0 {
            let angle = angleFromValue(limitValue)
            let point = CGPoint(x: dotRadius * cos(angle) + Double(center.x),
                                y: dotRadius * sin(angle) + Double(center.y))
            context?.drawDot(center: point,
                             radius: limitDotRadius,
                             fillColor: limitDotColor)
        }
        
        // Progress Layer
        if progressLayer.superlayer == nil {
            layer.addSublayer(progressLayer)
        }
        progressLayer.frame = CGRect(x: center.x - CGFloat(ringRadius) - CGFloat(ringThickness)/2,
                                     y: center.y - CGFloat(ringRadius) - CGFloat(ringThickness)/2,
                                     width: (CGFloat(ringRadius) + CGFloat(ringThickness)/2) * 2,
                                     height: (CGFloat(ringRadius) + CGFloat(ringThickness)/2) * 2)
        progressLayer.bounds = progressLayer.frame
        let smoothedPath = UIBezierPath(arcCenter: progressLayer.position,
                                        radius: CGFloat(ringRadius),
                                        startAngle: CGFloat(startAngle),
                                        endAngle: CGFloat(endAngle),
                                        clockwise: true)
        progressLayer.path = smoothedPath.cgPath
        progressLayer.lineWidth = CGFloat(ringThickness)
        
        // Value Label
        if valueLabel.superview == nil {
            addSubview(valueLabel)
        }
        valueLabel.text = String(format: "%.0f", value)
        valueLabel.textColor = UIColor.clear
        valueLabel.font = valueFont
        valueLabel.minimumScaleFactor = 10/valueFont.pointSize
        valueLabel.textColor = UIColor.clear
        let insetX = ringThickness + divisionsPadding * 2 + divisionsRadius
        valueLabel.frame = progressLayer.frame.insetBy(dx: CGFloat(insetX), dy: CGFloat(insetX))
        valueLabel.frame = valueLabel.frame.offsetBy(dx: 0, dy: showUnitOfMeasurement ? CGFloat(-divisionsPadding/2) : 0)
        
        // Min Value Label
        if minValueLabel.superview == nil {
            addSubview(minValueLabel)
        }
        minValueLabel.text = String(format: "%.0f", minValue)
        minValueLabel.font = minMaxValueFont
        minValueLabel.minimumScaleFactor = 10/minMaxValueFont.pointSize
        minValueLabel.textColor = UIColor.clear
        minValueLabel.isHidden = !showMinMaxValue
        let minDotCenter = CGPoint(x: CGFloat(dotRadius * cos(startAngle)) + center.x,
                                   y: CGFloat(dotRadius * sin(startAngle)) + center.y)
        minValueLabel.frame = CGRect(x: minDotCenter.x + 8, y: minDotCenter.y - 20, width: 40, height: 20)
        
        // Max Value Label
        if maxValueLabel.superview == nil {
            addSubview(maxValueLabel)
        }
        maxValueLabel.text = String(format: "%.0f", maxValue)
        maxValueLabel.font = minMaxValueFont
        maxValueLabel.minimumScaleFactor = 10/minMaxValueFont.pointSize
        maxValueLabel.textColor = UIColor.clear
        maxValueLabel.isHidden = !showMinMaxValue
        let maxDotCenter = CGPoint(x: CGFloat(dotRadius * cos(endAngle)) + center.x,
                                   y: CGFloat(dotRadius * sin(endAngle)) + center.y)
        maxValueLabel.frame = CGRect(x: maxDotCenter.x - 8 - 40, y: maxDotCenter.y - 20, width: 40, height: 20)
        
        // Unit Of Measurement Label
        if unitOfMeasurementLabel.superview == nil {
            addSubview(unitOfMeasurementLabel)
        }
        unitOfMeasurementLabel.text = unitOfMeasurement
        unitOfMeasurementLabel.font = unitOfMeasurementFont
        unitOfMeasurementLabel.minimumScaleFactor = 10/unitOfMeasurementFont.pointSize
        unitOfMeasurementLabel.textColor = UIColor.clear
        unitOfMeasurementLabel.isHidden = true
        unitOfMeasurementLabel.frame = CGRect(x: valueLabel.frame.origin.x,
                                              y: valueLabel.frame.maxY - 10,
                                              width: valueLabel.frame.width,
                                              height: 20)
//    drawHandleShape()
    }
    
    public func strokeGauge() {
        
        // Set progress for ring layer
        let progress = maxValue != 0 ? (value - minValue)/(maxValue - minValue) : 0
        progressLayer.strokeEnd = CGFloat(progress)

        // Set ring stroke color
        var ringColor = UIColor(red: 45 / 255, green: 225 / 255, blue: 210 / 255, alpha: 1)
        if let delegate = delegate {
            ringColor = delegate.ringStokeColor(gaugeView: self, value: value)
        }
        progressLayer.strokeColor = ringColor.cgColor
    }
    
    
    //MARK:- Draw Handle
    fileprivate func drawHandleShape() {
        handleShape = CAShapeLayer()
//        handleShape.fillColor = UIColor.green.cgColor
        
        let baseDegree = degreeToRadian(newPositionValue)
        let leftAngle = degreeToRadian(90 + newPositionValue)
        let rightAngle = degreeToRadian(-90 + newPositionValue)
        
        let startVal = frame.width / 3.3
        let length = CGFloat(18)
        let endVal = startVal + length
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let endPoint = CGPoint(x: cos(-baseDegree) * endVal + centerPoint.x,
                               y: sin(-baseDegree) * endVal + centerPoint.y)
        let rightPoint = CGPoint(x: cos(-leftAngle) * CGFloat(15) + centerPoint.x,
                                 y: sin(-leftAngle) * CGFloat(15) + centerPoint.y)
        let leftPoint = CGPoint(x: cos(-rightAngle) * CGFloat(15) + centerPoint.x,
                                y: sin(-rightAngle) * CGFloat(15) + centerPoint.y)
        
        let handlePath = UIBezierPath()
        handlePath.move(to: rightPoint)
        
        let midx = rightPoint.x + ((leftPoint.x - rightPoint.x) / 2)
        let midy = rightPoint.y + ((leftPoint.y - rightPoint.y) / 2)
        let diffx = midx - rightPoint.x
        let diffy = midy - rightPoint.y
        let angle = (atan2(diffy, diffx) * CGFloat((180 / Double.pi))) - 90
        let targetRad = degreeToRadian(angle)
        let newX = midx - 20 * cos(targetRad)
        let newY = midy - 20 * sin(targetRad)
        
        handlePath.addQuadCurve(to: leftPoint, controlPoint: CGPoint(x: newX, y: newY))
        handlePath.addLine(to: endPoint)
        handlePath.addLine(to: rightPoint)
        
        handleShape.path = handlePath.cgPath
        handleShape.anchorPoint = centerPoint
        handleShape.path = handlePath.cgPath
        handleShape.lineCap = .round
        layer.addSublayer(handleShape)
        
        absStartTime = CFAbsoluteTimeGetCurrent()
        displayLink = CADisplayLink(target: self, selector: #selector(updateHandle(_:)))
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    @objc fileprivate func updateHandle(_ sender: CADisplayLink) {
        let newPositionAngle = degreeToRadian(newPositionValue)
        let leftAngle = degreeToRadian(120 + newPositionValue)
        let rightAngle = degreeToRadian(-120 + newPositionValue)
        
        let startVal = frame.width / 3.3
        let length = CGFloat(18)
        let endVal = startVal + length
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let endPoint = CGPoint(x: cos(-newPositionAngle) * endVal + centerPoint.x,
                               y: sin(-newPositionAngle) * endVal + centerPoint.y)
        let rightPoint = CGPoint(x: cos(-leftAngle) * CGFloat(15) + centerPoint.x,
                                 y: sin(-leftAngle) * CGFloat(15) + centerPoint.y)
        let leftPoint = CGPoint(x: cos(-rightAngle) * CGFloat(15) + centerPoint.x,
                                y: sin(-rightAngle) * CGFloat(15) + centerPoint.y)
        
        let handlePath = UIBezierPath()
        handlePath.move(to: rightPoint)
        
        let midx = rightPoint.x + ((leftPoint.x - rightPoint.x) / 2)
        let midy = rightPoint.y + ((leftPoint.y - rightPoint.y) / 2)
        let diffx = midx - rightPoint.x
        let diffy = midy - rightPoint.y
        let angle = (atan2(diffy, diffx) * CGFloat((180 / Double.pi))) - 90
        let targetRad = degreeToRadian(angle)
        let newX = midx - 20 * cos(targetRad)
        let newY = midy - 20 * sin(targetRad)
        
        handlePath.addQuadCurve(to: leftPoint, controlPoint: CGPoint(x: newX, y: newY))
        handlePath.addLine(to: endPoint)
        handlePath.addLine(to: rightPoint)
        handlePath.lineCapStyle = .round
        handleShape.path = handlePath.cgPath
    }
    
    
    fileprivate func degreeToRadian(_ degree: CGFloat) -> CGFloat {
        return CGFloat(degree * CGFloat(Double.pi / 180.0))
    }
    
    fileprivate var newPositionValue: CGFloat {
        currentValue1 = CGFloat(self.value)
//        maxValue1 = 120
//        minValue1 = 0
        if currentValue1 > CGFloat(self.maxValue) {
            currentValue1 = CGFloat(self.maxValue)
        }
        return calculatedStartDegree - (currentValue1 * (360.0 - (calculatedEndDegree - calculatedStartDegree))) / CGFloat(self.maxValue)
    }
    
    fileprivate func calculateDegree(for point: CGFloat) -> CGFloat {
        if point == 0 {
            return calculatedStartDegree
        } else if point == CGFloat(totalSeparationPoints) {
            return calculatedEndDegree
        } else {
            return calculatedStartDegree - ((360.0 - (calculatedEndDegree - calculatedStartDegree)) / CGFloat(totalSeparationPoints)) * point
        }
    }
}



// MARK: - SUPPORT

extension GaugeView {
    func angleFromValue(_ value: Double) -> Double {
        let level = divisionUnitValue != 0 ? (value - minValue)/divisionUnitValue : 0
        let angle = level * divisionUnitAngle + startAngle
        return angle
    }
}

extension CGContext {
    func drawDot(center: CGPoint, radius: Double, fillColor: UIColor) {
        beginPath()
        addArc(center: center,
               radius: CGFloat(radius),
               startAngle: 0,
               endAngle: .pi * 2,
               clockwise: false)
        setFillColor(fillColor.cgColor)
        fillPath()
    }
}
