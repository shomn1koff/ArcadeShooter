//
//  GameOver.swift
//  ArcadeShooter
//
//  Created by Алексей Шомников on 14.12.2020.
//

import SpriteKit

class GameOver: SKScene {
    var starfield1: SKEmitterNode!
    var starfield2: SKEmitterNode!
    var starfield3: SKEmitterNode!
    
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    
    var playAgainButtonNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        starfield1 = self.childNode(withName: "starfield1") as! SKEmitterNode
        starfield1.advanceSimulationTime(10)
        starfield2 = self.childNode(withName: "starfield2") as! SKEmitterNode
        starfield2.advanceSimulationTime(10)
        starfield3 = self.childNode(withName: "starfield3") as! SKEmitterNode
        starfield3.advanceSimulationTime(10)
        
        playAgainButtonNode = self.childNode(withName: "playAgainButton") as! SKSpriteNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "Score: \(score)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "playAgainButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                gameScene.backgroundColor = .black
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
   
}
