//
//  GameScene.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None      : UInt32 = 0x1 << 0
    static let Player    : UInt32 = 0x1 << 1
    static let RedProj   : UInt32 = 0x1 << 2
    static let BlueProj  : UInt32 = 0x1 << 3
    static let All       : UInt32 = UINT32_MAX
}

class GameScene: SKScene,UIGestureRecognizerDelegate, SKPhysicsContactDelegate  {
    var levelNum:Int
    var levelScore:Int = 0
    var totalScore:Int
    let sceneManager:GameViewController
    var playableRect = CGRect.zero
    var totalSprites = 0

    let otherLabel = SKLabelNode(fontNamed: "Futura")
    let pauseLabel = SKLabelNode(fontNamed: "Futura")
    let winLabel = SKLabelNode(fontNamed: "Futura")

    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = false

    var redPlayer:Player
    var bluePlayer:Player
    
    var playerBlueTouchCount = 0
    var playerBluePos:CGPoint = CGPoint(x: 100, y: 100)
    var playerRedTouchCount = 0
    var playerRedPos:CGPoint = CGPoint(x: 300, y: 100)


    let playerSpeed = CGFloat(10)
    let iceShootTimer = CGFloat(3)
    let iceProjectileSpeed = CGFloat(300)
    let fishProjectileSpeed = CGFloat(450)
    let fishTimer = CGFloat(6)
    let fishRapidFireCount = 3
    let fishOffsetDist:CGFloat = 50
    
    var gameLoopPaused:Bool = false {
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
        redPlayer = Player(isRed: true, maxLife: 3,
                           screenSize: size,
                           playerSpeed: playerSpeed,
                           iceShootTimer: iceShootTimer,
                           iceProjectileSpeed: iceProjectileSpeed,
                           fishProjectileSpeed: fishProjectileSpeed,
                           fishTimer: fishTimer);
        
        bluePlayer = Player(isRed: false, maxLife: 3,
                            screenSize: size,
                            playerSpeed: playerSpeed,
                            iceShootTimer: iceShootTimer,
                            iceProjectileSpeed: iceProjectileSpeed,
                            fishProjectileSpeed: fishProjectileSpeed,
                            fishTimer: fishTimer);
        
        super.init(size: size)
        self.scaleMode = scaleMode
        self.pauseLabel.text = "Paused"
        pauseLabel.position = CGPoint(x:size.width/2, y:size.height/2)
        pauseLabel.alpha = 0.0
        self.addChild(self.pauseLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // lifecycle
    override func didMove(to view: SKView) {
        redPlayer.setScale(0.24)
        redPlayer.position = CGPoint(x: size.width/2 + 425, y: size.height/2)
        addChild(redPlayer)
        for i in 0..<redPlayer.lives.count {
            redPlayer.lives[i].setScale(0.02)
            addChild(redPlayer.lives[i])
        }
        
        playerRedPos = redPlayer.position;
        
        bluePlayer.setScale(0.32)
        bluePlayer.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(bluePlayer)
        for i in 0..<bluePlayer.lives.count {
            bluePlayer.lives[i].setScale(0.02)
            addChild(bluePlayer.lives[i])
        }
        
        playerBluePos = bluePlayer.position;
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        setupUI()
        
        spritesMoving = false
        //physicsWorld.speed = 0.0
        setupGestures()
        drawLine()
    }
    
    deinit {
        // todo clean up resources timers listeners etc
    }
    
    private func setupGestures(){
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
            self.alpha = 0.09
            self.pauseLabel.alpha = 1.0

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
        self.pauseLabel.alpha = 0.0

        
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

    // MARK: Input and touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                if (playerBlueTouchCount == 0)
                {
                    playerBluePos = location
                    playerBlueTouchCount = 1;
                }
                else
                {
                    shootFish(player: bluePlayer, location: location)
                    playerBlueTouchCount += 1;
                }
            } else {
                if (playerRedTouchCount == 0)
                {
                    playerRedPos = location
                    playerRedTouchCount = 1;
                }
                else
                {
                    shootFish(player: redPlayer, location: location)
                    playerRedTouchCount += 1;
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                if (playerBlueTouchCount == 1) {
                    playerBluePos = location;
                }
            } else {
                if (playerRedTouchCount == 1) {
                    playerRedPos = location;
                }
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                if (playerBlueTouchCount > 0) {
                    playerBlueTouchCount -= 1;
                }
                
            } else {
                if (playerRedTouchCount > 0) {
                    playerRedTouchCount -= 1;
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                if (playerBlueTouchCount > 0) {
                    playerBlueTouchCount -= 1;
                }
                
            } else {
                if (playerRedTouchCount > 0) {
                    playerRedTouchCount -= 1;
                }
            }
        }
    }
    
    // MARK
    
    func drawLine(){
        var l:Line
        l = Line(size:CGSize(width:size.width, height:size.height), lineWidth:5, strokeColor: SKColor.black, fillColor: SKColor.gray)
        addChild(l)
        
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
        redPlayer.UpdatePlayer(dt: dt, posToMoveTo: playerRedPos)
        bluePlayer.UpdatePlayer(dt: dt, posToMoveTo: playerBluePos)
    }
    
    func shootIcicle(dt: CGFloat) {
        if (redPlayer.currShootTimer < 0)
        {
            redPlayer.currShootTimer = redPlayer.shootTimer
            let i = IceProjectile(position: redPlayer.position, projectileSpeed: redPlayer.iceProjectileSpeed, fwd: CGPoint(x: -1, y:0), isRed:true)
            i.name = "ice"
            addChild(i);
        } else {
            redPlayer.currShootTimer -= dt;
        }
        
        if (bluePlayer.currShootTimer < 0)
        {
            bluePlayer.currShootTimer = bluePlayer.shootTimer
            let i = IceProjectile(position: bluePlayer.position, projectileSpeed: bluePlayer.iceProjectileSpeed, fwd: CGPoint(x: 1, y:0), isRed:false)
            i.name = "ice"
            addChild(i);
        } else {
            bluePlayer.currShootTimer -= dt;
        }
    }
    
    func shootFish(player: Player, location: CGPoint)
    {
        var playerPos:CGPoint
        if (player.isRed) {
            playerPos = playerRedPos
        } else {
            playerPos = playerBluePos
        }
        
        if(player.hasFishPowerUp) {
            for n in 1...fishRapidFireCount {
                let offSet:CGPoint = (location - playerPos).normalized() * CGFloat(n) * fishOffsetDist 
                let firePosition:CGPoint = player.position + offSet;
                
                let f:FishProjectile = FishProjectile(position: firePosition, projectileSpeed: player.fishProjectileSpeed, fwd: (location - playerPos).normalized(), timer: player.fishTimer, isRed: player.isRed)
                f.name = "fish"
                addChild(f);
            }
        } else {
            let f:FishProjectile = FishProjectile(position: playerPos, projectileSpeed: player.fishProjectileSpeed, fwd: (location - playerPos).normalized(), timer: player.fishTimer, isRed: player.isRed)
            f.name = "fish"
            addChild(f);
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask == PhysicsCategory.RedProj &&
            secondBody.categoryBitMask == PhysicsCategory.BlueProj) {
            if let proj1 = firstBody.node as? Projectile,
                let proj2 = secondBody.node as? Projectile {
                if (proj1.isRed != proj2.isRed)
                {
                    print("Projectile collision")
                    proj1.removeFromParent()
                    proj2.removeFromParent()
                }
            }
        }
        else if (firstBody.categoryBitMask == PhysicsCategory.Player &&
            (secondBody.categoryBitMask == PhysicsCategory.RedProj ||
            secondBody.categoryBitMask == PhysicsCategory.BlueProj)) {
            if let player = firstBody.node as? Player,
                let proj = secondBody.node as? Projectile {
                if (player.isRed != proj.isRed)
                {
                    player.TakeDamage()
                    proj.removeFromParent()
                }
            }
        }
    }
}
