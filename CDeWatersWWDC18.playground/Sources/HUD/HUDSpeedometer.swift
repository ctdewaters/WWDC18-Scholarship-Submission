//
//  HUDSpeedometer.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/28/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import AppKit

public class HUDSpeedometer: NSView {
    //MARK: - Properties.
    ///Displays the speed of the user controlled car, in MPH.
    public var label: NSTextField?
    
    ///Displays the the speed of the user controlled car visually (in a circle shape around the label).
    public var visualRepresentationLayer: CAShapeLayer?
    
    ///Displays a track for the visual representation to run along.
    private var trackLayer: CAShapeLayer?
    
    //MARK: - Initialization.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        //Setup
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
    }
    
    public override func layout() {
        super.layout()
    }
    
    //MARK: - Setup functions.
    ///Sets up the interface.
    private func setup() {
        //Label setup.
        self.label = NSTextField(labelWithAttributedString: self.attributedString(forSpeedInKPH: 0))
        self.label?.frame = self.bounds
        self.label?.alignment = .center
        self.label?.sizeToFit()
        self.centerLabel()
        self.addSubview(self.label!)
        
        //Track layer setup.
        self.trackLayer = CAShapeLayer()
        self.trackLayer?.path = CGPath(ellipseIn: self.bounds, transform: nil)
        self.trackLayer?.strokeColor = NSColor.black.cgColor
        self.trackLayer?.fillColor = NSColor.clear.cgColor
        self.trackLayer?.lineWidth = 7
        self.trackLayer?.lineJoin = kCALineJoinRound
        self.trackLayer?.fillRule = kCAFillRuleNonZero
        self.trackLayer?.lineCap = kCALineCapRound
        self.trackLayer?.frame = self.bounds
        self.trackLayer?.strokeStart = 0.1
        self.trackLayer?.strokeEnd = 0.9
        self.layer = self.trackLayer
        self.wantsLayer = true
        self.layer?.masksToBounds = false
        
        //Shape setup.
        self.visualRepresentationLayer = CAShapeLayer()
        self.visualRepresentationLayer?.path = CGPath(ellipseIn: self.bounds, transform: nil)
        self.visualRepresentationLayer?.strokeColor = NSColor.green.cgColor
        self.visualRepresentationLayer?.fillColor = NSColor.black.withAlphaComponent(0.75).cgColor
        self.visualRepresentationLayer?.lineWidth = 7
        self.visualRepresentationLayer?.lineJoin = kCALineJoinRound
        self.visualRepresentationLayer?.fillRule = kCAFillRuleNonZero
        self.visualRepresentationLayer?.lineCap = kCALineCapRound
        self.visualRepresentationLayer?.frame = self.bounds
        self.visualRepresentationLayer?.strokeStart = 0.9
        self.visualRepresentationLayer?.strokeEnd = 0.9
        self.trackLayer?.addSublayer(self.visualRepresentationLayer!)
    }
    
    ///Centers the label in the view.
    private func centerLabel() {
        self.label?.frame.origin = CGPoint(x: (self.frame.width / 2) - (self.label!.frame.width / 2), y: (self.frame.height / 2) - (self.label!.frame.height / 2))
    }
    
    //MARK: - Speed calculation functions.
    private func attributedString(forSpeedInKPH kph: CGFloat) -> NSAttributedString {
        let aString = NSMutableAttributedString(string: "\(Int(self.mph(fromKPH: kph))) ", attributes: [NSAttributedStringKey.font: NSFont.monospacedDigitSystemFont(ofSize: 17, weight: .bold), NSAttributedStringKey.foregroundColor: NSColor.white])
        //Add unit string.
        aString.append(NSAttributedString(string: "MPH", attributes: [NSAttributedStringKey.font: NSFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular), NSAttributedStringKey.foregroundColor: NSColor.white]))
        return aString
    }
    
    private func mph(fromKPH kph: CGFloat) -> CGFloat {
        return (kph / 1.621371) * 2
    }
    
    //MARK: - Update functions.
    public func update(withSpeedInKPH kph: CGFloat) {
        //Update the label.
        self.label?.attributedStringValue = self.attributedString(forSpeedInKPH: kph)
        self.label?.sizeToFit()
        self.centerLabel()
        
        //Update the visual representation.
        let speedRatio = kph / (RaceCar.maxSpeedInKilometersPerHour / 2)
        self.visualRepresentationLayer?.strokeStart = 0.9 - (0.8 * speedRatio)
        
        self.visualRepresentationLayer?.strokeColor = NSColor(calibratedRed: (255 * speedRatio) / 255, green: (255 - (255 * speedRatio)) / 255, blue: 0, alpha: 1).cgColor
    }
}
