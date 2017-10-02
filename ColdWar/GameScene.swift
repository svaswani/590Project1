//
//  GameScene.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,UIGestureRecognizerDelegate {
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
    let blueLife1 = SKSpriteNode(imageNamed: "heart")
    let blueLife2 = SKSpriteNode(imageNamed: "heart")
    let blueLife3 = SKSpriteNode(imageNamed: "heart")
    let redLife1 = SKSpriteNode(imageNamed: "heart")
    let redLife2 = SKSpriteNode(imageNamed: "heart")
    let redLife3 = SKSpriteNode(imageNamed: "heart")


    
    var playerBlueTouchCount = 0
    var playerBluePos:CGPoint = CGPoint(x: 100, y: 100)
    
    var playerRedTouchCount = 0
    var playerRedPos:CGPoint = CGPoint(x: 300, y: 100)
    
    var blueLife1Pos:CGPoint = CGPoint(x:10, y:10)
    var blueLife2Pos:CGPoint = CGPoint(x:10, y:10)
    var blueLife3Pos:CGPoint = CGPoint(x:10, y:10)
    
    var redLife1Pos:CGPoint = CGPoint(x:10, y:10)
    var redLife2Pos:CGPoint = CGPoint(x:10, y:10)
    var redLife3Pos:CGPoint = CGPoint(x:10, y:10)

    
    var shootTimer:CGFloat = CGFloat(3)
    
    var gameLoopPaused:Bool = true {
        didSet {
            print("gameLoopPaused=\(gameLoopPaused)")
            gameLoopPaused ? runPauseAction() : runUnpauseAction()
        }
    }
    
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
        playerBluePos = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(playerBlue)
        
        playerRed.setScale(0.24)
        playerRedPos = CGPoint(x: size.width/2 + 425, y: size.height/2)
        addChild(playerRed)
        
        blueLife1.setScale(0.02)
        blueLife1Pos = CGPoint(x: size.width/2 - 500, y: size.height - 600)
        blueLife1.position = blueLife1Pos
        addChild(blueLife1)
        
        blueLife2.setScale(0.02)
        blueLife2Pos = CGPoint(x: size.width/2 - 460, y: size.height - 600)
        blueLife2.position = blueLife2Pos
        addChild(blueLife2)
        
        blueLife3.setScale(0.02)
        blueLife3Pos = CGPoint(x: size.width/2 - 420, y: size.height - 600)
        blueLife3.position = blueLife3Pos
        addChild(blueLife3)
        
        redLife1.setScale(0.02)
        redLife1Pos = CGPoint(x: size.width/2 + 420, y: size.height - 600)
        redLife1.position = redLife1Pos
        addChild(redLife1)
        
        redLife2.setScale(0.02)
        redLife2Pos = CGPoint(x: size.width/2 + 460, y: size.height - 600)
        redLife2.position = redLife2Pos
        addChild(redLife2)
        
        redLife3.setScale(0.02)
        redLife3Pos = CGPoint(x: size.width/2 + 500, y: size.height - 600)
        redLife3.position = redLife3Pos
        addChild(redLife3)
        
        spritesMoving = false
        physicsWorld.speed = 0.0
        setupGestures()
        drawLine()
        
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
                    print((location - playerBluePos).normalized())
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

                    print((location - playerRedPos).normalized())
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
    
    private func setupGestures(){
        // taps
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePaused))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 3
        tap.delegate = self
        view!.addGestureRecognizer(tap)
    }
    
    func togglePaused(){
        gameLoopPaused = !gameLoopPaused
    }
    
    private func runPauseAction() {
        print(#function)
        physicsWorld.speed = 0.0
        spritesMoving = false
        let fadeAction = SKAction.customAction(withDuration: 0.25, actionBlock: {
            node,elapsedTime in
            let totalAnimationTime:CGFloat = 0.25
            let percentDone = elapsedTime/totalAnimationTime
            let amountToFade:CGFloat = 0.5
            node.alpha = 1.0 - (percentDone * amountToFade)
            self.alpha = 0.08

        })
        
        let pauseAction = SKAction.run({
            self.view?.isPaused = true
        })
        
        let pauseViewAfterFadeAction = SKAction.sequence([
            fadeAction,
            pauseAction
            ])
        
        run(pauseViewAfterFadeAction)
    }
    
    private func runUnpauseAction() {
        print(#function)
        view?.isPaused = false
        lastUpdateTime = 0
        dt = 0
        spritesMoving = false
        
        let unPauseAction = SKAction.sequence([
            SKAction.fadeIn(withDuration: 1.0),
            SKAction.run({
                self.physicsWorld.speed = 1.0
                self.spritesMoving = true
            })
            ])
        unPauseAction.timingMode = .easeIn
        run(unPauseAction)
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
    
    func drawLine(){
        var l:Line
        l = Line(size:CGSize(width:size.width, height:size.height), lineWidth:5, strokeColor: SKColor.black, fillColor: SKColor.gray)
        addChild(l)
        
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
        playableRect = getPlayableRectPhonePortrait(size: size)
        /*
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
            s.setScale(0.5)
            let halfWidth = s.frame.width/2
            let halfHeight = s.frame.height/2

            if (s.timer < 0) {
                s.removeFromParent()
            }
            

            if s.position.x <= halfWidth || s.position.x >= self.size.width - halfWidth {
                s.reflectX()
                s.update(dt: dt)
            }
            
            //print("\(s.position.y) is between \(self.playableRect.minY + halfHeight) & \(self.playableRect.maxY - halfHeight)")
            //print("\(s.position.y) & \(self.playableRect.maxY - halfHeight)")
            if s.position.y <= self.playableRect.minY + halfHeight || s.position.y >= self.playableRect.maxY - halfHeight {
                s.reflectY()
                s.update(dt:dt)
            }
 
        })
    }
    
    func updateIcicle(dt: CGFloat) {
        enumerateChildNodes(withName: "ice", using: {
            node, stop in
            let s = node as! IceProjectile
            s.update(dt: dt)
            
            s.setScale(0.5)
            
            let halfWidth = s.frame.width/2

            
            if s.position.x <= -halfWidth || s.position.x >= self.size.width + halfWidth {
                s.removeFromParent()
            }
            
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
