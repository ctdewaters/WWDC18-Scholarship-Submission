//
//  HUDMap.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/28/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import AppKit

public class HUDMap: NSView {
    
    //MARK: - Initialization.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layer = CALayer()
        self.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = 7
    }
    
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
