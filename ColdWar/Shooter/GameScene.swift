//
//  GameScene.swift
//  Shooter
//
//  Created by Sneha Vaswani on 9/19/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var levelNum:Int
    var levelScore:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(levelScore)"
        }
    }
    var totalScore:Int
    let sceneManager:GameViewController
    var playableRect = CGRect.zero
    var totalSprites = 0
    let levelLabel = SKLabelNode(fontNamed: "Futura")
    let scoreLabel = SKLabelNode(fontNamed: "Futura")
    let otherLabel = SKLabelNode(fontNamed: "Futura")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = false
    var tapCount = 0 // 3 taps and game is over
    
    // init
    init(size: CGSize, scaleMode:SKSceneScaleMode, levelNum:Int, totalScore:Int, sceneManager:GameViewController) {
        self.levelNum = levelNum
        self.totalScore = totalScore
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // lifecycle
    override func didMove(to view: SKView) {
        setupUI()
        makeSprites(howMany: 10)
        unpuaseSprites()
    }
    
    deinit {
        // todo clean up resources timers listeners etc
    }
    
    // helpers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapCount = tapCount + 1
        if tapCount < 3 {
            return
        }
        
        if levelNum < GameData.maxLevel {
            let results = LevelResults(levelNum: levelNum, levelScore: levelScore, totalScore: totalScore, msg: "You finished level \(levelNum)")
            sceneManager.loadLevelFishedScene(results: results)
        } else {
            let results = LevelResults(levelNum: levelNum, levelScore: levelScore, totalScore: totalScore, msg: "You finished level \(levelNum)")
            sceneManager.loadGameOverScene(results: results)
        }
    }
    func unpuaseSprites() {
        let unpauseAction = SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.run ({self.spritesMoving = true})
            ])
        run(unpauseAction)
    }
    private func setupUI(){
        playableRect = getPlayableRectPhonePortrait(size: size)
        let fontSize = GameData.hud.fontSize
        let fontColor = GameData.hud.fontColorWhite
        let marginH = GameData.hud.marginH
        let marginV = GameData.hud.marginV
        
        backgroundColor = GameData.hud.backgroundColor
        
        levelLabel.fontColor = fontColor
        levelLabel.fontSize = fontSize
        levelLabel.position = CGPoint(x: marginH,y: playableRect.maxY - marginV)
        levelLabel.verticalAlignmentMode = .top
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.text = "Level: \(levelNum)"
        addChild(levelLabel)
        
        scoreLabel.fontColor = fontColor
        scoreLabel.fontSize = fontSize
        
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .left
        // next 2 lines calculate the max width of scoreLabel
        scoreLabel.text = "Score: 000"
        let scoreLabelWidth = scoreLabel.frame.size.width
        
        // here is the starting text of scoreLabel
        scoreLabel.text = "Score: \(levelScore)"
        
        scoreLabel.position = CGPoint(x: playableRect.maxX - scoreLabelWidth - marginH,y: playableRect.maxY - marginV)
        addChild(scoreLabel)
        
        otherLabel.fontColor = fontColor
        otherLabel.fontSize = fontSize
        otherLabel.position = CGPoint(x: marginH, y: playableRect.minY + marginV)
        otherLabel.verticalAlignmentMode = .bottom
        otherLabel.horizontalAlignmentMode = .left
        otherLabel.text = "Num Sprites: 0"
        addChild(otherLabel)
    }
    
    func makeSprites(howMany:Int) {
        totalSprites = totalSprites + howMany
        otherLabel.text = "Num Sprites: \(totalSprites)"
        var s:DiamondSprite
        for _ in 0...howMany-1 {
            s = DiamondSprite(size: CGSize(width: 60, height: 100), lineWidth:10, strokeColor: SKColor.green, fillColor: SKColor.magenta)
            s.name = "diamond"
            s.position = randomCGPointInRect(playableRect, margin: 300)
            s.fwd = CGPoint.randomUnitVector()
            addChild(s)
        }
    }
    
    func calculateDeltaTime(currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    func moveSprites(dt:CGFloat) {
        if spritesMoving {
            enumerateChildNodes(withName: "diamond", using: {
                node, stop in
                let s = node as! DiamondSprite
                let halfWidth = s.frame.width/2
                let halfHeight = s.frame.height/2
                
                s.update(dt: dt)
                
                // check left/right
                if s.position.x <= halfWidth || s.position.x >= self.size.width - halfWidth {
                    s.reflectX() // bounce
                    s.update(dt: dt) // make an extra move
                    self.levelScore = self.levelScore + 1 // lamest game ever = bounce n win
                    
                }
                
                // check top/bottom
                if s.position.y <= self.playableRect.minY + halfHeight || s.position.y >= self.playableRect.maxY - halfHeight {
                    s.reflecyY() // bounce
                    s.update(dt: dt) // make extra move
                    self.levelScore = self.levelScore + 1
                }
            })
        }
    }
    
    // events
    
    // game loop
    override func update(_ currentTime: TimeInterval) {
        calculateDeltaTime(currentTime: currentTime)
        moveSprites(dt: CGFloat(dt))
    }
    
    
}
