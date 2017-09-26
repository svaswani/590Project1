//
//  GameScene.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var levelNum:Int
    var levelScore:Int = 0 //{
    //didSet {
    //    scoreLabel.text = "Score: \(levelScore)"
    //}
    //}
    var totalScore:Int
    let sceneManager:GameViewController
    var playableRect = CGRect.zero
    var totalSprites = 0
    //let levelLabel = SKLabelNode(fontNamed: "Futura")
    //let scoreLabel = SKLabelNode(fontNamed: "Futura")
    let otherLabel = SKLabelNode(fontNamed: "Futura")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = false
    var tapCount = 0 // 3 taps and game is over
    let playerBlue = SKSpriteNode(imageNamed: "bluePenguin")
    let playerRed = SKSpriteNode(imageNamed: "redPenguin")
    let iceLaser = SKSpriteNode(imageNamed: "iceLaser")
    let fish = SKSpriteNode(imageNamed: "fish")
    
    var playerBlueTouchCount = 0;
    var playerBluePos:CGPoint = CGPoint.zero;
    
    var playerRedTouchCount = 0;
    var playerRedPos:CGPoint = CGPoint.zero;
    
    var shootTimer:CGFloat = CGFloat(3);
    
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
        playerBlue.setScale(0.32)
        playerBlue.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(playerBlue)
        playerRed.setScale(0.24)
        playerRed.position = CGPoint(x: size.width/2 + 425, y: size.height/2)
        addChild(playerRed)
        iceLaser.setScale(0.54)
        iceLaser.position = CGPoint(x: size.width/2 + 225, y: size.height/2)
        addChild(iceLaser)
        fish.setScale(0.54)
        fish.position = CGPoint(x: size.width/2 + 75, y: size.height/2)
        addChild(fish)
    }
    
    deinit {
        // todo clean up resources timers listeners etc
    }
    
    // helpers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                //print("Blue player \(playerBlueTouchCount)")
                
                if (playerBlueTouchCount > 0) {

                    let f:FishProjectile = FishProjectile(position: location, projectileSpeed: 300, fwd: (location - playerBluePos).normalized(), timer: CGFloat(6))
                    f.name = "fish"
                    addChild(f);
                    
                    playerBlueTouchCount += 1;

                } else {
                    playerBluePos = location
                    playerBlueTouchCount = 1;
                }
                
                
                
            } else {
                //print("Red Player \(playerRedTouchCount)")
                
                if (playerRedTouchCount > 0) {

                    let f:FishProjectile = FishProjectile(position: location, projectileSpeed: 300, fwd: (location - playerRedPos).normalized(), timer: CGFloat(6))
                    f.name = "fish"
                    addChild(f);
                    
                    playerRedTouchCount += 1;

                } else {
                    playerRedPos = location
                    playerRedTouchCount = 1;
                    
                }
            }
        }
        
        tapCount = tapCount + 1
        return;
        /*
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
        */
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var currTouchRed = 0;
        var currTouchBlue = 0;
        
        for touch in touches {
            
            
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                
                if (currTouchBlue < 1) {
                    //print("Blue player \(location)")
                    currTouchBlue = 1;

                    playerBluePos = location;
                }
            } else {
                
                if (currTouchRed < 1) {
                    //print("Red Player \(location)")
                    currTouchRed = 1;
                    playerRedPos = location;
                }
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                //print("Blue player \(location)")
                
                if (playerBlueTouchCount > 0) {
                    playerBlueTouchCount -= 1;
                }
                
            } else {
                //print("Red Player \(location)")
                
                if (playerRedTouchCount > 0) {
                    playerRedTouchCount -= 1;
                }
            }
        }
    }
    
    
    private func setupUI(){
        backgroundColor = GameData.hud.backgroundColor
        /*
         playableRect = getPlayableRectPhonePortrait(size: size)
         let fontSize = GameData.hud.fontSize
         let fontColor = GameData.hud.fontColorWhite
         let marginH = GameData.hud.marginH
         let marginV = GameData.hud.marginV
         
         
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
         */
        
    }
    
    
    func calculateDeltaTime(currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    // events
    
    // game loop
    override func update(_ currentTime: TimeInterval) {
        calculateDeltaTime(currentTime: currentTime)
        updateFish(dt: CGFloat(dt))
        movePlayer(dt: CGFloat(dt))
        
        shootIcicle(dt: CGFloat(dt))
        updateIcicle(dt: CGFloat(dt))
    }
    
    func updateFish(dt: CGFloat) {
        enumerateChildNodes(withName: "fish", using: {
            node, stop in
            let s = node as! FishProjectile
            s.update(dt: dt)
            
            if (s.timer < 0) {
                s.removeFromParent()
            }
            
            /*
            if s.position.x <= halfWidth || s.position.x >= self.size.width - halfWidth {
                s.reflectX()
                s.update(dt: dt)
                self.levelScore = self.levelScore + 1
            }
            
            if s.position.y <= self.playableRect.minY + halfHeight || s.position.y >= self.playableRect.maxY - halfHeight {
                s.reflectY()
                s.update(dt:dt)
                self.levelScore = self.levelScore + 1
            }
 */
        })
    }
    
    func updateIcicle(dt: CGFloat) {
        enumerateChildNodes(withName: "ice", using: {
            node, stop in
            let s = node as! IceProjectile
            s.update(dt: dt)
            
        })
            
    }
    
    func movePlayer(dt:CGFloat) {
        playerRed.position = playerRedPos
        playerBlue.position = playerBluePos
    }
    
    func shootIcicle(dt: CGFloat) {
        if shootTimer < 0 {
            shootTimer = 3;
            let i = IceProjectile(position: playerRedPos, projectileSpeed: 300, fwd: CGPoint(x: -1, y:0))
            i.name = "ice"
            addChild(i);
            
            let i2 = IceProjectile(position: playerBluePos, projectileSpeed: 300, fwd: CGPoint(x: 1, y: 0))
            i2.name = "ice"
            addChild(i2);
        } else {
            shootTimer -= dt;
        }
    }
    
}
