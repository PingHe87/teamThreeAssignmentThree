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
        self.backgroundColor = UIColor(red: 253/255, green: 250/255, blue: 217/255, alpha: 1.0)

        // Reset all states when entering the game
        resetGame()
        
        // Disable global gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // Set physics world boundaries
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        
        // Create ball
        let ballTexture = SKTexture(imageNamed: "Kunkun")
        ballNode = SKSpriteNode(texture: ballTexture)
        ballNode.size = CGSize(width: 50, height: 50)
        ballNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        ballNode.physicsBody?.restitution = 0.5
        ballNode.physicsBody?.friction = 0.1
        ballNode.physicsBody?.linearDamping = 0.5
        addChild(ballNode)

        // Add score label
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height - 50)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        // Create countdown label
        countdownLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        countdownLabel.fontSize = 100
        countdownLabel.fontColor = .gray
        countdownLabel.alpha = 0.5  // Semi-transparent
        countdownLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        countdownLabel.text = "\(countdown)"
        addChild(countdownLabel)
        
        // Create coins
        for _ in 20...30 {
            createCoin()
        }

        // Initialize MotionManager
        motionManager = CMMotionManager()
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0  // 60 updates per second
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let data = data {
                    // Get gravity direction for x and y axes
                    let gravity = data.gravity
                    
                    // Control ball movement using gravity direction
                    self?.updateBallMovement(x: gravity.x, y: gravity.y)
                }
            }
        }
        
        // Start countdown timer
        startCountdown()
    }

    func resetGame() {
        score = 0  // Reset score
        currency = 0  // Reset currency
    }

    override func willMove(from view: SKView) {
        // Stop motion data updates
        motionManager.stopDeviceMotionUpdates()
        // Stop countdown timer
        countdownTimer?.invalidate()
    }

    // Create coin
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

    // Collision detection callback
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
        // Set threshold to avoid minor movements due to small gravity values
        let threshold: Double = 0.02
        
        var adjustedX = x
        var adjustedY = y
        
        if abs(x) < threshold {
            adjustedX = 0
        }
        if abs(y) < threshold {
            adjustedY = 0
        }
        
        // Apply force using adjusted gravity values
        let force = CGVector(dx: adjustedX * 100, dy: adjustedY * 100)
        ballNode.physicsBody?.applyForce(force)
    }
    
    // Start countdown timer
    func startCountdown() {
        countdownTimer?.invalidate()  // Ensure previous timer is stopped

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
        countdownTimer?.invalidate()  // Stop countdown timer
        
        print("EndGame called. Score: \(score)")  // Log confirmation

        // Clear all nodes and actions in the current scene
        self.removeAllChildren()
        self.removeAllActions()

        // Switch to GameOverScene
        let gameOverScene = GameOverScene(size: self.size, finalScore: score)
        self.view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1.0))
        
        print("Scene switched to GameOverScene.")  // Log scene switch
    }
}

// Game over scene
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
        print("GameOverScene did move to view.")  // Log confirmation
        
        self.backgroundColor = UIColor(red: 253/255, green: 250/255, blue: 217/255, alpha: 1.0)

        // Display "Congratulations!" as a separate line
        let congratsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        congratsLabel.fontSize = 40
        congratsLabel.fontColor = UIColor(red: 98/255, green: 86/255, blue: 202/255, alpha: 1.0)
        congratsLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 40)
        congratsLabel.text = "Congratulations!"
        congratsLabel.horizontalAlignmentMode = .center
        addChild(congratsLabel)

        print("Congrats label added. Position: \(congratsLabel.position), Text: \(congratsLabel.text ?? "")")
        
        // Display "Your score is XX" as the second line
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = UIColor(red: 98/255, green: 86/255, blue: 202/255, alpha: 1.0)
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 20)
        scoreLabel.text = "Your score is \(finalScore)"
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
        
        print("Score label added. Position: \(scoreLabel.position), Text: \(scoreLabel.text ?? "")")
    }
}

