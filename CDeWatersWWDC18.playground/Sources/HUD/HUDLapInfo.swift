//
//  HUDLapInfo.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/29/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import AppKit

public protocol HUDLapInfoDelegate {
    func didFinishBestLap(withLapTimeString lapTimeString: String)
}

///HUDLapInfo: Displays the user's best and current lap time.
public class HUDLapInfo: NSView {
    
    //MARK: - Properties.
    ///Displays the user's best lap time.
    public var bestLapTimeLabel: NSTextField?
    
    ///Displays the user's current lap time.
    public var currentLapTimeLabel: NSTextField?
    
    //Header labels.
    private var bestHeaderLabel: NSTextField?
    private var currentHeaderLabel: NSTextField?
    
    ///The background layer.
    private var backgroundLayer: CALayer?
    
    ///The current lap timer.
    private var lapTimer: Timer?
    
    ///The current lap time.
    private var currentLapTime: TimeInterval?
    
    ///The best lap time.
    private var bestLapTime: TimeInterval?
    
    ///The delegate object.
    public var delegate: HUDLapInfoDelegate?
    
    //MARK: - Initialization.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        //Setup the labels.
        self.setupLabels()
        
        //Setup background layer.
        self.backgroundLayer = CALayer()
        self.backgroundLayer?.frame = self.bounds
        self.backgroundLayer?.masksToBounds = true
        self.backgroundLayer?.cornerRadius = 7
        self.backgroundLayer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        self.layer = self.backgroundLayer
        self.wantsLayer = true
    }
    
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - NSTextField functions.
    ///Sets up the labels.
    private func setupLabels() {
        //Current labels setup.
        self.currentHeaderLabel = NSTextField(labelWithString: "CURRENT")
        self.currentHeaderLabel?.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        self.currentHeaderLabel?.textColor = .white
        self.currentHeaderLabel?.sizeToFit()
        self.addSubview(self.currentHeaderLabel!)
        
        self.currentLapTimeLabel = NSTextField(labelWithString: "-:--.---")
        self.currentLapTimeLabel?.font = NSFont.monospacedDigitSystemFont(ofSize: 17, weight: .black)
        self.currentLapTimeLabel?.textColor = .white
        self.currentLapTimeLabel?.sizeToFit()
        self.addSubview(self.currentLapTimeLabel!)
        
        //Best labels setup.
        self.bestHeaderLabel = NSTextField(labelWithString: "BEST")
        self.bestHeaderLabel?.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        self.bestHeaderLabel?.textColor = .white
        self.bestHeaderLabel?.sizeToFit()
        self.addSubview(self.bestHeaderLabel!)
        
        self.bestLapTimeLabel = NSTextField(labelWithString: "-:--.---")
        self.bestLapTimeLabel?.font = NSFont.monospacedDigitSystemFont(ofSize: 17, weight: .bold)
        self.bestLapTimeLabel?.textColor = .white
        self.bestLapTimeLabel?.sizeToFit()
        self.addSubview(self.bestLapTimeLabel!)
        
        self.alignLabels()
    }
    
    ///Places the labels in the correct positions.
    private func alignLabels() {
        self.currentLapTimeLabel?.sizeToFit()
        self.currentLapTimeLabel?.frame.origin.x = (self.frame.width / 2) - (self.currentLapTimeLabel!.frame.width / 2)
        self.currentLapTimeLabel?.frame.origin.y = (self.frame.height / 2) + self.currentLapTimeLabel!.frame.height - 20
        
        self.currentHeaderLabel?.frame.origin = CGPoint(x: self.currentLapTimeLabel!.frame.minX, y: self.currentLapTimeLabel!.frame.origin.y + self.currentLapTimeLabel!.frame.height)
        
        self.bestLapTimeLabel?.sizeToFit()
        self.bestLapTimeLabel?.frame.origin.x = (self.frame.width / 2) - (self.bestLapTimeLabel!.frame.width / 2)
        self.bestLapTimeLabel?.frame.origin.y = (self.frame.height / 2) - self.bestLapTimeLabel!.frame.height - 20
        
        self.bestHeaderLabel?.frame.origin = CGPoint(x: self.currentHeaderLabel!.frame.minX, y: self.bestLapTimeLabel!.frame.origin.y + self.bestLapTimeLabel!.frame.height)
    }
    
    ///MARK: - Lap time management functions.
    ///Starts a new lap time.
    public func startNewLapTime() {
        DispatchQueue.main.async {
            //Invalidate the lap timer.
            self.lapTimer?.invalidate()
            
            //Check if the lap was less than the previously posted best.
            if self.currentLapTime ?? 0 < self.bestLapTime ?? 9999999 {
                self.bestLapTime = self.currentLapTime
                if let bestLapTime = self.bestLapTime {
                    ///Run the delegate function.
                    self.delegate?.didFinishBestLap(withLapTimeString: bestLapTime.lapTimeString)
                    self.bestLapTimeLabel?.stringValue = bestLapTime.lapTimeString
                }
                else {
                    self.bestLapTime = 9999999
                }
                
                //Update the current best lap time label.
                self.alignLabels()
            }
            self.currentLapTime = 0.0
            
            //Start the lap timer.
            self.lapTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { (timer) in
                //Increase lap time.
                self.currentLapTime = (self.currentLapTime ?? 0) + 0.001
                //Update the current lap time label.
                DispatchQueue.main.async {
                    self.currentLapTimeLabel?.stringValue = self.currentLapTime?.lapTimeString ?? "-:--.---"
                    self.alignLabels()
                }
            })
        }
    }
}

//MARK: - TimeInterval extension.
public extension TimeInterval {
    ///The string value, containing time data to the thousandth of a second.
    public var lapTimeString: String {
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((self - Double(Int(self))) * 1000)
        
        let secondsString = String(format: "%02d", seconds)
        let millisecondsString = String(format: "%03d", milliseconds)
        return "\(minutes):\(secondsString).\(millisecondsString)"
    }
}
