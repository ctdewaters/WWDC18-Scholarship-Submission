//
//  HUDLapCounter.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/30/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import Cocoa

public class HUDLapCounter: NSView {

    //MARK: - Properties.
    ///The lap counter label.
    public var label: NSTextField?
    
    ///The lap count.
    public var lap: Int = 0
    
    //MARK: - Initialization.
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        //Setup label.
        self.label = NSTextField(labelWithString: "LAP \(self.lap)")
        self.label?.font = NSFont.systemFont(ofSize: 17, weight: .bold)
        self.label?.textColor = .white
        self.addSubview(self.label!)
        self.alignLabel()
        
        ///Setup layer.
        self.wantsLayer = true
        self.layer = CALayer()
        self.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = 7
    }
    
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///MARK: - Label functions.
    ///Places label in the center of the view.
    private func alignLabel() {
        self.label?.sizeToFit()
        self.label?.frame.origin.x = (self.frame.width / 2) - (self.label!.frame.width / 2)
        self.label?.frame.origin.y = (self.frame.height / 2) - (self.label!.frame.height / 2)
    }
    
    //MARK: - Lap functions.
    ///Increments lap counter.
    public func incrementLapCounter() {
        DispatchQueue.main.async {
            self.lap += 1
            self.label?.stringValue = "LAP \(self.lap)"
            self.alignLabel()
        }
    }
    
}
