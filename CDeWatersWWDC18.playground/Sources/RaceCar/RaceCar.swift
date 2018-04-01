//
//  RaceCar.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/25/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import Cocoa
import SceneKit

///RaceCar: defines the properties and actions of a race car, including its physics and visual representations.
public class RaceCar {

    //MARK: - Properties.
    ///The physics vehicle object that will provide motion to the car.
    public var physicsVehicle: SCNPhysicsVehicle?
    
    ///The chassis node, that provides the visual representation of the car.
    public var chassisNode: SCNNode?
    
    ///The engine sound effect player.
    public var engineSoundPlayer: SCNAudioPlayer?
    
    ///Determines if this car can be controlled by the user.
    public var isUserControlled: Bool = true
    
    ///The cameras attacted to the chassis node.
    public var cameras: [SCNNode]?
    
    ///The current steering angle of the front tires.
    private var currentSteeringAngle: CGFloat = 0.0
    
    ///RaceCar.SteeringState: Describes the current steering angle.
    private enum SteeringState: String {
        case right, left, idle
    }
    
    ///The current steering state.
    private var steeringState: RaceCar.SteeringState = .idle
    
    ///The previous steering state.
    private var previousSteeringState: RaceCar.SteeringState = .idle
    
    ///The number of frames completed for the steering animation.
    private var steeringAnimationFrameCount = 0
    
    ///The angle the steering animation started at.
    private var steeringAnimationStartAngle: CGFloat = 0
    
    ///The max speed.
    static let maxSpeedInKilometersPerHour: CGFloat = 389.346862792969
    
    ///The max steering lock.
    static let maxSteeringLock: CGFloat = 0.35
    
    ///The currentSpeed, in KPH.
    public var currentSpeedInKPH: CGFloat {
        return self.physicsVehicle?.speedInKilometersPerHour ?? 0
    }
    
    ///The environment scene.
    public var environmentScene: SCNScene?
    
    ///The position of the nose of the car, relative to the environment scene.
    public var nosePosition: SCNVector3? {
        if let noseLocator = self.chassisNode?.childNode(withName: "noseLocator", recursively: true) {
            return noseLocator.presentation.convertPosition(SCNVector3Zero, to: self.environmentScene?.rootNode)
        }
        return nil
    }
    
    //MARK: - Initialization.
    public init(toScene scene: SCNScene? = nil, atPosition position: SCNVector3? = nil, isUserControlled userControlled: Bool) {
        self.isUserControlled = userControlled
        self.environmentScene = scene
        
        //Setup.
        self.setup()
        
        //Load the cameras.
        let tCam = self.chassisNode!.childNode(withName: "tCam", recursively: true)!
        let chaseCam = self.chassisNode!.childNode(withName: "chaseCam", recursively: true)!
        self.cameras = [chaseCam, tCam]
        
        //Add to the scene, if applicable.
        if let scene = scene {
            self.add(toScene: scene, atPosition: position ?? SCNVector3Zero)
        }
    }
    
    //MARK: - SCNPhysicsVehicle Setup.
    ///Loads the car node from the scn file, and creates the SCNPhysicsVehicle object.
    private func setup() {
        //Load the car scene.
        if let carScene = SCNScene(named: "SceneKitAssets/car.scn") {
            //Retrieve the chassis node and tire locator nodes.
            self.chassisNode = carScene.rootNode.childNode(withName: "chassis", recursively: true)!
            let frontRight = self.chassisNode!.childNode(withName: "frontRightTireLocator", recursively: true)!
            let frontLeft = self.chassisNode!.childNode(withName: "frontLeftTireLocator", recursively: true)!
            let rearRight = self.chassisNode!.childNode(withName: "rearRightTireLocator", recursively: true)!
            let rearLeft = self.chassisNode!.childNode(withName: "rearLeftTireLocator", recursively: true)!

            //Create the SCNPhysicsVehicleWheel array.
            let wheels = [frontLeft, frontRight, rearLeft, rearRight].map {
                return SCNPhysicsVehicleWheel(node: $0)
            }
            
            //Setup the physics body for the car.
            let physicsBody = SCNPhysicsBody.dynamic()
            physicsBody.mass = 140
            physicsBody.allowsResting = false
            physicsBody.isAffectedByGravity = true
            self.chassisNode?.physicsBody = physicsBody
            
            //Create the SCNPhysicsVehicle object.
            self.physicsVehicle = SCNPhysicsVehicle(chassisBody: self.chassisNode!.physicsBody!, wheels: wheels)
            
            //Setup the connection position values for each wheel.
            let y: CGFloat = 2.86082750558853
            wheels[0].connectionPosition = SCNVector3Make(-wheels[0].connectionPosition.x - 0.28, y - 0.3, wheels[0].connectionPosition.z)
            wheels[1].connectionPosition = SCNVector3Make(-wheels[1].connectionPosition.x + 0.28, y - 0.3, wheels[1].connectionPosition.z)
            wheels[2].connectionPosition = SCNVector3Make(-wheels[2].connectionPosition.x, y, wheels[2].connectionPosition.z)
            wheels[3].connectionPosition = SCNVector3Make(-wheels[3].connectionPosition.x, y, wheels[3].connectionPosition.z)
        }
    }
    
    ///Sets up the sound sources and player.
    public func setupAudio() {
        //Load the idle sound as an audio source.
        if let idleSource = SCNAudioSource(fileNamed: "SceneKitAssets/carEngineIdle.m4a") {
            idleSource.loops = true
            idleSource.shouldStream = false
            idleSource.isPositional = true
            idleSource.volume = 0.02
            idleSource.load()
            
            //Setup the sound player.
            self.engineSoundPlayer = SCNAudioPlayer(source: idleSource)
            
            //Load the sound source node from the car chassis node.
            if let soundSourceNode = self.chassisNode?.childNode(withName: "engineSoundSource", recursively: true) {
                soundSourceNode.addAudioPlayer(self.engineSoundPlayer!)
            }
        }
    }
    
    //MARK: - SCNScene Functions.
    public func add(toScene scene: SCNScene, atPosition position: SCNVector3 = SCNVector3Zero) {
        guard let chassisNode = self.chassisNode, let physicsVehicle = self.physicsVehicle else {
            return
        }
        
        //Set the position of the chassis node.
        chassisNode.position = position
        
        //Add the chassis node to the scene's rootNode.
        scene.rootNode.addChildNode(chassisNode)
        
        //Add the physics vehicle behavior to the scene's physics world.
        scene.physicsWorld.addBehavior(physicsVehicle)
        
        //Setup audio.
        //self.setupAudio()
    }
    
    //MARK: - Vehicle driving functions.
    ///Applies an engine force to both of the rear wheels, to simulate RWD.
    public func accelerate(withEngineForce force: CGFloat) {
        self.apply(engineForce: force, toWheelAtIndex: 2)
        self.apply(engineForce: force, toWheelAtIndex: 3)
    }
    
    ///Steers both front wheels to a specified angle.
    public func steer(toAngle angle: CGFloat) {
        var newAngle: CGFloat = 0.0
        if angle > 0.6 {
            newAngle = 0.6
        }
        else if angle < -0.6 {
            newAngle = -0.6
        }
        else {
            newAngle = angle
        }
        self.steer(toAngle: newAngle, forWheelAtIndex: 0)
        self.steer(toAngle: newAngle, forWheelAtIndex: 1)
        
        self.currentSteeringAngle = newAngle
    }
    
    ///Applies a braking force to all wheels.
    public func brake(withForce force: CGFloat) {
        for i in 0...3 {
            self.physicsVehicle?.applyBrakingForce(force, forWheelAt: i)
        }
    }

    ///Applies force to a wheel in loaded physics vehicle.
    private func apply(engineForce force: CGFloat, toWheelAtIndex index: Int) {
        self.physicsVehicle?.applyEngineForce(force, forWheelAt: index)
    }
    
    ///Steers a wheel to a specified angle (in radians).
    private func steer(toAngle angle: CGFloat, forWheelAtIndex index: Int) {
        self.physicsVehicle?.setSteeringAngle(angle, forWheelAt: index)
    }
    
    public func applyUserInteraction(withControls controls: RaceCar.Controls) {
        //Check if this car is user controlled.
        if self.isUserControlled {
            var engineForce: CGFloat = 0
            var brakingForce: CGFloat = 0
            
            //Check if brake and accelerate are both inactive.
            if !controls.accelerateKeyActive && !controls.brakeReverseKeyActive {
                engineForce = 0
                brakingForce = 0
            }
            
            //Check for accelerate key.
            if controls.accelerateKeyActive {
                //Apply engine force.
                engineForce += 410
                brakingForce += 0
            }
            
            //Check for braking key.
            if controls.brakeReverseKeyActive {
                if (self.physicsVehicle?.speedInKilometersPerHour ?? 0) > 0 {
                    engineForce = 0
                    brakingForce += 5
                }
                else {
                    engineForce -= 50
                    brakingForce += 0
                }
            }
            
            //Apply braking and engine forces.
            self.accelerate(withEngineForce: engineForce)
            self.brake(withForce: brakingForce)
            
            //Adjust steering.
            if controls.rightKeyActive && controls.leftKeyActive {
                //Both steering keys active, set the steering state to idle.
                self.resetSteeringAnimationIfNeeded(withGeneratedSteeringState: .idle)
            }
            else if controls.rightKeyActive {
                //Right steering key active, set the steering state to right.
                self.resetSteeringAnimationIfNeeded(withGeneratedSteeringState: .right)
            }
            else if controls.leftKeyActive {
                //Left steering key active, set the steering state to left.
                self.resetSteeringAnimationIfNeeded(withGeneratedSteeringState: .left)
            }
            else {
                //No steering keys active, set the steering state to idle.
                self.resetSteeringAnimationIfNeeded(withGeneratedSteeringState: .idle)
            }
            
            //Update the steering animation.
            self.updateSteeringAnimation()
        }
    }
    
    ///Checks if the steering animation frames completed property should be reset.
    private func resetSteeringAnimationIfNeeded(withGeneratedSteeringState newState: RaceCar.SteeringState) {
        //If the state has changed, we need to start a new animation.
        if newState != self.steeringState {
            self.steeringAnimationFrameCount = 0
            self.previousSteeringState = self.steeringState
            self.steeringState = newState
        }
    }
    
    ///Updates the steering animation for a frame.
    private func updateSteeringAnimation() {
        //Animate over six frames (@60FPS animation duration will be 0.1 seconds).
        let maxFrameCount = 6
        
        //Set the steering animation start angle if the frame count was just reset.
        if self.steeringAnimationFrameCount == 0 {
            self.steeringAnimationStartAngle = self.currentSteeringAngle
        }
        
        //Calculate the steering destination angle.
        let destinationAngle: CGFloat = self.steeringState == .idle ? 0 : self.steeringState == .right ? -RaceCar.maxSteeringLock : RaceCar.maxSteeringLock
        
        let multiplier: CGFloat = ((self.previousSteeringState == .right || self.previousSteeringState == .idle) && (self.steeringState == .idle || self.steeringState == .left)) ? 1 : -1
        let totalDelta = multiplier * (abs(self.steeringAnimationStartAngle) + abs(destinationAngle))
        let frameDelta = totalDelta / CGFloat(maxFrameCount)
        
        if self.steeringAnimationFrameCount < maxFrameCount {
            self.steer(toAngle: self.currentSteeringAngle + frameDelta)
        }
        //Increment the frame count.
        self.steeringAnimationFrameCount += 1
    }
    
}
