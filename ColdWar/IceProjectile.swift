//
//  IceProjectile.swift
//  ColdWar
//
//  Created by Daniel Giaime on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class IceProjectile : Projectile {
    init(position:CGPoint, projectileSpeed:CGFloat, fwd:CGPoint, isRed:Bool, icePhysicsBody: SKPhysicsBody) {
        let texture = SKTexture(imageNamed: "iceLaser")
        super.init(position: position, projectileSpeed: projectileSpeed, fwd: fwd, isRed: isRed, texture: texture, physicsBody: icePhysicsBody)
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
