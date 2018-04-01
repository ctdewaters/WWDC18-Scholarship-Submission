//: # Creating a Time Trial Racing Game
//: ## Using `SceneKit` and `SCNPhysicsVehicle`.
import AppKit
import PlaygroundSupport
import SceneKit
//: Initialize a `GameView`. This class, a subclass of `SCNView`, will construct a `SCNScene` object from the packaged `scn` file and setup the game. The `HUD` view will also be added, which displays information like lap count, current lap time, and speed in MPH.
let gameView = GameView(withFrame: NSRect(x: 0, y: 0, width: 700, height: 500))
//: Set `gameView` as the `PlaygroundPage` `liveView`.
PlaygroundPage.current.liveView = gameView
PlaygroundPage.current.needsIndefiniteExecution = true
