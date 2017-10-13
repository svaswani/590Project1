//
//  GameScene.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,UIGestureRecognizerDelegate, SKPhysicsContactDelegate  {
    
    //MARK: iVars
    let sceneManager:GameViewController

    let pauseLabel = SKLabelNode(fontNamed: "Futura")
    let winLabel = SKLabelNode(fontNamed: "Futura")

    //for udpates
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = false

    //player
    var redPlayer:Player
    var bluePlayer:Player
    let playerSpeed = CGFloat(10)
    
    //variables for inputs
    var playerBlueTouchCount = 0
    var playerBluePos:CGPoint = CGPoint(x: 100, y: 100)
    var playerRedTouchCount = 0
    var playerRedPos:CGPoint = CGPoint(x: 300, y: 100)

    //constants for ice attacks
    let iceShootTimer = CGFloat(3)
    let iceProjectileSpeed = CGFloat(200)
    let iceFanAngle = CGFloat(15)
    let iceFanCount = 3
    
    //constants for fish attacks
    let fishProjectileSpeed = CGFloat(300)
    let fishTimer = CGFloat(6)
    let fishRapidFireCount = 3
    let fishOffsetDist:CGFloat = 75
    
    //power ups
    let minTimeToSpawnPowerUp = CGFloat(15)
    let maxTimeToSpawnPowerUp = CGFloat(25)
    var timeToSpawnPowerUp:CGFloat
    
    //create a copy of each physics body
    let icePhysicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "iceLaser"), size: SKTexture(imageNamed: "iceLaser").size())
    let fishPhysicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "fish"), size: SKTexture(imageNamed: "fish").size())
    let powerUpPhysicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "icePowerUp"), size: SKTexture(imageNamed: "icePowerUp").size())
    
    //MARK: Property
    var gameLoopPaused:Bool = false {
        didSet {
            //print("gameLoopPaused=\(gameLoopPaused)")
            gameLoopPaused ? runPauseAction() : runUnpauseAction()
        }
    }
    
    // MARK: Init
    init(size: CGSize, scaleMode:SKSceneScaleMode, levelNum:Int, totalScore:Int, sceneManager:GameViewController) {
        
        //set up variables
        timeToSpawnPowerUp = CGFloat.random(min: minTimeToSpawnPowerUp, max: maxTimeToSpawnPowerUp)
        self.sceneManager = sceneManager
        redPlayer = Player(isRed: true, maxLife: 5,
                           screenSize: size,
                           playerSpeed: playerSpeed,
                           iceShootTimer: iceShootTimer,
                           iceProjectileSpeed: iceProjectileSpeed,
                           fishProjectileSpeed: fishProjectileSpeed,
                           fishTimer: fishTimer);
        
        bluePlayer = Player(isRed: false, maxLife: 5,
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
    
    deinit {
        // todo clean up resources timers listeners etc
    }
    
    //more initialization
    override func didMove(to view: SKView) {
        
        //set up red player
        redPlayer.setScale(0.50)
        redPlayer.position = CGPoint(x: size.width/2 + 425, y: size.height/2)
        addChild(redPlayer)
        for i in 0..<redPlayer.lives.count {
            redPlayer.lives[i].setScale(0.02)
            redPlayer.lives[i].position = CGPoint(x: size.width - 40 - CGFloat(i * 40), y: size.height - 40)
            addChild(redPlayer.lives[i])
        }
        redPlayer.setAmmoBar(ammoBar: AmmoBar(position: CGPoint(x: size.width - 40, y: 60),
                                              isRed: true,
                                              width: 40, height: 300))
        addChild(redPlayer.ammoBar!)
        playerRedPos = redPlayer.position; 
        
        //set up blue player
        bluePlayer.setScale(0.50)
        bluePlayer.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(bluePlayer)
        for i in 0..<bluePlayer.lives.count {
            bluePlayer.lives[i].setScale(0.02)
            bluePlayer.lives[i].position = CGPoint(x: 40 + CGFloat(i * 40), y: 40)
            addChild(bluePlayer.lives[i])
        }
        bluePlayer.setAmmoBar(ammoBar: AmmoBar(position: CGPoint(x: 40, y: size.height - 60),
                                              isRed: false,
                                              width: 40, height: 300))
        addChild(bluePlayer.ammoBar!)
        playerBluePos = bluePlayer.position;
        
        //set up physics
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.collisionBitMask = PhysicsCategory.BlueProj | PhysicsCategory.RedProj
        borderBody.categoryBitMask = PhysicsCategory.Border
        borderBody.friction = 0
        borderBody.restitution = 1
        borderBody.isDynamic = true
        borderBody.isResting = true
        borderBody.mass = CGFloat.greatestFiniteMagnitude
        self.physicsBody = borderBody
        
        //more set up
        setupUI()
        spritesMoving = false
        setupGestures()
        drawLine()
        
        let backgroundMusic = SKAudioNode(fileNamed: "background")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

        
    }
    
    // MARK: Helper functions for set up
    private func setupUI(){
        backgroundColor = GameData.hud.backgroundColor
    }

    private func setupGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePaused))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 3
        tap.delegate = self
        view!.addGestureRecognizer(tap)
    }
    
    func drawLine(){
        var l:Line
        l = Line(size:CGSize(width:size.width, height:size.height), lineWidth:5, strokeColor: SKColor.black, fillColor: SKColor.gray)
        addChild(l)
    }
    
    //MARK: Helper functions for pausing
    func togglePaused(){
        gameLoopPaused = !gameLoopPaused
    }
    
    private func runPauseAction() {
        //print(#function)
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
        //print(#function)
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
    
    //handle when touches begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                //blue side
                
                if (playerBlueTouchCount == 0)
                {
                    playerBluePos = location
                    playerBlueTouchCount = 1;
                }
                else if (playerBlueTouchCount == 1)
                {
                    if (bluePlayer.useUpFishAmmo(ammoCost: 10)) {
                        shootFish(player: bluePlayer, location: location)
                    }
                    playerBlueTouchCount += 1;
                }
            } else {
                //red side
                
                if (playerRedTouchCount == 0)
                {
                    playerRedPos = location
                    playerRedTouchCount = 1;
                }
                else if (playerRedTouchCount == 1)
                {
                    if (redPlayer.useUpFishAmmo(ammoCost: 10)) {
                        shootFish(player: redPlayer, location: location)
                    }
                    playerRedTouchCount += 1;
                }
            }
        }
    }
    
    //handle moving touches
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        let threshold = CGFloat(20)
        let thresholdSqr = threshold * threshold
        for touch in touches {
            let location = touch.location(in: self)
            if (location.x < size.width / 2.0) {
                //only update to that position if it's smaller than a certain threshold
                if (location - playerBluePos).magnitudeSqr() < thresholdSqr {
                    playerBluePos = location
                } else {
                    playerBluePos = playerBluePos + (location - playerBluePos).normalized() * threshold
                }
            } else {
                //only update to that position if it's smaller than a certain threshold
                if (location - playerRedPos).magnitudeSqr() < thresholdSqr {
                    playerRedPos = location
                } else {
                    playerRedPos = playerRedPos + (location - playerRedPos).normalized() * threshold
                }
            }
        }
    }
    
    //handle when touches end
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
    
    //handle when touches are cancelled
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
    
    // MARK: Helper function for input handling
    func shootFish(player: Player, location: CGPoint)
    {
        //player of pos
        var playerPos:CGPoint
        if (player.isRed) {
            playerPos = playerRedPos
        } else {
            playerPos = playerBluePos
        }
        
        //shoots rapidly if has powerup
        if(player.hasFishPowerUp) {
            for n in 0..<fishRapidFireCount {
                let offSet:CGPoint = (location - playerPos).normalized() * CGFloat(n) * fishOffsetDist
                let firePosition:CGPoint = player.position + offSet;
                
                let f:FishProjectile = FishProjectile(position: firePosition, projectileSpeed: player.fishProjectileSpeed, fwd: (location - playerPos).normalized(), timer: player.fishTimer, isRed: player.isRed, fishPhysicsBody: fishPhysicsBody)
                f.name = "fish"
                addChild(f);
                
                f.setScale(0.25)
            }
        } else {
            let f:FishProjectile = FishProjectile(position: playerPos, projectileSpeed: player.fishProjectileSpeed, fwd: (location - playerPos).normalized(), timer: player.fishTimer, isRed: player.isRed, fishPhysicsBody: fishPhysicsBody)
            f.name = "fish"
            addChild(f);
            
            f.setScale(0.25)
        }
        
        run(SKAction.playSoundFileNamed("pew", waitForCompletion: false))

    }
    
    // MARK: Update Loop
    override func update(_ currentTime: TimeInterval) {
        calculateDeltaTime(currentTime: currentTime)
        
        let deltaTime = CGFloat(dt)
        movePlayer(dt: deltaTime)
        updateFish(dt: deltaTime)
        shootIcicle(dt: deltaTime)
        updateIcicle(dt: deltaTime)
        updatePowerUpSpawn(dt: deltaTime)
    }
    
    // MARK: Functions in update loop
    func calculateDeltaTime(currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    //updates the player
    func movePlayer(dt:CGFloat) {
        redPlayer.UpdatePlayer(dt: dt, posToMoveTo: playerRedPos)
        bluePlayer.UpdatePlayer(dt: dt, posToMoveTo: playerBluePos)
    }
    
    //updates the fishy
    func updateFish(dt: CGFloat) {
        enumerateChildNodes(withName: "fish", using: {
            node, stop in
            let s = node as! FishProjectile
            s.update(dt: dt)
        })
    }
    
    //updates the icicles
    func updateIcicle(dt: CGFloat) {
        enumerateChildNodes(withName: "ice", using: {
            node, stop in
            let s = node as! IceProjectile
            s.update(dt: dt)
            let halfWidth = s.frame.width/2
            
            //detects if off-screen
            if s.position.x <= -halfWidth || s.position.x >= self.size.width + halfWidth {
                s.removeFromParent()
            }
        })
    }
    
    //updates shooting icicle
    func shootIcicle(dt: CGFloat) {
        shootIcicle(dt: dt, player: redPlayer)
        shootIcicle(dt: dt, player: bluePlayer)
    }
    
    //shoots the icicle
    func shootIcicle(dt: CGFloat, player: Player)
    {
        //check timer
        if (player.currShootTimer < 0)
        {
            player.currShootTimer = player.shootTimer
            
            //fans the icicles instead if there's power up
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
                //shoots normally
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
    
    //check if it's time to spawn power ups
    func updatePowerUpSpawn(dt: CGFloat) {
        
        if timeToSpawnPowerUp < 0 {
            //reset timer
            timeToSpawnPowerUp = CGFloat.random(min: minTimeToSpawnPowerUp, max: maxTimeToSpawnPowerUp)
            
            let position = CGPoint(x: size.width / 2, y: CGFloat.random(min: 80, max: size.height - 80))
            
            //power up
            let p = PowerUp(position: position,
                            physicsBody: powerUpPhysicsBody, type: getRandomPowerUpType())
            p.setScale(0.50)
            
            //shadow and its actions
            let shadow = Shadow(position: position)
            let grow = SKAction.scale(by: 18, duration: 5)
            let removeShadow = SKAction.removeFromParent()
            let shadowAction = SKAction.sequence([grow, removeShadow])
            
            //emitter actions
            let wait = SKAction.wait(forDuration: TimeInterval(1.5))
            let remove = SKAction.removeFromParent()
            let eAction = SKAction.sequence([wait, remove])
            
            //run the whole action as an animation of sorts
            self.run(SKAction.sequence([SKAction.run({
                self.addChild(shadow)
                shadow.run(shadowAction)}),
                                        SKAction.wait(forDuration: 5),
                                        SKAction.run({
                                            let e = SKEmitterNode(fileNamed: "Landing")
                                            e?.position = p.position
                                            e?.zPosition = p.zPosition - 1
                                            self.addChild(e!)
                                            self.addChild(p)
                                            e?.run(eAction)})]))
        } else {
            timeToSpawnPowerUp -= dt
        }
    }
    
    //MARK: Collision detection
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        //set ups the variables
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //opposing projectile collision handling
        if (firstBody.categoryBitMask == PhysicsCategory.RedProj &&
            secondBody.categoryBitMask == PhysicsCategory.BlueProj) {
            if let proj1 = firstBody.node as? Projectile,
                let proj2 = secondBody.node as? Projectile {
                if (proj1.isRed != proj2.isRed)
                {
                    //plays emitter and remove nodes
                    let emitter = SKEmitterNode(fileNamed: "ProjectileDeath")
                    emitter?.position = contact.contactPoint

                    addChild(emitter!)
                    
                    let wait = SKAction.wait(forDuration: TimeInterval((emitter?.particleLifetime)!))
                    let remove = SKAction.removeFromParent()
                    emitter?.run(SKAction.sequence([wait, remove]))
                    
                    proj1.removeFromParent()
                    proj2.removeFromParent()
                    
                }
            }
        }
            
        //handle projectile vs player
        else if (firstBody.categoryBitMask == PhysicsCategory.Player &&
            (secondBody.categoryBitMask == PhysicsCategory.RedProj ||
            secondBody.categoryBitMask == PhysicsCategory.BlueProj)) {
            if let player = firstBody.node as? Player,
                let proj = secondBody.node as? Projectile {
                if (player.isRed != proj.isRed)
                {
                    //player takes damage, remove proj and play emitter
                    if player.life == 1 {
                        player.TakeDamage()
                        print(bluePlayer.life)
                        if bluePlayer.life == 0 {
                            sceneManager.loadGameOverScene(player: "Red Player")
                        }
                        if redPlayer.life == 0 {
                            sceneManager.loadGameOverScene(player: "Blue Player")
                        }

                    }
                    else if player.life > 0 {
                        player.TakeDamage()
                        print(player.life)
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
        }
            
        //handles player vs power ups
        else if (firstBody.categoryBitMask == PhysicsCategory.Player &&
            secondBody.categoryBitMask == PhysicsCategory.PowerUp) {
            if let player = firstBody.node as? Player,
                let powerUp = secondBody.node as? PowerUp {

                //appropriately responds to different power ups
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
                
                //plays animation if it's not shield
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
                
                //powerup collection emitter
                let emitter = SKEmitterNode(fileNamed: "PowerUp")
                emitter?.position = contact.contactPoint

                let wait = SKAction.wait(forDuration: TimeInterval((emitter?.particleLifetime)!))
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
