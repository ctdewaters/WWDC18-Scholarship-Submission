//
//  HUDBestLapIndicator.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 4/1/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import AppKit
import AVFoundation

public class HUDBestLapIndicator: NSView {

    //MARK: - Properties.
    ///The title label.
    public var titleLabel: NSTextField?
    
    ///The lap time label.
    public var lapTimeLabel: NSTextField?
    
    ///The background layer.
    public var backgroundLayer: CALayer?
    
    ///The audio player.
    public var player: AVAudioPlayer?
    
    //MARK: - Initialization.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        ///Setup background.
        self.backgroundLayer = CALayer()
        self.backgroundLayer?.masksToBounds = true
        self.backgroundLayer?.cornerRadius = 7
        self.backgroundLayer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        self.wantsLayer = true
        self.layer = backgroundLayer
        
        //Setup title label.s
        self.titleLabel = NSTextField(labelWithString: "New Lap Record!")
        self.titleLabel?.font = NSFont.systemFont(ofSize: 22, weight: .bold)
        self.titleLabel?.textColor = .white
        self.addSubview(self.titleLabel!)
        
        //Setup lap time label.
        self.lapTimeLabel = NSTextField(labelWithString: "")
        self.lapTimeLabel?.font = NSFont.monospacedDigitSystemFont(ofSize: 17, weight: .medium)
        self.lapTimeLabel?.textColor = .white
        self.addSubview(self.lapTimeLabel!)
    }
    
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup function.
    private func setup(withLapTimeString lapTimeString: String) {
        //Update the string value of the lap time label.
        self.lapTimeLabel?.stringValue = lapTimeString
        
        ///Layout the labels.
        self.alignLabels()
    }
    
    //MARK : - Label functions.
    private func alignLabels() {
        self.titleLabel?.sizeToFit()
        self.titleLabel?.frame.origin = CGPoint(x: (self.frame.width / 2) - (self.titleLabel!.frame.width / 2), y: (self.frame.height / 2) + (self.titleLabel!.frame.height / 2) - 15)
        
        self.lapTimeLabel?.sizeToFit()
        self.lapTimeLabel?.frame.origin.x = (self.frame.width / 2) - (self.lapTimeLabel!.frame.width / 2)
        self.lapTimeLabel?.frame.origin.y = self.titleLabel!.frame.origin.y - self.lapTimeLabel!.frame.height
    }
    
    //MARK: - Present and dismiss functions.
    ///Presents the indicator.
    public func present(withLapTimeString lapTimeString: String) {
        self.setup(withLapTimeString: lapTimeString)
        
        //Setup audio player.
        if let url = Bundle.main.url(forResource: "bestLapTimeJingle", withExtension: "m4a") {
            do {
                self.player = try AVAudioPlayer(contentsOf: url)
                self.player?.prepareToPlay()
                self.player?.play()
            }
            catch {
                print(error)
            }
        }
        
        //Run animation.
        if let superview = self.superview {
            //Prepare for animation.
            self.alphaValue = 0
            self.frame.origin.y = superview.frame.height
            
            //Animate in
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 0.3
            self.animator().alphaValue = 1
            self.animator().frame.origin.y = superview.frame.height - self.frame.height - 20
            NSAnimationContext.endGrouping()
            
            //Dismiss after 3.5 seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                self.dismiss()
            }
        }
    }
    
    ///Dismisses the indicator.
    public func dismiss() {
        if let superview = self.superview {
            //Prepare for animation.
            self.alphaValue = 0
            self.frame.origin.y = superview.frame.height - self.frame.height - 20
            
            //Animate in
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 0.3
            self.animator().alphaValue = 0
            self.animator().frame.origin.y = superview.frame.height
            NSAnimationContext.endGrouping()
        }
    }
}
