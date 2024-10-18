//
//  GameScene.swift
//  teamThreeAssignmentThree
//
//  Created by shirley on 10/17/24.
//

import Foundation
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ballNode: SKSpriteNode!
    var currency = 0 // 步数货币
    var scoreLabel: SKLabelNode! // 显示分数
    var score = 0 { // 记录分数，并在更新时显示
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        self.backgroundColor = .white  // 设置背景颜色
        
        // 设置物理世界边界
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self  // 设置碰撞检测代理

        // 创建小球
        let ballTexture = SKTexture(imageNamed: "Kunkun")  // 替换为你的球图片
        ballNode = SKSpriteNode(texture: ballTexture)
        ballNode.size = CGSize(width: 50, height: 50)  // 设置小球大小
        ballNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)  // 将小球初始位置设置在屏幕中间
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: 25)  // 设置圆形物理体
        ballNode.physicsBody?.restitution = 0.5  // 设置弹性
        ballNode.physicsBody?.friction = 0.1  // 控制摩擦力
        addChild(ballNode)

        // 添加分数标签
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height - 50)  // 将分数标签放在屏幕顶部
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        // 创建多个金币
        for _ in 1...5 {
            createCoin()
        }
    }

    // 创建金币
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        // 设置金币的固定尺寸
        coin.size = CGSize(width: 30, height: 30)  // 设置固定大小，例如 30x30
        coin.position = CGPoint(x: CGFloat.random(in: 50...self.frame.width - 50),
                                y: CGFloat.random(in: 50...self.frame.height - 50))
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 15)  // 设置圆形物理体
        coin.physicsBody?.isDynamic = false  // 不受物理世界影响
        coin.physicsBody?.categoryBitMask = 2  // 设置金币类别
        coin.physicsBody?.contactTestBitMask = 1  // 小球可以检测到金币的碰撞
        addChild(coin)
    }

    // 碰撞检测回调
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA.node
        let contactB = contact.bodyB.node
        
        // 检测小球和金币的碰撞
        if let ball = ballNode, (contactA == ball || contactB == ball) {
            if contactA?.physicsBody?.categoryBitMask == 2 || contactB?.physicsBody?.categoryBitMask == 2 {
                if let coin = (contactA == ball) ? contactB : contactA {
                    coin.removeFromParent()  // 移除金币
                    score += 1  // 增加分数
                }
            }
        }
    }

    // 使用加速度计数据更新小球的运动
    func updateBallMovement(x: Double, y: Double) {
        let force = CGVector(dx: x * 100, dy: y * 100)
        ballNode.physicsBody?.applyForce(force)
    }
}

    


