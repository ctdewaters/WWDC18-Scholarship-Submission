//
//  GameView.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/26/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import Cocoa
import SceneKit

public class GameView: SCNView, SCNSceneRendererDelegate {
    
    //MARK: - Properties.
    ///The car controlled by the user.
    public var userCar: RaceCar?
    
    ///The HUD view.
    public var hud: HUD?
    
    ///The time the lap count was updated.
    private var lapCountUpdateTime: TimeInterval?
    
    
    //MARK: - Initialization.
    public init(withFrame frame: NSRect) {
        super.init(frame: frame, options: nil)
        
        //Setup the scene view.
        self.scene = SCNScene(named: "SceneKitAssets/Scene.scn")!
        
        //Add the user controlled car.
        self.userCar = RaceCar(toScene: self.scene!, atPosition: SCNVector3Make(0, 0, 50), isUserControlled: true)
        
        //Position the car.
        self.userCar?.chassisNode?.eulerAngles.y = CGFloat.pi
        
        //Setup HUD.
        self.hud = HUD(frame: frame)
        self.addSubview(self.hud!)
        
        //Setup.
        self.delegate = self
        self.backgroundColor = .black
        
        //Set initial POV.
        self.pointOfView = self.userCar?.cameras?[0]
        
    }
    
    
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Changing point of view.
    ///Changes the point of view in the SCNScene.
    func swapPOV() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.25
        self.pointOfView = (self.userCar?.cameras?[0] == self.pointOfView) ? self.userCar?.cameras?[1] : self.userCar?.cameras?[0]
        SCNTransaction.commit()
    }
    
    //MARK: - NSView overrides.
    override public func keyDown(with event: NSEvent) {
        if let key = RaceCar.Controls.Key.from(event: event) {
            RaceCar.Controls.shared.didRecieve(keyInput: key)
        }
    }
    
    override public func keyUp(with event: NSEvent) {
        if let key = RaceCar.Controls.Key.from(event: event) {
            RaceCar.Controls.shared.didEnd(keyInput: key)
        }
    }
    
    //MARK: - Updating functions.
    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        //Apply controls.
        self.applyControls()
        
        //Update the HUD.
        self.hud?.update(with2DCarPosition: .zero, andCarSpeedInKilometersPerHour: self.userCar?.currentSpeedInKPH ?? 0)
        
        self.checkForLapFinish(atTime: time)
    }
    
    ///Applies the current shared instance of the RaceCar controls to the scene.
    public func applyControls() {
        //Apply movement controls to the user controlled car.
        self.userCar?.applyUserInteraction(withControls: RaceCar.Controls.shared)
        
        //Check if the change camera button was activated.
        if RaceCar.Controls.shared.changeCameraKeyActive {
            self.swapPOV()
            RaceCar.Controls.shared.cameraDidChange()
        }
    }
    
    ///Determines if we should time a new lap.
    private func checkForLapFinish(atTime time: TimeInterval) {
        //Check distance of the nose of the user controlled car from the start finish line (centered at (0, 0, 0).
        let chassisXDistance = SCNVector3Zero.xDistance(from: self.userCar!.nosePosition!)
        
        //Check if car is on main straight (in range -48 < x < 75).
        if chassisXDistance > -48 && chassisXDistance < 75 {
            //Check z distance from the line.
            let distanceFromLine = abs(SCNVector3Zero.zDistance(from: self.userCar!.nosePosition!))
            
            //Check if distance from the line is less than 5, and if an update has not recently occurred. If so, start scoring a new lap.
            if distanceFromLine < 5 && (time - (self.lapCountUpdateTime ?? 0)) > 5  {
                //Signal for HUD lap counter to increment value.
                self.hud?.lapCounter?.incrementLapCounter()
                
                //Signal for HUD lap timer to begin timing a new lap.
                self.hud?.lapInfoView?.startNewLapTime()
                
                self.lapCountUpdateTime = time
            }
        }
    }
}

//MARK: - SCNVector3 extension.
public extension SCNVector3 {
    ///Calculates the straight line distance from two SCNVector3 points.
    public func distance(from b: SCNVector3) -> CGFloat {
        let x = pow((b.x - self.x), 2)
        let y = pow((b.y - self.y), 2)
        let z = pow((b.z - self.z), 2)
        
        return sqrt(x + y + z)
    }
    
    ///Calculates the difference in x values.
    public func xDistance(from b: SCNVector3) -> CGFloat {
        return b.x - self.x
    }
    
    ///Calculates the difference in z values.
    public func zDistance(from b: SCNVector3) -> CGFloat {
        return b.z - self.z
    }
}
