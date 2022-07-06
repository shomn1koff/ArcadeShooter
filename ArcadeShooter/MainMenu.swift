//
//  MainMenu.swift
//  ArcadeShooter
//
//  Created by Алексей Шомников on 14.12.2020.
//

import SpriteKit

class MainMenu: SKScene {
    var starfield1: SKEmitterNode!
    var starfield2: SKEmitterNode!
    var starfield3: SKEmitterNode!
    
    var newGameButtonNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        starfield1 = self.childNode(withName: "starfield1") as! SKEmitterNode
        starfield1.advanceSimulationTime(10)
        starfield2 = self.childNode(withName: "starfield2") as! SKEmitterNode
        starfield2.advanceSimulationTime(10)
        starfield3 = self.childNode(withName: "starfield3") as! SKEmitterNode
        starfield3.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                gameScene.backgroundColor = .black
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    
}
