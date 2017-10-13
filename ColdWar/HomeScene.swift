//
//  HomeScene.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit
class HomeScene: SKScene {
    // ivars
    let sceneManager:GameViewController
    let button:SKLabelNode = SKLabelNode(fontNamed: GameData.font.mainFont)
    
    // init
    init(size: CGSize, scaleMode:SKSceneScaleMode, sceneManager:GameViewController) {
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = GameData.scene.backgroundColor
        let label = SKLabelNode(fontNamed: GameData.font.mainFont)
        let label2 = SKLabelNode(fontNamed: GameData.font.mainFont)
        let label3 = SKLabelNode(fontNamed: GameData.font.mainFont)
        let label5 = SKLabelNode(fontNamed: GameData.font.mainFont)

        
        label.text = "Cold War"
        label2.text = "This is a two player game. \n Drag to move with one finger. \n Tap with another finger to shoot."
        label3.text = "Avoid enemy projectiles. \n Collect power ups. \n The first to lose 5 lives is out."
        label5.text = "Stay on your side of the screen. \n 3 Finger double tap to pause."
        
        label.fontSize = 200
        label2.fontSize = 18
        label3.fontSize = 20
        label5.fontSize = 20


        label.position = CGPoint(x:size.width/2, y:size.height/2 + 100)
        label2.position = CGPoint(x:size.width/2, y:size.height/2 - 120)
        label3.position = CGPoint(x:size.width/2, y:size.height/2 - 160)
        label5.position = CGPoint(x:size.width/2, y:size.height/2 - 200)

        
        label.zPosition = 1
        label2.zPosition = 1
        label3.zPosition = 1
        label5.zPosition = 1

        addChild(label)
        addChild(label2)
        addChild(label3)
        addChild(label5)

        
        let label4 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label4.text = "Tap to continue"
        label4.fontColor = UIColor.purple
        label4.fontSize = 70
        label4.position = CGPoint(x:size.width/2, y:size.height/2 - 300)
        addChild(label4)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneManager.loadGameScene(levelNum: 1, totalScore: 0)
    }
}

