//
//  Projectile.swift
//  ColdWar
//
//  Created by Student on 10/11/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class Projectile : SKSpriteNode {
    var projectileSpeed:CGFloat = 300.0
    var fwd:CGPoint = CGPoint(x:0.0, y:1.0) // north/up
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    var isRed:Bool = false
    
    init(position:CGPoint, projectileSpeed:CGFloat, fwd:CGPoint, isRed:Bool, texture: SKTexture) {
        super.init(texture: texture, color: UIColor.clear, size: (texture.size()))
        
        self.position = position;
        self.projectileSpeed = projectileSpeed
        self.fwd = fwd
        self.isRed = isRed
        
      
        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.isDynamic = true
        if (isRed) {
            self.physicsBody?.categoryBitMask = PhysicsCategory.RedProj
            self.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.BlueProj
            self.physicsBody?.collisionBitMask = PhysicsCategory.None
        } else {
            self.physicsBody?.categoryBitMask = PhysicsCategory.BlueProj
            self.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.RedProj
            self.physicsBody?.collisionBitMask = PhysicsCategory.None
        }
        
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // methods
    func update(dt:CGFloat) {
        velocity = fwd * projectileSpeed
        position = position + velocity * dt
        
        zRotation = -atan2(fwd.y, fwd.x)
    }
}

