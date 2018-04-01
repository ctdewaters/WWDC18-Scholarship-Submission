//
//  HUD.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/28/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import AppKit

//HUD: Displays graphics like the track map and the user controlled car's physical properties.
public class HUD: NSView, HUDLapInfoDelegate {
    
    //MARK: - Properties.
    ///The speedometer view.
    public var speedometer: HUDSpeedometer?
    
    ///The lap info view.
    public var lapInfoView: HUDLapInfo?
    
    ///The track map.
    public var trackMap: HUDMap?
    
    ///The lap counter.
    public var lapCounter: HUDLapCounter?
    
    ///The best lap indicator.
    public var bestLapIndicator: HUDBestLapIndicator?
    
    //MARK: - Initialization.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.resignFirstResponder()
        
        //Setup speedometer.
        self.speedometer = HUDSpeedometer(frame: NSRect(x: frameRect.width - 110, y: 20, width: 90, height: 90))
        self.addSubview(self.speedometer!)
        
        //Setup lap info view.
        self.lapInfoView = HUDLapInfo(frame: NSRect(x: frameRect.width - 120, y: frameRect.height - 120, width: 100, height: 100))
        self.lapInfoView?.delegate = self
        self.addSubview(self.lapInfoView!)
        
        //Setup track map.
//        self.trackMap = HUDMap(frame: NSRect(x: 20, y: 20, width: 130, height: 110))
//        self.addSubview(self.trackMap!)
        
        //Setup lap counter.
        self.lapCounter = HUDLapCounter(frame: NSRect(x: 20, y: frameRect.height - 55, width: 130, height: 35))
        self.addSubview(self.lapCounter!)
        
        //Setup best lap indicator.
        self.bestLapIndicator = HUDBestLapIndicator(frame: NSRect(x: (frameRect.width / 2) - (250 / 2), y: frameRect.height, width: 250, height: 65))
        self.addSubview(self.bestLapIndicator!)
    }
    
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Hit test.
    public override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    //MARK: - Update function.
    ///Updates the HUD with the user controlled car's position and speed.
    public func update(with2DCarPosition carPosition: CGPoint, andCarSpeedInKilometersPerHour carSpeed: CGFloat) {
        DispatchQueue.main.async {
            //Update the speedometer.
            self.speedometer?.update(withSpeedInKPH: carSpeed)
        }
    }
    
    //MARK: - HUDLapInfoDelegate.
    public func didFinishBestLap(withLapTimeString lapTimeString: String) {
        self.bestLapIndicator?.present(withLapTimeString: lapTimeString)
    }
}
