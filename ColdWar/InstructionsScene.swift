//
//  InstructionsScene.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 10/13/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//


import SpriteKit
class Instructions: SKScene {
    // MARK: - ivars -
    let sceneManager:GameViewController
    let button:SKLabelNode = SKLabelNode(fontNamed: GameData.font.mainFont)
    var touchCount = 0
    var texture:SKSpriteNode
    
    // MARK: - Initialization -
    init(size: CGSize, sceneManager:GameViewController) {
        self.sceneManager = sceneManager
        texture = SKSpriteNode(imageNamed: "instructionsControls")
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func didMove(to view: SKView){
        backgroundColor = GameData.scene.backgroundColor
        
        texture.size = self.size
        texture.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        addChild(texture)
    }
    
    
    // MARK: - Events -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchCount += 1
        if touchCount == 1 {
            texture.texture = SKTexture(imageNamed: "instructionsHUD")
        } else {
            sceneManager.loadHomeScreen()

        }
    }
}


