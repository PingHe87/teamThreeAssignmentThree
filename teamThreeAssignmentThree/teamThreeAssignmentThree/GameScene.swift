//
//  GameScene.swift
//  teamThreeAssignmentThree
//
//  Created by shirley on 10/17/24.
//

import Foundation
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ballNode: SKSpriteNode!
    var currency = 0
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var motionManager: CMMotionManager!

    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        // 禁用全局重力
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // 设置物理世界边界
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        
        // 创建小球
        let ballTexture = SKTexture(imageNamed: "Kunkun")
        ballNode = SKSpriteNode(texture: ballTexture)
        ballNode.size = CGSize(width: 50, height: 50)
        ballNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        ballNode.physicsBody?.restitution = 0.5
        ballNode.physicsBody?.friction = 0.1
        ballNode.physicsBody?.linearDamping = 0.5
        addChild(ballNode)

        // 添加分数标签
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height - 50)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        // 创建金币
        for _ in 1...5 {
            createCoin()
        }

        // 初始化 MotionManager
        motionManager = CMMotionManager()
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0  // 每秒 60 次
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let data = data {
                    // 获取重力方向，x 和 y 轴
                    let gravity = data.gravity
                    
                    // 使用重力方向控制小球的运动
                    self?.updateBallMovement(x: gravity.x, y: gravity.y)
                }
            }
        }
    }

    override func willMove(from view: SKView) {
        motionManager.stopDeviceMotionUpdates()
    }

    // 创建金币
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 30, height: 30)
        coin.position = CGPoint(x: CGFloat.random(in: 50...self.frame.width - 50),
                                y: CGFloat.random(in: 50...self.frame.height - 50))
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = 2
        coin.physicsBody?.contactTestBitMask = 1
        addChild(coin)
    }

    // 碰撞检测回调
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA.node
        let contactB = contact.bodyB.node
        
        if let ball = ballNode, (contactA == ball || contactB == ball) {
            if contactA?.physicsBody?.categoryBitMask == 2 || contactB?.physicsBody?.categoryBitMask == 2 {
                if let coin = (contactA == ball) ? contactB : contactA {
                    coin.removeFromParent()
                    score += 1
                }
            }
        }
    }

    func updateBallMovement(x: Double, y: Double) {
        // 设置阈值，避免微小的重力数据导致小球移动
        let threshold: Double = 0.02
        
        var adjustedX = x
        var adjustedY = y
        
        if abs(x) < threshold {
            adjustedX = 0
        }
        if abs(y) < threshold {
            adjustedY = 0
        }
        
        // 施加力，使用经过调整的重力值
        let force = CGVector(dx: adjustedX * 100, dy: adjustedY * 100)
        ballNode.physicsBody?.applyForce(force)
    }

}
