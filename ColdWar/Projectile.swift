//
//  Projectile.swift
//  ColdWar
//
//  Created by student on 10/5/17.
//  Copyright © 2017 Sneha Vaswani. All rights reserved.
//

import Foundation
import SpriteKit

class Projectile : SKSpriteNode {
    var projectileSpeed:CGFloat = 300.0
    var fwd:CGPoint = CGPoint(x:0.0, y:1.0) // north/up
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    
    init (spriteTexture: SKTexture) {
        super.init(texture: spriteTexture, color: UIColor.clear, size: spriteTexture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(dt:CGFloat, min:CGPoint, max:CGPoint) {
        velocity = fwd * projectileSpeed
        position = position + velocity * dt
        
        if(position.x > max.x || position.x < min.x) {
            
        }
        
        zRotation = -atan2(-fwd.y, fwd.x)
    }
    
    func resolveX() {
        
    }
    
    func resolveY() {
        
    }
}
