//
//  GameScene.swift
//  ArcadeShooter
//
//  Created by Алексей Шомников on 05.12.2020.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield1: SKEmitterNode!
    var starfield2: SKEmitterNode!
    var starfield3: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var lives: Int = 3 {
        didSet {
            livesLabel.text = "lives: \(lives)"
        }
    }
    var enemies = ["Enemy1", "Enemy2", "Enemy3"]
    var gameTimer: Timer!
    
    let enemyCategory: UInt32 = 0x1 << 1
    let bulletCategory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAccelerate: CGFloat = 0
    
    
    
    override func didMove(to view: SKView) {
        
        starfield1 = SKEmitterNode(fileNamed: "Starfield1")
        starfield1.position = CGPoint(x: 0, y: 0)
        starfield1.advanceSimulationTime(10)
        self.addChild(starfield1)
        
        starfield1.zPosition = -1
        
        starfield2 = SKEmitterNode(fileNamed: "Starfield2")
        starfield2.position = CGPoint(x: 0, y: 0)
        starfield2.advanceSimulationTime(10)
        self.addChild(starfield2)
        
        starfield2.zPosition = -1
        
        starfield3 = SKEmitterNode(fileNamed: "Starfield3")
        starfield3.position = CGPoint(x: 0, y: 0)
        starfield3.advanceSimulationTime(10)
        self.addChild(starfield3)
        
        starfield3.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "Player1")
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 40)
        player.setScale(2)
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "score: 0")
        scoreLabel.fontName = "Thintel"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: UIScreen.main.bounds.maxX - 60, y: UIScreen.main.bounds.height - 50)
        scoreLabel.zPosition = 1
        score = 0
        self.addChild(scoreLabel)
        
        
        livesLabel = SKLabelNode(text: "lives: 0")
        livesLabel.fontName = "Thintel"
        livesLabel.fontSize = 36
        livesLabel.fontColor = UIColor.white
        livesLabel.position = CGPoint(x: UIScreen.main.bounds.minX + 60, y: UIScreen.main.bounds.height - 50)
        livesLabel.zPosition = 1
        lives = 3
        self.addChild(livesLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < frame.minX - 50 {
            player.position = CGPoint(x: frame.maxX + 50, y: player.position.y)
        } else if player.position.x > frame.maxX + 50 {
            player.position = CGPoint(x: frame.minX - 50, y: player.position.y)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var enemyBody: SKPhysicsBody
        var bulletBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bulletBody = contact.bodyA
            enemyBody = contact.bodyB
        } else {
            bulletBody = contact.bodyB
            enemyBody = contact.bodyA
        }
        
        if (enemyBody.categoryBitMask & enemyCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, enemyNode: enemyBody.node as! SKSpriteNode)
        }
    }
    
    func collisionElements(bulletNode: SKSpriteNode, enemyNode: SKSpriteNode) {
        bulletNode.removeFromParent()
        enemyNode.removeFromParent()
        score += 5
    }
    
    @objc func addEnemy() {
        enemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: enemies) as! [String]
        let enemy = SKSpriteNode(imageNamed: enemies[0])
        let randomPos = GKRandomDistribution(lowestValue: Int(frame.minX + 50), highestValue: Int(frame.maxX - 50))
        let pos = CGFloat(randomPos.nextInt())
        enemy.position = CGPoint(x: pos, y: frame.maxY + 50)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = bulletCategory
        enemy.physicsBody?.collisionBitMask = 0
        enemy.setScale(2)
        self.addChild(enemy)
        
        let animDuration: TimeInterval = 3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: frame.minY - enemy.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        enemy.run(SKAction.sequence(actions), completion: {self.lives -= 1})
        
        
       
        
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("fire.mp3", waitForCompletion: false))
        let bullet = SKSpriteNode(imageNamed: "Bullet")
        bullet.position = player.position
        bullet.position.y += 5
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = 0
        
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.setScale(2)
        self.addChild(bullet)
        
        let animDuration: TimeInterval = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: frame.maxY + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        bullet.run(SKAction.sequence(actions))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if lives < 1 {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOver = SKScene(fileNamed: "GameOver") as! GameOver
            gameOver.score = self.score
            self.view?.presentScene(gameOver, transition: transition)
        }
    }
}
