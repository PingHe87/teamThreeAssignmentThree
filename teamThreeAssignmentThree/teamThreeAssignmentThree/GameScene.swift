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
    var scoreLabel: SKLabelNode!
    var currency = 0
    var score = 0 {
        didSet {
            if let label = scoreLabel {
                label.text = "Score: \(score)"
            } else {
                print("Error: scoreLabel is nil")
            }
        }
    }
    var countdownLabel: SKLabelNode!
    var countdownTimer: Timer!
    var countdown = 10
    var motionManager: CMMotionManager!

    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        // 每次进入游戏时重置所有状态
        resetGame()
        
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
        
        // 创建倒计时标签
        countdownLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        countdownLabel.fontSize = 100
        countdownLabel.fontColor = .gray
        countdownLabel.alpha = 0.5  // 半透明
        countdownLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        countdownLabel.text = "\(countdown)"
        addChild(countdownLabel)
        
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
        
        // 启动倒计时
        startCountdown()
    }

    func resetGame() {
        score = 0  // 重置得分
        countdown = 10  // 重置倒计时
        currency = 0  // 重置步数货币
    }


    override func willMove(from view: SKView) {
        // 停止运动数据更新
        motionManager.stopDeviceMotionUpdates()
        // 停止倒计时
        countdownTimer?.invalidate()
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
    
    // 启动倒计时
    func startCountdown() {
        countdownTimer?.invalidate()  // 确保之前的 Timer 停止
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.countdown -= 1
            self?.countdownLabel.text = "\(self?.countdown ?? 0)"
            
            print("Timer fired. Countdown: \(self?.countdown ?? -1)")
            
            if self?.countdown == 0 {
                timer.invalidate()
                print("Countdown reached zero. Ending game.")
                self?.endGame()
            }
        }
    }

    func endGame() {
        countdownTimer?.invalidate()  // 停止倒计时
        
        print("EndGame called. Score: \(score)")  // 添加日志确认

        // 清理当前场景的所有节点和动作，避免残留
        self.removeAllChildren()
        self.removeAllActions()

        // 切换到结束界面，不再使用 nil 清空场景
        let gameOverScene = GameOverScene(size: self.size, finalScore: score)
        self.view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1.0))
        
        print("Scene switched to GameOverScene.")  // 添加日志确认场景切换
    }




}

// 结束场景
class GameOverScene: SKScene {
    var finalScore: Int = 0
    
    init(size: CGSize, finalScore: Int) {
        self.finalScore = finalScore
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        print("GameOverScene did move to view.")  // 添加日志确认
        
        self.backgroundColor = .white

        // "Congratulations!" 作为一行单独显示
        let congratsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        congratsLabel.fontSize = 40
        congratsLabel.fontColor = .black
        congratsLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 40)
        congratsLabel.text = "Congratulations!"
        congratsLabel.horizontalAlignmentMode = .center
        addChild(congratsLabel)

        print("Congrats label added. Position: \(congratsLabel.position), Text: \(congratsLabel.text ?? "")")
        
        // "Your score is XX" 作为第二行显示
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 20)
        scoreLabel.text = "Your score is \(finalScore)"
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
        
        print("Score label added. Position: \(scoreLabel.position), Text: \(scoreLabel.text ?? "")")
    }

}
