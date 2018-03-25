//
//  RaceCar.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/25/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import Cocoa
import SceneKit

public class RaceCar {

    //MARK: - Properties.
    ///The physics vehicle object that will provide motion to the car.
    public var physicsVehicle: SCNPhysicsVehicle?
    
    ///The chassis node, that provides the visual representation of the car.
    public var chassisNode: SCNNode?
    
    //MARK: - Initialization.
    public init(toScene scene: SCNScene? = nil, atPosition position: SCNVector3? = nil) {
        //Setup.
        self.setup()
        
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
    }
    
    //MARK: - Vehicle driving functions.
    //Applies an engine force to both of the rear wheels, to simulate RWD.
    public func accelerate(withEngineForce force: CGFloat) {
        self.apply(engineForce: force, toWheelAtIndex: 2)
        self.apply(engineForce: force, toWheelAtIndex: 3)
    }
    
    ///Applies force to a wheel in loaded physics vehicle.
    public func apply(engineForce force: CGFloat, toWheelAtIndex index: Int) {
        self.physicsVehicle?.applyEngineForce(force, forWheelAt: index)
    }
    
    ///Steers a wheel to a specified angle (in radians).
    public func steer(toAngle angle: CGFloat, forWheelAtIndex index: Int) {
        self.physicsVehicle?.setSteeringAngle(angle, forWheelAt: index)
    }
    
    
}
