//
//  ModuleBViewController.swift
//  teamThreeAssignmentThree
//
//  Created by p h on 10/16/24.
//

import UIKit
import SpriteKit
import CoreMotion

class ModuleBViewController: UIViewController, MotionDelegate {
    var motionModel = MotionModel()
    var skView: SKView!
    var currency = 0  // Currency earned through steps
    var gameTime: Int = 10  // Default game time in seconds

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set motionModel delegate
        motionModel.delegate = self

        // Start monitoring pedometer and accelerometer
        motionModel.startPedometerMonitoring()
        motionModel.startAccelerometerMonitoring()

        // Set up SpriteKit view
        if let view = self.view as? SKView {
            skView = view
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.currency = currency // Pass currency to the game scene
            scene.countdown = gameTime  // Set countdown timer from Module A
            skView.presentScene(scene)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop all monitoring
        motionModel.stopMonitoring()
    }

    // Update currency based on step count
    func pedometerUpdated(pedData: CMPedometerData) {
        currency = Int(pedData.numberOfSteps.doubleValue / 1000)
        print("Currency: \(currency)") // Can be used for unlocking game items
    }

    // Update game object movement based on accelerometer data
    func accelerometerUpdated(x: Double, y: Double, z: Double) {
        if let gameScene = skView.scene as? GameScene {
            gameScene.updateBallMovement(x: x, y: y)  // Update ball movement
        }
    }

    func activityUpdated(activity: CMMotionActivity) {
        // Adjust game difficulty or other logic based on activity
    }
}
