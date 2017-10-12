//
//  Player.swift
//  ColdWar
//
//  Created by Student on 10/11/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import GameKit

class Player: SKSpriteNode{
    
    var life:Int
    var lives:[SKSpriteNode]
    var hasIcePowerUp = false
    let icePowerUpMaxTimer = CGFloat(4)
    var icePowerUpTimer:CGFloat = 0
    
    var hasFishPowerUp = false
    let fishPowerUpMaxTimer = CGFloat(4)
    var fishPowerUpTimer:CGFloat = 0
    
    var hasShield = false
    
    var baseIceProjectileSpeed:CGFloat
    var iceProjectileSpeed:CGFloat {
        get {
            if (hasIcePowerUp) {
                return (baseIceProjectileSpeed * 2.1)
            } else {
                return baseIceProjectileSpeed
            }
        }
    }
    
    var baseFishProjectileSpeed:CGFloat
    var fishProjectileSpeed:CGFloat {
        get {
            if (hasFishPowerUp) {
                return (baseFishProjectileSpeed * 1.5)
            } else {
                return baseFishProjectileSpeed
            }
        }
    }
    
    var baseFishTimer:CGFloat
    var fishTimer:CGFloat {
        get {
            if (hasFishPowerUp) {
                return (baseFishTimer * 1.25)
            } else {
                return baseFishTimer
            }
        }
    }
    
    var baseShootTimer:CGFloat
    var currShootTimer:CGFloat
    var shootTimer:CGFloat {
        get {
            if (hasIcePowerUp) {
                return baseShootTimer * 0.55
            } else {
                return baseShootTimer
            }
        }
    }
    
    var currLife: Int {
        get {return life}
    }
    
    var playerSpeed:CGFloat
    var isRed:Bool
    
    init(isRed: Bool, maxLife: Int, screenSize: CGSize, playerSpeed: CGFloat, iceShootTimer: CGFloat, iceProjectileSpeed: CGFloat, fishProjectileSpeed: CGFloat, fishTimer: CGFloat) {
        self.isRed = isRed
        life = maxLife
        self.playerSpeed = playerSpeed
        baseShootTimer = iceShootTimer
        currShootTimer = iceShootTimer
        baseIceProjectileSpeed = iceProjectileSpeed
        baseFishProjectileSpeed = fishProjectileSpeed
        baseFishTimer = fishTimer
        
        var texture:SKTexture
        if (isRed) {
            texture = SKTexture(imageNamed: "redPenguin")
        } else {
            texture = SKTexture(imageNamed: "bluePenguin")
        }
        
        let lifeTexture = SKTexture(imageNamed: "heart");
        lives = [];
        for i in 0..<maxLife
        {
            lives.append(SKSpriteNode(texture: lifeTexture));
            if (!isRed)
            {
                lives[i].position = CGPoint(x: screenSize.width/2 - 500 + CGFloat(i * 40), y: screenSize.height - 600)
            } else {
                lives[i].position = CGPoint(x: screenSize.width/2 + 420 + CGFloat(i * 40), y: screenSize.height - 600)
            }
        }

        super.init(texture: texture, color: UIColor.clear, size: (texture.size()))
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.All
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func TakeDamage() {
        if (hasShield)
        {
            hasShield = false
            return
        }
        
        life -= 1;
        
        //remove hearts
        switch (life)
        {
            case 2:
                lives[2].removeFromParent();
                break;
            case 1:
                lives[1].removeFromParent();
                break;
            case 0:
                lives[0].removeFromParent();
                break;
            default: break;
        }
    }
    
    func UpdatePlayer(dt:CGFloat, posToMoveTo:CGPoint) {
        position = position + (posToMoveTo - position) * playerSpeed * dt;
        
        if (hasFishPowerUp) {
            fishPowerUpTimer -= dt
            if (fishPowerUpTimer < 0) {
                hasFishPowerUp = false
            }
        }
        
        if (hasIcePowerUp) {
            icePowerUpTimer -= dt
            if (icePowerUpTimer < 0) {
                hasIcePowerUp = false
            }
        }
    }
}
