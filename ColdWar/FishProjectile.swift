//
//  FishProjectile.swift
//  ColdWar
//
//  Created by Sneha Vaswani on 9/25/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class FishProjectile:Projectile {
    var timer:CGFloat
    
    init(position:CGPoint, projectileSpeed:CGFloat, fwd:CGPoint, timer:CGFloat, isRed: Bool, fishPhysicsBody: SKPhysicsBody) {
        let texture = SKTexture(imageNamed: "fish")
        self.timer = timer;

        super.init(position: position, projectileSpeed: projectileSpeed, fwd: fwd, isRed: isRed, texture: texture, physicsBody: fishPhysicsBody)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // methods
    
    override func update(dt: CGFloat) {
        timer -= dt
        super.update(dt: dt);
        
        zRotation = atan2(fwd.y, fwd.x)
    }
    
    func reflectX() {
        fwd.x *= CGFloat(-1.0)
    }
    
    func reflectY() {
        fwd.y *= CGFloat(-1.0)
    }
}
