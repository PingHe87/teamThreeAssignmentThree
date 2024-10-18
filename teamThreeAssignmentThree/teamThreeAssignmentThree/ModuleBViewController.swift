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
    var currency = 0  // 通过步数获取货币

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置 motionModel 的代理
        motionModel.delegate = self

        // 启动步数和加速度计监控
        motionModel.startPedometerMonitoring()
        motionModel.startAccelerometerMonitoring()

        // 设置 SpriteKit view
        if let view = self.view as? SKView {
            skView = view
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.currency = currency // 传递步数货币
            skView.presentScene(scene)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 停止所有监控
        motionModel.stopMonitoring()
    }

    // 更新步数货币
    func pedometerUpdated(pedData: CMPedometerData) {
        currency = Int(pedData.numberOfSteps.doubleValue / 1000)
        print("Currency: \(currency)") // 可用于游戏解锁道具
    }

    // 通过加速度计数据更新游戏物体运动
    func accelerometerUpdated(x: Double, y: Double, z: Double) {
        if let gameScene = skView.scene as? GameScene {
            gameScene.updateBallMovement(x: x, y: y)  // 更新小球运动
        }
    }

    func activityUpdated(activity: CMMotionActivity) {
        // 根据活动调整游戏难度或其他逻辑
    }
}

