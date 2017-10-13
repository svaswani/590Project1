//
//  HomeScene.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit
class HomeScene: SKScene {
    //MARK: iVars
    let sceneManager:GameViewController
    let button:SKLabelNode = SKLabelNode(fontNamed: GameData.font.mainFont)
    
    // MARK: Init
    init(size: CGSize, scaleMode:SKSceneScaleMode, sceneManager:GameViewController) {
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    // MARK: Helper functions for set up and input and touches
    override func didMove(to view: SKView) {
        
        backgroundColor = GameData.scene.backgroundColor
        let label = SKLabelNode(fontNamed: GameData.font.mainFont)
        
        label.text = "Cold War"

        label.position = CGPoint(x:size.width/2, y:size.height/2 + 100)
        
        label.fontSize = 165
        
        label.zPosition = 1

        addChild(label)
        
        let label4 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label4.text = "Tap to continue"
        label4.fontColor = UIColor.purple
        label4.fontSize = 70
        label4.position = CGPoint(x:size.width/2, y:size.height/2 - 300)
        addChild(label4)
        
        button.text = "Instructions"
        button.position = CGPoint(x:size.width/2, y: size.height/2 - 160)
        button.fontSize = 100
        addChild(button)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            if button.frame.contains(touch.location(in: self)) {
                sceneManager.loadInstructionsScene()
                
            } else {
                
                sceneManager.loadGameScene(levelNum: 1, totalScore: 0)
            }
        }
    }
}

