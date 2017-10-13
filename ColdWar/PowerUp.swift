//
//  PowerUp.swift
//  ColdWar
//
//  Created by Student on 10/12/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit



class PowerUp : SKSpriteNode {
    var type:PowerUpType
    let maxSpeed = CGFloat(50)
    var maxSpeedSqr:CGFloat
    
    init(position:CGPoint, physicsBody: SKPhysicsBody, type: PowerUpType) {
        self.type = type
        maxSpeedSqr = maxSpeed * maxSpeed;
        var texture:SKTexture? = nil
        switch (type)
        {
        case PowerUpType.Ice:
            texture = SKTexture(imageNamed: "icePowerUp")
            break;
        case PowerUpType.Fish:
            texture = SKTexture(imageNamed: "fishPowerUp")
            break;
        case PowerUpType.Shield:
            texture = SKTexture(imageNamed: "sheildPowerUp")
            break;
        }
        
        super.init(texture: texture!, color: UIColor.clear, size: (texture?.size())!)
        
        self.position = position;
       
        self.physicsBody = SKPhysicsBody(bodies: [physicsBody])
        self.physicsBody?.isDynamic = true

        self.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.RedProj | PhysicsCategory.BlueProj | PhysicsCategory.Border
    
        self.physicsBody?.usesPreciseCollisionDetection = false
        
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 1
        self.physicsBody?.mass = 0.05
        
        
        self.physicsBody?.angularVelocity = CGFloat.random(min: 0, max: 10)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func update() {
//        var vel = self.physicsBody?.velocity
//        let velSqr:CGFloat = vel!.magnitudeSqr()
//        
//        if (velSqr > maxSpeedSqr)
//        {
//            vel = (vel?.normalize())! * maxSpeed
//        }
//        
//        //self.physicsBody?.velocity = vel!
//    }
}
