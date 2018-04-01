//
//  RaceCarControls.swift
//  WWDC18 Submission
//
//  Created by Collin DeWaters on 3/25/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import Cocoa
import SceneKit

public extension RaceCar {
    ///RaceCar.Controls: enables user control of the race car with the keyboard.
    
    public class Controls {
        
        //MARK: - Properties.
        ///Shared Instance
        public static let shared = RaceCar.Controls()
        
        ///RaceCar.Controls.Key: specifies control mappings with the keyboard.
        public enum Key: UInt16 {
            case accelerateKey = 13   // W
            case leftKey = 0          // A
            case brakeReverseKey = 1  // S
            case rightKey = 2         // D
            case space = 49           // SPACE
            case changeCameraKey = 8  // C
            
            public static func from(event: NSEvent) -> RaceCar.Controls.Key? {
                return RaceCar.Controls.Key(rawValue: event.keyCode)
            }
        }
        
        ///Array of the active keys.
        public var activeKeys = [RaceCar.Controls.Key]()
        
        //MARK: - Calculated variables.
        public var accelerateKeyActive: Bool {
            return self.activeKeys.contains(.accelerateKey)
        }
        
        public var rightKeyActive: Bool {
            return self.activeKeys.contains(.rightKey)
        }
        
        public var leftKeyActive: Bool {
            return self.activeKeys.contains(.leftKey)
        }
        
        public var brakeReverseKeyActive: Bool {
            return self.activeKeys.contains(.brakeReverseKey)
        }
        
        public var changeCameraKeyActive: Bool {
            return self.activeKeys.contains(.changeCameraKey)
        }
        
        //MARK: - Key input functions.
        ///Called when the main SCNView initially recieves a key input.
        public func didRecieve(keyInput key: RaceCar.Controls.Key) {
            //Add the key to the active keys.
            if !self.activeKeys.contains(key) {
                self.activeKeys.append(key)
            }
        }
        
        ///Called when  the main SCNView ceases of key input.
        public func didEnd(keyInput key: RaceCar.Controls.Key) {
            //Remove the key from the active key array.
            for i in 0..<self.activeKeys.count {
                if self.activeKeys[i] == key {
                    self.activeKeys.remove(at: i)
                    return
                }
            }
        }
        
        ///Removes the change camera button from the active keys (called when the camera was swapped once).
        public func cameraDidChange() {
            self.didEnd(keyInput: .changeCameraKey)
        }
    }
}
