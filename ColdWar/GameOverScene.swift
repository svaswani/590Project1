//
//  GameOverScene.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit
class GameOverScene: SKScene {
    // MARK: - ivars -
    let sceneManager:GameViewController
    let button:SKLabelNode = SKLabelNode(fontNamed: GameData.font.mainFont)
    var player:String = "foo"
    
    // MARK: - Initialization -
    init(size: CGSize, sceneManager:GameViewController, player: String) {
        self.sceneManager = sceneManager
        super.init(size: size)
        self.player = player
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func didMove(to view: SKView){
        backgroundColor = GameData.scene.backgroundColor
        
        let label = SKLabelNode(fontNamed: GameData.font.mainFont)
        label.text = "Game Over"
        label.fontSize = 100
        label.position = CGPoint(x:size.width/2, y:size.height/2 + 200)
        addChild(label)
        
        let label2 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label2.text = " \(player) Won!"
        label2.fontSize = 70
        label2.position = CGPoint(x:size.width/2, y:size.height/2 - 100)
        addChild(label2)
        
        let label4 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label4.text = "Tap to play again"
        label4.fontColor = UIColor.purple
        label4.fontSize = 70
        label4.position = CGPoint(x:size.width/2, y:size.height/2 - 300)
        addChild(label4)
        
    }
    
    
    // MARK: - Events -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneManager.loadHomeScreen()
    }
}


