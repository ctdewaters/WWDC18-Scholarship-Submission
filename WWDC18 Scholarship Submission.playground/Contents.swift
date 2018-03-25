//: A SpriteKit based Playground

import Cocoa
import PlaygroundSupport
import SceneKit

let scene = SCNScene(named: "SceneKitAssets/Scene.scn")!

let view = SCNView(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
view.scene = scene

let raceCar = RaceCar(toScene: scene)
raceCar.accelerate(withEngineForce: 300)
raceCar.steer(toAngle: 0.3, forWheelAtIndex: 0)

PlaygroundSupport.PlaygroundPage.current.liveView = view
