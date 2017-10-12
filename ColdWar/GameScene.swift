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
    static let PowerUp   : UInt32 = 0x1 << 4
    static let Border    : UInt32 = 0x1 << 5
    static let All       : UInt32 = UINT32_MAX
}

class GameScene: SKScene,UIGestureRecognizerDelegate, SKPhysicsContactDelegate  {
    var levelNum:Int
    var levelScore:Int = 0
    var totalScore:Int
    let sceneManager:GameViewController
    //var playableRect = CGRect.zero
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
    let iceProjectileSpeed = CGFloat(200)
    let iceFanAngle = CGFloat(15)
    let iceFanCount = 3
    
    let fishProjectileSpeed = CGFloat(300)
    let fishTimer = CGFloat(6)
    let fishRapidFireCount = 3
    let fishOffsetDist:CGFloat = 75
    
    let minTimeToSpawnPowerUp = CGFloat(1)
    let maxTimeToSpawnPowerUp = CGFloat(2)
    
    var timeToSpawnPowerUp:CGFloat
    
    let icePhysicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "iceLaser"), size: SKTexture(imageNamed: "iceLaser").size())
    let fishPhysicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "fish"), size: SKTexture(imageNamed: "fish").size())
    let powerUpPhysicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "icePowerUp"), size: SKTexture(imageNamed: "icePowerUp").size())
    
    let projEmitter:SKEmitterNode? = SKEmitterNode(fileNamed: "ParticleDeath")
    
    var gameLoopPaused:Bool = false {
        didSet {
            print("gameLoopPaused=\(gameLoopPaused)")
            gameLoopPaused ? runPauseAction() : runUnpauseAction()
        }
    }
    
    // init
    init(size: CGSize, scaleMode:SKSceneScaleMode, levelNum:Int, totalScore:Int, sceneManager:GameViewController) {
        timeToSpawnPowerUp = CGFloat.random(min: minTimeToSpawnPowerUp, max: maxTimeToSpawnPowerUp)
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
            redPlayer.lives[i].position = CGPoint(x: size.width - 120 + CGFloat(i * 40), y: size.height - 40)
            addChild(redPlayer.lives[i])
        }
        
        playerRedPos = redPlayer.position;
        
        bluePlayer.setScale(0.32)
        bluePlayer.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(bluePlayer)
        for i in 0..<bluePlayer.lives.count {
            bluePlayer.lives[i].setScale(0.02)
            bluePlayer.lives[i].position = CGPoint(x: 40 + CGFloat(i * 40), y: 40)
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
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.collisionBitMask = PhysicsCategory.BlueProj | PhysicsCategory.RedProj
        borderBody.categoryBitMask = PhysicsCategory.Border
        borderBody.friction = 0
        borderBody.restitution = 1
        borderBody.isDynamic = true
        borderBody.isResting = true
        borderBody.mass = CGFloat.greatestFiniteMagnitude
        self.physicsBody = borderBody
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
                else if (playerBlueTouchCount == 1)
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
                else if (playerRedTouchCount == 1)
                {
                    shootFish(player: redPlayer, location: location)
                    playerRedTouchCount += 1;
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        let threshold = CGFloat(20)
        let thresholdSqr = threshold * threshold
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                if (location - playerBluePos).magnitudeSqr() < thresholdSqr {
                    playerBluePos = location
                } else {
                    playerBluePos = playerBluePos + (location - playerBluePos).normalized() * threshold
                }
            } else {
                if (location - playerRedPos).magnitudeSqr() < thresholdSqr {
                    playerRedPos = location
                } else {
                    playerRedPos = playerRedPos + (location - playerRedPos).normalized() * threshold
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                if (playerBlueTouchCount > 2) {
                    playerBlueTouchCount = 2
                }
                if (playerBlueTouchCount > 0) {
                    playerBlueTouchCount -= 1;
                }
                
            } else {
                if (playerRedTouchCount > 2) {
                    playerRedTouchCount = 2
                }
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
                if (playerBlueTouchCount > 2) {
                    playerBlueTouchCount = 2
                }
                if (playerBlueTouchCount > 0) {
                    playerBlueTouchCount -= 1;
                }
                
            } else {
                if (playerRedTouchCount > 2) {
                    playerRedTouchCount = 2
                }
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
        //playableRect = getPlayableRectPhonePortrait(size: size)
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
        let deltaTime = CGFloat(dt)
        updateFish(dt: deltaTime)
        movePlayer(dt: deltaTime)
        shootIcicle(dt: deltaTime)
        updateIcicle(dt: deltaTime)
        updatePowerUpSpawn(dt: deltaTime)
        updatePowerUp()
    }
    
    func updatePowerUpSpawn(dt: CGFloat)
    {
        if timeToSpawnPowerUp < 0 {
            timeToSpawnPowerUp = CGFloat.random(min: minTimeToSpawnPowerUp, max: maxTimeToSpawnPowerUp)
            let p = PowerUp(position: CGPoint(x: size.width / 2, y: CGFloat.random(min: 30, max: 80)),
                            physicsBody: powerUpPhysicsBody, type: getRandomPowerUpType())
            p.name = "powerUp"
            addChild(p)
        } else {
            timeToSpawnPowerUp -= dt
        }
    }
    
    func updatePowerUp() {
//        enumerateChildNodes(withName: "powerUp", using: {
//            node, stop in
//            let s = node as! PowerUp
//            s.update()
//        })
    }
    
    func updateFish(dt: CGFloat) {
        enumerateChildNodes(withName: "fish", using: {
            node, stop in
            let s = node as! FishProjectile
            s.update(dt: dt)
        })
    }
    
    func updateIcicle(dt: CGFloat) {
        enumerateChildNodes(withName: "ice", using: {
            node, stop in
            let s = node as! IceProjectile
            s.update(dt: dt)
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
        shootIcicle(dt: dt, player: redPlayer)
        shootIcicle(dt: dt, player: bluePlayer)
    }
    
    func shootIcicle(dt: CGFloat, player: Player)
    {
        if (player.currShootTimer < 0)
        {
            player.currShootTimer = player.shootTimer
            if (player.hasIcePowerUp)
            {
                let startAngle = -iceFanAngle / 2 * 3.14159 / 180.0
                for n in 0..<iceFanCount {
                    let angle = startAngle + (iceFanAngle / CGFloat(iceFanCount - 1)) * CGFloat(n) * 3.14159 / 180.0
                    var dir = CGPoint(x: cos(angle), y: sin(angle))
                    if (player.isRed) {
                        dir.x = -dir.x
                    }
                    
                    let i = IceProjectile(position: player.position,
                                          projectileSpeed: player.iceProjectileSpeed,
                                          fwd: dir, isRed:player.isRed,
                                          icePhysicsBody: icePhysicsBody)
                    i.name = "ice"
                    addChild(i);
                    
                    i.setScale(0.5)
                }
            } else {
                var dir = CGPoint(x: 1, y: 0)
                if (player.isRed) {
                    dir.x = -dir.x
                }
                
                let i = IceProjectile(position: player.position,
                                      projectileSpeed: player.iceProjectileSpeed,
                                      fwd: dir, isRed:player.isRed,
                                      icePhysicsBody: icePhysicsBody)
                i.name = "ice"
                addChild(i);
                
                i.setScale(0.5)
            }
        } else {
            player.currShootTimer -= dt
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
            for n in 0..<fishRapidFireCount {
                let offSet:CGPoint = (location - playerPos).normalized() * CGFloat(n) * fishOffsetDist 
                let firePosition:CGPoint = player.position + offSet;
                
                let f:FishProjectile = FishProjectile(position: firePosition, projectileSpeed: player.fishProjectileSpeed, fwd: (location - playerPos).normalized(), timer: player.fishTimer, isRed: player.isRed, fishPhysicsBody: fishPhysicsBody)
                f.name = "fish"
                addChild(f);
                
                f.setScale(0.5)
            }
        } else {
            let f:FishProjectile = FishProjectile(position: playerPos, projectileSpeed: player.fishProjectileSpeed, fwd: (location - playerPos).normalized(), timer: player.fishTimer, isRed: player.isRed, fishPhysicsBody: fishPhysicsBody)
            f.name = "fish"
            addChild(f);
            
            f.setScale(0.5)
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
                    let emitter = SKEmitterNode(fileNamed: "ProjectileDeath")
                    emitter?.position = contact.contactPoint

                    addChild(emitter!)
                    
                    let wait = SKAction.wait(forDuration: TimeInterval(0.25))
                    let remove = SKAction.removeFromParent()
                    emitter?.run(SKAction.sequence([wait, remove]))
                    
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
                    
                    let emitter = SKEmitterNode(fileNamed: "Hurt")
                    emitter?.position = contact.contactPoint
                    
                    addChild(emitter!)
                    
                    let wait = SKAction.wait(forDuration: TimeInterval(1))
                    let remove = SKAction.removeFromParent()
                    emitter?.run(SKAction.sequence([wait, remove]))
                }
            }
        }
        else if (firstBody.categoryBitMask == PhysicsCategory.Player &&
            secondBody.categoryBitMask == PhysicsCategory.PowerUp) {
            if let player = firstBody.node as? Player,
                let powerUp = secondBody.node as? PowerUp {

                var timer:TimeInterval = 0.0
                switch(powerUp.type)
                {
                case PowerUpType.Fish:
                    player.hasFishPowerUp = true
                    player.fishPowerUpTimer = player.fishPowerUpMaxTimer
                    timer = TimeInterval(player.fishPowerUpTimer)
                    break;
                case PowerUpType.Ice:
                    player.hasIcePowerUp = true
                    player.icePowerUpTimer = player.icePowerUpMaxTimer
                    timer = TimeInterval(player.icePowerUpTimer)
                    break;
                case PowerUpType.Shield:
                    player.hasShield = true
                    break;
                }
                
                if (powerUp.type != PowerUpType.Shield) {
                    let playerEmitter = SKEmitterNode(fileNamed: "PowerUpEffect")
                    playerEmitter?.position = player.position
                    playerEmitter?.zPosition = player.zPosition - 1
                    let playerWait = SKAction.wait(forDuration: timer)
                    let playerRemove = SKAction.removeFromParent()
                    playerEmitter?.run(SKAction.sequence([playerWait, playerRemove]))
                    
                    player.SetPlayerEmitter(emitter: playerEmitter)
                    addChild(playerEmitter!)
                }
                
                let emitter = SKEmitterNode(fileNamed: "PowerUp")
                emitter?.position = contact.contactPoint

                let wait = SKAction.wait(forDuration: TimeInterval(0.25))
                let remove = SKAction.removeFromParent()
                emitter?.run(SKAction.sequence([wait, remove]))
                
                if emitter != nil
                {
                    addChild(emitter!)
                }
                
                powerUp.removeFromParent()
            }
        }
    }
}
